package com.modestmaps.core
{
	import com.modestmaps.Map;
	import com.modestmaps.events.MapEvent;
	import com.modestmaps.geo.Location;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	public class PolygonMarker extends Sprite
	{
		protected var map:Map;
		protected var drawZoom:Number;
		
		public var locations:Array;
		public var extent:MapExtent;
		public var location:Location;
				
		public var line:Boolean = true;
		public var lineThickness:Number = 0;
		public var lineColor:uint = 0xffffff;
		public var lineAlpha:Number = 1;

		public var fill:Boolean = true;
		public var fillColor:uint = 0xff0000;
		public var fillAlpha:Number = 0.2;
				
		public function PolygonMarker(map:Map, locations:Array)
		{
			this.map = map;
			this.mouseEnabled = false;

			map.addEventListener(MapEvent.EXTENT_CHANGED, rescale);
			map.addEventListener(MapEvent.ZOOMED_BY, rescale);
			map.addEventListener(MapEvent.STOP_ZOOMING, redraw);
			
			if (locations && locations.length > 0) {
				this.locations = locations;
				this.extent = MapExtent.fromLocations(locations);
				this.location = locations[0] as Location;
			}
		}
	
		public function rescale(event:Event=null):void
		{
			scaleX = scaleY = Math.pow(2, map.grid.zoomLevel - drawZoom);
		}
		
		public function redraw(event:Event=null):void
		{
			drawZoom = map.grid.zoomLevel;
			scaleX = scaleY = 1;
			
			var firstPoint:Point = map.locationPoint(location)		
			graphics.clear();
			if (line && lineAlpha) {
				graphics.lineStyle(lineThickness, lineColor, lineAlpha);
			}
			else {
				graphics.lineStyle();
			}
			if (fill && fillAlpha) {
				graphics.beginFill(fillColor, fillAlpha);
			}
			graphics.moveTo(0, 0);
			for each (var loc:Location in locations.slice(1)) {
				var p:Point = map.locationPoint(loc);
				graphics.lineTo(p.x-firstPoint.x, p.y-firstPoint.y);
			}
			if (loc.lat != location.lat && loc.lon != location.lon) {
				graphics.lineTo(0, 0);
			}
			if (fillAlpha) {
				graphics.endFill();
			}
		}
				
	}
}