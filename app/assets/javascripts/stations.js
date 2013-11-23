$(function () {

    /**
     * Really generic google maps implimention that uses data attributes and good old html
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
            var $markers, $controls, mapOptions, map, bounds;

            // Define the overlay, derived from google.maps.OverlayView
            function Label(opt_options) {
                // Initialization
                this.setValues(opt_options);

                // Label specific
                var span = this.span_ = document.createElement('div');
                span.style.cssText = 'font-size: 12px; position: relative; top: 18px; left:-50%; padding: 3px; height: 14px; font-weight: bolder; z-index: 999; -webkit-text-stroke: -1px white;';
                span.style.cssText = span.style.cssText + " text-shadow: 3px 3px 3px rgba(255,255,255, 0.5), -1px -1px 0 rgba(255,255,255, 0.5), 1px -1px 0 rgba(255,255,255, 0.5),-1px 1px 0 rgba(255,255,255, 0.5),1px 1px 0 rgba(255,255,255, 0.5);"

                var div = this.div_ = document.createElement('div');
                div.appendChild(span);
                div.style.cssText = 'position: absolute; display: none';
            };
            Label.prototype = new google.maps.OverlayView;

            // Implement onAdd
            Label.prototype.onAdd = function() {
                var pane = this.getPanes().overlayLayer;
                pane.appendChild(this.div_);

                // Ensures the label is redrawn if the text or position is changed.
                var me = this;
                this.listeners_ = [
                    google.maps.event.addListener(this, 'position_changed',
                        function() { me.draw(); }),
                    google.maps.event.addListener(this, 'text_changed',
                        function() { me.draw(); })
                ];
            };

            // Implement onRemove
            Label.prototype.onRemove = function() {
                this.div_.parentNode.removeChild(this.div_);

                // Label is removed from the map, stop updating its position/text.
                for (var i = 0, I = this.listeners_.length; i < I; ++i) {
                    google.maps.event.removeListener(this.listeners_[i]);
                }
            };

            // Implement draw
            Label.prototype.draw = function() {
                var projection = this.getProjection();
                var position = projection.fromLatLngToDivPixel(this.get('position'));

                var div = this.div_;
                div.style.left = position.x + 'px';
                div.style.top = position.y + 'px';
                div.style.display = 'block';

                this.span_.innerHTML = this.get('text').toString();
            };


            $markers = $map_canvas.find('.marker').clone();
            $controls = $map_canvas.find('.controls').clone();
            $map_canvas.empty();

            mapOptions = {
                center: new google.maps.LatLng($map_canvas.data('lat'), $map_canvas.data('lon')),
                zoom: 10,
                mapTypeId: google.maps.MapTypeId.ROADMAP
            };

            map = new google.maps.Map($map_canvas[0],
                mapOptions);

            map.infoWindow = new google.maps.InfoWindow();
            map.all_markers_bounds = new google.maps.LatLngBounds();


            var markerCluster = new MarkerClusterer(map);


            $markers.each(function(){

                var direction, speed, marker, beaufort, icon;

                speed = $(this).find('.measure').data('speed');
                direction = $(this).find('.measure').data('direction');
                // we use the beaufort scale to color the arrows
                beaufort = remotewind.util.msToBeaufort(speed);

                var icon = {
                    size: new google.maps.Size(40, 40),
                    // The origin for this image is 0,0.
                    origin: new google.maps.Point(20,20),
                    // The anchor for this image is the base of the flagpole at 0,32.
                    anchor: new google.maps.Point(20, 20),
                    path: remotewind.arrow,
                    fillColor: beaufort.color,
                    fillOpacity: 0.8,
                    strokeColor: 'black',
                    strokeWeight: 1,
                    rotation: direction - 180
                };

                marker = new google.maps.Marker({
                    position: new google.maps.LatLng($(this).data('lat'), $(this).data('lon')),
                    title: $(this).find('.title').text(),
                    content: $(this).html(),
                    direction: direction,
                    speed: speed,
                    icon: icon,
                    zIndex: 50
                });

                markerCluster.addMarker(marker);

                var label = new Label({
                    map: map,
                    text: marker.title + " (" + marker.speed + "m/s)"
                });
                label.bindTo('position', marker, 'position');
                //label.bindTo('text', marker, 'title');

                map.all_markers_bounds.extend(marker.position);




                google.maps.event.addListener(marker, 'click', function(){
                    map.infoWindow.close();
                    map.panTo(marker.position);
                    map.infoWindow.setPosition(marker.position);
                    map.infoWindow.setContent(marker.content);
                    map.infoWindow.open(map, marker);
                });
            });

            map.fitBounds(map.all_markers_bounds);

            if ($controls.length) {
                map.controls[google.maps.ControlPosition.LEFT_TOP].push($controls[0]);

                google.maps.event.addDomListener($controls[0], 'click', function(e) {
                    map.fitBounds(map.all_markers_bounds);
                    e.preventDefault();
                });
            }
        });
    }());


    /**
     * Station chart
     */
    (function(){
        var $chart = $('#station_measures_chart');
        /**
         * when user clicks section
         * load and render chart
         */
        $('.section-container').on('opened.fndtn.section', function(e, d){
            if ($($chart).closest(e.target).length) {
                $chart.trigger('chart.load-measures', $chart.data('path') );
            }
        });
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
                if (this.max_wind_speed > data.max_recorded_speed) {
                    data.max_recorded_speed = this.max_wind_speed;
                }
                data.speed.push([this.tstamp, this.speed]);
                data.min_wind_speed.push([this.tstamp, this.min_wind_speed]);
                data.max_wind_speed.push([this.tstamp, this.max_wind_speed]);
                data.direction.push([this.tstamp, this.direction]);
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
    }());
});

