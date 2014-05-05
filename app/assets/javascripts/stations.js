jQuery(function($){
    var $doc = $(document), $map_canvas = $('#map_canvas'), $menu = $('#left-off-canvas-menu').find('.off-canvas-list');

    $doc.on('load.stations', function(){
        $.getJSON('/stations', function(data){
            $menu.trigger('stations.loaded', [data]);
            $map_canvas.trigger('stations.loaded', [data]);
        });
    });

    if ($map_canvas.length) {
        $doc.trigger('load.stations');
    }

    /**
     * Load stations
     */
    (function(){
        // Populate off-canvas menu with stations
        $menu.one('stations.loaded', function(event, data){
            $(data).each(function(i, obj){
                $menu.append('<li><a href="'+ obj.href +'">'+obj.name+'</a></li>');
            });
        });

        $('.left-off-canvas-toggle').one('click', function(){
            $doc.trigger('load.stations');
        });
    }());

    /**
     * Use JSON data to create station markers on google map
     */
    (function(){
        var map, data_store;

        $doc.on('google.maps.apiloaded', function(){
            if ($map_canvas.length){
                $map_canvas.trigger('map.init');
            }
        });

        $doc.on('stations.loaded', function(e, data){
            // Handle case when stations data is loaded before google maps api
            if (!map) {
                data_store = data;
            } else if (data.length) {
                $map_canvas.trigger('map.add_markers', [data]);
            }
        });

        $map_canvas.on('map.init', function(e, stations){
            var $controls = $map_canvas.find('.controls').clone();
            $map_canvas.empty();

            // poll for window size changes and resize map
            if ($map_canvas.hasClass("fullscreen")) {
                // cause binding a handler to window resize causes performance problems
                $map_canvas.height($(window).innerHeight() - 45);
                window.setInterval(function(){
                    $map_canvas.height($(window).innerHeight() - 45);
                }, 800);

            }

            map = new google.maps.Map($map_canvas[0],{
                center: new google.maps.LatLng(63.399313, 13.082236),
                zoom: 10,
                mapTypeId: google.maps.MapTypeId.ROADMAP
            });

            if ($map_canvas.hasClass("cluster")) {
                map.markerCluster = new MarkerClusterer(map);
            }

            if ($controls.length) {
                $map_canvas.trigger('map.add_controls', [map, $controls]);
            }

            // In case stations data was loaded before map is ready
            if (data_store && data_store.length) {
                $map_canvas.trigger('map.add_markers', [map, data_store]);
            }

        });

        $map_canvas.on('map.add_controls', function(event, map, $controls){
            map.controls[google.maps.ControlPosition.LEFT_TOP].push($controls[0]);

            google.maps.event.addDomListener($controls[0], 'click', function(e) {
                map.fitBounds(map.stations_bounds);
                e.preventDefault();
            });
        });

        $map_canvas.on('map.add_markers', function(event, map, stations){
            if (map && stations.length) {
                // Bounds fitting all the stations in view
                map.stations_bounds = new google.maps.LatLngBounds();

                $.each(stations, function(i, station){
                    var marker, label;
                    marker = stationMarkerFactory(station);
                    label = labelFactory(map, station);

                    if (map.markerCluster) {
                        map.markerCluster.addMarker(marker);
                    } else {
                        marker.setMap(map);
                    }
                    map.stations_bounds.extend(marker.position);
                    label.bindTo('position', marker, 'position');
                });

                if (stations.length > 1) {
                    map.fitBounds(map.stations_bounds);
                }
            }
        });


        /**
         * Factory to create labels
         * @param station Object
         */
        function labelFactory(map, station) {

            var text;

            /**
             * Constructor for overlay, derived from google.maps.OverlayView
             * @param opt_options
             * @constructor
             */
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

            text = station.name + "<br>";

            if (station.down) {
                text += " Offline";
            } else {
                text += (function(m){
                    return  m.speed + "(" + m.min_wind_speed + "-" + m.max_wind_speed + ")  m/s"
                }(station.latest_measure.measure));
            }

            return new Label({
                map: map,
                text: text
            });
        }

        function stationMarkerFactory(station) {

            var marker, options = {
                position: new google.maps.LatLng(station.latitude, station.longitude),
                title: station.name,
                href: station.path,
                zIndex: 50
            };

            if (station.down) {
                options.icon = remotewind.icons.station_down();
            } else {
                options.icon = remotewind.icons.station(station.latest_measure.measure);
            }

            marker = new google.maps.Marker( options );

            google.maps.event.addListener(marker, 'click', function(){
                if (marker.href) window.location = marker.href;
                return false;
            });

            return marker;
        }

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

