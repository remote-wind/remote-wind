/**
 * Chart showing station observations
 * @see [rickshaw.js docs](http://code.shutterstock.com/rickshaw/) for more details
 */
$(function(){
    // The actual rickshaw.js graph
    var graph, refresh, $graph, series;

    // Simple implementation that just checks for measures every x seconds
    // time in seconds to check for new observations
    refresh = 60;

    // Cached jQuery selectors
    $graph = $('#station_observations_chart');
    $graph.$chart =     $graph.find('.chart');
    $graph.$y_axis =    $graph.find('.y-axis');
    $graph.$x_axis =    $graph.find('.x-axis');
    $graph.$scroll =    $graph.find('.scroll-contents');
    $graph.$timeline =  $graph.find('.timeline');

    /**
     * Format observations into stacks for Rickshaw
     * @param series array
     * @param data object
     * @returns array
     */
    function formatSeriesData(series, data) {
        if (data.length) {
            $(data).each(function(k,m){
                series[0].data.push({
                    x : Date.parse(m.created_at)/1000,
                    y : m.min_wind_speed
                });
                series[1].data.push({
                    x : Date.parse(m.created_at)/1000,
                    y : m.speed
                });
                series[2].data.push({
                    x : Date.parse(m.created_at)/1000,
                    y : m.max_wind_speed
                });
            });
        }
        return series;
    }

    $graph.on('graph.data.load', function(){
        $.ajax({
            url: $graph.data('path'),
            type: 'GET',
            dataType: 'JSON',
            ifModified: true,
            success: function(data, textStatus, jqXHR){
              $graph.parents('.chart-wrapper').find("alert-box").remove();
              if (textStatus == "notmodified") { 
              } else if (textStatus == "success" && data.length) {
                  $graph.show();
                  $graph.trigger('graph.render', [data]);
              } else {
                 $graph.parents('.chart-wrapper').prepend('<div class="alert-box alert">No recent data available :|</div>')
                 $graph.hide();
              }

              // Read max_age from Cache-Control header
              var max_age = (function(cc) {
                  return parseInt(cc.match(/max-age=(\d*),/).pop());
              }(jqXHR.getResponseHeader('Cache-Control') || refresh));

              // Fetch new observations when max_age has expired
              window.setTimeout(function() {
                  $graph.trigger('graph.data.load');
              }, max_age * 1000);
            }
        });
    });

    $graph.on('graph.render', function(e, data) {
        // These are the values drawn
        series = formatSeriesData([
            {
                name: 'Min Wind Speed',
                color: "#91B4ED",
                data: []
            },
            {
                name: 'Average Wind Speed',
                color: "#3064B8",
                data: []
            },
            {
                name: 'Max Wind Speed',
                color: "#91B4ED",
                data: []
            }
        ], data.reverse() );

        // If already initialized
        if (graph) {
            // Refresh graph data
            $(graph.series).each(function(i){
                graph.series[i] = series[i];
                graph.configure({
                    width: $graph.$chart.innerWidth() - 20,
                    height: $graph.$chart.innerHeight() - 20
                });
            });
        }
        // Create graph and fixtures
        graph = graph || new Rickshaw.Graph( {
            element: $graph.$chart[0],
            renderer: 'line',
            dotSize: 2,
            series: series
        });
        // Scale the Scroll Container after the number of observations
        $graph.$scroll.width( data.length *  30 );
        // Scale chart after number of measures
        graph.configure({
            width: $graph.$chart.innerWidth() - 20,
            height: $graph.$chart.innerHeight() - 20
        });
        graph.time =  graph.time || new Rickshaw.Fixtures.Time();


        // Custom timescale with 15min "clicks"
				var timeAxisUnit = {
				  name: 'custom',
				  seconds: 60*15,
				  formatter: function (d) {
				    return d.toLocaleTimeString().match(/(\d+:\d+):/)[1];
				  }
				}
				
        graph.x_axis = graph.x_axis || new Rickshaw.Graph.Axis.Time({
            element: $graph.$x_axis[0],
            graph: graph,
						timeFixture: new Rickshaw.Fixtures.Time.Local(),
            timeUnit: timeAxisUnit
        });

        graph.y_axis = graph.y_axis || new Rickshaw.Graph.Axis.Y( {
            graph: graph,
            orientation: 'left',
            element: $graph.$y_axis[0],
            tickFormat: function(y){
                return y + ' m/s'
            }
        });

        // Add direction arrows under x-axis
        graph.annotator = graph.annotator || new Rickshaw.Graph.DirectionAnnotate({
            graph: graph,
            element: $graph.find('.timeline')[0]
        });
        $(data).each(function(i,m){
            if(m.direction!= null) graph.annotator.add(Date.parse(m.created_at)/1000, m.direction);
        });

				graph.hoverDetail = graph.hoverDetail || new Rickshaw.Graph.HoverDetail( {
				    graph: graph,
				    xFormatter: function(x) { return new Date(x*1000).toLocaleTimeString()},
				    yFormatter: function(y) { return y + " m/s" }
				} );

        graph.render();
        graph.annotator.update();
        // Scroll to latest observation
        $graph.find('.scroll-window').scrollLeft(999999);
    });

    if ($graph.length) {
        $graph.trigger('graph.data.load');
    }

}());
