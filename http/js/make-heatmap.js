function makeHeatmap(d) {
    d3.json(d, function(err, json) {
        if (err) return (err);

        else {
            countries = Object.getOwnPropertyNames(json);
            countries = countries.splice(1, countries.length);

            // Reshaping data.
            // [a, b, c]
            // a = country
            // b = indicator
            // c = assessment value
            var d = [];
            var ind_index = [];
            for (var i = 0; i != 119; ++i) ind_index.push(i)

            for (i = 0; i < countries.length; i++) {
                c = i;
                v = json[countries[i]];
                for (j = 0; j != 119; j++) {
                    it = [c, ind_index[j], v[j]];
                    d.push(it);
                }
            };

            // console.log(d);

            $('#data-heatmap').highcharts({

                chart: {
                    type: 'heatmap',
                    marginTop: 40,
                    marginBottom: 80,
                    height: 2000
                },

                credits: false,

                title: {
                    text: null
                },

                // load categories
                xAxis: {
                    categories: countries,
                    opposite: true
                },

                // load country list
                yAxis: {
                    categories: json["Indicator"],
                    title: null,
                    minPadding: 0,
                    maxPadding: 0,
                    startOnTick: false,
                    endOnTick: false,
                    min: 0
                },

                colorAxis: {
                    min: 0,
                    max: 100,
                    minColor: '#ffffff',
                    maxColor: '#27ae60'
                },

                legend: {
                    align: 'right',
                    layout: 'vertical',
                    margin: 0,
                    verticalAlign: 'top',
                    y: 120,
                    symbolHeight: 280,
                    style: {"color": "contrast", "fontSize": "11px", "fontWeight": "bold", "textShadow": null }
                },

                tooltip: {
                    formatter: function() {
                        return '<b>' + this.series.xAxis.categories[this.point.x] + '</b> is <br><b>' +
                            this.point.value + '</b>% complete on the indicator <br><b>' + this.series.yAxis.categories[this.point.y] + '</b>';
                    }
                },

                series: [{
                    name: 'Data Completeness',
                    borderWidth: 0,
                    data: d,
                    dataLabels: {
                        enabled: false,
                        color: '#000000'
                        // format: '{z}%',
                    }
                }]

            });
        };
    });
};

makeHeatmap("data/indicator_data_indicator_assessment.json");
