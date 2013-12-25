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

                var direction, speed, marker, beaufort, icon;

                speed = $(this).find('.measure').data('speed');
                direction = 180.0+Number($(this).find('.measure').data('direction'));
								console.log("Speed. " + speed + " direction " +direction);
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

                var label = new Label({
                    map: map,
                    text: marker.title + "<br>(" + marker.speed + "m/s)"
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
        var $chart = $('#station_measures_chart');

        /**
         * load measures via ajax
         */
        $chart.one('chart.load-measures', function(event, path){
            $.getJSON(path, function(data){
                $chart.trigger('chart.measures.data-loaded', [processMeasureData(data)]);
            });
        });

        /**
         * Convert each measure property to an array containing all the measurements
         * @param data Object
         * @return Object
         */
        function processMeasureData(data) {

            data.speed = [];
            data.min_wind_speed = [];
            data.max_wind_speed = [];
            data.direction = [];
            data.max_recorded_speed = 0;

            $(data.measures).each(function(k, v){
                var tstamp = this.tstamp * 1000;

                if (this.max_wind_speed > data.max_recorded_speed) {
                    data.max_recorded_speed = this.max_wind_speed;
                }
                data.speed.push([tstamp, this.speed]);
                data.min_wind_speed.push([tstamp, this.min_wind_speed]);
                data.max_wind_speed.push([tstamp, this.max_wind_speed]);
                data.direction.push([tstamp, this.direction]);
            });

            return data;
        }

        /**
         * process data and render chart
         */
        $chart.one('chart.measures.data-loaded', function(event, data){
            var dataset = [
                { yaxis: 1, data: data.max_wind_speed,  id: "max", lines: { show: true, lineWidth: 0, fill: false} },
                { yaxis: 1, data: data.min_wind_speed,  fillBetween: "max", lines: { show: true, lineWidth: 0, fill: 0.5}, color: "rgb(80,80,255)"},
                { yaxis: 1, label: "Windspeed", color: "rgb(0,0,255)", shadowSize: 0, data: data.speed },
                { yaxis: 2, color: "rgb(255,0,0)", data: data.direction, label: "Direction" }
            ];
            function speedUnitAdder(v, axis) {
                return v.toFixed(axis.tickDecimals) + "m/s";
            }
            $.plot($chart, dataset,
                {
                    xaxes: [
                        {mode: 'time'}
                    ],
                    yaxis: { min: 0, max: data.max_recorded_speed + 5, position: "left", tickFormatter: speedUnitAdder},
                    yaxes: [ {}, { tickSize: 45, max: 360, position: "right",
                        ticks: [
                            [0, "N"], [45, "NE"], [90, "E"], [135, "SE"],
                            [180, "S"], [225, "SW"], [270, "W"], [315, "NW"], [360, "N"]
                        ] } ]
                }
            );
        });

        if ($chart.length) {
            $chart.trigger('chart.load-measures', $chart.data('path') );
        }

    }());
});

