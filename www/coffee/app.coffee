storage = Tabletop.init
	key: '0AkTjJmB1VuOXdGV1NkRnU1Y4d2pJeHd6Y2wybTZ1ZVE'
	wait: true
	parseNumbers: true
	#proxy: "http://gender-balance.local/data/"
	simpleSheet: true
	singleton: true
	debug: false

RATIO = "RATIO"
TIME = "TIME"
SERIES = "SERIES"
NUM = "NUM"
IDENTICAL = "IDENTICAL"

sortMode = null
scaling = null

router = null

# -----------------------------------

class Event extends Backbone.Model
	initialize: (o)->
		@.set "series", o["conferenceseries"]
		@.set "date", o.year + "-" + o.month
		@.set "numMale", o.nummale
		@.set "numFemale", o.numfemale
		@.set "numTotal", o.numfemale + o.nummale
		@.set "ratioFemale", o.numfemale/(o.numfemale + o.nummale)

class Events extends Backbone.Collection
	tabletop:
          instance: storage
          sheet: 'collection'
	sync: Backbone.tabletopSync
	model: Event

class Router extends Backbone.Router
	routes: 
		"*args": "path"

	path: (x) =>
		sortMode = x.split("/")[0] || RATIO
		scaling = x.split("/")[1] || NUM
		router.navigate("#{sortMode}/#{scaling}", 
			trigger: false
		)
		updateVis()

# -----------------------------------

w = 0
h = 0
padding = {}
chartHeight = 0
chartWidth = 0

totalNumSpeakers = 0
avg = 0
avgTotal = 0

widthScale = null
valueScale = null

data = null

getHeight = null
posScale = null

events = null

averageLine = null
averageLine2 = null
averageLine3 = null

nicePercent = (x) ->
	"#{(x*100).toFixed(1)}%"

calcSizes = () ->
	w = $(".chart").width()
	h = $(".chart").height()

	padding = 
		top: 35
		right: 20
		bottom: 160
		left: 20

	chartHeight = h - padding.top  - padding.bottom
	chartWidth  = w - padding.left - padding.right

updateScales = () ->
	if scaling is NUM
		posScale = d3.scale.linear()
			.domain([0, totalNumSpeakers])
			.range([0, chartHeight-data.length-20])
		getHeight = (d) ->
			posScale d.numTotal
	else	
		posScale = d3.scale.linear()
			.domain([0, data.length])
			.range([0, chartHeight-data.length-20])
		getHeight = (d) ->
			posScale 1
	

sortFunc = (a,b) ->
	switch sortMode
		when RATIO  	
			if a.ratioFemale > b.ratioFemale then return 1
			if a.ratioFemale < b.ratioFemale then return -1
			if a.series > b.series then return 1
			if a.series < b.series then return -1
			if a.date > b.date then return 1
			if a.date < b.date then return -1
			0
		when TIME  
			if a.date > b.date then return 1
			if a.date < b.date then return -1
			if a.event > b.event then return 1
			if a.event < b.event then return -1
			0
		when SERIES
			if a.series > b.series then return 1
			if a.series < b.series then return -1
			if a.date > b.date then return 1
			if a.date < b.date then return -1
			if a.event > b.event then return 1
			if a.event < b.event then return -1
			0
		when NUM
			if a.numTotal > b.numTotal then return 1
			if a.numTotal < b.numTotal then return -1
			if a.date > b.date then return 1
			if a.date < b.date then return -1
			if a.event > b.event then return 1
			if a.event < b.event then return -1
			0

updatePositions = () ->
	y = 0
	for d in data
		d.x = valueScale(d.ratioFemale)
		d.y = y + 10
		d.height =  getHeight d
		
		d.labelVisible = d.height>10
		y += 1 + d.height


updateVis = () =>
	updateScales()
	data = data.sort(sortFunc)
	updatePositions()

	# averageLine
	# 	.transition()
	# 	.duration(500)
	# 	.style("opacity", ()->
	# 		if scaling is NUM then 0 else 1
	# 	)

	# averageLine2
	# 	.transition()
	# 	.duration(500)
	# 	.style("opacity", ()->
	# 		if scaling is NUM then 1 else 0
	# 	)

	d3
		.select("#scaling")
		.selectAll("a")
		.classed("active", ()->
			d3.select(@).attr("data-value") is scaling
		)

	d3
		.select("#sortMode")
		.selectAll("a")
		.classed("active", ()->
			d3.select(@).attr("data-value") is sortMode
		)

	ani = events
		.transition()
		.duration(500)
		.delay((d,i)->
			d.y + d.x
		)
	
	ani.attr(
		transform: (d) -> 
			"translate(#{d.x}, #{d.y})" 
	)
		

	ani
		.selectAll(".bg")
		.attr(
			height: (d) -> d.height 
		)

	ani
		.selectAll(".female")
		.attr(
			height: (d) -> d.height 
		)

	ani
		.selectAll(".male")
		.attr(
			height: (d) -> d.height 
		)

	ani
		.selectAll(".male")
		.attr(
			height: (d) -> d.height 
		)

	ani
		.selectAll("text")
		.attr(
			opacity: (d) -> if d.labelVisible then 1 else 0
		)


initVis = () =>

	data = @eventsData.toJSON()

	totalNumSpeakers = d3.sum data, (x) -> x.numTotal
	avg = d3.mean data, (x) -> x.ratioFemale
	avgTotal = (d3.sum data, (x) -> x.numFemale) / totalNumSpeakers

	@svg = d3.select(".chart")
		.append("svg")
		.attr(
			width: "100%"
			height: "100%"
		)
	calcSizes()
	
	widthScale = d3.scale.linear()
		.domain([0, 1])
		.range([0, 20])

	valueScale = d3.scale.linear()
		.domain([0, 1])
		.nice()
		.range([0, chartWidth])


	container = svg.append("g")
		.attr(
			"transform": "translate(#{padding.left}, #{padding.top})"
		)

	xAxis = d3.svg.axis()
		.scale(valueScale)
		.tickSize(chartHeight-3)
		.tickPadding(13)
		.ticks(if w>600 then 10 else 5)
		.orient("bottom")
		.tickFormat((d,i) ->
			"#{Math.floor(d*100)}%"
		)

	d3.select("#average1").text(nicePercent avg)

	averageLine = container.append("g")
		.classed("averageLine", true)
		.attr(
			transform: "translate(#{valueScale(avg)}, #{chartHeight + 150})"
		)

	averageLine.append("line")
		.attr(
			x1: 0
			x2: 0
			y1: 0
			y2: -130
			#"stroke-dasharray": "2,2"
		)

	averageLine.append("text")
		.attr(
			x: 5
		)
		.text("Average proportion of female speakers per conference")

	averageLine.append("text")
		.classed("percentage", true)
		.attr(
			x: 5
			y: -15
		)
		.text(nicePercent avg)

	d3.select("#average2").text(nicePercent avgTotal)

	averageLine2 = container.append("g")
		.classed("averageLine", true)
		.attr(
			transform: "translate(#{valueScale(avgTotal)}, #{chartHeight + 110})"
		)

	averageLine2.append("line")
		.attr(
			x1: 0
			x2: 0
			y1: 0
			y2: -90
			# "stroke-dasharray": "2,2"
		)

	averageLine2.append("text")
		.attr(
			x: 5
			
		)
		.text("Overall proportion of female speakers")


	averageLine2.append("text")
		.classed("percentage", true)
		.attr(
			x: 5
			y: -15
		)
		
		.text(nicePercent avgTotal)

	averageLine3 = container.append("g")
		.classed("averageLine target", true)
		.attr(
			transform: "translate(#{valueScale(.2307)}, #{chartHeight + 70})"
		)

	averageLine3.append("line")
		.attr(
			x1: 0
			x2: 0
			y1: 0
			y2: -50
			# "stroke-dasharray": "2,2"
		)

	averageLine3.append("text")
		.attr(
			x: 5
			
		)
		.text("Proportion of women in datavisualization")

	averageLine3.append("text")
		.classed("percentage", true)
		.attr(
			x: 5
			y: -15
		)
		.text(nicePercent .2307)

	container.append("rect")	
		.attr(
			x: -padding.left-3
			y: -padding.top-1
			width: w+6
			height: padding.top-5
		)
		.classed("legendBorder", true)

	container.append("rect")	
		.attr(
			x: -padding.left-3
			y: chartHeight-1
			width: w+6
			height: 30
		)
		.classed("legendBorder", true)
	
	container.append("g")
		.classed(
			"axisLegend x": true
		)
		.call(xAxis)
		.selectAll("line")
		.attr(
			
			"stroke-dasharray": "1,3"
		)

	container.append("text")	
		.attr(
			x: -20 + valueScale 0
			y: -15
		)
		.classed("male legend", true)
		.text("Only male speakers")

	container.append("text")	
		.attr(
			x: 20 + valueScale 1
			y: -15
			"text-anchor": "end"
		)

		.classed("female legend", true)
		.text("Only female speakers")

	container.append("text")	
		.attr(
			x: valueScale .5
			y: -15
			"text-anchor": "middle"
		)
		.classed("legend", true)
		.text("Equal mixture")

	events = container.append("g")
		.selectAll("g.event")
		.data(data, (d) -> d.event)	


	enter = events.enter()
		.append("g")
		.classed(
			"event": true
		)
		
		.attr(
			"title": (d) -> 
				"""
					<table>
						
						<tr >
							<td class="titleCell" rowspan="2">
								<div class="year">#{d.year}</div>
								<div class="title">#{d.event}</div>
							</td>
							<td class="numbers">
								<span class="numFemale">#{d.numFemale}</span>
							</td>
							<td class="labels">
								female speakers
							</td>
						</tr>
						<tr>
							<td class="numbers">
								<span class="numMale">#{d.numMale}</span>
							</td>
							<td class="labels">
								male speakers
							</td>
						</tr>
					</table>
				"""
		)

	enter.attr(
		transform: (d) -> 
			"translate(-200, #{d.y})" 
	)

	enter.append("rect")
		.classed("bg", true)
		.attr(
			x: -widthScale(.5)
			y: 0
			width: (d) -> widthScale 1
		)

	enter.append("rect")
		.classed("male", true)
		.attr(
			x: (d) -> -widthScale(.5) - 1
			y: 0
			width: (d) -> widthScale(1-d.ratioFemale)
	)
	
	enter.append("rect")
		.classed("female", true)
		.attr(
			x: (d) -> - widthScale(.5)  + widthScale(1-d.ratioFemale)
			y: 0
			width: (d) -> widthScale d.ratioFemale
		)

	textGroup = enter
		.append("g")
		.classed("label", true)
		.attr(
			transform: "translate(#{widthScale(.5) + 5}, #{11})"
		)

	textGroup.append("text")
		.text((d)->
			d.event
		)
		.style(
			"stroke": "#FFF"
			"stroke-width": "2px"
		)

	textGroup.append("text")
		.text((d)->
			d.event
		)

	updateVis()
	events.style("cursor", "pointer")
	events.each(() ->
		$(@).qtip(
			content: true
			position:
				my: "left bottom"
				at: "right center"
				target: "mouse"
				adjust:
					x:  5
					y:  0
			style:
				classes: 'qtip-light'
		)
	)

	events.on("click", (d)->
		window.open(d.url) unless !d.url
	)


	# events.on("mouseover", (d)->
	# 	sameSeries = _.filter(data, (x) -> x.series is d.series)
	# 	if sameSeries?.length>1
	# 		events
	# 		.transition()
	# 		.delay(500)
	# 		.duration(500)
	# 		.style("opacity", (x)->
	# 			if x.series is d.series then 1 else 0.4
	# 		)
	# 	else 
	# 		events.style("opacity", 1)
	# )

	# events.on("mouseout", (d)->
	# 	sameSeries = _.filter data, (x) -> x.series is d.series
	# 	if sameSeries?.length>1
	# 		events
	# 		.transition().duration(250)
	# 		.style("opacity", 1)
	# )

	d3
		.select("#sortMode")
		.selectAll("a")
		.on("click", (d)->
			 
			sortMode = d3.select(@).attr "data-value"
			router.navigate("#{sortMode}/#{scaling}",
				trigger: true
			)
		)
	d3
		.select("#scaling")
		.selectAll("a")
		.on("click", (d)->
			scaling = d3.select(@).attr "data-value"
			router.navigate("#{sortMode}/#{scaling}",
				trigger: true
			)
		)
	@


$ => 

	router = new Router()
	
	@eventsData = new Events()
	@eventsData.fetch(
		success: () =>
			initVis()
			Backbone.history.start()
	)

	$("a").each(()->
		if $(@).attr("href")?.indexOf("#") is 0
			$(@).click(()->
				$("html, body").animate(
					scrollTop: "0px"
				)
			)
		)
	
	
