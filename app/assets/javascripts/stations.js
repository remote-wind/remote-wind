jQuery(document).ready(function($){

    var $doc = $(document),
        $map_canvas = $('#map_canvas'),
        $menu = $('#left-off-canvas-menu').find('.off-canvas-list');

    // Load stations and notify listeners
    $doc.on('load.stations', function(){
        $.getJSON('/stations', function(data){
            $map_canvas.trigger('stations.loaded', [data]);
            $menu.trigger('stations.loaded');
        });
    });

    /**
     * Load stations in off canvas menu
     */
    (function(){
        // Populate off-canvas menu with stations
        $menu.one('stations.loaded', function(event, data){

            // Remove stations to ensure that we don´ for whatever reason add items twice
            $menu.children('li').slice(1).remove();

            // create LI with link to each station
            $(data).each(function(i, obj){
                $menu.append('<li><a href="'+ obj.href +'">'+obj.name+'</a></li>');
            });
        });

        // bind handler to menu toggle button
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

        $map_canvas.on('stations.loaded', function(e, data){
            // Handle case when stations data is loaded before google maps api
            if (data && data.length) {
                if (map) {
                    $map_canvas.trigger('map.add_markers', [map, data]);
                } else {
                    data_store = data;
                }
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

            var lat_lng;

            if (map && stations && stations.length) {
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

                // uses data on map to set position if available
                lat_lng = (function(data){
                    return (data.lat && data.lon) ? new google.maps.LatLng(data.lat, data.lon) : false;
                }($map_canvas.data()));

                if (lat_lng) {
                    map.setCenter(lat_lng);
                    map.setZoom(10);
                } else {
                    map.fitBounds(map.stations_bounds);
                }
            }

        });

        /**
         * Factory to create labels
         * @param map google.maps.Map
         * @param station Object
         * @return Label object
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

            if (station.offline) {
                text += " Offline";
            } else {
                text += (function(m){
                    return  m.speed + "(" + m.min_wind_speed + "-" + m.max_wind_speed + ")  m/s"
                }(station.latest_observation.observation));
            }

            return new Label({
                map: map,
                text: text
            });
        }

        /**
         * Factory to create station markers
         * @param station
         * @returns google.maps.Marker
         */
        function stationMarkerFactory(station) {

            var marker, options = {
                position: new google.maps.LatLng(station.latitude, station.longitude),
                title: station.name,
                href: station.path,
                zIndex: 50
            };

            if (station.offline) {
                options.icon = remotewind.icons.station_down();
            } else {
                options.icon = remotewind.icons.station(station.latest_observation.observation);
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
     * Chart showing station observations
     * @see [rickshaw.js docs](http://code.shutterstock.com/rickshaw/) for more details
     */
    (function(){
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
                        x : m.tstamp,
                        y : m.min_wind_speed
                    });
                    series[1].data.push({
                        x : m.tstamp,
                        y : m.speed + Math.random() * 10
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
            $.ajax({
                url: $graph.data('path'),
                type: 'GET',
                dataType: 'JSON',
                ifModified:true,
                success: function(data, textStatus, jqXHR){
                    // Status is 200 OK
                    if (data) {
                        $graph.trigger('graph.render', [data]);
                        //@todo use last observation received time to figure out when to load new observations
                    } else {
                        // Status is 304 not modified
                        //@todo check for new observations in x seconds
                    }
                    window.setTimeout(function(){
                        $graph.trigger('graph.data.load');
                    }, refresh * 1000);
                }
            });
        });

        if ($graph.length) {
            $graph.trigger('graph.data.load');
        }

        $graph.on('graph.render', function(e, data) {

            console.log('graph.render');

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


            if (graph) {
                // Replace graph data
                $(graph.series).each(function(i){
                    graph.series[i] = series[i];
                });
            }

            // Scale the Scroll Container after the number of observations
            $graph.$scroll.width( data.length *  30 );

            graph = graph || new Rickshaw.Graph( {
                element: $graph.$chart[0],
                width: $graph.$chart.innerWidth() - 20,
                height: $graph.$chart.innerHeight() - 20,
                renderer: 'line',
                dotSize: 2,
                series: series
            });



            graph.time =  graph.time || new Rickshaw.Fixtures.Time();

            // Custom timescale with 15min "clicks"
            graph.x_axis = graph.x_axis || new Rickshaw.Graph.Axis.Time({
                element: $graph.$x_axis[0],
                graph: graph,
                timeUnit: graph.time.unit('15 minute')
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
            if (data.length) {
                $(data).each(function(i,m){
                    graph.annotator.add(m.tstamp, m.direction);
                });
            }
            // Scroll to end of observations
            // Browsers won´t allow scrolling beyond the width of the container anyways
            $graph.$scroll.scrollLeft(99999999);
            graph.render();
            graph.update();
            graph.annotator.update();
        });
    }());

    if ($map_canvas.length) {
        $doc.trigger('load.stations');
    }
});

