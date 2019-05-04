// This uses Chroma.js to build a color scale which is used for wind speed.
// http://gka.github.io/chroma.js
// note that this is actually a function which can be chained.
Remotewind.color_scale = chroma.scale([
  'lightblue',
  'green',
  'red',
  'purple'
])
  .mode('hsl') // the blending mode
  .domain([0, 7, 15, 25]); // the distinct steps for each.

/**
* Base class for creating vector based icons.
* can be customized by creating '_createPath' and '_createText' methods
* in subclasses
*/
Remotewind.VectorIcon = L.Icon.extend({
  options: {
    height: 26,
    width: 26,
    stroke: 'white',
    strokeWidth: 2
  },
  _createElement: function(tagName){
    return document.createElementNS('http://www.w3.org/2000/svg', tagName);
  },
  createIcon: function (oldIcon) {
    var div = (oldIcon && oldIcon.tagName === 'DIV') ? oldIcon : document.createElement('div'),
      svg = this._createElement('svg');
    $(svg).attr({
      "version": '1.1',
      "xmlns": "http://www.w3.org/2000/svg",
      "xmlns:xlink": "http://www.w3.org/1999/xlink",
      "height": this.options.height,
      "width": this.options.width
    });

    if (typeof this._createPath === 'function') {
      svg.appendChild(this._createPath());
    }
    if (typeof this._createText === 'function'){
      svg.appendChild(this._createText());
    }
    div.appendChild(svg);
    this._setIconStyles(div, 'icon');
    return div;
  },
  createShadow: function () {
    return null;
  }
});

/**
* Vector based icon for a station
*
*/
Remotewind.StationIcon = Remotewind.VectorIcon.extend({
  options: {
    className: 'leaflet-station-icon active',
    speed: 0,
    direction: 0,
  },
  _createPath: function(){
    var g = this._createElement('g'),
        path = this._createElement('path'),
        options = this.options;
    g.setAttributeNS(null, "transform", "translate(0,-6)");
		if(options.direction==null) {
			path = this._createElement('circle')
			$(path).attr({
	      'cx': 13,
	      'cy': 13,
	      'r': 13,
				"stroke": options.stroke,
	      "stroke-width": options.strokeWidth,
	      "fill": Remotewind.color_scale(options.speed).name(),
	 			"transform": "translate(0,6)"
	    });
		} else {
			$(path).attr({
	      "d": "M26,19c0-2.2-0.6-4.4-1.6-6.2C22.2,8.8,13,0,13,0S3.8,8.7,1.6,12.8c-1,1.8-1.6,4-1.6,6.2c0,7.2,5.8,13,13,13 S26,26.2,26,19z",
	      "stroke": options.stroke,
	      "stroke-width": options.strokeWidth,
	      "fill": Remotewind.color_scale(options.speed).name(),
	      "transform": "rotate(% 13 19)".replace('%', options.direction)
	    });
		}
    g.appendChild(path);
    return g;
  },
  _createText: function(){
    var g = this._createElement('g');
        txt =  this._createElement('text');
        options = this.options;

    $(txt).attr({
      "fill": "white",
      "x": (options.height / 2),
      "y": (options.width / 2),
      "text-anchor": "middle",
      "dominant-baseline": "central",
    }).text(Math.round(options.speed).toString());
    g.appendChild(txt);
    return g;
  }
});

Remotewind.stationIcon = function (options) {
  return new Remotewind.StationIcon(options);
};

/*
* Vector based icon for an unresponsive station
*/
Remotewind.UnresponsiveIcon = Remotewind.VectorIcon.extend({
  options: {
    className: 'leaflet-station-icon unresponsive',
  },
  _createPath: function(){
    var g = this._createElement('g');;
        circle = this._createElement('circle');
    $(circle).attr({
      'cx': 13,
      'cy': 13,
      'r': 13,
      'stroke': this.options.stroke,
      'stroke-width': this.options.strokeWidth,
      'fill': '#333',
    });
    g.appendChild(circle);
    return g;
  }
});

Remotewind.unresponsiveIcon = function (options) {
  return new Remotewind.UnresponsiveIcon(options);
};
