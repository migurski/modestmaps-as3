package com.modestmaps.mapproviders.yahoo
{
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.io.MapProviderPaintThrottledRequest;
	import com.modestmaps.events.*;
	import com.modestmaps.mapproviders.IMapProvider;
	import com.modestmaps.mapproviders.yahoo.AbstractYahooMapProvider;
	import flash.display.Sprite;
	import flash.system.LoaderContext;
	import flash.display.LoaderInfo;
	
	/**
	 * @author darren
	 */
	public class YahooHybridMapProvider 
		extends AbstractYahooMapProvider 
		implements IMapProvider
	{
		override public function toString():String
		{
			return "YAHOO_HYBRID";
		}
		
		/**
		 * Yahoo sprites are 258x258 to deal with Flash pixel fudge, we mask and offset them by
		 * one pixel so they show up correctly.
		 */
		override public function paint(sprite:Sprite, coord:Coordinate):void 
		{
			var bg:Sprite = new Sprite();
			bg.name = "bg";
			sprite.addChild(bg);
			
			var overlay:Sprite = new Sprite();
			overlay.name = "overlay";
			sprite.addChild(overlay);
			
			var request:MapProviderPaintThrottledRequest = new MapProviderPaintThrottledRequest(bg, getBGTileUrl( coord ), coord );
			request.addEventListener(ThrottledRequestEvent.REQUEST_ERROR, onRequestError);
			request.addEventListener(ThrottledRequestEvent.RESPONSE_COMPLETE, onResponseComplete);
			request.addEventListener(ThrottledRequestEvent.RESPONSE_ERROR, onResponseError);
			request.send();
	
			request = new MapProviderPaintThrottledRequest(overlay, getOverlayTileUrl( coord ), coord );
			request.addEventListener(ThrottledRequestEvent.REQUEST_ERROR, onRequestError);
			request.addEventListener(ThrottledRequestEvent.RESPONSE_COMPLETE, onResponseComplete);
			request.addEventListener(ThrottledRequestEvent.RESPONSE_ERROR, onResponseError);
			request.send();

			bg.x = bg.y = -.5;
			overlay.x = overlay.y = -.5;
	
			createMask( sprite );		
		}	
	
		private function getBGTileUrl(coord:Coordinate):String
		{		
	        return "http://us.maps3.yimg.com/aerial.maps.yimg.com/tile?v=1.7&t=a" + getZoomString(sourceCoordinate(coord));
		}
	
		private function getOverlayTileUrl(coord:Coordinate):String
		{		
			return "http://us.maps3.yimg.com/aerial.maps.yimg.com/png?v=2.2&t=h" + getZoomString(sourceCoordinate(coord));
		}
		
		
		private function getZoomString( coord:Coordinate ):String
		{		
	        var row:Number = ( Math.pow( 2, coord.zoom ) /2 ) - coord.row - 1;
			return "&x=" + coord.column + "&y=" + row + "&z=" + (18 - coord.zoom);
		}	
	
		private function isClipLoaded( sprite:Sprite ):Boolean
		{
			var info:LoaderInfo = sprite.loaderInfo;
			return info.bytesTotal > 0 && info.bytesLoaded == info.bytesTotal;
		}
	
		// Event Handlers
		
		override protected function onResponseComplete(event:ThrottledRequestEvent):void
		{
			/*
			// HAKT
			var bgClip:Sprite = sprite._parent.bg;
			var overlayClip:Sprite = sprite._parent.overlay;
			
			if ( isClipLoaded( bgClip ) && isClipLoaded( overlayClip ) )
			{
				raisePaintComplete( sprite._parent, coordinate );
			}
			*/
		}
	}
}