/**
 *	Copyright (c) 2012 Andrew Stone
 *	This file is part of ads-creation-kit.
 *
 *	ads-creation-kit is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	ads-creation-kit is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with ads-creation-kit.  If not, see <http://www.gnu.org/licenses/>.
 */
package com.iheart.pushdown {
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	
	public class Pushdown extends Sprite {
		private static var JS_PREFIX:String;
		
		if (CONFIG::DEBUG) {
			JS_PREFIX = 'swf.';
		} else {
			JS_PREFIX = 'IHR.utils.ads.types.pushdown.swf.';
		}
		
		private var _ad:AdLoader;
		
		public function Pushdown() {
			if (!ExternalInterface.available) {
				throw new Error("ExternalInterface must be enabled.")
			}
			
			Security.allowDomain('*');
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			ExternalInterface.addCallback('load', loadPushdown);
			ExternalInterface.addCallback('destroy', destroyPushdown);
			ExternalInterface.addCallback('open', openPushdown);
			ExternalInterface.addCallback('close', closePushdown);
			
			ExternalInterface.call(JS_PREFIX + 'ready');
		}
		
		private function loadPushdown(ord:String, url:String, clickthrough:String, startOpened:Boolean):void {
			destroyPushdown();
			_ad = new AdLoader(url, clickthrough);
			
			_ad.addEventListener(AdLoader.GOOD, function(e:Event):void {
				if (ExternalInterface.call(JS_PREFIX + 'loaded', ord) !== false) {
					addChild(_ad);
					
					//if there's a custom clickthrough, we're not a button; if there isn't,
					//we are a button
					buttonMode = !_ad.customClickthrough;
					
					if (startOpened) {
						openPushdown();
					}
				} else {
					destroyPushdown();
				}
			});
			
			_ad.addEventListener(AdLoader.BAD, function(e:Event):void {
				ExternalInterface.call(JS_PREFIX + 'error', ord);
			});
			
			_ad.addEventListener(AdLoader.OPEN, function(e:Event):void {
				ExternalInterface.call(JS_PREFIX + 'open', ord, _ad.animationDuration);
			});
			
			_ad.addEventListener(AdLoader.CLOSE, function(e:Event):void {
				ExternalInterface.call(JS_PREFIX + 'close', ord, _ad.animationDuration);
			});
			
			_ad.addEventListener(AdLoader.MOUSE_OVER, function(e:Event):void {
				ExternalInterface.call(JS_PREFIX + 'mouseover');
			});

			_ad.addEventListener(AdLoader.MOUSE_OUT, function(e:Event):void {
				ExternalInterface.call(JS_PREFIX + 'mouseout');
			});
		}
		
		private function destroyPushdown():void {
			if (_ad) {
				if (contains(_ad)) {
					//raises an exception...awesome
					removeChild(_ad);
				}
				
				_ad.destroyAd();
			}
			
			_ad = null;
			
			buttonMode = false;
		}
		
		private function openPushdown():void {
			if (_ad) {
				_ad.openAd(null);
			}
		}
		
		private function closePushdown():void {
			if (_ad) {
				_ad.closeAd(null);
			}
		}
	}
}