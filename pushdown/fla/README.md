# Flash Pushdown Creation

If you are looking to create a flash pushdown for iheart.com, you are in the right place.  Let's take a look at the basic steps behind creating a pushdown:

## Testing Your Pushdown

If you wish to test your pushdown before submitting, check out [the test page](test).

## Good-to-knows

* The pushdown must start in a closed state.  If it is going to be auto-opened, it will recieve a call to [open()](#the-open-callback) right after the call to [adReady](#ad-ready) is made.

* Both the `open()` and `close()` callbacks must be set in order for a pushdown to display.

* By default, the entire pushdown, minus the registered open and close buttons, will handle click events and open up the clickthrough address.
	
	* DO NOT implement your own clickthrough handling in the pushdown; all click-handling element should be passed to `swf_parent` with `p['clickthrough'](openBtn)` (see [Clickthrough Events](#clickthrough-events) below).

## The Template

`pushdown.fla` contains all of the method calls and configuration options to interact with `swf_parent`.  Let's step through all of the options found in the first frame in the Config layer.

### Boilerplate Initialization Code

The following code is required to be present so that the pushdown can interact with `swf_parent`, and vice-versa.

```actionscript
import flash.system.Security;
import flash.display.DisplayObject;
import flash.utils.getQualifiedClassName;
Security.allowDomain('*');

var p:DisplayObject = parent;
while (true) {
	//when using gotoAndPlay(1), the parent changes, so we have to climb
	if (getQualifiedClassName(p) == 'com.iheart.pushdown::AdLoader') {
		break;
	}
	p = p.parent;
}
```

### Animation Duration

This is the amount of time that the animation that expands the pushdown will take. If you wish for your animation to be a different length than the default, be sure to keep in mind that this is in milliseconds.

For more information, see the [open() and close()](#open-and-close-callbacks) callbacks below.

```actionscript
//time in milliseconds for open and close animations
p['animationDuration'] = 250;
```

### Open and Close Handlers

Each flash pushdown must include at least two buttons: one for expanding the pushdown, another for closing it. Our default buttons ([close](assets/default_close.png) and [expand](assets/default_expand.png)) use the text "Close" and "Expand" to indicate these two actions, but the actual wording and appearance in your ad are up to you.

In the event that you wish to have multiple open and close buttons on the pushdown, you simply need to call the respective functions below multiple times, each time passing in the new button.

These two methods may be called multiple times with the same element; any duplicates are simply ignored.

```actionscript
//any number of open and close buttons can be added
//they can be added at any point in the video, duplicate adds are ignored
p['addCloseHandler'](closeBtn);
p['addOpenHandler'](openBtn);
```

### Open and Close Callbacks

Since the iheart.com is ultimately responsible for displaying the ad and interactions, you must listen for events from the page and respond accordingly.  To this end, there are two methods that must be defined; their actual implementation is up to you.

#### The Open Callback

This callback is called right when the animation that expands the pushdown has begun. Once this method is called, you should immediately begin to expand the pushdown, and that expansion should last the amount of time you specified in `Animation Duration` above.

In the example implementation, we merely go to frame 2 and play until frame 14, 500 milliseconds later, when the open animation completes.  At this point, the pushdown is completely expanded, and you are free to do whatever you wish.  In the example, we merely made an iPad and an Android Phone dance.

#### The Close Callback

The close callback follows all the same rules as the open callback, except for one important, and obvious, difference: it closes the pushdown.

The example implementation jumps to frame 31, plays until 43, when the pushdown is fully collapsed, and then jumps to frame 1, where it stops playback.

#### Relevant Code

In this example, our simple implementation of the methods `open()` and `close()` are passed to `swf_parent`, and we are all set to go.

Warning: if you do not set these two methods, the pushdown will be regarded as invalid and it will not be displayed.

```actionscript
function open():void{
	gotoAndPlay(2);
}

function close():void{
	gotoAndPlay(31);
}

//there can (and must) only be 1 open and close callback
//these must be set in this frame, before the movie begins, for the ad to work
p['openCallback'] = open;
p['closeCallback'] = close;
```

### Clickthrough Events

Like any ad, there should be a way for the user to click on the ad and go to the relevant webpage for what is being advertised.  By default, the entire banner, minus the open and close buttons, is a clickable element that will send the user to the clickthrough address.  If you want to get fancy and specify your own clickthrough elements, you may do so as follows, but keep in mind that the default clickthrough will be disabled.

Simply pass in an element to the below method, and it will be set to handle clicks.  You may pass as many elements as you want, as many times as you want.

```actionscript
//if you want to handle clickthrough events by yourself, you'll need:
//be aware: any call to the following method will completely disable the default clickthrough handling
p['clickthrough'](openBtn);
```

### Ad Ready

The final step in displaying your ad on iheart.com is to tell `swf_parent` that you're ready for display.  Without this, your pushdown will never show.

```actionscript
//once the preparations to display the ad have been complete, call this.
//by default, the ad should show in a closed state; once adReady has been called,
//however, it might receive an immediate call to open()
//
//this method has no effect after the first call; any future calls will do nothing
p['adReady']();
```

### Stop

The final bit of code in the first frame of `Config` is a call to `stop()`.  This is not necessary, and you may delete it / do whatever you please to queue up your pushdown and manage video flow.

```actionscript
//not required
stop();
```