// Credit to:
// Basemap https://bl.ocks.org/mbostock/4657115 
// Click-to-zoom https://bl.ocks.org/mbostock/2206590

var width = 800,
    height = 400,
    legendWidth = 15,
    legendHeight = 15,
    centered,
    num;

var blue = "#2166ac",
    red = "#b2182b",
    palette = ['#67001f','#b2182b','#d6604d','#f4a582','#fddbc7','#f7f7f7','#d1e5f0','#92c5de','#4393c3','#2166ac','#053061'];

var color = d3.scale.linear()
      .domain([0, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0])
      .interpolate(d3.interpolateRgb)
      .range(palette);

var tooltipScale = d3.scale.linear()
      .domain([0, 100])
      .range([0, 150]);

var projection = d3.geo.albersUsa()
    .scale(1280)
    .translate([width / 2, height / 2]);

var path = d3.geo.path()
    .projection(projection);

var mapDiv = d3.select("body").append("div").attr("id", "mapDiv");

var svg = mapDiv.append("svg")
    .attr("id", "map")
    .attr("width", width)
    .attr("height", height);

svg.append("rect")
    .attr("class", "background")
    .attr("width", width)
    .attr("height", height)
    .on("click", clicked);

var g = svg.append("g");

var div = d3.select("body").append("div")   
        .attr("class", "tooltip")               
        .style("opacity", 0);

var container = d3.select("body").append("div").attr("id", "container");

container.append("div").attr("id", "left");

container.append("div").attr("id", "right");

d3.select("#right").append("div").attr("class", "slider")
  .append("input")
    .attr("type", "range")
    .attr("id", "mapSlider")
    .attr("min", "1")
    .attr("max", "7")
    .attr("step", "1")
    .attr("value", "1")
    .attr("list", "ticks");

var datalist = d3.select("input#mapSlider").append("datalist")
    .attr("id", "ticks");

datalist.append("option").attr("value", "1");
datalist.append("option").attr("value", "2");
datalist.append("option").attr("value", "3");
datalist.append("option").attr("value", "4");
datalist.append("option").attr("value", "5");
datalist.append("option").attr("value", "6");
datalist.append("option").attr("value", "7");

d3.select("div.slider").append("label")
    .text(" ")
    .style("display", "block")
    .style("text-align", "left")
  .append("span")
    .attr("id", "mapSliderValue");

var g = svg.append("g");

svg.append("g")
  .attr("class", "legendLinear")
  .attr("transform", "translate(20, "+(height+140)+")");

var legendLinear = d3.legend.color()
  .shapeWidth(15)
  .labels(["Rep. 100%", "", "", "", "", "50%", "", "", "", "", "Dem. 100%"])
  .orient('horizontal')
  .title('Voting Party Share')
  .scale(color)
  .cells(11);

svg.select(".legendLinear")
  .call(legendLinear);

d3.selection.prototype.moveToFront = function() { 
    return this.each(function() { 
      this.parentNode.appendChild(this); 
    }); 
  }; 

queue()
    .defer(d3.json, "states.json")
    .defer(d3.json, "districts-clipped.json")
    .await(ready);

function ready(error, us, congress) {
  if (error) throw error;

  num = 1

  svg.append("defs").append("path")
      .attr("id", "land")
      .datum(topojson.feature(us, us.objects.states))
      .attr("d", path);

  svg.append("clipPath")
      .attr("id", "clip-land")
    .append("use")
      .attr("xlink:href", "#land");

  g.append("g")
      .attr("class", "districts")
      .attr("clip-path", "url(#clip-land)")
    .selectAll("path")
      .data(topojson.feature(congress, congress.objects['districts']).features)
    .enter().append("path")
      .attr("d", path)
      .attr("id", function(d,i) { return "districtPath"+i})
      .attr("class", "districtPath")
      .on("click", clicked)
      .style("fill", function(d) {
        return color(d["properties"]["democrat"+num.toString()])
      })
    .on("mouseover", function(d, i) {
      d3.select("#districtPath" + i).moveToFront().transition().duration(300)
      .style("stroke", "black").style("stroke-width", "1px").style("cursor", "pointer");

      div.transition()        
          .duration(200)      
          .style("opacity", 1);

      div.html('<div class="districtName"><b>'+d["properties"]["district"]+'</b></div><br>'+
                '<div class="party"><div class="rep">Rep.</div><div class="dem">Dem.</div><div><br>'+
                '<svg class="square" width="'+tooltipScale(d["properties"]["republican"+num.toString()])+'px" height="10px"><rect width="'+tooltipScale(d["properties"]["republican"+num.toString()])+'px" height="10px" style="fill:'+red+'"><rect></svg>'+
                '<svg class="square" width="'+tooltipScale(d["properties"]["democrat"+num.toString()])+'px" height="10px"><rect width="'+tooltipScale(d["properties"]["democrat"+num.toString()])+'px" height="10px" style="fill:'+blue+'"><rect></svg>'+
                '<div class="percent"><div class="repPercent" style="color:'+red+'">'+d["properties"]["republican"+num.toString()]+'%</div><div class="demPercent" style="color:'+blue+'">'+d["properties"]["democrat"+num.toString()]+'%</div><div>')
          .style("left", (d3.event.pageX - 75) + "px")     
          .style("top", (d3.event.pageY + 20) + "px")    
          .style("text-align", "left");
      })                  
    .on("mouseout", function(d, i) {       
      div.transition()        
          .duration(500)      
          .style("opacity", 0);

      d3.select("#districtPath" + i).moveToFront().transition().style("stroke", "none").style("stroke-width", "0px");
      });

  g.append("path")
      .attr("id", "district-boundaries")
      .datum(topojson.mesh(congress, congress.objects['districts'], function(a, b) { return a !== b && (a.id / 1000 | 0) === (b.id / 1000 | 0); }))
      .attr("d", path);

  g.append("path")
      .attr("id", "state-boundaries")
      .datum(topojson.mesh(us, us.objects.states, function(a, b) { return a !== b; }))
      .attr("d", path);
}

function clicked(d) {
  var x, y, k, opacity;

  if (d && centered !== d) {
    var centroid = path.centroid(d);
    x = centroid[0];
    y = centroid[1];
    k = 2.5;
    centered = d;
    opacity = 0.8;
  } else {
    x = width / 2;
    y = height / 2;
    k = 1;
    centered = null;
    opacity = 0;
  }

  g.selectAll("path")
      .classed("active", centered && function(d) { return d === centered; });

  g.transition()
      .duration(750)
      .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")scale(" + k + ")translate(" + -x + "," + -y + ")")
      .style("stroke-width", 1.5 / k + "px");

  //d3.select("div#container").transition().duration(750).style("background", "rgba(255,255,255, "+opacity+")");//108, 111, 125,
}

d3.select("#mapSlider").on("input", function() {
  num = +this.value
  update(num);
});

update(1);

function update(num) {
  var i;
  for (i = 0; i < 436; i++) {
    d3.select("path#districtPath"+i).transition().duration(300).style("fill", function(d) {
      return color(d["properties"]["democrat"+num.toString()]);
    });
  }

  d3.select("#mapSliderValue").text(function(d) {
    if (num == 1) {
      return '2018 Predictions: Baseline Model';
    } else if (num == 2) {
      return '2018 Predictions: Democrat - Black';
    } else if (num == 3) {
      return '2018 Predictions: Democrat - Hispanic';
    } else if (num == 4) {
      return '2018 Predictions: Democrat - White';
    } else if (num == 5) {
      return '2018 Predictions: Democrat - Other Race';
    } else if (num == 6) {
      return '2018 Predictions: Authoritarianism in Model';
    } else if (num == 7) {
      return '2016 Results';
    }
  });
}

d3.select(self.frameElement).style("height", height + "px");
