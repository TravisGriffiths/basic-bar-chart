class BarChart

  old_data: false

  makeChart: (data) ->
    @parse(data)
    @draw()

  parse: (d) ->
    values = []
    for k, v of d #cast any undef/null to "0"
      v = 0 unless v
    values[0] = {current: d['3LoDist'], old: false, label: "3rd Low Income Town"}
    values[1] = {current:d['3LoSt'], old: false, label: "3rd Low Income State"}
    values[2] = {current:d['3PeerDist'], old: false, label: "3rd Peer Town"}
    values[3] = {current:d['3PeerSt'], old: false, label: "3rd Peer State"}
    values[4] = {current:d['10LoDist'], old: false, label: "10th Low Income Town"}
    values[5] = {current:d['10LoSt'], old: false, label: "10th Low Income State"}
    values[6] = {current:d['10PeerDist'], old: false, label: "10th Peer Town"}
    values[7] = {current:d['10PeerSt'], old: false, label: "10th Peer State"}
    if @old_data
      values[0].old = @old_data['3LoDist']
      values[1].old = @old_data['3LoSt']
      values[2].old = @old_data['3PeerDist']
      values[3].old = @old_data['3PeerSt']
      values[4].old = @old_data['10LoDist']
      values[5].old = @old_data['10LoSt']
      values[6].old = @old_data['10PeerDist']
      values[7].old = @old_data['10PeerSt']
    d.values = values
    @data = d

  rendered: (@old_data) ->

  draw: ->
    ###
    Check if this browser can render SVGs, all post IE8 browsers should manage this
    If IE8 or before, do the simple table render instead.
    ###
    if jQuery.browser == "msie" and jQuery.browser.version.split(".")[0] < 9
      return @makeSimpleTable()

    if @old_data  #redrawing remove the old chart
      $("svg.bar_chart").remove()
    temp_values = []
    temp_values.push(value.current) for value in @data.values
    chart_width = 800
    chart_height = 500
    bar_width = 50
    bar_space = 60
    chart_top_margin = 50
    chart_bottom_margin = 35
    top_label = 100 #Math.ceil(d3.max(temp_values) / 5) * 5 #first multiple of 5 above our max data point
    chart_left_margin = 50
    chart_right_margin = 60
    chart_working_height = chart_height - chart_top_margin - chart_bottom_margin
    value_multiple = chart_working_height / top_label #d3.max(temp_values)

    #First insert the SVG itself
    svg = d3.select("#bar-chart-target")
      .append("svg")
      .classed("bar_chart", true)
      .attr("width", chart_width)
      .attr("height", chart_height)

    #Make the legend lines
    ticks = []
    current_tick = 0
    while current_tick <= top_label
      ticks.push(current_tick)
      current_tick += 5

    svg.selectAll('line.tick').data(ticks).enter()
      .append("line")
      .attr("class", "tick")
      .attr("x1", (0 + chart_left_margin))
      .attr("x2", (chart_width - chart_right_margin))
      .attr("y1", (d) ->
        chart_height - chart_bottom_margin - (d * value_multiple)
      )
      .attr("y2", (d) ->
        chart_height - chart_bottom_margin - (d * value_multiple)
      );

    svg.selectAll('text.mark').data(ticks).enter()
      .append("text")
      .attr("x", chart_left_margin - 15)
      .attr("y", (d) ->
        chart_height - chart_bottom_margin - (d * value_multiple)
      )
      .attr("text-anchor", "center")
      .text((d) -> d)

    #drop in the y label
    svg.append("svg:text")
      .attr("x", 10)
      .attr("y", chart_height - chart_bottom_margin)
      .attr("transform", "rotate(-90),translate(-350,-440)")#bit of a pain in the ass, rotates around 0,0 in top left corner
      .attr("text-anchor", "center")
      .attr("font-family", "sans-serif")
      .attr("font-size", "20px").text("Percent At or Above Goal")

    #drop in the x labels
    svg.append("svg:text")
      .attr("x", chart_left_margin + 15)
      .attr("y", chart_height - 20)
      .attr("text-anchor", "center")
      .attr("font-family", "sans-serif")
      .attr("font-size", "20px").text("Low Income")

    svg.append("svg:text")
      .attr("x", chart_left_margin + 15 + (2 * bar_width) + bar_space + 20)
      .attr("y", chart_height - 20)
      .attr("text-anchor", "center")
      .attr("font-family", "sans-serif")
      .attr("font-size", "20px").text("Peers")

    svg.append("svg:text")
      .attr("x",chart_left_margin + 15 + (4 * bar_width) + (2 * bar_space))
      .attr("y", chart_height - 20)
      .attr("text-anchor", "center")
      .attr("font-family", "sans-serif")
      .attr("font-size", "20px").text("Low Income")

    svg.append("svg:text")
      .attr("x", chart_left_margin + 15 + (6 * bar_width) + (3 * bar_space) + 20)
      .attr("y", chart_height - 20)
      .attr("text-anchor", "center")
      .attr("font-family", "sans-serif")
      .attr("font-size", "18px").text("Peers")

    #Grade x-labels
    svg.append("svg:text")
      .attr("x",(chart_width / 4) - 40)
      .attr("y", chart_height - 1)
      .attr("text-anchor", "center")
      .attr("font-family", "sans-serif")
      .attr("font-size", "20px").text("3rd Grade")

    svg.append("svg:text")
      .attr("x", (chart_width / 2) + 50)
      .attr("y", chart_height - 1)
      .attr("text-anchor", "center")
      .attr("font-family", "sans-serif")
      .attr("font-size", "20px").text("10th Grade")

    #Seperator Line
    svg.append("svg:line")
      .attr("class", "grade_sep")
      .attr("x1", chart_left_margin + (4 * bar_width) + (2 * bar_space) - 15)
      .attr("x2", chart_left_margin + (4 * bar_width) + (2 * bar_space) - 15)
      .attr("y1", chart_top_margin)
      .attr("y2", chart_height - (chart_bottom_margin / 2));

    #Bar Labels
    svg.append("svg:rec")
      .attr("class", "town_datum")
      .attr("x", chart_width - chart_right_margin)
      .attr("y", chart_height / 2)
      .attr("height", 10)
      .attr("width")

    #Draw the bars themselves
    svg.selectAll("rect.ach")
      .data(@data.values)
      .enter()
      .append("rect")
      .attr("id", (d, i) -> "bar_rect_#{i}")
      .classed("town_datum", (d, i) ->
        return not Boolean(i % 2)
      )
      .classed("state_datum", (d, i) ->
        return Boolean(i % 2)
      )
      .attr("x", (d, i) ->
        return ((i * bar_width) + (Math.floor(i / 2) * bar_space ) + 15 + chart_left_margin)
      )
      .attr("y", (d) ->
        if d.old
          return (chart_height - chart_bottom_margin - Math.round(d.old * value_multiple))
        else
          return (chart_height - chart_bottom_margin - Math.round(d.current * value_multiple))
      )
      .attr("width", bar_width)
      .attr("height", (d, i) ->
        if d.old
          return Math.round(d.old * value_multiple)
        else
          return Math.round(d.current * value_multiple)
      )
      .transition() #Set the transition
      .duration(1000) #Transition happens over 1 second time period
      .attr("y", (d) ->
        return (chart_height - chart_bottom_margin - Math.round(d.current * value_multiple))
      )
      .attr("height", (d, i) ->
        return Math.round(d.current * value_multiple)
      )


    # Put on the Title
    svg.append("svg:text")
      .attr("x", chart_left_margin + 100)
      .attr("y", 27)
      .attr("text-anchor", "center")
      .attr("font-family", "sans-serif")
      .attr("font-size", "25px").text("#{@data.Dist} Achievement Gap")

    # Put on Color Legend
    svg.append("svg:text")
      .attr("x", chart_width - chart_right_margin + 5)
      .attr("y", chart_height / 2 + 40)
      .attr("text-anchor", "start")
      .attr("font-family", "sans-serif")
      .attr("font-size", "18px")
      .text("State")

    svg.append("svg:rect")
      .attr("x", chart_width - chart_right_margin + 50)
      .attr("y", chart_height / 2 + 28)
      .classed("state_datum", true)
      .attr("width", 10)
      .attr("height", 10)

    svg.append("svg:text")
      .attr("x", chart_width - chart_right_margin + 5)
      .attr("y", chart_height / 2 + 10)
      .attr("text-anchor", "start")
      .attr("font-family", "sans-serif")
      .attr("font-size", "18px")
      .text("Town")

    svg.append("svg:rect")
      .attr("x", chart_width - chart_right_margin + 50)
      .attr("y", chart_height / 2)
      .classed("town_datum", true)
      .attr("width", 10)
      .attr("height", 10)

    @rendered(@data)

  makeSimpleTable: ->
    jQuery("table.bar_chart").remove()
    jQuery("div#browser_update_notice").remove()

    table = d3.select("#bar-chart-target")
      .append("table")
      .classed("bar_chart", true)

    table.append("tr")
      .html("<th class='table_title'>#{@data.Dist} Achievement Gap</th><th class='table_title'>%</th>")

    #Draw the table entries themselves
    table.selectAll("tr.ach")
      .data(@data.values)
      .enter()
      .append("tr")
      .attr("id", (d, i) -> "bar_rect_#{i}")
      .classed("town_datum", (d, i) ->
        return not Boolean(i % 2)
      )
      .classed("state_datum", (d, i) ->
        return Boolean(i % 2)
      )
      .html((d) ->  #Draw the table row
        "<td>#{d.label}</td><td>#{d.current}</td>"
      )
    d3.select("#bar-chart-target")
      .append('div')
      .attr('id', 'browser_update_notice')
      .html("""This data is shown here in simple table form. There is a full graphical presentation of this data, but it
            requires a modern browser conforming to the W3C standard for Scalar Vector Graphics objects. If you wish to
            view this data graphically, you may update your current browser to at least
            <a href='http://windows.microsoft.com/en-US/internet-explorer/downloads/ie-9/worldwide-languages'>
            Internet Explorer 9</a>. This requires MS Windows 7 or later. You may also download and use a
            different compliant browser, such as
            <a href='https://www.google.com/intl/en/chrome/browser/'>Google Chrome</a>, which should work on most
            operating systems and versions. Last, you may try installing and using a plug-in that renders Scalar Vector
            Graphics to older Flash formats, such as
            <a href='http://code.google.com/p/svgweb/'>this one</a> produced by Google. More information about the W3C
            and international internet standards may be found here:
            <a href='http://http://www.w3.org/TR/SVG/'>http://http://www.w3.org/TR/SVG/</a>  and here:
            <a href ='http://en.wikipedia.org/wiki/World_Wide_Web_Consortium'>
            http://en.wikipedia.org/wiki/World_Wide_Web_Consortium</a>
            """)

window.barchart = BarChart
window.chart_data = JSON.parse("""[{"ID":"1","Dist":"Andover","3LoDist":"0","3LoSt":"35","3PeerDist":"86","3PeerSt":"73","10LoDist":"18","10LoSt":"20","10PeerDist":"40","10PeerSt":"59"},{"ID":"2","Dist":"Ansonia","3LoDist":"36","3LoSt":"35","3PeerDist":"51","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"73","10PeerSt":"59"},{"ID":"3","Dist":"Ashford","3LoDist":"0","3LoSt":"35","3PeerDist":"71","3PeerSt":"73","10LoDist":"32","10LoSt":"20","10PeerDist":"72","10PeerSt":"59"},{"ID":"4","Dist":"Avon","3LoDist":"0","3LoSt":"35","3PeerDist":"87","3PeerSt":"73","10LoDist":"44","10LoSt":"20","10PeerDist":"67","10PeerSt":"59"},{"ID":"5","Dist":"Barkhamsted","3LoDist":"0","3LoSt":"35","3PeerDist":"68","3PeerSt":"73","10LoDist":"21","10LoSt":"20","10PeerDist":"31","10PeerSt":"59"},{"ID":"7","Dist":"Berlin","3LoDist":"48","3LoSt":"35","3PeerDist":"61","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"78","10PeerSt":"59"},{"ID":"8","Dist":"Bethany","3LoDist":"0","3LoSt":"35","3PeerDist":"75","3PeerSt":"73","10LoDist":"36","10LoSt":"20","10PeerDist":"59","10PeerSt":"59"},{"ID":"9","Dist":"Bethel","3LoDist":"55","3LoSt":"35","3PeerDist":"74","3PeerSt":"73","10LoDist":"8","10LoSt":"20","10PeerDist":"0","10PeerSt":"59"},{"ID":"11","Dist":"Bloomfield","3LoDist":"58","3LoSt":"35","3PeerDist":"45","3PeerSt":"73","10LoDist":"23","10LoSt":"20","10PeerDist":"53","10PeerSt":"59"},{"ID":"12","Dist":"Bolton","3LoDist":"0","3LoSt":"35","3PeerDist":"70","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"70","10PeerSt":"59"},{"ID":"14","Dist":"Branford","3LoDist":"48","3LoSt":"35","3PeerDist":"76","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"71","10PeerSt":"59"},{"ID":"15","Dist":"Bridgeport","3LoDist":"23","3LoSt":"35","3PeerDist":"0","3PeerSt":"73","10LoDist":"28","10LoSt":"20","10PeerDist":"68","10PeerSt":"59"},{"ID":"17","Dist":"Bristol","3LoDist":"37","3LoSt":"35","3PeerDist":"61","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"56","10PeerSt":"59"},{"ID":"18","Dist":"Brookfield","3LoDist":"0","3LoSt":"35","3PeerDist":"75","3PeerSt":"73","10LoDist":"14","10LoSt":"20","10PeerDist":"60","10PeerSt":"59"},{"ID":"19","Dist":"Brooklyn","3LoDist":"0","3LoSt":"35","3PeerDist":"59","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"65","10PeerSt":"59"},{"ID":"22","Dist":"Canterbury","3LoDist":"0","3LoSt":"35","3PeerDist":"65","3PeerSt":"73","10LoDist":"30","10LoSt":"20","10PeerDist":"56","10PeerSt":"59"},{"ID":"23","Dist":"Canton","3LoDist":"0","3LoSt":"35","3PeerDist":"83","3PeerSt":"73","10LoDist":"15","10LoSt":"20","10PeerDist":"40","10PeerSt":"59"},{"ID":"24","Dist":"Chaplin","3LoDist":"0","3LoSt":"35","3PeerDist":"0","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"75","10PeerSt":"59"},{"ID":"25","Dist":"Cheshire","3LoDist":"36","3LoSt":"35","3PeerDist":"76","3PeerSt":"73","10LoDist":"23","10LoSt":"20","10PeerDist":"40","10PeerSt":"59"},{"ID":"26","Dist":"Chester","3LoDist":"0","3LoSt":"35","3PeerDist":"75","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"67","10PeerSt":"59"},{"ID":"27","Dist":"Clinton","3LoDist":"64","3LoSt":"35","3PeerDist":"77","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"53","10PeerSt":"59"},{"ID":"28","Dist":"Colchester","3LoDist":"50","3LoSt":"35","3PeerDist":"73","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"72","10PeerSt":"59"},{"ID":"30","Dist":"Columbia","3LoDist":"0","3LoSt":"35","3PeerDist":"58","3PeerSt":"73","10LoDist":"12","10LoSt":"20","10PeerDist":"39","10PeerSt":"59"},{"ID":"32","Dist":"Coventry","3LoDist":"68","3LoSt":"35","3PeerDist":"77","3PeerSt":"73","10LoDist":"22","10LoSt":"20","10PeerDist":"32","10PeerSt":"59"},{"ID":"33","Dist":"Cromwell","3LoDist":"65","3LoSt":"35","3PeerDist":"81","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"70","10PeerSt":"59"},{"ID":"34","Dist":"Danbury","3LoDist":"30","3LoSt":"35","3PeerDist":"65","3PeerSt":"73","10LoDist":"25","10LoSt":"20","10PeerDist":"44","10PeerSt":"59"},{"ID":"35","Dist":"Darien","3LoDist":"0","3LoSt":"35","3PeerDist":"81","3PeerSt":"73","10LoDist":"24","10LoSt":"20","10PeerDist":"61","10PeerSt":"59"},{"ID":"36","Dist":"Deep River","3LoDist":"0","3LoSt":"35","3PeerDist":"79","3PeerSt":"73","10LoDist":"24","10LoSt":"20","10PeerDist":"46","10PeerSt":"59"},{"ID":"37","Dist":"Derby","3LoDist":"33","3LoSt":"35","3PeerDist":"61","3PeerSt":"73","10LoDist":"45","10LoSt":"20","10PeerDist":"75","10PeerSt":"59"},{"ID":"40","Dist":"East Granby","3LoDist":"0","3LoSt":"35","3PeerDist":"64","3PeerSt":"73","10LoDist":"32","10LoSt":"20","10PeerDist":"73","10PeerSt":"59"},{"ID":"41","Dist":"East Haddam","3LoDist":"0","3LoSt":"35","3PeerDist":"89","3PeerSt":"73","10LoDist":"26","10LoSt":"20","10PeerDist":"66","10PeerSt":"59"},{"ID":"42","Dist":"East Hampton","3LoDist":"0","3LoSt":"35","3PeerDist":"68","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"60","10PeerSt":"59"},{"ID":"43","Dist":"East Hartford","3LoDist":"31","3LoSt":"35","3PeerDist":"56","3PeerSt":"73","10LoDist":"38","10LoSt":"20","10PeerDist":"76","10PeerSt":"59"},{"ID":"44","Dist":"East Haven","3LoDist":"25","3LoSt":"35","3PeerDist":"49","3PeerSt":"73","10LoDist":"26","10LoSt":"20","10PeerDist":"35","10PeerSt":"59"},{"ID":"45","Dist":"East Lyme","3LoDist":"38","3LoSt":"35","3PeerDist":"77","3PeerSt":"73","10LoDist":"21","10LoSt":"20","10PeerDist":"50","10PeerSt":"59"},{"ID":"46","Dist":"Easton","3LoDist":"0","3LoSt":"35","3PeerDist":"85","3PeerSt":"73","10LoDist":"63","10LoSt":"20","10PeerDist":"79","10PeerSt":"59"},{"ID":"47","Dist":"East Windsor","3LoDist":"29","3LoSt":"35","3PeerDist":"56","3PeerSt":"73","10LoDist":"14","10LoSt":"20","10PeerDist":"43","10PeerSt":"59"},{"ID":"48","Dist":"Ellington","3LoDist":"49","3LoSt":"35","3PeerDist":"78","3PeerSt":"73","10LoDist":"14","10LoSt":"20","10PeerDist":"44","10PeerSt":"59"},{"ID":"49","Dist":"Enfield","3LoDist":"43","3LoSt":"35","3PeerDist":"74","3PeerSt":"73","10LoDist":"26","10LoSt":"20","10PeerDist":"41","10PeerSt":"59"},{"ID":"50","Dist":"Essex","3LoDist":"0","3LoSt":"35","3PeerDist":"70","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"58","10PeerSt":"59"},{"ID":"51","Dist":"Fairfield","3LoDist":"34","3LoSt":"35","3PeerDist":"78","3PeerSt":"73","10LoDist":"30","10LoSt":"20","10PeerDist":"53","10PeerSt":"59"},{"ID":"52","Dist":"Farmington","3LoDist":"69","3LoSt":"35","3PeerDist":"84","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"0","10PeerSt":"59"},{"ID":"54","Dist":"Glastonbury","3LoDist":"40","3LoSt":"35","3PeerDist":"78","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"83","10PeerSt":"59"},{"ID":"56","Dist":"Granby","3LoDist":"50","3LoSt":"35","3PeerDist":"87","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"84","10PeerSt":"59"},{"ID":"57","Dist":"Greenwich","3LoDist":"51","3LoSt":"35","3PeerDist":"83","3PeerSt":"73","10LoDist":"23","10LoSt":"20","10PeerDist":"50","10PeerSt":"59"},{"ID":"58","Dist":"Griswold","3LoDist":"46","3LoSt":"35","3PeerDist":"61","3PeerSt":"73","10LoDist":"11","10LoSt":"20","10PeerDist":"33","10PeerSt":"59"},{"ID":"59","Dist":"Groton","3LoDist":"38","3LoSt":"35","3PeerDist":"64","3PeerSt":"73","10LoDist":"23","10LoSt":"20","10PeerDist":"48","10PeerSt":"59"},{"ID":"60","Dist":"Guilford","3LoDist":"0","3LoSt":"35","3PeerDist":"82","3PeerSt":"73","10LoDist":"39","10LoSt":"20","10PeerDist":"54","10PeerSt":"59"},{"ID":"62","Dist":"Hamden","3LoDist":"31","3LoSt":"35","3PeerDist":"63","3PeerSt":"73","10LoDist":"52","10LoSt":"20","10PeerDist":"66","10PeerSt":"59"},{"ID":"64","Dist":"Hartford","3LoDist":"31","3LoSt":"35","3PeerDist":"73","3PeerSt":"73","10LoDist":"24","10LoSt":"20","10PeerDist":"58","10PeerSt":"59"},{"ID":"65","Dist":"Hartland","3LoDist":"0","3LoSt":"35","3PeerDist":"50","3PeerSt":"73","10LoDist":"30","10LoSt":"20","10PeerDist":"45","10PeerSt":"59"},{"ID":"67","Dist":"Hebron","3LoDist":"0","3LoSt":"35","3PeerDist":"83","3PeerSt":"73","10LoDist":"9","10LoSt":"20","10PeerDist":"38","10PeerSt":"59"},{"ID":"68","Dist":"Kent","3LoDist":"0","3LoSt":"35","3PeerDist":"76","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"89","10PeerSt":"59"},{"ID":"69","Dist":"Killingly","3LoDist":"48","3LoSt":"35","3PeerDist":"62","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"59","10PeerSt":"59"},{"ID":"71","Dist":"Lebanon","3LoDist":"0","3LoSt":"35","3PeerDist":"67","3PeerSt":"73","10LoDist":"18","10LoSt":"20","10PeerDist":"31","10PeerSt":"59"},{"ID":"72","Dist":"Ledyard","3LoDist":"48","3LoSt":"35","3PeerDist":"69","3PeerSt":"73","10LoDist":"47","10LoSt":"20","10PeerDist":"71","10PeerSt":"59"},{"ID":"73","Dist":"Lisbon","3LoDist":"0","3LoSt":"35","3PeerDist":"64","3PeerSt":"73","10LoDist":"22","10LoSt":"20","10PeerDist":"0","10PeerSt":"59"},{"ID":"74","Dist":"Litchfield","3LoDist":"0","3LoSt":"35","3PeerDist":"72","3PeerSt":"73","10LoDist":"26","10LoSt":"20","10PeerDist":"53","10PeerSt":"59"},{"ID":"76","Dist":"Madison","3LoDist":"0","3LoSt":"35","3PeerDist":"83","3PeerSt":"73","10LoDist":"48","10LoSt":"20","10PeerDist":"70","10PeerSt":"59"},{"ID":"77","Dist":"Manchester","3LoDist":"37","3LoSt":"35","3PeerDist":"73","3PeerSt":"73","10LoDist":"27","10LoSt":"20","10PeerDist":"59","10PeerSt":"59"},{"ID":"78","Dist":"Mansfield","3LoDist":"57","3LoSt":"35","3PeerDist":"76","3PeerSt":"73","10LoDist":"38","10LoSt":"20","10PeerDist":"63","10PeerSt":"59"},{"ID":"79","Dist":"Marlborough","3LoDist":"0","3LoSt":"35","3PeerDist":"75","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"59","10PeerSt":"59"},{"ID":"80","Dist":"Meriden","3LoDist":"28","3LoSt":"35","3PeerDist":"56","3PeerSt":"73","10LoDist":"21","10LoSt":"20","10PeerDist":"47","10PeerSt":"59"},{"ID":"83","Dist":"Middletown","3LoDist":"41","3LoSt":"35","3PeerDist":"73","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"0","10PeerSt":"59"},{"ID":"84","Dist":"Milford","3LoDist":"46","3LoSt":"35","3PeerDist":"67","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"62","10PeerSt":"59"},{"ID":"85","Dist":"Monroe","3LoDist":"75","3LoSt":"35","3PeerDist":"83","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"68","10PeerSt":"59"},{"ID":"86","Dist":"Montville","3LoDist":"46","3LoSt":"35","3PeerDist":"55","3PeerSt":"73","10LoDist":"14","10LoSt":"20","10PeerDist":"43","10PeerSt":"59"},{"ID":"88","Dist":"Naugatuck","3LoDist":"40","3LoSt":"35","3PeerDist":"63","3PeerSt":"73","10LoDist":"37","10LoSt":"20","10PeerDist":"48","10PeerSt":"59"},{"ID":"89","Dist":"New Britain","3LoDist":"20","3LoSt":"35","3PeerDist":"33","3PeerSt":"73","10LoDist":"38","10LoSt":"20","10PeerDist":"55","10PeerSt":"59"},{"ID":"90","Dist":"New Canaan","3LoDist":"0","3LoSt":"35","3PeerDist":"89","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"63","10PeerSt":"59"},{"ID":"91","Dist":"New Fairfield","3LoDist":"0","3LoSt":"35","3PeerDist":"72","3PeerSt":"73","10LoDist":"16","10LoSt":"20","10PeerDist":"34","10PeerSt":"59"},{"ID":"92","Dist":"New Hartford","3LoDist":"0","3LoSt":"35","3PeerDist":"88","3PeerSt":"73","10LoDist":"63","10LoSt":"20","10PeerDist":"82","10PeerSt":"59"},{"ID":"93","Dist":"New Haven","3LoDist":"29","3LoSt":"35","3PeerDist":"55","3PeerSt":"73","10LoDist":"33","10LoSt":"20","10PeerDist":"57","10PeerSt":"59"},{"ID":"94","Dist":"Newington","3LoDist":"52","3LoSt":"35","3PeerDist":"74","3PeerSt":"73","10LoDist":"14","10LoSt":"20","10PeerDist":"39","10PeerSt":"59"},{"ID":"95","Dist":"New London","3LoDist":"41","3LoSt":"35","3PeerDist":"0","3PeerSt":"73","10LoDist":"37","10LoSt":"20","10PeerDist":"59","10PeerSt":"59"},{"ID":"96","Dist":"New Milford","3LoDist":"59","3LoSt":"35","3PeerDist":"69","3PeerSt":"73","10LoDist":"44","10LoSt":"20","10PeerDist":"85","10PeerSt":"59"},{"ID":"97","Dist":"Newtown","3LoDist":"0","3LoSt":"35","3PeerDist":"83","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"55","10PeerSt":"59"},{"ID":"99","Dist":"North Branford","3LoDist":"0","3LoSt":"35","3PeerDist":"58","3PeerSt":"73","10LoDist":"33","10LoSt":"20","10PeerDist":"71","10PeerSt":"59"},{"ID":"100","Dist":"North Canaan","3LoDist":"0","3LoSt":"35","3PeerDist":"65","3PeerSt":"73","10LoDist":"43","10LoSt":"20","10PeerDist":"78","10PeerSt":"59"},{"ID":"101","Dist":"North Haven","3LoDist":"42","3LoSt":"35","3PeerDist":"66","3PeerSt":"73","10LoDist":"29","10LoSt":"20","10PeerDist":"57","10PeerSt":"59"},{"ID":"102","Dist":"North Stonington","3LoDist":"0","3LoSt":"35","3PeerDist":"76","3PeerSt":"73","10LoDist":"16","10LoSt":"20","10PeerDist":"45","10PeerSt":"59"},{"ID":"103","Dist":"Norwalk","3LoDist":"43","3LoSt":"35","3PeerDist":"72","3PeerSt":"73","10LoDist":"20","10LoSt":"20","10PeerDist":"58","10PeerSt":"59"},{"ID":"104","Dist":"Norwich","3LoDist":"35","3LoSt":"35","3PeerDist":"43","3PeerSt":"73","10LoDist":"19","10LoSt":"20","10PeerDist":"49","10PeerSt":"59"},{"ID":"106","Dist":"Old Saybrook","3LoDist":"60","3LoSt":"35","3PeerDist":"81","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"70","10PeerSt":"59"},{"ID":"107","Dist":"Orange","3LoDist":"0","3LoSt":"35","3PeerDist":"77","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"53","10PeerSt":"59"},{"ID":"108","Dist":"Oxford","3LoDist":"0","3LoSt":"35","3PeerDist":"79","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"52","10PeerSt":"59"},{"ID":"109","Dist":"Plainfield","3LoDist":"46","3LoSt":"35","3PeerDist":"62","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"58","10PeerSt":"59"},{"ID":"110","Dist":"Plainville","3LoDist":"46","3LoSt":"35","3PeerDist":"67","3PeerSt":"73","10LoDist":"16","10LoSt":"20","10PeerDist":"38","10PeerSt":"59"},{"ID":"111","Dist":"Plymouth","3LoDist":"48","3LoSt":"35","3PeerDist":"63","3PeerSt":"73","10LoDist":"41","10LoSt":"20","10PeerDist":"64","10PeerSt":"59"},{"ID":"112","Dist":"Pomfret","3LoDist":"0","3LoSt":"35","3PeerDist":"51","3PeerSt":"73","10LoDist":"21","10LoSt":"20","10PeerDist":"42","10PeerSt":"59"},{"ID":"113","Dist":"Portland","3LoDist":"0","3LoSt":"35","3PeerDist":"85","3PeerSt":"73","10LoDist":"36","10LoSt":"20","10PeerDist":"63","10PeerSt":"59"},{"ID":"114","Dist":"Preston","3LoDist":"0","3LoSt":"35","3PeerDist":"59","3PeerSt":"73","10LoDist":"14","10LoSt":"20","10PeerDist":"29","10PeerSt":"59"},{"ID":"116","Dist":"Putnam","3LoDist":"44","3LoSt":"35","3PeerDist":"68","3PeerSt":"73","10LoDist":"50","10LoSt":"20","10PeerDist":"71","10PeerSt":"59"},{"ID":"117","Dist":"Redding","3LoDist":"0","3LoSt":"35","3PeerDist":"84","3PeerSt":"73","10LoDist":"35","10LoSt":"20","10PeerDist":"52","10PeerSt":"59"},{"ID":"118","Dist":"Ridgefield","3LoDist":"0","3LoSt":"35","3PeerDist":"81","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"64","10PeerSt":"59"},{"ID":"119","Dist":"Rocky Hill","3LoDist":"52","3LoSt":"35","3PeerDist":"71","3PeerSt":"73","10LoDist":"33","10LoSt":"20","10PeerDist":"75","10PeerSt":"59"},{"ID":"121","Dist":"Salem","3LoDist":"0","3LoSt":"35","3PeerDist":"67","3PeerSt":"73","10LoDist":"19","10LoSt":"20","10PeerDist":"37","10PeerSt":"59"},{"ID":"122","Dist":"Salisbury","3LoDist":"0","3LoSt":"35","3PeerDist":"79","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"86","10PeerSt":"59"},{"ID":"124","Dist":"Seymour","3LoDist":"49","3LoSt":"35","3PeerDist":"58","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"85","10PeerSt":"59"},{"ID":"125","Dist":"Sharon","3LoDist":"0","3LoSt":"35","3PeerDist":"0","3PeerSt":"73","10LoDist":"46","10LoSt":"20","10PeerDist":"53","10PeerSt":"59"},{"ID":"126","Dist":"Shelton","3LoDist":"52","3LoSt":"35","3PeerDist":"69","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"81","10PeerSt":"59"},{"ID":"127","Dist":"Sherman","3LoDist":"0","3LoSt":"35","3PeerDist":"74","3PeerSt":"73","10LoDist":"9","10LoSt":"20","10PeerDist":"35","10PeerSt":"59"},{"ID":"128","Dist":"Simsbury","3LoDist":"52","3LoSt":"35","3PeerDist":"82","3PeerSt":"73","10LoDist":"12","10LoSt":"20","10PeerDist":"32","10PeerSt":"59"},{"ID":"129","Dist":"Somers","3LoDist":"0","3LoSt":"35","3PeerDist":"69","3PeerSt":"73","10LoDist":"21","10LoSt":"20","10PeerDist":"36","10PeerSt":"59"},{"ID":"131","Dist":"Southington","3LoDist":"55","3LoSt":"35","3PeerDist":"76","3PeerSt":"73","10LoDist":"42","10LoSt":"20","10PeerDist":"48","10PeerSt":"59"},{"ID":"132","Dist":"South Windsor","3LoDist":"42","3LoSt":"35","3PeerDist":"78","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"58","10PeerSt":"59"},{"ID":"133","Dist":"Sprague","3LoDist":"39","3LoSt":"35","3PeerDist":"0","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"71","10PeerSt":"59"},{"ID":"134","Dist":"Stafford","3LoDist":"46","3LoSt":"35","3PeerDist":"72","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"82","10PeerSt":"59"},{"ID":"135","Dist":"Stamford","3LoDist":"31","3LoSt":"35","3PeerDist":"76","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"57","10PeerSt":"59"},{"ID":"136","Dist":"Sterling","3LoDist":"0","3LoSt":"35","3PeerDist":"55","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"80","10PeerSt":"59"},{"ID":"137","Dist":"Stonington","3LoDist":"69","3LoSt":"35","3PeerDist":"75","3PeerSt":"73","10LoDist":"30","10LoSt":"20","10PeerDist":"68","10PeerSt":"59"},{"ID":"138","Dist":"Stratford","3LoDist":"43","3LoSt":"35","3PeerDist":"72","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"88","10PeerSt":"59"},{"ID":"139","Dist":"Suffield","3LoDist":"45","3LoSt":"35","3PeerDist":"82","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"67","10PeerSt":"59"},{"ID":"140","Dist":"Thomaston","3LoDist":"46","3LoSt":"35","3PeerDist":"54","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"52","10PeerSt":"59"},{"ID":"141","Dist":"Thompson","3LoDist":"53","3LoSt":"35","3PeerDist":"61","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"64","10PeerSt":"59"},{"ID":"142","Dist":"Tolland","3LoDist":"0","3LoSt":"35","3PeerDist":"75","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"51","10PeerSt":"59"},{"ID":"143","Dist":"Torrington","3LoDist":"52","3LoSt":"35","3PeerDist":"65","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"66","10PeerSt":"59"},{"ID":"144","Dist":"Trumbull","3LoDist":"62","3LoSt":"35","3PeerDist":"77","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"62","10PeerSt":"59"},{"ID":"146","Dist":"Vernon","3LoDist":"48","3LoSt":"35","3PeerDist":"66","3PeerSt":"73","10LoDist":"26","10LoSt":"20","10PeerDist":"50","10PeerSt":"59"},{"ID":"147","Dist":"Voluntown","3LoDist":"0","3LoSt":"35","3PeerDist":"48","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"66","10PeerSt":"59"},{"ID":"148","Dist":"Wallingford","3LoDist":"42","3LoSt":"35","3PeerDist":"73","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"76","10PeerSt":"59"},{"ID":"151","Dist":"Waterbury","3LoDist":"30","3LoSt":"35","3PeerDist":"57","3PeerSt":"73","10LoDist":"13","10LoSt":"20","10PeerDist":"53","10PeerSt":"59"},{"ID":"152","Dist":"Waterford","3LoDist":"38","3LoSt":"35","3PeerDist":"75","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"153","Dist":"Watertown","3LoDist":"41","3LoSt":"35","3PeerDist":"70","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"154","Dist":"Westbrook","3LoDist":"0","3LoSt":"35","3PeerDist":"85","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"155","Dist":"West Hartford","3LoDist":"40","3LoSt":"35","3PeerDist":"79","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"156","Dist":"West Haven","3LoDist":"31","3LoSt":"35","3PeerDist":"61","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"157","Dist":"Weston","3LoDist":"0","3LoSt":"35","3PeerDist":"85","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"158","Dist":"Westport","3LoDist":"0","3LoSt":"35","3PeerDist":"85","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"159","Dist":"Wethersfield","3LoDist":"37","3LoSt":"35","3PeerDist":"64","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"160","Dist":"Willington","3LoDist":"0","3LoSt":"35","3PeerDist":"68","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"161","Dist":"Wilton","3LoDist":"0","3LoSt":"35","3PeerDist":"87","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"162","Dist":"Winchester","3LoDist":"58","3LoSt":"35","3PeerDist":"64","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"163","Dist":"Windham","3LoDist":"29","3LoSt":"35","3PeerDist":"84","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"164","Dist":"Windsor","3LoDist":"39","3LoSt":"35","3PeerDist":"72","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"165","Dist":"Windsor Locks","3LoDist":"32","3LoSt":"35","3PeerDist":"67","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"166","Dist":"Wolcott","3LoDist":"51","3LoSt":"35","3PeerDist":"73","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"167","Dist":"Woodbridge","3LoDist":"0","3LoSt":"35","3PeerDist":"80","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"169","Dist":"Woodstock","3LoDist":"0","3LoSt":"35","3PeerDist":"71","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"206","Dist":"Regional Sch Dist 06","3LoDist":"0","3LoSt":"35","3PeerDist":"68","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"210","Dist":"Regional Sch Dist 10","3LoDist":"0","3LoSt":"35","3PeerDist":"82","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"212","Dist":"Regional Sch Dist 12","3LoDist":"0","3LoSt":"35","3PeerDist":"77","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"213","Dist":"Regional Sch Dist 13","3LoDist":"0","3LoSt":"35","3PeerDist":"61","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"214","Dist":"Regional Sch Dist 14","3LoDist":"0","3LoSt":"35","3PeerDist":"63","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"215","Dist":"Regional Sch Dist 15","3LoDist":"0","3LoSt":"35","3PeerDist":"83","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"216","Dist":"Regional Sch Dist 16","3LoDist":"44","3LoSt":"35","3PeerDist":"64","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"217","Dist":"Regional Sch Dist 17","3LoDist":"0","3LoSt":"35","3PeerDist":"73","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"0","Dist":"Town","3LoDist":"3","3LoSt":"3","3PeerDist":"3","3PeerSt":"3","10LoDist":"10","10LoSt":"10","10PeerDist":"10","10PeerSt":"10"},{"ID":"1","Dist":"Andover","3LoDist":"0","3LoSt":"35","3PeerDist":"86","3PeerSt":"73","10LoDist":"18","10LoSt":"20","10PeerDist":"40","10PeerSt":"59"},{"ID":"2","Dist":"Ansonia","3LoDist":"36","3LoSt":"35","3PeerDist":"51","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"73","10PeerSt":"59"},{"ID":"3","Dist":"Ashford","3LoDist":"0","3LoSt":"35","3PeerDist":"71","3PeerSt":"73","10LoDist":"32","10LoSt":"20","10PeerDist":"72","10PeerSt":"59"},{"ID":"4","Dist":"Avon","3LoDist":"0","3LoSt":"35","3PeerDist":"87","3PeerSt":"73","10LoDist":"44","10LoSt":"20","10PeerDist":"67","10PeerSt":"59"},{"ID":"5","Dist":"Barkhamsted","3LoDist":"0","3LoSt":"35","3PeerDist":"68","3PeerSt":"73","10LoDist":"21","10LoSt":"20","10PeerDist":"31","10PeerSt":"59"},{"ID":"7","Dist":"Berlin","3LoDist":"48","3LoSt":"35","3PeerDist":"61","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"78","10PeerSt":"59"},{"ID":"8","Dist":"Bethany","3LoDist":"0","3LoSt":"35","3PeerDist":"75","3PeerSt":"73","10LoDist":"36","10LoSt":"20","10PeerDist":"59","10PeerSt":"59"},{"ID":"9","Dist":"Bethel","3LoDist":"55","3LoSt":"35","3PeerDist":"74","3PeerSt":"73","10LoDist":"8","10LoSt":"20","10PeerDist":"0","10PeerSt":"59"},{"ID":"11","Dist":"Bloomfield","3LoDist":"58","3LoSt":"35","3PeerDist":"45","3PeerSt":"73","10LoDist":"23","10LoSt":"20","10PeerDist":"53","10PeerSt":"59"},{"ID":"12","Dist":"Bolton","3LoDist":"0","3LoSt":"35","3PeerDist":"70","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"70","10PeerSt":"59"},{"ID":"14","Dist":"Branford","3LoDist":"48","3LoSt":"35","3PeerDist":"76","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"71","10PeerSt":"59"},{"ID":"15","Dist":"Bridgeport","3LoDist":"23","3LoSt":"35","3PeerDist":"0","3PeerSt":"73","10LoDist":"28","10LoSt":"20","10PeerDist":"68","10PeerSt":"59"},{"ID":"17","Dist":"Bristol","3LoDist":"37","3LoSt":"35","3PeerDist":"61","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"56","10PeerSt":"59"},{"ID":"18","Dist":"Brookfield","3LoDist":"0","3LoSt":"35","3PeerDist":"75","3PeerSt":"73","10LoDist":"14","10LoSt":"20","10PeerDist":"60","10PeerSt":"59"},{"ID":"19","Dist":"Brooklyn","3LoDist":"0","3LoSt":"35","3PeerDist":"59","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"65","10PeerSt":"59"},{"ID":"22","Dist":"Canterbury","3LoDist":"0","3LoSt":"35","3PeerDist":"65","3PeerSt":"73","10LoDist":"30","10LoSt":"20","10PeerDist":"56","10PeerSt":"59"},{"ID":"23","Dist":"Canton","3LoDist":"0","3LoSt":"35","3PeerDist":"83","3PeerSt":"73","10LoDist":"15","10LoSt":"20","10PeerDist":"40","10PeerSt":"59"},{"ID":"24","Dist":"Chaplin","3LoDist":"0","3LoSt":"35","3PeerDist":"0","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"75","10PeerSt":"59"},{"ID":"25","Dist":"Cheshire","3LoDist":"36","3LoSt":"35","3PeerDist":"76","3PeerSt":"73","10LoDist":"23","10LoSt":"20","10PeerDist":"40","10PeerSt":"59"},{"ID":"26","Dist":"Chester","3LoDist":"0","3LoSt":"35","3PeerDist":"75","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"67","10PeerSt":"59"},{"ID":"27","Dist":"Clinton","3LoDist":"64","3LoSt":"35","3PeerDist":"77","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"53","10PeerSt":"59"},{"ID":"28","Dist":"Colchester","3LoDist":"50","3LoSt":"35","3PeerDist":"73","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"72","10PeerSt":"59"},{"ID":"30","Dist":"Columbia","3LoDist":"0","3LoSt":"35","3PeerDist":"58","3PeerSt":"73","10LoDist":"12","10LoSt":"20","10PeerDist":"39","10PeerSt":"59"},{"ID":"32","Dist":"Coventry","3LoDist":"68","3LoSt":"35","3PeerDist":"77","3PeerSt":"73","10LoDist":"22","10LoSt":"20","10PeerDist":"32","10PeerSt":"59"},{"ID":"33","Dist":"Cromwell","3LoDist":"65","3LoSt":"35","3PeerDist":"81","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"70","10PeerSt":"59"},{"ID":"34","Dist":"Danbury","3LoDist":"30","3LoSt":"35","3PeerDist":"65","3PeerSt":"73","10LoDist":"25","10LoSt":"20","10PeerDist":"44","10PeerSt":"59"},{"ID":"35","Dist":"Darien","3LoDist":"0","3LoSt":"35","3PeerDist":"81","3PeerSt":"73","10LoDist":"24","10LoSt":"20","10PeerDist":"61","10PeerSt":"59"},{"ID":"36","Dist":"Deep River","3LoDist":"0","3LoSt":"35","3PeerDist":"79","3PeerSt":"73","10LoDist":"24","10LoSt":"20","10PeerDist":"46","10PeerSt":"59"},{"ID":"37","Dist":"Derby","3LoDist":"33","3LoSt":"35","3PeerDist":"61","3PeerSt":"73","10LoDist":"45","10LoSt":"20","10PeerDist":"75","10PeerSt":"59"},{"ID":"40","Dist":"East Granby","3LoDist":"0","3LoSt":"35","3PeerDist":"64","3PeerSt":"73","10LoDist":"32","10LoSt":"20","10PeerDist":"73","10PeerSt":"59"},{"ID":"41","Dist":"East Haddam","3LoDist":"0","3LoSt":"35","3PeerDist":"89","3PeerSt":"73","10LoDist":"26","10LoSt":"20","10PeerDist":"66","10PeerSt":"59"},{"ID":"42","Dist":"East Hampton","3LoDist":"0","3LoSt":"35","3PeerDist":"68","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"60","10PeerSt":"59"},{"ID":"43","Dist":"East Hartford","3LoDist":"31","3LoSt":"35","3PeerDist":"56","3PeerSt":"73","10LoDist":"38","10LoSt":"20","10PeerDist":"76","10PeerSt":"59"},{"ID":"44","Dist":"East Haven","3LoDist":"25","3LoSt":"35","3PeerDist":"49","3PeerSt":"73","10LoDist":"26","10LoSt":"20","10PeerDist":"35","10PeerSt":"59"},{"ID":"45","Dist":"East Lyme","3LoDist":"38","3LoSt":"35","3PeerDist":"77","3PeerSt":"73","10LoDist":"21","10LoSt":"20","10PeerDist":"50","10PeerSt":"59"},{"ID":"46","Dist":"Easton","3LoDist":"0","3LoSt":"35","3PeerDist":"85","3PeerSt":"73","10LoDist":"63","10LoSt":"20","10PeerDist":"79","10PeerSt":"59"},{"ID":"47","Dist":"East Windsor","3LoDist":"29","3LoSt":"35","3PeerDist":"56","3PeerSt":"73","10LoDist":"14","10LoSt":"20","10PeerDist":"43","10PeerSt":"59"},{"ID":"48","Dist":"Ellington","3LoDist":"49","3LoSt":"35","3PeerDist":"78","3PeerSt":"73","10LoDist":"14","10LoSt":"20","10PeerDist":"44","10PeerSt":"59"},{"ID":"49","Dist":"Enfield","3LoDist":"43","3LoSt":"35","3PeerDist":"74","3PeerSt":"73","10LoDist":"26","10LoSt":"20","10PeerDist":"41","10PeerSt":"59"},{"ID":"50","Dist":"Essex","3LoDist":"0","3LoSt":"35","3PeerDist":"70","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"58","10PeerSt":"59"},{"ID":"51","Dist":"Fairfield","3LoDist":"34","3LoSt":"35","3PeerDist":"78","3PeerSt":"73","10LoDist":"30","10LoSt":"20","10PeerDist":"53","10PeerSt":"59"},{"ID":"52","Dist":"Farmington","3LoDist":"69","3LoSt":"35","3PeerDist":"84","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"0","10PeerSt":"59"},{"ID":"54","Dist":"Glastonbury","3LoDist":"40","3LoSt":"35","3PeerDist":"78","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"83","10PeerSt":"59"},{"ID":"56","Dist":"Granby","3LoDist":"50","3LoSt":"35","3PeerDist":"87","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"84","10PeerSt":"59"},{"ID":"57","Dist":"Greenwich","3LoDist":"51","3LoSt":"35","3PeerDist":"83","3PeerSt":"73","10LoDist":"23","10LoSt":"20","10PeerDist":"50","10PeerSt":"59"},{"ID":"58","Dist":"Griswold","3LoDist":"46","3LoSt":"35","3PeerDist":"61","3PeerSt":"73","10LoDist":"11","10LoSt":"20","10PeerDist":"33","10PeerSt":"59"},{"ID":"59","Dist":"Groton","3LoDist":"38","3LoSt":"35","3PeerDist":"64","3PeerSt":"73","10LoDist":"23","10LoSt":"20","10PeerDist":"48","10PeerSt":"59"},{"ID":"60","Dist":"Guilford","3LoDist":"0","3LoSt":"35","3PeerDist":"82","3PeerSt":"73","10LoDist":"39","10LoSt":"20","10PeerDist":"54","10PeerSt":"59"},{"ID":"62","Dist":"Hamden","3LoDist":"31","3LoSt":"35","3PeerDist":"63","3PeerSt":"73","10LoDist":"52","10LoSt":"20","10PeerDist":"66","10PeerSt":"59"},{"ID":"64","Dist":"Hartford","3LoDist":"31","3LoSt":"35","3PeerDist":"73","3PeerSt":"73","10LoDist":"24","10LoSt":"20","10PeerDist":"58","10PeerSt":"59"},{"ID":"65","Dist":"Hartland","3LoDist":"0","3LoSt":"35","3PeerDist":"50","3PeerSt":"73","10LoDist":"30","10LoSt":"20","10PeerDist":"45","10PeerSt":"59"},{"ID":"67","Dist":"Hebron","3LoDist":"0","3LoSt":"35","3PeerDist":"83","3PeerSt":"73","10LoDist":"9","10LoSt":"20","10PeerDist":"38","10PeerSt":"59"},{"ID":"68","Dist":"Kent","3LoDist":"0","3LoSt":"35","3PeerDist":"76","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"89","10PeerSt":"59"},{"ID":"69","Dist":"Killingly","3LoDist":"48","3LoSt":"35","3PeerDist":"62","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"59","10PeerSt":"59"},{"ID":"71","Dist":"Lebanon","3LoDist":"0","3LoSt":"35","3PeerDist":"67","3PeerSt":"73","10LoDist":"18","10LoSt":"20","10PeerDist":"31","10PeerSt":"59"},{"ID":"72","Dist":"Ledyard","3LoDist":"48","3LoSt":"35","3PeerDist":"69","3PeerSt":"73","10LoDist":"47","10LoSt":"20","10PeerDist":"71","10PeerSt":"59"},{"ID":"73","Dist":"Lisbon","3LoDist":"0","3LoSt":"35","3PeerDist":"64","3PeerSt":"73","10LoDist":"22","10LoSt":"20","10PeerDist":"0","10PeerSt":"59"},{"ID":"74","Dist":"Litchfield","3LoDist":"0","3LoSt":"35","3PeerDist":"72","3PeerSt":"73","10LoDist":"26","10LoSt":"20","10PeerDist":"53","10PeerSt":"59"},{"ID":"76","Dist":"Madison","3LoDist":"0","3LoSt":"35","3PeerDist":"83","3PeerSt":"73","10LoDist":"48","10LoSt":"20","10PeerDist":"70","10PeerSt":"59"},{"ID":"77","Dist":"Manchester","3LoDist":"37","3LoSt":"35","3PeerDist":"73","3PeerSt":"73","10LoDist":"27","10LoSt":"20","10PeerDist":"59","10PeerSt":"59"},{"ID":"78","Dist":"Mansfield","3LoDist":"57","3LoSt":"35","3PeerDist":"76","3PeerSt":"73","10LoDist":"38","10LoSt":"20","10PeerDist":"63","10PeerSt":"59"},{"ID":"79","Dist":"Marlborough","3LoDist":"0","3LoSt":"35","3PeerDist":"75","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"59","10PeerSt":"59"},{"ID":"80","Dist":"Meriden","3LoDist":"28","3LoSt":"35","3PeerDist":"56","3PeerSt":"73","10LoDist":"21","10LoSt":"20","10PeerDist":"47","10PeerSt":"59"},{"ID":"83","Dist":"Middletown","3LoDist":"41","3LoSt":"35","3PeerDist":"73","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"0","10PeerSt":"59"},{"ID":"84","Dist":"Milford","3LoDist":"46","3LoSt":"35","3PeerDist":"67","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"62","10PeerSt":"59"},{"ID":"85","Dist":"Monroe","3LoDist":"75","3LoSt":"35","3PeerDist":"83","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"68","10PeerSt":"59"},{"ID":"86","Dist":"Montville","3LoDist":"46","3LoSt":"35","3PeerDist":"55","3PeerSt":"73","10LoDist":"14","10LoSt":"20","10PeerDist":"43","10PeerSt":"59"},{"ID":"88","Dist":"Naugatuck","3LoDist":"40","3LoSt":"35","3PeerDist":"63","3PeerSt":"73","10LoDist":"37","10LoSt":"20","10PeerDist":"48","10PeerSt":"59"},{"ID":"89","Dist":"New Britain","3LoDist":"20","3LoSt":"35","3PeerDist":"33","3PeerSt":"73","10LoDist":"38","10LoSt":"20","10PeerDist":"55","10PeerSt":"59"},{"ID":"90","Dist":"New Canaan","3LoDist":"0","3LoSt":"35","3PeerDist":"89","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"63","10PeerSt":"59"},{"ID":"91","Dist":"New Fairfield","3LoDist":"0","3LoSt":"35","3PeerDist":"72","3PeerSt":"73","10LoDist":"16","10LoSt":"20","10PeerDist":"34","10PeerSt":"59"},{"ID":"92","Dist":"New Hartford","3LoDist":"0","3LoSt":"35","3PeerDist":"88","3PeerSt":"73","10LoDist":"63","10LoSt":"20","10PeerDist":"82","10PeerSt":"59"},{"ID":"93","Dist":"New Haven","3LoDist":"29","3LoSt":"35","3PeerDist":"55","3PeerSt":"73","10LoDist":"33","10LoSt":"20","10PeerDist":"57","10PeerSt":"59"},{"ID":"94","Dist":"Newington","3LoDist":"52","3LoSt":"35","3PeerDist":"74","3PeerSt":"73","10LoDist":"14","10LoSt":"20","10PeerDist":"39","10PeerSt":"59"},{"ID":"95","Dist":"New London","3LoDist":"41","3LoSt":"35","3PeerDist":"0","3PeerSt":"73","10LoDist":"37","10LoSt":"20","10PeerDist":"59","10PeerSt":"59"},{"ID":"96","Dist":"New Milford","3LoDist":"59","3LoSt":"35","3PeerDist":"69","3PeerSt":"73","10LoDist":"44","10LoSt":"20","10PeerDist":"85","10PeerSt":"59"},{"ID":"97","Dist":"Newtown","3LoDist":"0","3LoSt":"35","3PeerDist":"83","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"55","10PeerSt":"59"},{"ID":"99","Dist":"North Branford","3LoDist":"0","3LoSt":"35","3PeerDist":"58","3PeerSt":"73","10LoDist":"33","10LoSt":"20","10PeerDist":"71","10PeerSt":"59"},{"ID":"100","Dist":"North Canaan","3LoDist":"0","3LoSt":"35","3PeerDist":"65","3PeerSt":"73","10LoDist":"43","10LoSt":"20","10PeerDist":"78","10PeerSt":"59"},{"ID":"101","Dist":"North Haven","3LoDist":"42","3LoSt":"35","3PeerDist":"66","3PeerSt":"73","10LoDist":"29","10LoSt":"20","10PeerDist":"57","10PeerSt":"59"},{"ID":"102","Dist":"North Stonington","3LoDist":"0","3LoSt":"35","3PeerDist":"76","3PeerSt":"73","10LoDist":"16","10LoSt":"20","10PeerDist":"45","10PeerSt":"59"},{"ID":"103","Dist":"Norwalk","3LoDist":"43","3LoSt":"35","3PeerDist":"72","3PeerSt":"73","10LoDist":"20","10LoSt":"20","10PeerDist":"58","10PeerSt":"59"},{"ID":"104","Dist":"Norwich","3LoDist":"35","3LoSt":"35","3PeerDist":"43","3PeerSt":"73","10LoDist":"19","10LoSt":"20","10PeerDist":"49","10PeerSt":"59"},{"ID":"106","Dist":"Old Saybrook","3LoDist":"60","3LoSt":"35","3PeerDist":"81","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"70","10PeerSt":"59"},{"ID":"107","Dist":"Orange","3LoDist":"0","3LoSt":"35","3PeerDist":"77","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"53","10PeerSt":"59"},{"ID":"108","Dist":"Oxford","3LoDist":"0","3LoSt":"35","3PeerDist":"79","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"52","10PeerSt":"59"},{"ID":"109","Dist":"Plainfield","3LoDist":"46","3LoSt":"35","3PeerDist":"62","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"58","10PeerSt":"59"},{"ID":"110","Dist":"Plainville","3LoDist":"46","3LoSt":"35","3PeerDist":"67","3PeerSt":"73","10LoDist":"16","10LoSt":"20","10PeerDist":"38","10PeerSt":"59"},{"ID":"111","Dist":"Plymouth","3LoDist":"48","3LoSt":"35","3PeerDist":"63","3PeerSt":"73","10LoDist":"41","10LoSt":"20","10PeerDist":"64","10PeerSt":"59"},{"ID":"112","Dist":"Pomfret","3LoDist":"0","3LoSt":"35","3PeerDist":"51","3PeerSt":"73","10LoDist":"21","10LoSt":"20","10PeerDist":"42","10PeerSt":"59"},{"ID":"113","Dist":"Portland","3LoDist":"0","3LoSt":"35","3PeerDist":"85","3PeerSt":"73","10LoDist":"36","10LoSt":"20","10PeerDist":"63","10PeerSt":"59"},{"ID":"114","Dist":"Preston","3LoDist":"0","3LoSt":"35","3PeerDist":"59","3PeerSt":"73","10LoDist":"14","10LoSt":"20","10PeerDist":"29","10PeerSt":"59"},{"ID":"116","Dist":"Putnam","3LoDist":"44","3LoSt":"35","3PeerDist":"68","3PeerSt":"73","10LoDist":"50","10LoSt":"20","10PeerDist":"71","10PeerSt":"59"},{"ID":"117","Dist":"Redding","3LoDist":"0","3LoSt":"35","3PeerDist":"84","3PeerSt":"73","10LoDist":"35","10LoSt":"20","10PeerDist":"52","10PeerSt":"59"},{"ID":"118","Dist":"Ridgefield","3LoDist":"0","3LoSt":"35","3PeerDist":"81","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"64","10PeerSt":"59"},{"ID":"119","Dist":"Rocky Hill","3LoDist":"52","3LoSt":"35","3PeerDist":"71","3PeerSt":"73","10LoDist":"33","10LoSt":"20","10PeerDist":"75","10PeerSt":"59"},{"ID":"121","Dist":"Salem","3LoDist":"0","3LoSt":"35","3PeerDist":"67","3PeerSt":"73","10LoDist":"19","10LoSt":"20","10PeerDist":"37","10PeerSt":"59"},{"ID":"122","Dist":"Salisbury","3LoDist":"0","3LoSt":"35","3PeerDist":"79","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"86","10PeerSt":"59"},{"ID":"124","Dist":"Seymour","3LoDist":"49","3LoSt":"35","3PeerDist":"58","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"85","10PeerSt":"59"},{"ID":"125","Dist":"Sharon","3LoDist":"0","3LoSt":"35","3PeerDist":"0","3PeerSt":"73","10LoDist":"46","10LoSt":"20","10PeerDist":"53","10PeerSt":"59"},{"ID":"126","Dist":"Shelton","3LoDist":"52","3LoSt":"35","3PeerDist":"69","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"81","10PeerSt":"59"},{"ID":"127","Dist":"Sherman","3LoDist":"0","3LoSt":"35","3PeerDist":"74","3PeerSt":"73","10LoDist":"9","10LoSt":"20","10PeerDist":"35","10PeerSt":"59"},{"ID":"128","Dist":"Simsbury","3LoDist":"52","3LoSt":"35","3PeerDist":"82","3PeerSt":"73","10LoDist":"12","10LoSt":"20","10PeerDist":"32","10PeerSt":"59"},{"ID":"129","Dist":"Somers","3LoDist":"0","3LoSt":"35","3PeerDist":"69","3PeerSt":"73","10LoDist":"21","10LoSt":"20","10PeerDist":"36","10PeerSt":"59"},{"ID":"131","Dist":"Southington","3LoDist":"55","3LoSt":"35","3PeerDist":"76","3PeerSt":"73","10LoDist":"42","10LoSt":"20","10PeerDist":"48","10PeerSt":"59"},{"ID":"132","Dist":"South Windsor","3LoDist":"42","3LoSt":"35","3PeerDist":"78","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"58","10PeerSt":"59"},{"ID":"133","Dist":"Sprague","3LoDist":"39","3LoSt":"35","3PeerDist":"0","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"71","10PeerSt":"59"},{"ID":"134","Dist":"Stafford","3LoDist":"46","3LoSt":"35","3PeerDist":"72","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"82","10PeerSt":"59"},{"ID":"135","Dist":"Stamford","3LoDist":"31","3LoSt":"35","3PeerDist":"76","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"57","10PeerSt":"59"},{"ID":"136","Dist":"Sterling","3LoDist":"0","3LoSt":"35","3PeerDist":"55","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"80","10PeerSt":"59"},{"ID":"137","Dist":"Stonington","3LoDist":"69","3LoSt":"35","3PeerDist":"75","3PeerSt":"73","10LoDist":"30","10LoSt":"20","10PeerDist":"68","10PeerSt":"59"},{"ID":"138","Dist":"Stratford","3LoDist":"43","3LoSt":"35","3PeerDist":"72","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"88","10PeerSt":"59"},{"ID":"139","Dist":"Suffield","3LoDist":"45","3LoSt":"35","3PeerDist":"82","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"67","10PeerSt":"59"},{"ID":"140","Dist":"Thomaston","3LoDist":"46","3LoSt":"35","3PeerDist":"54","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"52","10PeerSt":"59"},{"ID":"141","Dist":"Thompson","3LoDist":"53","3LoSt":"35","3PeerDist":"61","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"64","10PeerSt":"59"},{"ID":"142","Dist":"Tolland","3LoDist":"0","3LoSt":"35","3PeerDist":"75","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"51","10PeerSt":"59"},{"ID":"143","Dist":"Torrington","3LoDist":"52","3LoSt":"35","3PeerDist":"65","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"66","10PeerSt":"59"},{"ID":"144","Dist":"Trumbull","3LoDist":"62","3LoSt":"35","3PeerDist":"77","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"62","10PeerSt":"59"},{"ID":"146","Dist":"Vernon","3LoDist":"48","3LoSt":"35","3PeerDist":"66","3PeerSt":"73","10LoDist":"26","10LoSt":"20","10PeerDist":"50","10PeerSt":"59"},{"ID":"147","Dist":"Voluntown","3LoDist":"0","3LoSt":"35","3PeerDist":"48","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"66","10PeerSt":"59"},{"ID":"148","Dist":"Wallingford","3LoDist":"42","3LoSt":"35","3PeerDist":"73","3PeerSt":"73","10LoDist":"0","10LoSt":"20","10PeerDist":"76","10PeerSt":"59"},{"ID":"151","Dist":"Waterbury","3LoDist":"30","3LoSt":"35","3PeerDist":"57","3PeerSt":"73","10LoDist":"13","10LoSt":"20","10PeerDist":"53","10PeerSt":"59"},{"ID":"152","Dist":"Waterford","3LoDist":"38","3LoSt":"35","3PeerDist":"75","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"153","Dist":"Watertown","3LoDist":"41","3LoSt":"35","3PeerDist":"70","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"154","Dist":"Westbrook","3LoDist":"0","3LoSt":"35","3PeerDist":"85","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"155","Dist":"West Hartford","3LoDist":"40","3LoSt":"35","3PeerDist":"79","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"156","Dist":"West Haven","3LoDist":"31","3LoSt":"35","3PeerDist":"61","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"157","Dist":"Weston","3LoDist":"0","3LoSt":"35","3PeerDist":"85","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"158","Dist":"Westport","3LoDist":"0","3LoSt":"35","3PeerDist":"85","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"159","Dist":"Wethersfield","3LoDist":"37","3LoSt":"35","3PeerDist":"64","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"160","Dist":"Willington","3LoDist":"0","3LoSt":"35","3PeerDist":"68","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"161","Dist":"Wilton","3LoDist":"0","3LoSt":"35","3PeerDist":"87","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"162","Dist":"Winchester","3LoDist":"58","3LoSt":"35","3PeerDist":"64","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"163","Dist":"Windham","3LoDist":"29","3LoSt":"35","3PeerDist":"84","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"164","Dist":"Windsor","3LoDist":"39","3LoSt":"35","3PeerDist":"72","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"165","Dist":"Windsor Locks","3LoDist":"32","3LoSt":"35","3PeerDist":"67","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"166","Dist":"Wolcott","3LoDist":"51","3LoSt":"35","3PeerDist":"73","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"167","Dist":"Woodbridge","3LoDist":"0","3LoSt":"35","3PeerDist":"80","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"169","Dist":"Woodstock","3LoDist":"0","3LoSt":"35","3PeerDist":"71","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"206","Dist":"Regional Sch Dist 06","3LoDist":"0","3LoSt":"35","3PeerDist":"68","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"210","Dist":"Regional Sch Dist 10","3LoDist":"0","3LoSt":"35","3PeerDist":"82","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"212","Dist":"Regional Sch Dist 12","3LoDist":"0","3LoSt":"35","3PeerDist":"77","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"213","Dist":"Regional Sch Dist 13","3LoDist":"0","3LoSt":"35","3PeerDist":"61","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"214","Dist":"Regional Sch Dist 14","3LoDist":"0","3LoSt":"35","3PeerDist":"63","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"215","Dist":"Regional Sch Dist 15","3LoDist":"0","3LoSt":"35","3PeerDist":"83","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"216","Dist":"Regional Sch Dist 16","3LoDist":"44","3LoSt":"35","3PeerDist":"64","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"},{"ID":"217","Dist":"Regional Sch Dist 17","3LoDist":"0","3LoSt":"35","3PeerDist":"73","3PeerSt":"73","10LoDist":"0","10LoSt":"0","10PeerDist":"0","10PeerSt":"0"}]""")

class SelectWidget

  constructor: (@data) ->

  setChart: (@chart) ->

  draw: (target) ->
    sel = d3.select(target).append('select').attr('id', 'chart_selector')
    sel.selectAll('option.chart_option').data(@data).enter()
      .append('option')
      .classed("chart_option", true)
      .attr('value', (d, i) ->
        return String(i)
      )
      .text((d, i) ->
        d.Dist
      )

window.selectwidget = SelectWidget