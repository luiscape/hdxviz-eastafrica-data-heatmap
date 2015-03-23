function makeHeatmap(d, div_id, max, color_index) {

  color_range = [{ // white --> green
    min: '#ffffff',
    max: '#16a085'
  }, { // grey --> black
    min: '#bdc3c7',
    max: '#000000'

  }];

  console.log("The color index is: " + color_index);
  if (color_index) {
    var color_set = color_range[color_index];
  } else {
    var color_set = color_range[0];
  };

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

      console.log("Number of indicators: " + json["Indicator"].length);
      // console.log(d);

      var indicators = [];

      function cut(data) {
        indicators.push(data.substring(0, 14) + ' (...)');
      }
      json["Indicator"].forEach(cut);

      $(div_id).highcharts({

        chart: {
          type: 'heatmap',
          marginTop: 80,
          marginBottom: 80,
          marginLeft: 80,
          marginRight: 120,
          height: 2000,
          width: 800,
          reflow: true
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
          title: null,
          categories: indicators,
          title: null,
          opposite: true,
          minPadding: 0,
          maxPadding: 0,
          startOnTick: false,
          endOnTick: false,
          min: 0,
          offset: 0,
          maxPadding: .4,
          max: json["Indicator"].length - 1
        },

        colorAxis: {
          min: 0,
          max: max,
          minColor: color_set.min,
          maxColor: color_set.max
        },

        legend: {
          enabled: true,
          align: 'left',
          layout: 'vertical',
          verticalAlign: 'top',
          margin: 0,
          y: 120,
          symbolHeight: 250,
          style: {
            "color": "contrast",
            "fontSize": "10px",
            "fontWeight": "bold",
            "textShadow": null
          }
        },

        tooltip: {
          formatter: function() {
            return '<b>' + this.point.value + '</b>' + '</b>% of sub-national data is available for <br><i>' + '<b>' + this.series.xAxis.categories[this.point.x] + '</b> on the indicator <br><b>' +
              '<i>' + this.series.yAxis.categories[this.point.y] + '</i>';
          }
        },

        series: [{
          name: 'Data Completeness',
          borderWidth: 5,
          borderRadius: 10,
          borderColor: '#ffffff',
          data: d,
          colsize: 1,
          dataLabels: {
            enabled: false,
            color: '#000000'
          }
        }]

      });
    };
  });
};

function makeHeatmapNational(d, div_id, max, color_index) {

  color_range = [{ // white --> green
    min: '#ffffff',
    max: '#27ae60'
  }, { // red --> green
    min: '#ffffff',
    max: '#d35400'
  }];

  console.log("The color index is: " + color_index);
  if (color_index) {
    var color_set = color_range[color_index];
  } else {
    var color_set = color_range[0];
  };

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

      console.log("Number of indicators: " + json["Indicator"].length);
      // console.log(d);

      $(div_id).highcharts({

        chart: {
          type: 'heatmap',
          marginTop: 80,
          marginBottom: 80,
          marginLeft: 0,
          height: 2000,
          width: 800
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
          opposite: true,
          minPadding: 0,
          maxPadding: 0,
          startOnTick: false,
          endOnTick: false,
          min: 0,
          max: json["Indicator"].length - 1
        },

        colorAxis: {
          min: 0,
          max: max,
          minColor: color_set.min,
          maxColor: color_set.max
        },

        legend: {
          enabled: false,
          align: 'top',
          layout: 'vertical',
          margin: 0,
          verticalAlign: 'top',
          y: 120,
          symbolHeight: 280,
          style: {
            "color": "contrast",
            "fontSize": "10px",
            "fontWeight": "bold",
            "textShadow": null
          }
        },

        tooltip: {
          formatter: function() {
            if (this.point.value === 1) {
              t = " National data<b> available</b> for <br>";
            } else {
              t = " National data<b> not available</b> for <br>";
            };
            return t + '<b>' + this.series.xAxis.categories[this.point.x] + '</b>' +
              '<i> on ' + this.series.yAxis.categories[this.point.y] + '</i>';
          }
        },

        series: [{
          name: 'Data Completeness',
          borderWidth: 5,
          borderRadius: 10,
          borderColor: '#ffffff',
          data: d,
          colsize: 1,
          dataLabels: {
            enabled: false,
            color: '#000000'
          }
        }]

      });
    };
  });
};

makeHeatmap("data/indicator_data_indicator_assessment.json", '#heatmap', 100, 0);
