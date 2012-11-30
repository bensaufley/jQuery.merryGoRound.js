// Generated by CoffeeScript 1.4.0

/*
 * jQuery.scroller
 * A simple jQuery plugin for content carousels
 * Author: Ben Saufley
 *   for Millennium Partners Sports Club Management, LLC
 *   http://sportsclubla.com
 * Based on jQuery plugin boilerplate by Jonathan Nicol @f6design
*/


(function() {

  (function($) {
    var Plugin, pluginName;
    pluginName = 'scroller';
    Plugin = function(element, options) {
      var $c, $el, $next, $prev, destroy, el, fill, hook, hover, hoverUpdate, init, looper, moveTo, next, onFirst, onLast, option, prev, startAuto, stopAuto;
      el = element;
      $el = $(element);
      $c = $el.children().first();
      $next = $prev = null;
      looper = null;
      hover = false;
      options = $.extend({}, $.fn[pluginName].defaults, options);
      init = function() {
        $el.css({
          'overflow-x': 'hidden',
          'position': 'relative'
        });
        $c.css({
          'position': 'absolute',
          'left': options.infinite ? 0 : '50%'
        });
        if (options.nojs_class) {
          $c.children().removeClass(options.nojs_class);
        }
        if (options.focused) {
          options.focused = $(options.focused);
        } else {
          options.focused = $c.children().first();
        }
        if (options.infinite) {
          moveTo(options.focused, 0, true);
          if (options.focus_class) {
            $(options.focused).addClass(options.focus_class);
          }
          fill();
        } else {
          $c.css({
            'margin-left': -(options.focused.outerWidth(true) / 2 + options.focused.position().left)
          });
          if (options.focus_class) {
            options.focused.addClass(options.focus_class);
          }
        }
        $next = $('<div />', {
          'class': options.next_class,
          'text': 'NEXT'
        });
        $prev = $('<div />', {
          'class': options.prev_class,
          'text': 'PREVIOUS'
        });
        $next.appendTo($el).on('click tap', next);
        $prev.appendTo($el).on('click tap', prev);
        if (onLast() && !options.infinite && !options.typewriter) {
          $next.hide();
        }
        if (onFirst() && !options.infinite && !options.typewriter) {
          $prev.hide();
        }
        if (options.auto !== false) {
          startAuto();
        }
        return hook('onInit');
      };
      destroy = function() {
        return $el.each(function() {
          el = this;
          $el = $(this);
          $el.css({
            'overflow-x': '',
            'position': ''
          });
          $c.css({
            'position': '',
            'left': '',
            'margin-left': ''
          });
          $next.add($prev).remove();
          stopAuto();
          if (options.nojs_class) {
            $c.addClass(options.nojs_class);
          }
          if (options.focus_class) {
            $c.find("." + options.focus_class).removeClass(options.focus_class);
          }
          hook('onDestroy');
          return $el.removeData("plugin_" + pluginName);
        });
      };
      moveTo = function(to, speed, init) {
        var $first, $moved, width;
        if (speed == null) {
          speed = options.speed;
        }
        if (options.focused[0] !== to[0]) {
          if (options.infinite) {
            if (!init) {
              hook('onStart');
            }
            width = 0;
            $first = $c.children().first();
            $moved = $first.add($first.nextUntil(to));
            $moved.each(function() {
              return width += $(this).outerWidth(true);
            });
            if (options.focus_class) {
              options.focused.removeClass(options.focus_class);
            }
            options.focused = to;
            $moved.clone().appendTo($c);
            return $c.animate({
              'left': -width
            }, speed, options.easing, function() {
              if (options.focus_class) {
                options.focused.addClass(options.focus_class);
              }
              $moved.remove();
              $c.css('left', 0);
              if (!init) {
                return hook('onComplete');
              }
            });
          } else {
            if (!init) {
              hook('onStart');
            }
            if (options.focus_class) {
              options.focused.removeClass(options.focus_class);
            }
            options.focused = to;
            if (!options.typewriter) {
              if (onLast()) {
                $next.fadeOut(speed / 2);
              } else if ($next.not(':visible')) {
                $next.fadeIn(speed / 2);
              }
              if (onFirst()) {
                $prev.fadeOut(speed / 2);
              } else if ($next.not(':visible')) {
                $prev.fadeIn(speed / 2);
              }
            }
            return $c.animate({
              'margin-left': -(options.focused.outerWidth(true) / 2 + options.focused.position().left)
            }, speed, options.easing, function() {
              if (options.focus_class) {
                options.focused.addClass(options.focus_class);
              }
              if (!init) {
                return hook('onComplete');
              }
            });
          }
        }
      };
      next = function() {
        if (options.infinite) {
          return moveTo(options.focused.next());
        } else {
          if (!onLast()) {
            return moveTo(options.focused.next());
          } else if (options.typewriter) {
            return moveTo($c.children().first());
          }
        }
      };
      prev = function() {
        if (options.infinite) {
          hook('onStart');
          $c.children().last().clone().prependTo($c);
          if (options.focus_class) {
            options.focused.removeClass(options.focus_class);
          }
          options.focused = options.focused.prev();
          $c.css({
            'left': -$c.children().first().outerWidth(true)
          });
          return $c.animate({
            'left': 0
          }, options.speed, options.easing, function() {
            $c.children().last().remove();
            if (options.focus_class) {
              options.focused.addClass(options.focus_class);
            }
            return hook('onComplete');
          });
        } else {
          if (!onFirst()) {
            return moveTo(options.focused.prev());
          } else if (options.typewriter) {
            return moveTo($c.children().last());
          }
        }
      };
      startAuto = function(speed) {
        if (speed) {
          options.auto = speed;
        }
        $el.on('mouseenter mouseleave', hoverUpdate);
        looper = setInterval(function() {
          if (!hover) {
            return next();
          }
        }, options.auto);
        return looper;
      };
      stopAuto = function() {
        if (looper) {
          $el.off('mouseenter mouseleave', hoverUpdate);
          return clearInterval(looper);
        }
      };
      hoverUpdate = function(e) {
        hover = e.type === 'mouseenter';
        return hover;
      };
      fill = function() {
        var timeout, _results;
        timeout = 0;
        _results = [];
        while ($c.outerWidth() < $el.innerWidth() && timeout < $c.children().length + 1) {
          timeout++;
          _results.push($c.children().clone().appendTo($c));
        }
        return _results;
      };
      onLast = function() {
        return options.focused[0] === $c.children().last()[0];
      };
      onFirst = function() {
        return options.focused[0] === $c.children().first()[0];
      };
      option = function(key, val) {
        if (val) {
          return options[key] = val;
        } else {
          return options[key];
        }
      };
      hook = function(hookName) {
        if (options[hookName] !== void 0) {
          return options[hookName].call(el, options.focused);
        }
      };
      init();
      return {
        option: option,
        destroy: destroy,
        fill: fill,
        onLast: onLast,
        onFirst: onFirst,
        moveTo: moveTo,
        next: next,
        prev: prev,
        startAuto: startAuto,
        stopAuto: stopAuto
      };
    };
    $.fn[pluginName] = function(options) {
      var args, methodName, returnVal;
      if (typeof arguments[0] === 'string') {
        methodName = arguments[0];
        args = Array.prototype.slice.call(arguments, 1);
        returnVal = null;
        this.each(function() {
          if ($.data(this, "plugin_" + pluginName) && typeof $.data(this, "plugin_" + pluginName)[methodName] === 'function') {
            return (returnVal = $.data(this, "plugin_" + pluginName)[methodName].apply(this, args));
          } else {
            throw new Error("Method " + methodName + " does not exist on jQuery." + pluginName);
          }
        });
        if (returnVal !== void 0) {
          return returnVal;
        } else {
          return this;
        }
      } else if (typeof options === "object" || !options) {
        return this.each(function() {
          if (!$.data(this, 'plugin_' + pluginName)) {
            return $.data(this, "plugin_" + pluginName, new Plugin(this, options));
          }
        });
      }
    };
    return $.fn[pluginName].defaults = {
      next_class: 'next',
      prev_class: 'prev',
      nojs_class: 'nojs',
      focus_class: 'focus',
      focused: false,
      infinite: false,
      easing: 'linear',
      typewriter: false,
      speed: 300,
      hover: false,
      auto: false,
      onInit: function() {},
      onChange: function() {},
      onDestroy: function() {}
    };
  })(jQuery);

}).call(this);
