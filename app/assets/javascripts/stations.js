/**
 * StationMap
 * This is a helper to help manipulate the google map
 * Author: Max Calabrese < max.calabrese@ymail.com >
 * @deps google.maps, jquery


function StationMap(options){

    this.options =  $.extend(true,{
        // default options
        text_output: "current",
        canvas_id: "stations_map",
        zoom: 4,
        // default center (AARE) to suppress errors
        center: new google.maps.LatLng(63.39564, 13.073),
        mapTypeControl: true,
        mapTypeControlOptions: {style: google.maps.MapTypeControlStyle.DROPDOWN_MENU},
        navigationControl: true,
        navigationControlOptions: {style: google.maps.NavigationControlStyle.SMALL},
        mapTypeId: google.maps.MapTypeId.ROADMAP
    }, options);


    this.map = new google.maps.Map(document.getElementById(this.options.canvas_id), this.options);
    this.$text_output = $("#" + this.options.text_output);


    this.addMarker = function(map, pos, title, text) {

        var infowindow, marker, map;

        marker = new google.maps.Marker({ position: pos, map: map, title: title });
        infowindow = new google.maps.InfoWindow({content: text});

        google.maps.event.addListener(marker, 'click', function() {

            infowindow.open(map,marker);
        });

    }

    this.show_map_based_on_last_station = function(lat, lng) {
        this.map.panTo(new google.maps.LatLng(lat, lng));
    }

    this.addStationToMap = function(station) {

        var pos, speed, direction, text, a;

        a = '<a href="'+"/stations/" + station.id +'">' + station.name + '</a>';

        if (station.lat && station.lon) {
            pos = new google.maps.LatLng(station.lat, station.lon);
            speed = parseFloat((station.current_measure.speed / 300).toPrecision(1));
            direction = parseFloat((station.current_measure.direction / 10).toPrecision(1));
            text = a + ", ";
            text += speed + " m/s, ";
            text += direction   + "°";
            this.addMarker(this.map, pos, station.name, text);
        }
    }

    this.addStationsToMap = function(stations) {
        for (i in stations) {
            this.addStationToMap(stations[i]);
        }
    }

    this.print = function(message) {
        this.$text_output.text(message);
    }

} **/