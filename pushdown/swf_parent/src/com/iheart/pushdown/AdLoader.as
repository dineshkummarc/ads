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
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	internal class AdLoader extends Loader {
		public static const GOOD:String = 'onGood';
		public static const BAD:String = 'onBad';
		public static const OPEN:String = 'onOpenClick';
		public static const CLOSE:String = 'onCloseClick';
		public static const MOUSE_OUT:String = 'onMouseOver';
		public static const MOUSE_OVER:String = 'onMouseOut';
		
		private var _clickthrough:String;
		private var _customClickthrough:Boolean = false;
		private var _duration:int = 0;
		private var _open:Function = null;
		private var _close:Function = null;
		private var _click:Function = null;
		
		public function AdLoader(url:String, clickthrough:String) {
			_clickthrough = clickthrough;
			
			var request:URLRequest = new URLRequest(url);
			
			contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onBad);
			contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onBad);
			
			load(request);
		}
		
		/**
		 * Methods for Pushdown to control loaded swf
		 */
		
		public function destroyAd():void {
			unload();
		}
		
		public function get animationDuration():int {
			return _duration;
		}
		
		public function get customClickthrough():Boolean {
			return _customClickthrough;
		}
		
		public function openAd(e:Event):void {
			if (e) {
				e.stopImmediatePropagation()
			}
			
			dispatchEvent(new Event(OPEN));
			_open();
		}
		
		public function closeAd(e:Event):void {
			if (e) {
				e.stopImmediatePropagation()
			}
			
			dispatchEvent(new Event(CLOSE));
			_close();
		}
		
		/**
		 * Event handlers
		 */
		
		private function onBad(e:Event):void {
			destroyAd();
			dispatchEvent(new Event(BAD));
		}
		
		private function onClick(e:Event):void {
			navigateToURL(new URLRequest(_clickthrough));
		}
		
		
		private var _mouseTimeout:uint;
		private function onMouseOver(e:Event):void {
			if (!_mouseTimeout) {
				dispatchEvent(new Event(MOUSE_OVER));
			} else {
				clearTimeout(_mouseTimeout);
			}
		}
		
		private function onMouseOut(e:Event):void {
			//stop the crazy slew of events that come from moving
			//the moust around the canvas
			_mouseTimeout = setTimeout(function():void {
				_mouseTimeout = 0;
				dispatchEvent(new Event(MOUSE_OUT));
			}, 1);
		}
		
		private function setButtonMode(el:DisplayObject):void {
			if (el.hasOwnProperty('buttonMode')) {
				el['buttonMode'] = true;
			}
			
			if (el.hasOwnProperty('useHandCursor')) {
				el['useHandCursor'] = true;
			}
		}
		
		/**
		 * Methods for the loaded swf
		 */
		
		public function addOpenHandler(btn:DisplayObject):void {
			//only 1 callback should be added, or CRAZY CRAP happens
			btn.removeEventListener(MouseEvent.CLICK, openAd);
			btn.addEventListener(MouseEvent.CLICK, openAd);
			setButtonMode(btn);
		}
		
		public function addCloseHandler(btn:DisplayObject):void {
			//only 1 callback should be added, or CRAZY CRAP happens
			btn.removeEventListener(MouseEvent.CLICK, closeAd);
			btn.addEventListener(MouseEvent.CLICK, closeAd);
			setButtonMode(btn);
		}
		
		public function set openCallback(callback:Function):void {
			_open = callback;
		}
		
		public function set closeCallback(callback:Function):void {
			_close = callback;
		}
		
		public function clickthrough(el:InteractiveObject):void {
			_customClickthrough = true;
			
			el.removeEventListener(MouseEvent.CLICK, onClick);
			el.addEventListener(MouseEvent.CLICK, onClick);
			setButtonMode(el);
		}
		
		private var _adReady:Boolean = false;
		public function adReady():void {
			if (_adReady) {
				return;
			}
			
			_adReady = true;
			
			if (_open != null && _close != null) {
				dispatchEvent(new Event(GOOD));
				
				addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				
				if (!_customClickthrough) {
					removeEventListener(MouseEvent.CLICK, onClick);
					addEventListener(MouseEvent.CLICK, onClick);
				}
			} else {
				dispatchEvent(new Event(BAD));
			}
		}
		
		public function set animationDuration(duration:int):void {
			_duration = duration < 0 ? 0 : duration;
		}
	}
}