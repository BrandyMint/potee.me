/*!
 * jQuery live outside events  - v0.1 - 14/05/2011
 *
 * Remake of a slick project by Ben Alman:
 * http://benalman.com/projects/jquery-outside-events-plugin/
 *
 * This project is inferior in every way to the work of Ben Alman
 * but it allows for attaching live events.
 *
 */

(function(jQuery, document) {

    var bindings = {};
    var live_handler = {};

    jQuery.fn.outside = function(event_name, attach_method, handler) {

        if (attach_method == 'live' || attach_method == 'bind') {

            if (live_handler[event_name] == null) {
                live_handler[event_name] = liveOutsideHandlerFactory();
                $(document).bind(event_name, live_handler[event_name]);
            }

            bindings[event_name] = bindings[event_name] || [];
            bindings[event_name].push({
                targetSelector: attach_method == 'live' ? this.selector : null,
                targetElements: attach_method == 'bind' ? this : null,
                without: [],
                handler: handler
            });

        }

        if (attach_method == 'die' || attach_method == 'unbind') {
            var _that = this;
            $.each(bindings[event_name], function(idx, elem) {
                elem.without.push(attach_method == 'die' ? _that.selector : _that);
            });
        }

        function liveOutsideHandlerFactory() {
            return function(event) {
                var event_name = event.type;

                if (bindings[event_name]) {
                    $.each(bindings[event_name], function(idx, binding) {
                        var handler = binding.handler;
                        var target_elements = $(binding.targetSelector || binding.targetElements);

                        $.each(binding.without, function(idx, elem) {
                            target_elements = target_elements.not($(elem));
                        });

                        target_elements.each(function(idx, elem) {

                            if (elem != event.target && !$(elem).has(event.target).length) {

                                handler.apply(elem, [event]);
                            }
                        });

                    });

                }
            }
        }

    };
})(jQuery, document);