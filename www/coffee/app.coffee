storage = Tabletop.init
	key: '0AkTjJmB1VuOXdGV1NkRnU1Y4d2pJeHd6Y2wybTZ1ZVE'
	wait: true

# -----------------------------------

class Event extends Backbone.Model
	tabletop:
		instance: storage
		sheet: 'collection'
	sync: Backbone.tabletopSync
	initialize: (o)->
		@.set "numMale", Number(o.nummale)
		@.set "numFemale", Number(o.numfemale)
		@.set "numTotal", Number(o.numfemale) + Number(o.nummale)
		@.set "ratioFemale", Number(o.numfemale/(Number(o.numfemale) + Number(o.nummale)))
		console.log @.toJSON()

class Events extends Backbone.Collection
	tabletop:
          instance: storage
          sheet: 'collection'
	sync: Backbone.tabletopSync
	model: Event

# -----------------------------------

initVis = =>
	console.log @events
	data = @events.toJSON()

	totalNumSpeakers = d3.sum data, (x) -> x.numTotal
	avg = d3.mean data, (x) -> x.ratioFemale
	avgTotal = (d3.sum data, (x) -> x.numFemale) / totalNumSpeakers

	svg = d3.select(".chart")
		.append("svg")
		.attr(
			width: "100%"
			height: "100%"
		)

	w = $(".chart").width()
	h = $(".chart").height()

	padding = 
		top: 35
		right: 20
		bottom: 140
		left: 20

	chartHeight = h - padding.top  - padding.bottom
	chartWidth  = w - padding.left - padding.right

	widthScale = d3.scale.linear()
		.domain([0, 1])
		.range([0, 20])

	posScale = d3.scale.linear()
		.domain([0, totalNumSpeakers])
		.nice()
		.range([0, chartHeight-data.length])

	valueScale = d3.scale.linear()
		.domain([0, 1])
		.nice()
		.range([0, chartWidth])

	data = _.sortBy data, (x) -> x.ratioFemale

	y = 0
	for d in data
		d.y = y
		y += 1 + posScale d.numTotal

	container = svg.append("g")
		.attr(
			"transform": "translate(#{padding.left}, #{padding.top})"
		)

	xAxis = d3.svg.axis()
		.scale(valueScale)
		.tickSize(chartHeight,0,chartHeight)
		.tickPadding(10)
		.ticks(10)
		.orient("bottom")
		.tickFormat((d,i) ->
			"#{Math.floor(d*100)}%"
		)

	

	averageLine = container.append("g")
		.classed("averageLine", true)
		.attr(
			transform: "translate(#{valueScale(avg)}, #{chartHeight + 130})"
		)

	averageLine.append("line")
		.attr(
			x1: 0
			x2: 0
			y1: 0
			y2: -110
			#"stroke-dasharray": "2,2"
		)

	averageLine.append("text")
		.attr(
			x: 5
		)
		.text("Average ratio of women speakers at a conference")

	averageLine2 = container.append("g")
		.classed("averageLine", true)
		.attr(
			transform: "translate(#{valueScale(avgTotal)}, #{chartHeight + 100})"
		)

	averageLine2.append("line")
		.attr(
			x1: 0
			x2: 0
			y1: 0
			y2: -80
			# "stroke-dasharray": "2,2"
		)

	averageLine2.append("text")
		.attr(
			x: 5
		)
		.text("Overall average of female speakers")

	averageLine3 = container.append("g")
		.classed("averageLine target", true)
		.attr(
			transform: "translate(#{valueScale(.25)}, #{chartHeight + 70})"
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
		.text("Percentage of women in datavisualization (*)")

	# averageLine4 = container.append("g")
	# 	.classed("averageLine target thin", true)
	# 	.attr(
	# 		transform: "translate(#{valueScale(.495)}, #{chartHeight + 70})"
	# 	)

	# averageLine4.append("line")
	# 	.attr(
	# 		x1: 0
	# 		x2: 0
	# 		y1: 0
	# 		y2: -50
	# 		# "stroke-dasharray": "2,2"
	# 	)

	# averageLine4.append("text")
	# 	.attr(
	# 		x: 5
	# 	)
	# 	.text("Percentage of women in population")

	container.append("rect")	
		.attr(
			x: -padding.left-3
			y: -padding.top
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
			x: -10 + valueScale 0
			y: -15
		)
		.classed("male legend", true)
		.text("Only male speakers")

	container.append("text")	
		.attr(
			x: 10 + valueScale 1
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
		.data(data)
		
	enter = events.enter()
		.append("g")
		.classed(
			"event": true
		)
		.attr(
			"title": (d) -> 
				"""
					<div><span class="title">#{d.event}</span><div>
					<div><span class="numFemale">#{d.numFemale}</span> female speakers<div>
					<div><span class="numMale">#{d.numMale}</span> male speakers<div>
				"""
		)

	enter.append("rect")
		.classed("bg", true)
		.attr(
			x: -widthScale(.5)
			y: 0
			width: (d) -> widthScale 1
			height: (d) -> posScale d.numTotal
		)

	enter.append("rect")
		.classed("male", true)
		.attr(
			x: (d) -> -widthScale(.5) - 1
			y: 0
			width: (d) -> widthScale(1-d.ratioFemale)
			height: (d) -> posScale d.numTotal
	)
	
	enter.append("rect")
		.classed("female", true)
		.attr(
			x: (d) -> - widthScale(.5)  + widthScale(1-d.ratioFemale)
			y: 0
			width: (d) -> widthScale d.ratioFemale
			height: (d) -> posScale d.numTotal
		)
		

	enter.append("text")
		.attr(
			x: widthScale(.5) + 5
			y: 8
			visibility: (d) -> "hidden" if posScale (d.numTotal) < 20
		)
		.text((d)->
			d.event
		)
		.style(
			"stroke": "#FFF"
			"stroke-width": "8px"
		)

	enter.append("text")
		.attr(
			x: widthScale(.5) + 5
			y: 8
			visibility: (d) -> "hidden" if posScale (d.numTotal) < 18
		)
		.text((d)->
			d.event
		)


	events
		.attr(
			transform: (d) -> 
				"translate(#{valueScale(d.ratioFemale)}, #{d.y+20})" 
		)
		.style("cursor", "pointer")
	
	events.each(() ->
		console.log @
		$(@).qtip(
			content: true
			position:
				my: "left center"
				at: "right center"
				target: "mouse"
				adjust:
					x:  5
					y:  0
			style:
				classes: 'qtip-light'
		)
	)
	@
$ => 
	console.log "* * *"
	@events = new Events()
	@events.fetch(
		success: initVis
	)
