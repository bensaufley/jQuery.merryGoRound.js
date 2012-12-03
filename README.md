# jQuery.Carousel.js #

A simple, lightweight jQuery plugin for horizontally-scrolling content blocks. Because what everyone really needed was one more carousel plugin.

by Ben Saufley ([@bensaufley](http://twitter.com/bensaufley))  
<http://bensaufley.com>

## Usage ##

Simple **initialization** with all defaults:

```javascript
    $('#frame').carousel()
```

This requires at least two things:
- A frame object, which the plugin will set to `overflow-x: hidden` and (if `position` is not already `absolute` or `relative`) `position: relative`
- A container object, child to the frame object, which will hold all of the elements to be scrolled through and be set to `position: absolute` so as to easily move all of its children

Best practice is to make the frame `overflow-x: auto` so that if javascript is not enabled, the user can still scroll through the gallery.
The container object can be styled by setting its width and floating its children or by setting it as `display: table` and its children `display: table-cell` (see demo).

To **revert** to original state/remove carousel

```javascript
    $('#frame').carousel('destroy')
```

One thing to note is that because of the way jQuery.Carousel loops for an infinite carousel, `$(document).on(event, '.selector', É)` must be used to apply event listeners to gallery objects.
    
## Initialization Options ##

Options can be set on initialization like so:

```javascript
    $('#frame').carousel({
      'auto'    : true,
      'easing'  : 'swing',
      'speed'   : 1500,
      'onStart' : function($sel) {
        $sel.animate({ 'border-width' : '10px' }, 300)
      }
    })
```

- `auto`:
    - Auto-scroll.
    - **Default:** `false`
- `infinite`:
    - Infinite scrolling.
    - **Default:** `false`
- `easing`:
    - jQuery easing value. This plugin doesn't use jQuery UI so the only two options are `swing` and `linear`. You should be able to use more if you include jQuery UI's easing controls.
    - **Default:** `'linear'`
- `typewriter`:
    - Wraparound effect for non-infinite scrolling. When the user gets to the end of the set, the "next" button will remain, and triggering it will send the user back (like a typewriter resetting) to the start. The inverse is true with the "previous" button.  
    If set as `false`, the "next" and "previous" buttons fade out when on last and first elements respectively.
    - **Default:** `false`
- `speed`:
    - Scroll speed.
    - **Default:** `300`
- `next_class`
    - Class for `div` element which will function as "next" button. Carousel creates this element and appends it to the container object. 
    - **Default:** `'next'`
- `prev_class`:
    - Class for `div` element which will function as "previous" button. Carousel creates this element and appends it to the container object. 
    - **Default:** `'prev'`
- `nojs_class`:
    - Class to remove from gallery objects (and replace on `destroy`). Useful if you want to have a `:hover` state that only applies if jQuery.Carousel isn't enabled, for example.
    - **Default:** `false`
- `focus_class`:
    - Class to add to the element currently in focus. Set as `false` if you don't need it.
    - **Default:** `'focus'`
- `onInit`:
    - Function that passes the currently-focused child in a jQuery object for manipulation after the carousel is initialized.
    - **Default:** `function($sel) { }`
- `onStart`:
    - Function that passes the currently-focused child in a jQuery object for manipulation before moving the carousel.
    - Example usage: to de-emphasize the focused object before the focus changes:
      ```javascript
      function($sel) {  
        $sel.animate({ 'font-size' : 10px }, 300)  
      }
      ```
    - **Default:** `function($sel) { }`
- `onComplete`:
    - Function that passes the currently-focused child in a jQuery object for manipulation after moving the carousel.
    - Example usage: to emphasize the newly-focused object after the focus changes:
      ```javascript
      function($sel) {  
        $sel.animate({ 'font-size' : 16px }, 300)  
      }
      ```
    - **Default:** `function($sel) { }`
- `onDestroy`:
    - Function to run after the carousel is destroyed.
    - **Default:** `function($sel) { }`
- `hover`:
    - The hover state. Used to stop auto-scrolling when the mouse is hovering over the carousel. Not sure there's any use in manipulating it, but here it is if you need to, or just to know it.
    - **Default:** `false`
- `focused`:
    - Stores the currently-focused object. Setting it on initialize will tell the plugin to focus on an element other than the first child of the container element.
    - **Default:** `false`

## Methods ##

Methods can be applied to an active carousel instance like so:

```javascript
    $('#frame').carousel('option','hover') // Returns hover state  
    $('#frame').carousel('option','onComplete',function() { }) // Changes onComplete function to empty function  
    $('#frame').carousel('startAuto') // Starts automatic scrolling
```

- `option` ( *function([opt])* ):
    - If one value is passed, it returns the value of the option.
    - If two values are passed, it sets the value of the option.
- `destroy` ( *function()* ): Destroys the instance of jQuery.Carousel
- `fill` ( *function()* ): Fills the space of the frame element with duplicate sets of the container's children until the container is wider than the frame. This is run on initialization, but may need to be run on window.resize for example
- `onLast` ( *bool* ): Whether the carousel is on the last object
- `onFirst` ( *bool* ): Whether the carousel is on the first object
- `moveTo` ( *function($e)* ): Function that can be passed a child element of the container to scroll directly to that object. Eg:
  ```javascript
  $(document).on('click tap','#frame > .container > *',function() {  
    $('#frame').carousel('moveTo',$(this))  
  })
  ```
- `next` ( *function()* ): Triggers the carousel to move to the next object if available. Useful for custom navigation.
- `prev` ( *function()* ): Triggers the carousel to move to the previous object if available. Useful for custom navigation.
- `startAuto` ( *function()* ): Starts auto-scroll.
- `stopAuto` ( *function()* ): Stops auto-scroll.