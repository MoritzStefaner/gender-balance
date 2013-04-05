// Generated by CoffeeScript 1.6.1
(function() {
  var Event, Events, initVis, storage,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    _this = this;

  storage = Tabletop.init({
    key: '0AkTjJmB1VuOXdGV1NkRnU1Y4d2pJeHd6Y2wybTZ1ZVE',
    wait: true
  });

  Event = (function(_super) {

    __extends(Event, _super);

    function Event() {
      return Event.__super__.constructor.apply(this, arguments);
    }

    Event.prototype.tabletop = {
      instance: storage,
      sheet: 'collection'
    };

    Event.prototype.sync = Backbone.tabletopSync;

    Event.prototype.initialize = function(o) {
      this.set("numMale", Number(o.nummale));
      this.set("numFemale", Number(o.numfemale));
      this.set("numTotal", Number(o.numfemale) + Number(o.nummale));
      this.set("ratioFemale", Number(o.numfemale / (Number(o.numfemale) + Number(o.nummale))));
      return console.log(this.toJSON());
    };

    return Event;

  })(Backbone.Model);

  Events = (function(_super) {

    __extends(Events, _super);

    function Events() {
      return Events.__super__.constructor.apply(this, arguments);
    }

    Events.prototype.tabletop = {
      instance: storage,
      sheet: 'collection'
    };

    Events.prototype.sync = Backbone.tabletopSync;

    Events.prototype.model = Event;

    return Events;

  })(Backbone.Collection);

  initVis = function() {
    var averageLine, avg, avgTotal, chartHeight, chartWidth, container, d, data, enter, events, h, padding, posScale, svg, totalNumSpeakers, valueScale, w, widthScale, xAxis, y, _i, _len;
    console.log(_this.events);
    data = _this.events.toJSON();
    totalNumSpeakers = d3.sum(data, function(x) {
      return x.numTotal;
    });
    avg = d3.mean(data, function(x) {
      return x.ratioFemale;
    });
    avgTotal = (d3.sum(data, function(x) {
      return x.numFemale;
    })) / totalNumSpeakers;
    svg = d3.select(".chart").append('svg').attr({
      'width': "100%",
      'height': "100%"
    });
    w = $(".chart").width();
    h = $(".chart").height();
    padding = {
      top: 20,
      right: 20,
      bottom: 40,
      left: 20
    };
    chartHeight = h - padding.top - padding.bottom;
    chartWidth = w - padding.left - padding.right;
    widthScale = d3.scale.linear().domain([0, 1]).range([0, 20]);
    posScale = d3.scale.linear().domain([0, totalNumSpeakers]).nice().range([0, chartHeight - data.length]);
    valueScale = d3.scale.linear().domain([0, 1]).nice().range([0, chartWidth]);
    data = _.sortBy(data, function(x) {
      return x.ratioFemale;
    });
    y = 0;
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      d = data[_i];
      d.y = y;
      y += 1 + posScale(d.numTotal);
    }
    console.log(totalNumSpeakers);
    container = svg.append("g").attr({
      "transform": "translate(" + padding.left + ", " + padding.top + ")"
    });
    xAxis = d3.svg.axis().scale(valueScale).tickSize(chartHeight, 0, chartHeight).tickPadding(10).ticks(10).orient("bottom").tickFormat(function(d, i) {
      return "" + (Math.floor(d * 100)) + "%";
    });
    container.append("g").classed({
      "axisLegend x": true
    }).call(xAxis);
    averageLine = container.append("g").classed("averageLine", true).attr({
      transform: "translate(" + (valueScale(avg)) + ", 0)"
    });
    averageLine.append("line").attr({
      x1: 0,
      x2: 0,
      y1: 0,
      y2: chartHeight,
      "stroke-dasharray": "2,2"
    });
    averageLine = container.append("g").classed("averageLine", true).attr({
      transform: "translate(" + (valueScale(avgTotal)) + ", 0)"
    });
    averageLine.append("line").attr({
      x1: 0,
      x2: 0,
      y1: 0,
      y2: chartHeight,
      "stroke-dasharray": "2,2"
    });
    events = container.append("g").selectAll("g.event").data(data);
    enter = events.enter().append("g").classed({
      "event": true
    }).attr({
      "title": function(d) {
        return d.event;
      }
    });
    enter.append("rect").classed("bg", true).attr({
      x: -widthScale(d.ratioFemale) - 1,
      y: 0,
      width: function(d) {
        return widthScale(1);
      },
      height: function(d) {
        return posScale(d.numTotal);
      }
    });
    enter.append("rect").classed("male", true).attr({
      x: 0,
      y: 0,
      width: function(d) {
        return widthScale(1 - d.ratioFemale);
      },
      height: function(d) {
        return posScale(d.numTotal);
      }
    });
    enter.append("rect").classed("female", true).attr({
      x: function(d) {
        return -widthScale(d.ratioFemale) - 1;
      },
      y: 0,
      width: function(d) {
        return widthScale(d.ratioFemale);
      },
      height: function(d) {
        return posScale(d.numTotal);
      }
    });
    enter.append("text").attr({
      x: widthScale(1 - d.ratioFemale) + 8,
      y: 10,
      visibility: function(d) {
        if (posScale(d.numTotal < 20)) {
          return "hidden";
        }
      }
    }).text(function(d) {
      return d.event;
    }).style({
      "stroke": "#FFF",
      "stroke-width": "10px"
    });
    enter.append("text").attr({
      x: widthScale(1 - d.ratioFemale) + 8,
      y: 10,
      visibility: function(d) {
        if (posScale(d.numTotal < 20)) {
          return "hidden";
        }
      }
    }).text(function(d) {
      return d.event;
    });
    return events.attr({
      transform: function(d) {
        return "translate(" + (valueScale(d.ratioFemale)) + ", " + d.y + ")";
      }
    });
  };

  $(function() {
    console.log("* * *");
    _this.events = new Events();
    return _this.events.fetch({
      success: initVis
    });
  });

}).call(this);
