//= require map/icons
//= require_self

$(document).one('stations.loaded', function(e, data){
  $('#map_canvas').trigger('stations.loaded', [data]);
});

$(function(){
  'use strict';

  var $el, map;
  $el = $('#map_canvas');
  if ($el){
    map = L.mapbox.map($el[0].id, 'mapbox.streets', {
      accessToken: "pk.eyJ1IjoicmVtb3RlLXdpbmQiLCJhIjoiY2l4d3l2emxzMDAyazJ3czM1M2JvbDg2ZyJ9.TjcAEb3LDXFocBFK3XwNCQ",
      zoomControl: true,
      // This sets the maxbounds so that it displays all of sweden per default.
      // it also limits the user zoom and pan so that they don't end up in africa
      maxBounds: [[70.191547, 26.118596],[54.227830, 9.445964]],
    }).on('locationerror', function(){
      map.setView([$el.data('lat'), $el.data('lng')], 8);
    });
    if ($el.hasClass('stations-show')) {
      map.setView([$el.data('lat'), $el.data('lng')], 8);
    } else {
      map.locate({setView: true, maxZoom: 8});
    }
  }

  $el.on('stations.loaded', function(e, stations){

    console.log('adding markers to stations');

    $.each(stations, function(i, s){
      var o, marker;
      o = s.latest_observation;
      if(o!==null){
        marker = (function(){
          if (s.status === 'active' && o) {
            return L.marker([s.latitude, s.longitude], {
              title: s.name + " | " + o.speed + "(" + (o.min_wind_speed==null ? "" : (o.min_wind_speed + "-")) + o.max_wind_speed + ") m/s",
              icon: Remotewind.stationIcon({
                speed: o.speed,
                direction: o.direction
              }),
              uri: s.path
            });
          } else {
            return L.marker([s.latitude, s.longitude], {
              title: s.name,
              icon: Remotewind.unresponsiveIcon(),
              uri: s.path
            });
          }
        }());
        marker.addTo(map).on('click', function(e) {
          window.location = e.target.options.uri;
          return false;
        });
      }
    });
  });
});
