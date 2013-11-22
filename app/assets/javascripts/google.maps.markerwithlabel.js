/**
 * google.maps.MarkerWithLabel plugin
 *
 * This adds a constructor to google maps to create markers with labels
 * This plug attempts to make as few assumptions about your implimention as possible, yet have sensible defaults
 *
 * This plugin targets Google Maps Api v3.
 *
 * It has a strong dependency on jQuery or Zepto and google maps of course.
 *
 * This plugin is made to be compatible with async loading, and will not do anything until you fire a 'google.maps.apiloaded'
 * event. This ensures that the google maps depency is resolved. Example:
 * $({}).trigger('google.maps.apiloaded');
 *
 * @author max.calabrese@ymail.com
 *
 */
$(function(){
    /**
     * Constructor that subtypes google.maps.Marker
     * to create a marker with an associated label.
     * The actual DOM elements can be acessed via .elem
     *
     * Options (see google.maps.Marker for other options!)
     * ==================
     *
     * Label  (literal)
     * ---------
     * text: the text inserted in label (duuh)
     * class: html class attribute applied to label
     * css (literal): a literal of css properties accepted by jQuery.css
     *
     * Callbacks (literal)
     * ---------
     * This can be used for animations etc.
     *
     * The events available are onAdd and onRemove
     *
     * each callback event is expected to be a either an
     * array or object with callback functions as mermbers
     *
     * Callbacks recieve the following arguments
     * marker, container
     *
     *
     * @param options
     * @constructor
     * @protype google.maps.Marker
     */
    function MarkerWithLabel(options) {

        /**
         * This constructor creates the actual elements
         * EI a label associated with a marker.
         * @param marker MarkerWithLabel
         * @constructor
         */
        function Elem(marker){
            var self = this;

            function init(self){
                self.marker = marker;
                self.$container = $('<div class="marker">');
                self.container =  self.$container[0];
                self.$label = $('<div class="marker">');
                self.label = self.$label[0];
                self.$container.append(this.label);

                // public "methods"
                self.draw = draw;
                self.onAdd = onAdd;
                self.onRemove = onRemove;

                //
                $(self.container).hide().on("selectstart", ".label",function(){
                    return false;
                });
            }

            function draw(self){
                var position, options;
                options = self.marker.options;
                position = self.getProjection()
                    .fromLatLngToDivPixel(this.marker.getPosition());
                this.container.css($.extend({
                    top: position.y + "px",
                    left: position.x + "px",
                    zIndex: options.zIndex
                }, options.label.css));

                $(this.label)
                    .addClass(options.label.class)
                    .text(options.label.text);
            };

            /**
             * Adds the DIV representing the label to the DOM. It is called
             * automatically when the marker  method is called.
             */
            function onAdd(){
                draw();
                this.getPanes().overlayImage.appendChild(this.container);
                this.onAddCallback(this.container);
                this.listeners = [];
                $.each(this.options.callbacks.onAdd, function(k,f){
                    f.call(self, self.marker, self.container);
                });
                this.addListeners();
                $(this.container).show();
            };

            function addListeners(){
                var self = this;
                self.marker.listeners.push(google.maps.event.addDomListener(marker.container, "click", function (e) {
                    google.maps.event.trigger(marker, "click", e);
                }));
            }

            function removeListeners(){
                var listeners = marker.listeners;

                // Remove event listeners:
                for (i = 0; i < listeners.length; i++) {
                    google.maps.event.removeListener(listeners[i]);
                }
            }

            /**
             * Removes the elemts for the marker from the DOM. It also removes all event handlers.
             * This method is called when setMap(null) is called.
             */
            function onRemove(){
                $.each(this.options.callbacks.onRemove, function(k,f){
                    f.call(self, self.marker, self.container);
                });

                this.containerparentNode.removeChild(this.container);
                removeListeners(this.marker);
            };

            // Constructor should run init
            init(self);
        };

        Elem.prototype = new google.maps.OverlayView();


        /**
         * initialize
         * Merge defualt options with options passed on creation
         */
        $.extend( options, {
            container: {
                class: "marker"
            },
            label: {
                text: "",
                class: "label",
                zIndex: 999,
                css: {
                    position: "releative"
                }
            },
            callbacks : {
                onAdd : [],
                onRemove : [],
            }
        });
        this.options = options;
        this.position = options.position;
        this.map = options.map;

        this.elem = new Elem(this);
        this.listeners = [];

        this.setMap = function(map){

        };

        return this;

    }
    /**
     * We make sure google maps api is loaded to make sure google.maps is resolved
     */
    $(document).on('google.maps.apiloaded', function(){
        MarkerWithLabel.prototype = new google.maps.Marker();
        // Add constructor to google.maps namespace but avoid overwriting any existing implimentation
        google.maps.MarkerWithLabel = google.maps.MarkerWithLabel || MarkerWithLabel;
    });
});

