
package com.modestmaps.io
{
	import com.modestmaps.io.IRequest;
	import com.modestmaps.io.ThrottledRequest;
	import com.modestmaps.events.ThrottledRequestEvent;
	import com.modestmaps.events.ThrottledRequestErrorEvent;

	import flash.display.Loader;
	import flash.system.LoaderContext;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.display.LoaderInfo;

	/**
	 * @author darren
	 */
	public class LoadMovieThrottledRequest
		extends ThrottledRequest 
		implements IRequest
	{
		protected var _sprite:Sprite;
		protected var _loader:Loader;
		protected var _request:URLRequest;
		protected var _httpStatus:int;
		
		public function LoadMovieThrottledRequest(sprite:Sprite, url:String) 
		{
			super(url, false);
			_sprite = sprite;
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.INIT, onSpriteLoaded);
			// _loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoaderProgress);
			
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			_loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
		}

		protected function onLoaderProgress(event:ProgressEvent):void
		{
			var info:LoaderInfo = event.target as LoaderInfo;
			trace("loaded: " + info.bytesLoaded + " of " + info.bytesTotal + " total bytes");
		}
		
		override public function send():void
		{
			if (!_sprite || !_url)
			{
				var event:ThrottledRequestEvent = new ThrottledRequestEvent(ThrottledRequestEvent.REQUEST_ERROR);
				event.message = Boolean(_sprite) ? "No URL provided!" : "No sprite provided!";
				dispatchEvent(event);
				cleanup();
			}
			else
			{
				super.send();
			}			
		}
	
		/*
		 * To be called by the throttler.
		 */
		override public function execute():void
		{
//			trace("LoadMovieThrottledRequest.execute(): loading '" + _url + "'...");
			_request = new URLRequest(_url);
			
			// adding a context in a vain attempt to work out 
			// security issues - doesn't seem to have an effect
//			var context:LoaderContext = new LoaderContext();
//			context.checkPolicyFile = false;
//			_loader.load(_request, context);
			
			_loader.load(_request);
		}
	
		// Protected Methods
	
		/*
		 * Cleans up after a request or response.
		 */
		protected function cleanup():void
		{
			if (_loader)
			{
				/*
				 * FIXME: there must be a better way to know if the Loader has an open connection.
				 * For now, we'll just try to close it and catch the exception if it hasn't been
				 * opened yet.
				 */
				try
				{
					_loader.close();
				}
				catch (e:Error)
				{
					// trace("LoadMovieThrottledRequest.cleanup(): unable to close loader! " + e.message);
				}
			}
		}
	
		// Event Handlers

		protected function onHTTPStatus(event:HTTPStatusEvent):void
		{
			_httpStatus = event.status;
		}
		
		// overridden by MapProviderPaintThrottledRequest to be coord aware
		protected function onSpriteLoaded(event:Event):void
		{
			var e:ThrottledRequestEvent = new ThrottledRequestEvent(ThrottledRequestEvent.RESPONSE_COMPLETE);
			e.sprite = _sprite;
			e.request = _request;
			
			_sprite.addChild(_loader);

			dispatchEvent(e);
			cleanup();
		}

		// overridden by MapProviderPaintThrottledRequest to be coord aware
		protected function onLoadError(event:IOErrorEvent):void
		{
//			trace("LoadMovieThrottledRequest.onLoadError()!");
			var e:ThrottledRequestEvent = new ThrottledRequestErrorEvent(ThrottledRequestEvent.RESPONSE_ERROR);
			e.sprite = _sprite;
			e.status = _httpStatus;
			e.request = _request;
			dispatchEvent(e);
			cleanup();
		}
	}
}
