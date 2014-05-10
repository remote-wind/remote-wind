/**
 * Just a Namespaced "junk drawer" for converters, scales, utils
 * @type {Object}
 */

window.remotewind = {};

/**
 * Icons
 * These are SVG (vector) path notations of icons used in the map
 */
remotewind.icons = {};

/**
 * Create object with parameters for offline station icon
 * @returns object
 */
remotewind.icons.station_down = function(){
    // Path in SVG notation
    var path = "M42.143,34.055L30.611,22.523l11.531-11.531c-1.828-2.983-4.344-5.499-7.327-7.327L23.284,15.197L11.753,3.665 C8.77,5.493,6.254,8.009,4.426,10.992l11.531,11.531L4.426,34.055c1.828,2.983,4.344,5.499,7.327,7.327L23.284,29.85l11.531,11.531 C37.799,39.554,40.315,37.038,42.143,34.055z";
    return {
        size: new google.maps.Size(25, 25),
        origin: new google.maps.Point(20, 20),
        anchor: new google.maps.Point(23, 23),
        path: path,
        fillColor: 'white',
        fillOpacity: 0.8,
        strokeColor: 'black',
        strokeWeight: 1.2
    }
}

/**
 * Create object with parameters for regular map icon
 * @returns object
 */
remotewind.icons.station = function(observation) {
    // Path in SVG notation
    var path = "M20,3.272c0,0,13.731,12.53,13.731,19.171S31.13,36.728,31.13,36.728S23.372,31.536,20,31.536 S8.87,36.728,8.87,36.728s-2.601-7.644-2.601-14.285S20,3.272,20,3.272z";
    var beaufort = remotewind.util.msToBeaufort(observation.speed || 0);

    return {
        size: new google.maps.Size(40, 40),
        origin: new google.maps.Point(20,20),
        anchor: new google.maps.Point(20, 20),
        path: path,
        fillColor: beaufort.color,
        fillOpacity: 0.8,
        strokeColor: 'black',
        strokeWeight: 1.2,
        rotation: 180.0 + observation.direction
    }
}



remotewind.util = {};
remotewind.reference = {};
remotewind.reference.BEAUFORT_SCALE = {
    1: {
        min: 0,
        max: 0.3,
        desc: "Calm",
        color: "#FFF"
    },
    2: {
        min: 0.3,
        max:3.4,
        desc: "Light air",
        color: "#CCFFFF2"
    },
    3: {
        min: 3.5,
        max: 5.4,
        desc: "Light breeze",
        color: "#99FF99"
    },
    4: {
        min: 5.5,
        max: 7.9,
        desc: "Moderate breeze",
        color: "#99FF66"
    },
    5: {
        min: 8.0,
        max: 10.7,
        desc: "Fresh breeze",
        color: "#99FF00"
    },
    6: {
        min: 10.8,
        max: 13.8,
        desc: "Strong breeze",
        color: "#CCFF00"
    },
    7: {
        min: 13.9,
        max: 17.1,
        desc: "High wind",
        color: "#FFFF00"
    },
    8: {
        min: 17.2,
        max: 20.7,
        desc: "Gale",
        color: "#FFCC00"
    },
    9: {
        min: 20.8,
        max: 24.4,
        desc: "Strong gale",
        color: "#FF9900"
    },
    10: {
        min: 24.5,
        max: 28.4,
        desc: "Storm",
        color: "#FF6600"
    },
    11: {
        min: 28.5,
        max: 32.6,
        desc: "Violent storm",
        color: "#FF3300"
    },
    12: {
        min: 32.7,
        max: 999,
        desc: "Hurricane force",
        color: "#FF0000"
    }
}

/**
 * @param ms
 * @param mode (bool) ||= false, return the number on the scale or a object containing all the meta
 * @return {Number}
 */
remotewind.util.msToBeaufort = function(ms, meta){
    var i, bf, mode = mode || false;

    i = 1;
    bf = remotewind.reference.BEAUFORT_SCALE;

    while (i <= 12) {
        if (ms < bf[i].max) {
            if (meta) {
                return bf[i];
            }
            return bf[i];
        }
        i++;
    }
}

/**
 * A very special velocity converter
 * Designed mainly for a very natural syntax
 * It allows full chainable conversion calls and maintains its on internal state.
 * Credit goes out to: http://codereview.stackexchange.com/users/14370/flambino
 *
 * example:
 * remotewind.convert(10).knots().to.mph().valueOf();
 * 11.507794484115342
 * remotewind.convert(10).knots().to.kmh() + remotewind.convert(4).mph().to.kmh()
 * 24.957376029164976
 */
remotewind.convert = (function () {
    var conversions = {
        ms:    1, // use m/s as our base unit
        kmh:   3.6,
        mph:   2.23693629,
        knots: 1.94384449
    };

    function Unit(unit, ms) {
        this.value = ms * conversions[unit];
        this.to = {};
        for(var otherUnit in conversions) {
            (function (target) {
                this.to[target] = function () {
                    return new Unit(target, ms);
                }
            }).call(this, otherUnit);
        }
    }

    Unit.prototype = {
        toString: function () {
            return String(this.value);
        },

        valueOf: function () {
            return this.value.toPrecision(3);
        }
    };

    return function (value) {
        var units = {};
        for(var unit in conversions) {
            (function (unit) {
                units[unit] = function () {
                    return new Unit(unit, value / conversions[unit]);
                };
            }(unit));
        }
        return units;
    }
}());