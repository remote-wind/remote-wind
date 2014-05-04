$(function () {

    /**
     * Really generic google maps implementation that uses data attributes and good old html
     * to place markers
     */
    (function(){
        var $map_canvas = $('#map_canvas');
        var map;

        $(document).on('google.maps.apiloaded', function(){
            if ($map_canvas.length){
                $map_canvas.trigger('map.init');
            }
        });

        $map_canvas.on('map.init', function(){
            var $markers, $controls, map;
            if ($map_canvas.hasClass("fullscreen")) {
                // poll for window size changes and resize map
                // cause binding a handler to window resize causes performance problems
                $map_canvas.height($(window).innerHeight() - 45);
                window.setInterval(function(){
                    $map_canvas.height($(window).innerHeight() - 45);
                }, 800);

            }

            $markers = $map_canvas.find('.marker').clone();
            $controls = $map_canvas.find('.controls').clone();
            $map_canvas.empty();
            map = new google.maps.Map($map_canvas[0],{
                    center: new google.maps.LatLng($map_canvas.data('lat'), $map_canvas.data('lon')),
                    zoom: 10,
                    mapTypeId: google.maps.MapTypeId.ROADMAP
                });

            if ($controls.length) {
                $map_canvas.trigger('map.add_controls', [map, $controls]);
            }
            if ($markers.length) {
                $map_canvas.trigger('map.add_markers', [map, $markers]);
            }
        });

        $map_canvas.on('map.add_controls', function(event, map, $controls){
            map.controls[google.maps.ControlPosition.LEFT_TOP].push($controls[0]);

            google.maps.event.addDomListener($controls[0], 'click', function(e) {
                map.fitBounds(map.all_markers_bounds);
                e.preventDefault();
            });
        });

        $map_canvas.on('map.add_markers', function(event, map, $markers){

            if ($map_canvas.hasClass("cluster")) {
                map.markerCluster = new MarkerClusterer(map);
            }

            // Define the overlay, derived from google.maps.OverlayView
            function Label(opt_options) {
                // Initialization
                this.setValues(opt_options);
                // Label specific
                this.span_ = document.createElement('div');
                this.span_.setAttribute('class', 'map-label-inner');
                this.div_ = document.createElement('div');
                this.div_.setAttribute('class', 'map-label-outer');
                this.div_.appendChild(this.span_);
                this.div_.style.cssText = 'position: absolute; display: none';
            }
            Label.prototype = new google.maps.OverlayView;

            Label.prototype.onAdd = function() {
                var label = this;
                this.getPanes().overlayLayer.appendChild(this.div_);

                // Ensures the label is redrawn if the text or position is changed.
                this.listeners_ = [
                    google.maps.event.addListener(this, 'position_changed',
                        function() { label.draw(); }),
                    google.maps.event.addListener(this, 'text_changed',
                        function() { label.draw(); })
                ];
            };

            Label.prototype.onRemove = function() {
                this.div_.parentNode.removeChild(this.div_);

                for (var i = 0, I = this.listeners_.length; i < I; ++i) {
                    google.maps.event.removeListener(this.listeners_[i]);
                }
            };

            Label.prototype.draw = function() {
                var position = this.getProjection().fromLatLngToDivPixel(this.get('position'));
                this.div_.style.left = position.x + 'px';
                this.div_.style.top = position.y + 'px';
                this.div_.style.display = 'block';
                this.span_.innerHTML = this.get('text').toString();
            };

            map.all_markers_bounds = new google.maps.LatLngBounds();

            /**
             * Loop through the HTML "markers", extract data and create google.maps.Markers
             */
            $markers.each(function(i, elem){

                var station, measure, marker, label, label_text, beaufort, start_val, hue, $elem = $(elem);

                // Fetch all data attributes from station
                station = $elem.data();

                // default attributes for marker
                marker = {
                    position: new google.maps.LatLng(station.lat, station.lon),
                    title: $elem.find('.title').text(),
                    content: $elem.html(),
                    href: $elem.find('a').attr('href'),
                    zIndex: 50
                };

                if (station.down) {
                    // Configure marker
                    marker = $.extend(marker, {
                        icon: {
                            size: new google.maps.Size(25, 25),
                            origin: new google.maps.Point(20, 20),
                            anchor: new google.maps.Point(23, 23),
                            path: remotewind.icons.station_down,
                            fillColor: 'white',
                            fillOpacity: 0.8,
                            strokeColor: 'black',
                            strokeWeight: 1.2
                        }
                    });

                    label = new Label({
                        map: map,
                        text: marker.title + "<br> Offline"
                    });

                } else {
                    // Fetch all data attributes from  measure
                    measure = $elem.find('.measure').data() || {};
                    measure.direction = parseInt($(this).find('.measure').data('direction'));
                    beaufort = remotewind.util.msToBeaufort(measure.speed || 0);


                    // Configure marker
                    marker = $.extend(marker, {
                        direction: measure.direction,
                        speed: measure.speed,
                        icon: {
                            size: new google.maps.Size(40, 40),
                            origin: new google.maps.Point(20,20),
                            anchor: new google.maps.Point(20, 20),
                            path: remotewind.icons.arrow,
                            fillColor: beaufort.color,
                            fillOpacity: 0.8,
                            strokeColor: 'black',
                            strokeWeight: 1.2,
                            rotation: 180.0 + measure.direction
                        }
                    });

                    label_text = function(m){
                        return m.speed + "(" + m.minSpeed + "-" + m.maxSpeed + ")  m/s"
                    }

                    label = new Label({
                        map: map,
                        text: marker.title + "<br>" + label_text(measure)
                    });
                }

                // Mutate marker args to google.maps.Marker
                marker = new google.maps.Marker( marker );

                // Add marker to map
                if (map.markerCluster) {
                    map.markerCluster.addMarker(marker);
                } else {
                    marker.setMap(map);
                }

                label.bindTo('position', marker, 'position');
                map.all_markers_bounds.extend(marker.position);

                google.maps.event.addListener(marker, 'click', function(){
                    if (marker.href) window.location = marker.href;
                    return false;
                });
            });

            if ($markers.length > 1) {
                map.fitBounds(map.all_markers_bounds);
            }
        });

    }());


    /**
     * Station chart
     */
    (function(){

        var $graph = $('#station_measures_chart');
        $graph.$chart = $graph.find('.chart');
        $graph.$y_axis = $graph.find('.y-axis');
        $graph.$x_axis = $graph.find('.x-axis');

        /**
         * Format measures into stacks for Rickshaw
         * @param series array
         * @param data object
         * @returns array
         */
        function formatSeriesData(series, data) {

            if (data.length) {
                $(data).each(function(k,m){
                    series[0].data.push({
                        x : m.tstamp,
                        y : m.min_wind_speed
                    });
                    series[1].data.push({
                        x : m.tstamp,
                        y : m.speed
                    });
                    series[2].data.push({
                        x : m.tstamp,
                        y : m.max_wind_speed
                    });
                });
            }
            return series;
        }

        $graph.on('graph.data.load', function(){
            $.getJSON($graph.data('path') + '.json', function(data){
                $graph.trigger('graph.render', [data]);
            });
        });

        if ($graph.length) {
            $graph.trigger('graph.data.load');
        }

        $graph.on('graph.render', function(e, data) {
            var graph, time, series, annotator;

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
            ], data);

            $chart_div = $graph.find('.chart');

            time = new Rickshaw.Fixtures.Time();

            // Scale the Scroll Container after the number of measures
            $graph.find('.scroll-contents').width( data.length *  30 );

            graph = new Rickshaw.Graph( {
                element: $graph.$chart[0],
                width: $chart_div.innerWidth() - 20,
                height: $chart_div.innerHeight() - 20,
                renderer: 'line',
                dotSize: 2,
                series: series
            });
            // Custom timescale with 15min "clicks"
            new Rickshaw.Graph.Axis.Time({
                element: $graph.$x_axis[0],
                graph: graph,
                timeUnit: time.unit('15 minute')
            });
            new Rickshaw.Graph.Axis.Y( {
                graph: graph,
                orientation: 'left',
                element: $graph.$y_axis[0],
                tickFormat: function(y){
                    return y + ' m/s'
                }
            });

            // Add direction arrows under x-axis
            annotator = new Rickshaw.Graph.DirectionAnnotate({
                graph: graph,
                element: $graph.find('.timeline')[0]
            });
            if (data.length) {
                $(data).each(function(i,m){
                    annotator.add(m.tstamp, m.direction);
                });
            }
            // Scroll to end of measures
            // Browsers won´t allow scrolling beyond the width of the container anyways
            $graph.find('.scroll-window').scrollLeft(99999999);
            graph.render();
            annotator.update();
        });


    }());
});

