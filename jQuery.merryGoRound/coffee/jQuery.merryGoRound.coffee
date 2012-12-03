###
 * jQuery.merryGoRound
 * v1.01
 * last updated 2012-12-03
 *
 * A simple jQuery plugin for content carousels.
 * Full documentation available at http://github.com/bensaufley/jquery.
 *
 * Author: Ben Saufley
 *     http://bensaufley.com
 *
 * Based on jQuery plugin boilerplate by Jonathan Nicol @f6design
###
(($) ->
  pluginName = 'merrygoround'

  # If you want to use console, this is just
  # to make sure it works in IE, and that it's
  # defined for code linters:
  #
  # console = window.console || log: ->

  Plugin = (element, options) ->
    el  = element
    $el = $(element)
    
    # Container Element
    $c=$el.children().first()
    
    # Nav elements
    $next=$prev=$('')

    # Auto-carousel
    looper = null
    hover  = false
    
    # Queuing
    queued = false

    # Implements defaults where the user hasn't defined explicit
    # values for options.
    options = $.extend({}, $.fn[pluginName].defaults, options)

    init = ->
      $el.css
        'overflow-x': 'hidden'
        'position'  : 'relative'
      $c.css
        'position'  : 'absolute'
        'left'      : '50%'
      $c.children().removeClass(options.nojs_class) if options.nojs_class
      if options.focused
        options.focused = $(options.focused)
      else
        options.focused = $c.children().first()
      if options.infinite
        if $c.children().first()[0]!=options.focused[0]
          $c.children().first().add($c.children().first().nextUntil($(options.focused))).appendTo($c)
        fill()
        width=0
        $half=null
        cwidth = 0
        $c.children().each ->
          cwidth+=$(this).outerWidth(true)
        options.focused.nextAll().each ->
          width+=$(this).outerWidth(true)
          $half=$(this)
          false if width>=cwidth/2
        $half.add($half.nextAll()).prependTo($c)
      moveTo(options.focused,0,true)
      if options.nextbtn != false
        if typeof options.nextbtn =='object'
          $next = options.nextbtn
        else
          $next = $ '<div />'
            'class' : options.nextbtn
            'text'  : 'NEXT'
          $next.appendTo($el).on('click tap',next)
        $next.hide() if onLast() && !options.infinite && !options.typewriter
      if options.prevbtn != false
        if typeof options.prevbtn == 'object'
          $prev = options.prevbtn
        else
          $prev = $ '<div />'
            'class' : options.prevbtn
            'text'  : 'PREVIOUS'
          $prev.appendTo($el).on('click tap',prev)
        $prev.hide() if onFirst() && !options.infinite && !options.typewriter
      startAuto() if options.auto
      hook('onInit')

    destroy = ->
      $el.each ->
        $el = $(this)
        $el.css
          'overflow-x'  : ''
          'position'    : ''
        $c.css
          'position'    : ''
          'left'        : ''
          'margin-left' : ''
        if typeof options.nextbtn != 'object'
          $next.remove()
        if typeof options.prevbtn != 'object'
          $prev.remove()
        stopAuto()
        $c.addClass(options.nojs_class) if options.nojs_class
        $c.find(".#{options.focus_class}").removeClass(options.focus_class) if options.focus_class
        hook('onDestroy')
        $el.removeData("plugin_#{pluginName}")

    moveTo = (to,speed = options.speed,init) ->
      if !queued
        queued = true
        if options.focused[0]!=to[0] || init
          hook('onStart') if !init
          if options.infinite && !init
            ind = options.focused.index()
            movewidth = 0
            $moving   = []
            width     = 0
            # This is a lot of code to move the right amount of
            # children from one side to the other on scroll.
            if ind > to.index()
              to.add(to.nextUntil(options.focused)).each ->
                movewidth += $(this).outerWidth(true)
              fromEnd = Array.prototype.slice.call($c.children().last().prevUntil(options.focused).add($c.children().last())).reverse()
              for e, i in fromEnd
                width += $(e).outerWidth(true)
                $moving[i] = $(e)
                $(e).clone().prependTo($c)
                break if width >= movewidth
              $c.css('margin-left',"-=#{width}")
            else
              to.add(to.prevUntil(options.focused)).each ->
                movewidth += $(this).outerWidth(true)
              $c.children().first().add($c.children().first().nextUntil(options.focused)).each (i) ->
                width += $(this).outerWidth(true)
                $moving[i] = $(this)
                $(this).clone().appendTo($c)
                false if width >= movewidth
          else
            if !options.typewriter
              if onLast()
                $next.fadeOut(speed/2)
              else if $next.not(':visible')
                $next.fadeIn(speed/2)
              if onFirst()
                $prev.fadeOut(speed/2)
              else if $next.not(':visible')
                $prev.fadeIn(speed/2)
          options.focused.removeClass(options.focus_class) if options.focus_class
          $c.animate
            'margin-left' : -(to.outerWidth(true)/2 + to.position().left)
            speed
            options.easing
            ->
              options.focused = to
              options.focused.addClass(options.focus_class) if options.focus_class
              if options.infinite && $moving
                for e, i in $moving
                  $(e).remove()
                $c.css 'margin-left', -(options.focused.outerWidth(true)/2 + options.focused.position().left)
              queued = false
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
        moveTo(options.focused.prev())
      else
        if !onFirst()
          moveTo(options.focused.prev())
        else if options.typewriter
          moveTo($c.children().last())

    #Auto-scrolling
    
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
      while $c.outerWidth()<$el.innerWidth() && timeout < 25
        $c.children().clone().appendTo($c)
        timeout++
    
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
    nextbtn    : 'next'
    prevbtn    : 'prev'
    nojs_class : false
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