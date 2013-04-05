storage = Tabletop.init
	key: '0AkTjJmB1VuOXdGV1NkRnU1Y4d2pJeHd6Y2wybTZ1ZVE'
	wait: true

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

initVis = =>
	console.log @events
	data = @events.toJSON()

	totalNumSpeakers = d3.sum data, (x) -> x.numTotal
	avg = d3.mean data, (x) -> x.ratioFemale
	avgTotal = (d3.sum data, (x) -> x.numFemale) / totalNumSpeakers

	svg = d3.select(".chart")
		.append('svg')
		.attr(
			'width': "100%"
			'height': "100%"
		)

	w = $(".chart").width()
	h = $(".chart").height()

	padding = 
		top: 20
		right: 20
		bottom: 40
		left: 20

	chartHeight = h-padding.top-padding.bottom
	chartWidth = w-padding.left-padding.right

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
		y += 1+posScale d.numTotal

	

	console.log totalNumSpeakers

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

	container.append("g")
		.classed(
			"axisLegend x": true
		)
		.call(xAxis)

	averageLine = container.append("g")
		.classed("averageLine", true)
		.attr(
			transform: "translate(#{valueScale(avg)}, 0)"
		)

	averageLine.append("line")
		.attr(
			x1: 0
			x2: 0
			y1: 0
			y2: chartHeight
			"stroke-dasharray": "2,2"
		)

	averageLine = container.append("g")
		.classed("averageLine", true)
		.attr(
			transform: "translate(#{valueScale(avgTotal)}, 0)"
		)

	averageLine.append("line")
		.attr(
			x1: 0
			x2: 0
			y1: 0
			y2: chartHeight
			"stroke-dasharray": "2,2"
		)

	events = container.append("g")
		.selectAll("g.event")
		.data(data)
		
	enter = events.enter()
		.append("g")
		.classed(
			"event": true
		)
		.attr(
			"title": (d) -> d.event
		)

	enter.append("rect")
		.classed("bg", true)
		.attr(
			x: -widthScale(d.ratioFemale)-1
			y: 0
			width: (d) -> widthScale 1
			height: (d) -> posScale d.numTotal
		)

	enter.append("rect")
		.classed("male", true)
		.attr(
			x:0
			y:0
			width: (d) -> widthScale 1-d.ratioFemale
			height: (d) -> posScale d.numTotal
		)

	enter.append("rect")
		.classed("female", true)
		.attr(
			x: (d) -> -widthScale(d.ratioFemale)-1
			y: 0
			width: (d) -> widthScale d.ratioFemale
			height: (d) -> posScale d.numTotal
		)

	enter.append("text")
		.attr(
			x: widthScale(1-d.ratioFemale) + 8
			y: 10
			visibility: (d) -> "hidden" if posScale (d.numTotal) < 20
		)
		.text((d)->
			d.event
		)
		.style(
			"stroke": "#FFF"
			"stroke-width": "10px"
		)

	enter.append("text")
		.attr(
			x: widthScale(1-d.ratioFemale) + 8
			y: 10
			visibility: (d) -> "hidden" if posScale (d.numTotal) < 20
		)
		.text((d)->
			d.event
		)


	events
		.attr(
			transform: (d) -> 
				"translate(#{valueScale(d.ratioFemale)}, #{d.y})" 
		)
	
$ => 
	console.log "* * *"
	@events = new Events()
	@events.fetch(
		success: initVis
	)
