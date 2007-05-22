/**
 * vim:et sts=4 sw=4 cindent:
 * @ignore
 *
 * @author darren
 * @author migurski
 *
 * AbstractMapProvider is the base class for all MapProviders.
 * 
 * @description AbstractMapProvider is the base class for all 
 * 				MapProviders. MapProviders are primarily responsible
 * 				for "painting" map Tiles with the correct 
 * 				graphic imagery.
 */

package com.modestmaps.mapproviders
{
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.events.MapProviderEvent;
	import com.modestmaps.geo.IProjection;
	import com.modestmaps.geo.LinearProjection;
	import com.modestmaps.geo.Location;
	import com.modestmaps.geo.Transformation;
	import com.modestmaps.io.RequestThrottler;
	
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.text.TextColorType;
	import flash.text.TextField;
	import flash.display.Sprite;
	
	internal class AbstractMapProvider  
		extends EventDispatcher
	{
		// Event Types
		//public static var EVENT_PAINT_COMPLETE : String = "onPaintComplete"; // TODO: OK to delete? TC
		
		protected var __requestThrottler : RequestThrottler;
		protected var __projection:IProjection;
		
		// boundaries for the current provider
		protected var __topLeftOutLimit:Coordinate;
		protected var __bottomRightInLimit:Coordinate;
	
		/*
		 * Abstract constructor, should not be instantiated directly.
		 */
		public function AbstractMapProvider()
		{
			__requestThrottler = RequestThrottler.getInstance();
	
		    var t:Transformation = new Transformation(1, 0, 0, 0, 1, 0);
	        __projection = new LinearProjection(Coordinate.MAX_ZOOM, t);
	
	        __topLeftOutLimit = new Coordinate(0, 0, 0);
	        __bottomRightInLimit = (new Coordinate(1, 1, 0)).zoomTo(Coordinate.MAX_ZOOM);
		}
	
		/**
		 * Paints a map graphic onto the supplied DisplayObject.
		 * 
		 * @param sprite The DisplayObject to contain the graphics.
		 * @param coord The coordinate of the Tile that contains the sprite.
		 */
		public function paint(sprite:Sprite, coord:Coordinate):void 
		{
			var image:Sprite = new Sprite();
			image.name = "image";
			sprite.addChild(image);
		}
	
	   /*
	    * String signature of the current map provider's geometric behavior.
	    */
		public function geometry():String
		{
	        return __projection.toString();
		}
	
		/**
		 * Generates a copy of the specified coordinate.
		 * 
		 * @param coord The Coordinate to copy.
		 */
	    public function sourceCoordinate(coord:Coordinate):Coordinate
	    {
	        return coord.copy();
	    }
	
	   /*
	    * Get top left outer-zoom limit and bottom right inner-zoom limits,
	    * as Coordinates in a two element array.
	    */
	    public function outerLimits():/*Coordinate*/Array
	    {
	        var limits:/*Coordinate*/Array = new Array();
	
	        limits[0] = __topLeftOutLimit.copy();
	        limits[1] = __bottomRightInLimit.copy();
	
	        return limits;
	    }
	
		/**
		 * Creates a text label for debugging purposes.
		 * 
		 * @param sprite The DisplayObject to contain the label.
		 * @param label The text the label.
		 */
		public function createLabel(sprite:Sprite, label:String):void
		{
			var field:TextField = sprite.getChildByName("label") as TextField;
			if (!field)
			{
				field = new TextField();
				field.name = "label";
				field.selectable = false;
				sprite.addChild(field);
			}
			field.text = label;
		}
	
	   /*
	    * Return projected and transformed coordinate for a location.
	    */
	    public function locationCoordinate(location:Location):Coordinate
	    {
	        return __projection.locationCoordinate(location);
	    }
	    
	   /*
	    * Return untransformed and unprojected location for a coordinate.
	    */
	    public function coordinateLocation(coordinate:Coordinate):Location
	    {
	        return __projection.coordinateLocation(coordinate);
	    }
		
		// Private Methods
		
		protected function raisePaintComplete(sprite:Sprite, coord:Coordinate):void
		{
			var event:MapProviderEvent = new MapProviderEvent(MapProviderEvent.PAINT_COMPLETE, sprite, coord);
//			trace("raisePaintComplete" + event);
			dispatchEvent(event);
		}
	}
}