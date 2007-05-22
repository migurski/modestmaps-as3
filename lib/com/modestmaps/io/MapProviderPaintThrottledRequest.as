package com.modestmaps.io
{
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.io.LoadMovieThrottledRequest;
	import com.modestmaps.io.ThrottledRequest;
	import com.modestmaps.events.ThrottledRequestEvent;
	import com.modestmaps.events.ThrottledRequestErrorEvent;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.display.Sprite;

	/**
	 * @author darren
	 */
	public class MapProviderPaintThrottledRequest extends LoadMovieThrottledRequest 
	{
		[Event(name="responseComplete", type="com.modestmaps.events.ThrottledRequestEvent")]

		private var _coord:Coordinate;
		
		public function MapProviderPaintThrottledRequest(sprite:Sprite, url:String, coord:Coordinate)
		{
			super(sprite, url);
			_coord = coord;
		}

		private function onClipAdded(event:Event):void
		{
			var e:ThrottledRequestEvent = new ThrottledRequestEvent(ThrottledRequestEvent.RESPONSE_COMPLETE);
			e.sprite = _sprite;
			e.request = _request;
			e.status = _httpStatus;
			e.coord = _coord;
			dispatchEvent(e);
			cleanup();
		}
		
		// needs to be overridden so that we have access to coord
		override protected function onSpriteLoaded(event:Event):void
		{
//			trace("MapProviderPaintThrottledRequest.onSpriteLoaded()!");
			var e:ThrottledRequestEvent = new ThrottledRequestEvent(ThrottledRequestEvent.RESPONSE_COMPLETE);
			e.sprite = _sprite;
			e.request = _request;
			e.coord = coord;
			
			_sprite.addChild(_loader);
			
			dispatchEvent(e);
			cleanup();
		}
		
		// again, overridden for access to coord
		override protected function onLoadError(event:IOErrorEvent):void
		{
//			trace("MapProviderPaintThrottledRequest.onLoadError()!");
			var e:ThrottledRequestEvent = new ThrottledRequestErrorEvent(ThrottledRequestEvent.RESPONSE_ERROR);
			e.sprite = _sprite;
			e.status = _httpStatus;
			e.request = _request;
			e.coord = coord;
			dispatchEvent(e);
			cleanup();
		}

		
		public function get coord():Coordinate
		{
			return _coord;
		}
	}
}
