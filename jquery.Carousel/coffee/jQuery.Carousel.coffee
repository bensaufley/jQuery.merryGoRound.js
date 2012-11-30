###
 * jQuery.carousel
 * A simple jQuery plugin for content carousels
 * Author: Ben Saufley
 *   for Millennium Partners Sports Club Management, LLC
 *   http://sportsclubla.com
 * Based on jQuery plugin boilerplate by Jonathan Nicol @f6design
###
(($) ->
  pluginName = 'carousel'

  # console = window.console || log: ->

  Plugin = (element, options) ->
    el = element
    $el = $(element)
    
    # Container Element
    $c=$el.children().first()
    
    # Nav elements
    $next=$prev=null
    
    # Auto-carousel
    looper = null
    hover  = false

    options = $.extend({}, $.fn[pluginName].defaults, options)

    init = ->
      $el.css
        'overflow-x': 'hidden'
        'position'  : 'relative'
      $c.css
        'position'  : 'absolute'
        'left'      : if options.infinite then 0 else '50%'
      $c.children().removeClass(options.nojs_class) if options.nojs_class
      if options.focused
        options.focused = $(options.focused)
      else
        options.focused = $c.children().first()
      if options.infinite
        if $c.children().first()[0]!=options.focused[0]
          $c.children().first().add($c.children().first().nextUntil($(options.focused))).appendTo($c)
        $(options.focused).addClass(options.focus_class) if options.focus_class
        fill()
      else
        $c.css
          'margin-left' : -(options.focused.outerWidth(true)/2 + options.focused.position().left)
        options.focused.addClass(options.focus_class) if options.focus_class          
      $next = $ '<div />'
        'class' : options.next_class
        'text'  : 'NEXT'
      $prev = $ '<div />'
        'class' : options.prev_class
        'text'  : 'PREVIOUS'
      $next.appendTo($el).on('click tap',next)
      $prev.appendTo($el).on('click tap',prev)
      $next.hide() if onLast()  && !options.infinite && !options.typewriter
      $prev.hide() if onFirst() && !options.infinite && !options.typewriter
      if options.auto!=false
        startAuto()
      hook('onInit')

    destroy = ->
      $el.each ->
        el = this
        $el = $(this)
        $el.css
          'overflow-x'  : ''
          'position'    : ''
        $c.css
          'position'    : ''
          'left'        : ''
          'margin-left' : ''
        $next.add($prev).remove()
        stopAuto()
        $c.addClass(options.nojs_class) if options.nojs_class
        $c.find(".#{options.focus_class}").removeClass(options.focus_class) if options.focus_class
        hook('onDestroy')
        $el.removeData("plugin_#{pluginName}")

    moveTo = (to,speed = options.speed, init) ->
      if options.focused[0]!=to[0]
        if options.infinite
          hook('onStart') if !init
          width = 0
          $first=$c.children().first()
          $moved=$first.add($first.nextUntil(to))
          $moved.each ->
            width += $(this).outerWidth(true)
          options.focused.removeClass(options.focus_class) if options.focus_class
          options.focused=to
          $moved.clone().appendTo($c)
          $c.animate
            'left': -width
            speed
            options.easing
            ->
              options.focused.addClass(options.focus_class) if options.focus_class
              $moved.remove()
              $c.css 'left', 0
              hook('onComplete') if !init
        else
          hook('onStart') if !init
          options.focused.removeClass(options.focus_class) if options.focus_class
          options.focused=to
          if !options.typewriter
            if onLast()
              $next.fadeOut(speed/2)
            else if $next.not(':visible')
              $next.fadeIn(speed/2)
            if onFirst()
              $prev.fadeOut(speed/2)
            else if $next.not(':visible')
              $prev.fadeIn(speed/2)
          $c.animate
            'margin-left' : -(options.focused.outerWidth(true)/2 + options.focused.position().left)
            speed
            options.easing
            ->
              options.focused.addClass(options.focus_class) if options.focus_class
              hook('onComplete') if !init
    
    next = ->
      if options.infinite
        moveTo(options.focused.next())
      else
        if !onLast()
          moveTo(options.focused.next())
        else if options.typewriter
          moveTo($c.children().first())
    
    prev = ->
      if options.infinite
        hook('onStart')
        $c.children().last().clone().prependTo($c)
        options.focused.removeClass(options.focus_class) if options.focus_class
        options.focused=options.focused.prev()
        $c.css 'left' : - $c.children().first().outerWidth(true)
        $c.animate
          'left' : 0
          options.speed
          options.easing
          ->
            $c.children().last().remove()
            options.focused.addClass(options.focus_class) if options.focus_class
            hook('onComplete')
      else
        if !onFirst()
          moveTo(options.focused.prev())
        else if options.typewriter
          moveTo($c.children().last())
    
    startAuto = (speed)->
      if speed then options.auto = speed
      $el.on('mouseenter mouseleave',hoverUpdate)
      looper = setInterval( ->
          if !hover
            next()
        options.auto)
      looper

    stopAuto = ->
      if looper
        $el.off('mouseenter mouseleave',hoverUpdate)
        clearInterval(looper)

    # Helpers

    hoverUpdate = (e)->
      hover = e.type=='mouseenter'
      hover
      
    fill = ->
      timeout = 0
      while $c.outerWidth()<$el.innerWidth() && timeout<$c.children().length+1
        timeout++
        $c.children().clone().appendTo($c)
    
    onLast = ->
      options.focused[0] == $c.children().last()[0]
    onFirst = ->
      options.focused[0] == $c.children().first()[0]

    option = (key, val) ->
      if (val)
        options[key] = val
      else
        return options[key]

    hook = (hookName) ->
      if (options[hookName] != undefined)
        options[hookName].call(el,options.focused)

    init()

    # Public Plugin methods
    return {
      option: option
      destroy: destroy
      fill: fill
      onLast: onLast
      onFirst: onFirst
      moveTo: moveTo
      next: next
      prev: prev
      startAuto: startAuto
      stopAuto: stopAuto
    }

  $.fn[pluginName] = (options) ->
    if (typeof arguments[0] is 'string')
      methodName = arguments[0]
      args = Array.prototype.slice.call(arguments, 1)
      returnVal = null
      this.each ->
        if ($.data(this, "plugin_#{pluginName}") && typeof $.data(this, "plugin_#{pluginName}")[methodName] is 'function')
          return (returnVal = $.data(this, "plugin_#{pluginName}")[methodName].apply(this, args))
        else
          throw new Error("Method #{methodName} does not exist on jQuery.#{pluginName}")
      if (returnVal != undefined)
        return returnVal
      else
        return this
    else if (typeof options is "object" || !options)
      return this.each ->
        if (!$.data(this, 'plugin_' + pluginName))
          $.data(this, "plugin_#{pluginName}", new Plugin(this, options))

  # Default plugin options.
  $.fn[pluginName].defaults =
    next_class : 'next'
    prev_class : 'prev'
    nojs_class : 'nojs'
    focus_class: 'focus'
    focused    : false
    infinite   : false
    easing     : 'linear'
    typewriter : false
    speed      : 300
    hover      : false
    auto       : false
    onInit     : ->
    onStart    : ->
    onComplete : ->
    onDestroy  : ->

)(jQuery)