/**
 * vim:et sts=4 sw=4 cindent:
 * @ignore
 *
 * @author darren
 * @author migurski
 *
 * AbstractImageBasedMapProvider is the base class for all MapProviders
 * that use externally loaded images to paint Tiles.
 * 
 * @see com.modestmaps.mapproviders.AbstractMapProvider
 */

package com.modestmaps.mapproviders
{ 
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.io.MapProviderPaintThrottledRequest;
	import com.modestmaps.events.ThrottledRequestEvent;
	import com.modestmaps.mapproviders.AbstractMapProvider;
	import flash.display.Sprite;
	import com.modestmaps.events.ThrottledRequestErrorEvent;
	import flash.events.ErrorEvent;
	
	public class AbstractImageBasedMapProvider
		extends AbstractMapProvider 
	{
		/**
		 * Abstract constructor, should not be instantiated directly.
		 */
		public function AbstractImageBasedMapProvider() 
		{
			super();
		}
	
		/**
		 * Generates a new MapProviderPaintThrottledRequest to load in an 
		 * external image.
		 * 
		 * @see com.modestmaps.mapproviders.AbstractMapProvider
	 	 * @param sprite The Sprite to contain the graphics.
		 * @param coord The coordinate of the Tile that contains the sprite.
		 */
		override public function paint(sprite:Sprite, coord:Coordinate):void 
		{
			super.paint(sprite, coord);

			var image:Sprite = sprite.getChildByName("image") as Sprite;
			var request:MapProviderPaintThrottledRequest = new MapProviderPaintThrottledRequest(image, getTileUrl(coord), coord);
			request.addEventListener(ThrottledRequestEvent.REQUEST_ERROR, onRequestError);
			request.addEventListener(ThrottledRequestEvent.RESPONSE_COMPLETE, onResponseComplete);
			request.addEventListener(ThrottledRequestEvent.RESPONSE_ERROR, onResponseError);
			request.send();
			
			// createLabel(sprite, coord.toString());
		}
	
		/*
		 * Returns the url needed to get the tile image. 
		 */
		public function getTileUrl(coord:Coordinate):String
		{
			throw new Error("Abstract method not implemented by subclass.");
			return null;
		}
	
		// Event Handlers
	
		/**
		 * Event handler for MapProviderPaintThrottledRequest.EVENT_REQUEST_ERROR
		 */
		protected function onRequestError(event:ThrottledRequestEvent):void
		{
		    paintFailure(event.sprite);
		}
		
		/**
		 * Event handler for MapProviderPaintThrottledRequest.EVENT_RESPONSE_COMPLETE
		 */
		protected function onResponseComplete(event:ThrottledRequestEvent):void
		{
			raisePaintComplete(event.sprite, event.coord);
		}
		
		/**
		 * Event handler for MapProviderPaintThrottledRequest.EVENT_RESPONSE_ERROR
		 */
		protected function onResponseError(event:ThrottledRequestErrorEvent):void
		{
			if (event.sprite)
			{
		    	paintFailure(event.sprite);
		 	}
		 	else
		 	{
		 		dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "No sprite in which to print failure!"));
		 	}
		}		
		
		protected function paintFailure(sprite:Sprite):void
		{
			if (!sprite)
			{
				trace("no sprite for failure painting");
				return;
			}
			
		    // length of 'X' side, padding from edge, weight of 'X' symbol
		    var size:uint = 32;
		    var padding:uint = 4;
		    var weight:uint = 4;
		    
		    with (sprite.graphics)
			{
		        clear();
		        
		        moveTo(0, 0);
		        beginFill(0x444444, 100);
		        lineTo(size, 0);
		        lineTo(size, size);
		        lineTo(0, size);
		        lineTo(0, 0);
		        endFill();
		        
		        moveTo(weight+padding, padding);
		        beginFill(0x888888, 100);
		        lineTo(padding, weight+padding);
		        lineTo(size-weight-padding, size-padding);
		        lineTo(size-padding, size-weight-padding);
		        lineTo(weight+padding, padding);
		        endFill();
		        
		        moveTo(size-weight-padding, padding);
		        beginFill(0x888888, 100);
		        lineTo(size-padding, weight+padding);
		        lineTo(weight+padding, size-padding);
		        lineTo(padding, size-weight-padding);
		        lineTo(size-weight-padding, padding);
		        endFill();
		    }
		}		
	}
}