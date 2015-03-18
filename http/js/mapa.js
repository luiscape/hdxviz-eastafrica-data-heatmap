(function() {
    // This is left outside because d3.json is asyncrhonous.
    // If we leave these parameters outside, the page will load
    // them and then load the SVG. Otherwise, the geometry will only
    // be loaded after d3.json is ready, possibly causing 'page reflow'.
    var width = 450,
        height = 600;

    // Create a projection object. Among its attributes:
    // a type of projection (`mercator`), a scale, the center point,
    // size (i.e. translation).
    var projection = d3.geo.mercator()
        .scale(5000)
        .center([0, 0])
        .translate([width / 2, height / 2]);

    // Create the SVG and determine its area.
    var svg = d3.selectAll("#mapa")
        .append("svg")
        .attr("width", width)
        .attr("height", height);

    // Create a path generator.
    var path = d3.geo.path()
        .projection(projection);

    var tip = d3.tip()
        .attr('class', 'd3-tip')
        .offset([-10, 0])
        .html(function(d) {
            return "<strong>Frequency:</strong> <span style='color:red'>" + d.frequency + "</span>";
        });

    svg.call(tip);

    // Loading json
    d3.json("data/geo/ce_niv3.json", function(error, json) {

        // Extracting the data from the topoJSON
        console.log(json)
        var ce = json;
        var c = d3.geo.centroid(ce); // calculating the centroid
        // Update the projection to use computed scale & translate.
        projection
            .center(c);

        // Adding
        svg.append("path")
            .datum(ce)
            .attr("d", path)
            .attr("class", "boundary");

        svg.append("path")
            .datum(ce)
            .attr("d", path)
            .attr("class", "intra-boundary")
            .on('mouseover', tip.show)
            .on('mouseout', tip.hide);

        // svg.append("path")
        //     .datum(topojson.mesh(json, json.features, function(a, b) {
        //         return a === b;
        //     }))
        //     .attr("d", path)
        //     .attr("class", "state-boundary");

        // Debuging
        console.log("Centroid: " + c);

    });
})();
