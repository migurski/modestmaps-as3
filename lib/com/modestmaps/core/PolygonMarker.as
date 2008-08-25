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
		
		public var coordinates:Array = [];
		public var location:Location;
				
		public var line:Boolean = true;
		public var lineThickness:Number = 0;
		public var lineColor:uint = 0xffffff;
		public var lineAlpha:Number = 1;

		public var fill:Boolean = true;
		public var fillColor:uint = 0xff0000;
		public var fillAlpha:Number = 0.2;
				
		public function PolygonMarker(map:Map, coordinates:Array)
		{
			this.map = map;
			this.mouseEnabled = false;

			map.addEventListener(MapEvent.EXTENT_CHANGED, redraw);
			map.addEventListener(MapEvent.STOP_ZOOMING, redraw);
			
			this.coordinates = coordinates;	
			location = coordinates[0] as Location;		
		}
		
		public function redraw(event:Event=null):void
		{
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
			for each (var loc:Location in coordinates.slice(1)) {
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