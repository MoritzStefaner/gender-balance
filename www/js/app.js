// Generated by CoffeeScript 1.6.1
(function() {
  var Event, Events, IDENTICAL, NUM, RATIO, Router, SERIES, TIME, averageLine, averageLine2, averageLine3, avg, avgTotal, calcSizes, chartHeight, chartWidth, data, events, getHeight, getSortFunc, h, initVis, padding, posScale, router, scaling, sortMode, storage, totalNumSpeakers, updatePositions, updateScales, updateVis, valueScale, w, widthScale,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    _this = this;

  storage = Tabletop.init({
    key: '0AkTjJmB1VuOXdGV1NkRnU1Y4d2pJeHd6Y2wybTZ1ZVE',
    wait: true,
    parseNumbers: true,
    simpleSheet: true,
    singleton: true,
    debug: true
  });

  RATIO = "RATIO";

  TIME = "TIME";

  SERIES = "SERIES";

  NUM = "NUM";

  IDENTICAL = "IDENTICAL";

  sortMode = null;

  scaling = null;

  router = null;

  Event = (function(_super) {

    __extends(Event, _super);

    function Event() {
      return Event.__super__.constructor.apply(this, arguments);
    }

    Event.prototype.initialize = function(o) {
      console.log(o);
      this.set("series", o["conferenceseries"]);
      this.set("date", o.year + "-" + o.month);
      this.set("numMale", o.nummale);
      this.set("numFemale", o.numfemale);
      this.set("numTotal", o.numfemale + o.nummale);
      return this.set("ratioFemale", o.numfemale / (o.numfemale + o.nummale));
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

  Router = (function(_super) {

    __extends(Router, _super);

    function Router() {
      var _this = this;
      this.path = function(x) {
        return Router.prototype.path.apply(_this, arguments);
      };
      return Router.__super__.constructor.apply(this, arguments);
    }

    Router.prototype.routes = {
      "*args": "path"
    };

    Router.prototype.path = function(x) {
      sortMode = x.split("/")[0] || RATIO;
      scaling = x.split("/")[1] || NUM;
      console.log(sortMode, scaling);
      router.navigate("" + sortMode + "/" + scaling, {
        trigger: false
      });
      return updateVis();
    };

    return Router;

  })(Backbone.Router);

  w = 0;

  h = 0;

  padding = {};

  chartHeight = 0;

  chartWidth = 0;

  totalNumSpeakers = 0;

  avg = 0;

  avgTotal = 0;

  widthScale = null;

  valueScale = null;

  data = null;

  getHeight = null;

  posScale = null;

  events = null;

  averageLine = null;

  averageLine2 = null;

  averageLine3 = null;

  calcSizes = function() {
    w = $(".chart").width();
    h = $(".chart").height();
    padding = {
      top: 35,
      right: 20,
      bottom: 140,
      left: 20
    };
    chartHeight = h - padding.top - padding.bottom;
    return chartWidth = w - padding.left - padding.right;
  };

  updateScales = function() {
    if (scaling === NUM) {
      posScale = d3.scale.linear().domain([0, totalNumSpeakers]).range([0, chartHeight - data.length - 20]);
      return getHeight = function(d) {
        return posScale(d.numTotal);
      };
    } else {
      posScale = d3.scale.linear().domain([0, data.length]).range([0, chartHeight - data.length - 20]);
      return getHeight = function(d) {
        return posScale(1);
      };
    }
  };

  getSortFunc = function(sortMode) {
    switch (sortMode) {
      case RATIO:
        return function(x) {
          return x.ratioFemale;
        };
      case TIME:
        return function(x) {
          return x.date;
        };
      case SERIES:
        return function(x) {
          return x.series;
        };
      case NUM:
        return function(x) {
          return x.numTotal;
        };
    }
  };

  updatePositions = function() {
    var d, y, _i, _len, _results;
    y = 0;
    _results = [];
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      d = data[_i];
      d.x = valueScale(d.ratioFemale);
      d.y = y + 10;
      d.height = getHeight(d);
      d.labelVisible = d.height > 10;
      _results.push(y += 1 + d.height);
    }
    return _results;
  };

  updateVis = function() {
    var ani, sortFunc;
    updateScales();
    sortFunc = getSortFunc(sortMode);
    data = _.sortBy(data, sortFunc);
    events.order();
    updatePositions();
    d3.select("#scaling").selectAll("a").classed("active", function() {
      return d3.select(this).attr("data-value") === scaling;
    });
    d3.select("#sortMode").selectAll("a").classed("active", function() {
      return d3.select(this).attr("data-value") === sortMode;
    });
    ani = events.transition().duration(500).delay(function(d, i) {
      return d.y + d.x;
    });
    ani.attr({
      transform: function(d) {
        return "translate(" + d.x + ", " + d.y + ")";
      }
    });
    ani.selectAll(".bg").attr({
      height: function(d) {
        return d.height;
      }
    });
    ani.selectAll(".female").attr({
      height: function(d) {
        return d.height;
      }
    });
    ani.selectAll(".male").attr({
      height: function(d) {
        return d.height;
      }
    });
    ani.selectAll(".male").attr({
      height: function(d) {
        return d.height;
      }
    });
    return ani.selectAll("text").attr({
      opacity: function(d) {
        if (d.labelVisible) {
          return 1;
        } else {
          return 0;
        }
      }
    });
  };

  initVis = function() {
    var container, enter, textGroup, xAxis;
    console.log(_this.events);
    data = _this.eventsData.toJSON();
    totalNumSpeakers = d3.sum(data, function(x) {
      return x.numTotal;
    });
    avg = d3.mean(data, function(x) {
      return x.ratioFemale;
    });
    avgTotal = (d3.sum(data, function(x) {
      return x.numFemale;
    })) / totalNumSpeakers;
    _this.svg = d3.select(".chart").append("svg").attr({
      width: "100%",
      height: "100%"
    });
    calcSizes();
    widthScale = d3.scale.linear().domain([0, 1]).range([0, 20]);
    valueScale = d3.scale.linear().domain([0, 1]).nice().range([0, chartWidth]);
    container = svg.append("g").attr({
      "transform": "translate(" + padding.left + ", " + padding.top + ")"
    });
    xAxis = d3.svg.axis().scale(valueScale).tickSize(chartHeight, 0, chartHeight).tickPadding(10).ticks(10).orient("bottom").tickFormat(function(d, i) {
      return "" + (Math.floor(d * 100)) + "%";
    });
    d3.select("#average1").text("" + (Math.floor(avg * 1000) / 10.0) + "%");
    averageLine = container.append("g").classed("averageLine", true).attr({
      transform: "translate(" + (valueScale(avg)) + ", " + (chartHeight + 135) + ")"
    });
    averageLine.append("line").attr({
      x1: 0,
      x2: 0,
      y1: 0,
      y2: -110
    });
    averageLine.append("text").attr({
      x: 5
    }).text("Average proportion of female speakers per conference");
    averageLine.append("text").classed("percentage", true).attr({
      x: 5,
      y: -15
    }).text(Math.floor(avg * 1000) / 10.0 + "%");
    d3.select("#average2").text("" + (Math.floor(avgTotal * 1000) / 10.0) + "%");
    averageLine2 = container.append("g").classed("averageLine", true).attr({
      transform: "translate(" + (valueScale(avgTotal)) + ", " + (chartHeight + 110) + ")"
    });
    averageLine2.append("line").attr({
      x1: 0,
      x2: 0,
      y1: 0,
      y2: -90
    });
    averageLine2.append("text").attr({
      x: 5
    }).text("Overall proportion of female speakers");
    averageLine2.append("text").classed("percentage", true).attr({
      x: 5,
      y: -15
    }).text(Math.floor(avgTotal * 1000) / 10.0 + "%");
    averageLine3 = container.append("g").classed("averageLine target", true).attr({
      transform: "translate(" + (valueScale(.2307)) + ", " + (chartHeight + 70) + ")"
    });
    averageLine3.append("line").attr({
      x1: 0,
      x2: 0,
      y1: 0,
      y2: -50
    });
    averageLine3.append("text").attr({
      x: 5
    }).text("Proportion of women in datavisualization");
    averageLine3.append("text").classed("percentage", true).attr({
      x: 5,
      y: -15
    }).text(Math.floor(.2307 * 1000) / 10.0 + "%");
    container.append("rect").attr({
      x: -padding.left - 3,
      y: -padding.top,
      width: w + 6,
      height: padding.top - 5
    }).classed("legendBorder", true);
    container.append("rect").attr({
      x: -padding.left - 3,
      y: chartHeight - 1,
      width: w + 6,
      height: 30
    }).classed("legendBorder", true);
    container.append("g").classed({
      "axisLegend x": true
    }).call(xAxis).selectAll("line").attr({
      "stroke-dasharray": "1,3"
    });
    container.append("text").attr({
      x: -20 + valueScale(0),
      y: -15
    }).classed("male legend", true).text("Only male speakers");
    container.append("text").attr({
      x: 20 + valueScale(1),
      y: -15,
      "text-anchor": "end"
    }).classed("female legend", true).text("Only female speakers");
    container.append("text").attr({
      x: valueScale(.5),
      y: -15,
      "text-anchor": "middle"
    }).classed("legend", true).text("Equal mixture");
    events = container.append("g").selectAll("g.event").data(data, function(d) {
      return d.event;
    }).sort(function(a, b) {
      if (sortFunc(a) > sortFunc(b)) {
        1;
      }
      if (sortFunc(b) > sortFunc(b)) {
        -1;
      }
      if (a.event > b.event) {
        1;
      }
      if (a.event < b.event) {
        -1;
      }
      return 0;
    });
    enter = events.enter().append("g").classed({
      "event": true
    }).attr({
      "title": function(d) {
        return "<div class=\"year\">" + d.year + "</div>\n<div><span class=\"title\">" + d.event + "</span><div>\n\n<div><span class=\"numFemale\">" + d.numFemale + "</span> female speakers<div>\n<div><span class=\"numMale\">" + d.numMale + "</span> male speakers<div>";
      }
    });
    enter.attr({
      transform: function(d) {
        return "translate(-200, " + d.y + ")";
      }
    });
    enter.append("rect").classed("bg", true).attr({
      x: -widthScale(.5),
      y: 0,
      width: function(d) {
        return widthScale(1);
      }
    });
    enter.append("rect").classed("male", true).attr({
      x: function(d) {
        return -widthScale(.5) - 1;
      },
      y: 0,
      width: function(d) {
        return widthScale(1 - d.ratioFemale);
      }
    });
    enter.append("rect").classed("female", true).attr({
      x: function(d) {
        return -widthScale(.5) + widthScale(1 - d.ratioFemale);
      },
      y: 0,
      width: function(d) {
        return widthScale(d.ratioFemale);
      }
    });
    textGroup = enter.append("g").classed("label", true).attr({
      transform: "translate(" + (widthScale(.5) + 5) + ", " + 11 + ")"
    });
    textGroup.append("text").text(function(d) {
      return d.event;
    }).style({
      "stroke": "#FFF",
      "stroke-width": "2px"
    });
    textGroup.append("text").text(function(d) {
      return d.event;
    });
    updateVis();
    events.style("cursor", "pointer");
    events.each(function() {
      return $(this).qtip({
        content: true,
        position: {
          my: "left center",
          at: "right center",
          target: "mouse",
          adjust: {
            x: 5,
            y: 0
          }
        },
        style: {
          classes: 'qtip-light'
        }
      });
    });
    d3.select("#sortMode").selectAll("a").on("click", function(d) {
      sortMode = d3.select(this).attr("data-value");
      return router.navigate("" + sortMode + "/" + scaling, {
        trigger: true
      });
    });
    d3.select("#scaling").selectAll("a").on("click", function(d) {
      scaling = d3.select(this).attr("data-value");
      return router.navigate("" + sortMode + "/" + scaling, {
        trigger: true
      });
    });
    return _this;
  };

  $(function() {
    console.log("* * *");
    router = new Router();
    _this.eventsData = new Events();
    _this.eventsData.fetch({
      success: function() {
        initVis();
        return Backbone.history.start();
      }
    });
    return $("a").each(function() {
      var _ref;
      if (((_ref = $(this).attr("href")) != null ? _ref.indexOf("#") : void 0) === 0) {
        return $(this).click(function() {
          return $("html, body").animate({
            scrollTop: "0px"
          });
        });
      }
    });
  });

}).call(this);
