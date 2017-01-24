//= require map/map
//= require stations/graph
//= require_self

jQuery(document).ready(function($){

  var $doc = $(document),
    $map_canvas = $('#map_canvas'),
    $menu = $('#left-off-canvas-menu').find('.off-canvas-list');

  // Load stations and notify listeners
  $doc.on('load.stations', function(){
    $.getJSON( '/stations.json').done(function(stations){
      $(document).trigger('stations.loaded', [stations]);
    });
  });

  /**
  * Load stations in off canvas menu
  */
  (function(){
    // Populate off-canvas menu with stations"
    $doc.one('stations.loaded', function(event, stations){
      // Remove stations to ensure that we don´ for whatever reason add items twice
      $menu.children('li').slice(1).remove();
      // create LI with link to each station
      $(stations).each(function(i, station){
        $menu.append('<li><a href="'+ station.path +'">'+station.name+'</a></li>');
        $menu.addClass('loaded');
      });
    });

    // bind handler to menu toggle button
    $('.left-off-canvas-toggle').one('click', function(){
      if (!$menu.hasClass('loaded')) {
        $doc.trigger('load.stations');
      }
    });
  }());

  if ($map_canvas.length) {
    $doc.trigger('load.stations');
  }
});
