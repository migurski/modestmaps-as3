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
	public class YahooOverlayMapProvider 
		extends AbstractYahooMapProvider 
		implements IMapProvider
	{
		override public function toString():String
		{
			return "YAHOO_OVERLAY";
		}
		
		/**
		 * Yahoo sprites are 258x258 to deal with Flash pixel fudge, we mask and offset them by
		 * one pixel so they show up correctly.
		 */
		override public function paint(sprite:Sprite, coord:Coordinate):void 
		{			
			var overlay:Sprite = new Sprite();
			overlay.name = "overlay";
			sprite.addChild(overlay);
			
			var request:MapProviderPaintThrottledRequest = new MapProviderPaintThrottledRequest(overlay, getOverlayTileUrl( coord ), coord );
			request.addEventListener(ThrottledRequestEvent.REQUEST_ERROR, onRequestError);
			request.addEventListener(ThrottledRequestEvent.RESPONSE_COMPLETE, onResponseComplete);
			request.addEventListener(ThrottledRequestEvent.RESPONSE_ERROR, onResponseError);
			request.send();

			overlay.x = overlay.y = -1;
			overlay.scaleX = overlay.scaleY = 257.0/256.0;
	
			createMask( sprite );		
		}	
		
		private function getOverlayTileUrl(coord:Coordinate):String
		{		
	        return "http://us.maps3.yimg.com/aerial.maps.yimg.com/img?md=200608221700&v=2.0&t=h" + getZoomString(sourceCoordinate(coord));
		}
		
		
		private function getZoomString( coord:Coordinate ):String
		{		
	        var row:Number = ( Math.pow( 2, coord.zoom ) /2 ) - coord.row - 1;
	
			var zoomString:String = "&x=" + coord.column + 
				"&y=" + row + 
				"&z=" + ( 18 - coord.zoom );
			return zoomString; 
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