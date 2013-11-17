// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require jquery.flot.min
//= require jquery.flot.fillbetween
//= require_tree .

// This lets us call console even in crap browsers.
window.console = window.console||{
    log : function(){},
    info: function(){},
    error: function(){}
};

$(function(){
    $(document).foundation();
    $('body').on('maps-api-loaded', function(){

        var $map_canvas = $('#stations_map');
        if ($map_canvas.length){
            (function() {

                var mapOptions = {
                    center: new google.maps.LatLng(-34.397, 150.644),
                    zoom: 10,
                    mapTypeId: google.maps.MapTypeId.ROADMAP
                };
                var map = new google.maps.Map(document.getElementById("stations_map"),
                    mapOptions);

                map.infoWindow = new google.maps.InfoWindow();

                $map_canvas.on('new-user-position', function(event, lat, lng){
                    map.panTo(new google.maps.LatLng(lat, lng));
                });

                $map_canvas.on('station-data-loaded', function(event, data){
                    $(data).each(function(){
                        var $row, marker, infowindow, text;
                        $row = $('#station-'+ this.id);
                        marker = new google.maps.Marker({
                            position: new google.maps.LatLng(this.latitude, this.longitude),
                            map: map,
                            title: this.name
                        });
                        marker.content = '<p><a href="'+ this.path +'">'+ this.name +'</a></p>';
                        google.maps.event.addListener(marker, 'click', function(){
                            map.infoWindow.close();
                            map.panTo(marker.position);
                            map.infoWindow.setPosition(marker.position);
                            map.infoWindow.setContent(marker.content);
                            map.infoWindow.open(map, marker);
                        });
                        $row.data('marker', marker);
                    });
                });

                $('.stations').on('click', '.station', function(e){
                    var marker = $(this).data('marker');
                    map.panTo(marker.position, 15);
                });

                var stations = $.getJSON('/stations', function(data, status){
                    $map_canvas.trigger('station-data-loaded', [data]);
                });

                if(navigator.geolocation) {
                    return navigator.geolocation.getCurrentPosition(
                        function(p) {
                            $map_canvas.trigger('new-user-position',[ p.coords.latitude, p.coords.longitude ]);
                        }
                    );
                };
            }());
        }
    });
});




