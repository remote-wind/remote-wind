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
//= require turbolinks
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

        console.log('maps-api-loaded');

        var map_canvas = document.getElementById("stations_map") || null;
        // Load client position
        var user_loction = (function(){
            if(navigator.geolocation) {

                return navigator.geolocation.getCurrentPosition(
                    function(p) {
                        //get position from p.coords.latitude and p.coords.longitude
                        console.info(p);
                        return p.coords;
                    }
                );
            };
        }());




    });
});




