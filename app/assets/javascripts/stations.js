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
                $map_canvas.height($(window).innerHeight() - 45);
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
                $map_canvas.trigger('map.add_markers', [map, $controls]);
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
            $markers.each(function(){

                var direction, speed, max_speed, min_speed, marker, beaufort, icon, label_text;

                speed = $(this).find('.measure').data('speed');
								min_speed = $(this).find('.measure').data('min-speed')
								max_speed = $(this).find('.measure').data('max-speed')
                direction = 180.0+Number($(this).find('.measure').data('direction'));
                // we use the beaufort scale to color the arrows
                beaufort = remotewind.util.msToBeaufort(speed);

                icon = {
                    size: new google.maps.Size(40, 40),
                    origin: new google.maps.Point(20,20),
                    anchor: new google.maps.Point(20, 20),
                    path: remotewind.arrow,
                    fillColor: beaufort.color,
                    fillOpacity: 0.8,
                    strokeColor: 'black',
                    strokeWeight: 1,
                    rotation: direction
                };

                marker = new google.maps.Marker({
                    position: new google.maps.LatLng($(this).data('lat'), $(this).data('lon')),
                    title: $(this).find('.title').text(),
                    content: $(this).html(),
                    direction: direction,
                    speed: speed,
                    icon: icon,
                    href: $(this).find('a').attr('href'),
                    zIndex: 50
                });

                if (map.markerCluster) {
                    map.markerCluster.addMarker(marker);
                } else {
                    marker.setMap(map);
                }

								label_text = "offline"
								if ((null!=speed) && (null!=min_speed) && (null!=max_speed)) {
									label_text = speed + "(" + min_speed + "-" + max_speed + ")"+ "m/s"
								}
                var label = new Label({
                    map: map,
                    text: marker.title + "<br>" + label_text
                });
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

        console.log($graph);

        /**
         * Format measures into stacks for Rickshaw
         * @param data
         */
        function formatData(data) {

            var formatted;

            formatted = [
                { key: 'min', data : [] },
                { key: 'avg', data : [] },
                { key: 'max', data : [] }
            ];

            if (data.measures.length) {
                $(data.measures).each(function(k,m){

                    formatted[0].data.push({
                        x : m.tstamp,
                        y : m.min_wind_speed
                    });
                    formatted[1].data.push({
                        x : m.tstamp,
                        y : m.speed
                    });
                    formatted[2].data.push({
                        x : m.tstamp,
                        y : m.max_wind_speed
                    });

                });
            }
            return formatted;
        }

        $graph.on('graph.data.load', function(){
            $.getJSON($graph.data('path') + '.json', function(data){
                $graph.trigger('graph.render', [formatData(data)]);
            });
        });


        $graph.on('graph.render', function(e, d) {

            var palette, graph, x_axis, y_axis, time, $scroll_contents;

            // Wraps the actual graph and x-axis so that we can scroll
            $scroll_contents = $graph.find('.scroll-contents');

            // Scroll to end of measures
            $graph.find('.scroll-window').scrollLeft(9999);

            // Fixtures
            time = new Rickshaw.Fixtures.Time();
            palette = new Rickshaw.Color.Palette();

            graph = new Rickshaw.Graph( {
                element: $graph.$chart[0],
                width: $scroll_contents.innerWidth() - 20,
                height: $scroll_contents.innerHeight() - 20,
                renderer: 'line',
                dotSize: 2,
                series: [
                    {
                        key: 'min',
                        name: 'Min Wind Speed',
                        color: "#91B4ED",
                        data: d[0].data
                    },
                    {
                        key: 'avg',
                        name: 'Average Wind Speed',
                        color: "#3064B8",
                        data: d[1].data
                    },
                    {
                        key: 'max',
                        name: 'Max Wind Speed',
                        color: "#91B4ED",
                        data: d[2].data
                    }
                ]

            });
            x_axis = new Rickshaw.Graph.Axis.Time({
                graph: graph,
                timeUnit: time.unit('15 minute')
            });
            y_axis = new Rickshaw.Graph.Axis.Y( {
                graph: graph,
                orientation: 'left',
                element: $graph.$y_axis[0],
                tickFormat: function(y){
                    return y + ' m/s'
                }
            });

            console.info(time.unit('15 minute'));

            graph.render();



        });

        if ($graph.length) {
            $graph.trigger('graph.data.load');
        }
    }());
});

