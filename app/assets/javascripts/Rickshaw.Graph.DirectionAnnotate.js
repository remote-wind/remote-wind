/**
 * An extension for Rickshaw.js which draws direction as annotations
 * @author max.calabrese@ymail.com
 */

Rickshaw.namespace('Rickshaw.Graph.DirectionAnnotate');

Rickshaw.Graph.DirectionAnnotate = function(args) {

    var graph = this.graph = args.graph;
    this.elements = { timeline: args.element };
    var self = this;
    this.data = {};

    this.elements.timeline.classList.add('rickshaw-direction-timeline');

    this.add = function(time, dir) {
        self.data[time] = self.data[time] || {};
        self.data[time].direction = dir;
    };

    this.update = function() {

        Rickshaw.keys(self.data).forEach( function(time) {

            var arrow, left;

            arrow = self.data[time];
            left = self.graph.x(time);

            if (left < 0 || left > self.graph.x.range()[1]) {
                if (arrow.element) {
                    arrow.line.classList.add('offscreen');
                    arrow.element.style.display = 'none';
                }
                return;
            }
            if (!arrow.element) {
                var element = arrow.element = document.createElement('div');
                element.classList.add('arrow');
                this.elements.timeline.appendChild(element);
            }

            $(element).css({
                transform: 'rotate(' + (360 - arrow.direction) + 'deg)',
                left : left + 'px',
                display : 'block'
            });
        }, this );
    };

    this.graph.onUpdate( function() { self.update() } );
};