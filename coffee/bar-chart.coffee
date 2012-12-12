class BarChart

  old_data: false

  makeChart: (data) ->
    @parse(data)
    @draw()

  parse: (d) ->
    values = []
    for k, v of d #cast any undef/null to "0"
      v = 0 unless v
    values[0] = {current: d['3LoDist'], old: false}
    values[1] = {current:d['3LoSt'], old: false}
    values[2] = {current:d['3PeerDist'], old: false}
    values[3] = {current:d['3PeerSt'], old: false}
    values[4] = {current:d['10LoDist'], old: false}
    values[5] = {current:d['10LoSt'], old: false}
    values[6] = {current:d['10PeerDist'], old: false}
    values[7] = {current:d['10PeerSt'], old: false}
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
    top_label = Math.ceil(d3.max(temp_values) / 5) * 5 #first multiple of 5 above our max data point
    chart_left_margin = 50
    chart_right_margin = 50
    chart_working_height = chart_height - chart_top_margin - chart_bottom_margin
    value_multiple = chart_working_height / d3.max(temp_values)

    #First insert the SVG itself
    svg = d3.select("#bar-chart-target")
      .append("svg")
      .classed("bar_chart", true)
      .attr("width", chart_width)
      .attr("height", chart_height);

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
      .transition()
      .duration(2000)
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
    @rendered(@data)

window.barchart = BarChart
