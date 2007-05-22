package com.modestmaps.mapproviders.google
{
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.io.MapProviderPaintThrottledRequest;
	import com.modestmaps.mapproviders.google.AbstractGoogleMapProvider;
	import com.modestmaps.mapproviders.google.GoogleAerialMapProvider;
	import com.modestmaps.mapproviders.IMapProvider;
	import flash.display.Sprite;
	import com.modestmaps.events.ThrottledRequestEvent;
	
	/**
	 * @author darren
	 */
	public class GoogleHybridMapProvider 
		extends AbstractGoogleMapProvider 
		implements IMapProvider
	{
		protected var __gamp:GoogleAerialMapProvider;
		
		public function GoogleHybridMapProvider()
		{
			super();
			__gamp = new GoogleAerialMapProvider();
		}
		
		override public function toString():String
		{
			return "GOOGLE_HYBRID";
		}
	
		override public function paint( sprite:Sprite, coord:Coordinate ):void 
		{
			checkVersionRequested();
			
			if (__hybridVersion)
			{		
				var bg:Sprite = new Sprite();
				bg.name = "bg";
				sprite.addChild(bg);
				
				var overlay:Sprite = new Sprite();
				overlay.name = "overlay";
				sprite.addChild(overlay);

				var request:MapProviderPaintThrottledRequest = new MapProviderPaintThrottledRequest(bg, getBGTileUrl(coord), coord);
				request.addEventListener(ThrottledRequestEvent.REQUEST_ERROR, onRequestError);
				request.addEventListener(ThrottledRequestEvent.RESPONSE_COMPLETE, onResponseComplete);
				request.addEventListener(ThrottledRequestEvent.RESPONSE_ERROR, onResponseError);
				request.send();
		
				request = new MapProviderPaintThrottledRequest(overlay, getOverlayTileUrl(coord), coord);
				request.addEventListener(ThrottledRequestEvent.REQUEST_ERROR, onRequestError);
				request.addEventListener(ThrottledRequestEvent.RESPONSE_COMPLETE, onResponseComplete);
				request.addEventListener(ThrottledRequestEvent.RESPONSE_ERROR, onResponseError);
				request.send();
			}
			else
			{
				enqueuePaintRequest( sprite, coord );
			}
			
			//createLabel( sprite, coord.toString() );
		}	
	
		protected function getBGTileUrl(coord:Coordinate):String
		{		
			return __gamp.getTileUrl(coord);
		}
	
		protected function getOverlayTileUrl(coord:Coordinate):String
		{		
	        var sourceCoord:Coordinate = sourceCoordinate(coord);
	        var zoomString:String = "&x=" + sourceCoord.column + "&y=" + sourceCoord.row + "&zoom=" + (17 - sourceCoord.zoom);
			return "http://mt" + Math.floor(Math.random() * 4) + ".google.com/mt?n=404&v=" + __hybridVersion + zoomString;
		}
	
		// Event Handlers
		
		override protected function onResponseComplete(event:ThrottledRequestEvent):void
		{
			var sprite:Sprite = event.sprite;
			var coord:Coordinate = event.coord;
			// this is broken!
			// if (sprite.getChildByName("bg").loaded && sprite.getChildByName("overlay").loaded)
			if (true)
			{
				raisePaintComplete(sprite.parent as Sprite, coord);
			}
		}
	}
}