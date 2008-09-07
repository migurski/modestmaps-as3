package com.modestmaps.core
{
	import com.modestmaps.Map;
	import com.modestmaps.geo.Location;
	
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	public class PolygonMarker extends Sprite implements Redrawable
	{
		protected var map:Map;
		protected var drawZoom:Number;
		
		public var zoomTolerance:Number = 4;
		
		public var locations:Array;
		protected var coordinates:Array;
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

			if (locations && locations.length > 0) {
				this.locations = locations;
				this.extent = MapExtent.fromLocations(locations);
				this.location = locations[0] as Location;
				this.coordinates = locations.map(l2c);
			}
		}
		
		protected function l2c(l:Location, ...rest):Coordinate
		{
			return map.getMapProvider().locationCoordinate(l);
		}
	
		public function redraw(event:Event=null):void
		{	
			var grid:TileGrid = map.grid;
			
			if (drawZoom && Math.abs(grid.zoomLevel-drawZoom) < zoomTolerance) {
				scaleX = scaleY = Math.pow(2, grid.zoomLevel-drawZoom);
				return;
			}
			
			drawZoom = grid.zoomLevel;
			scaleX = scaleY = 1;
			
			var firstPoint:Point = grid.coordinatePoint(coordinates[0]); // map.locationPoint(location)		
			graphics.clear();
			if (line && lineAlpha) {
				graphics.lineStyle(lineThickness, lineColor, lineAlpha, false, LineScaleMode.NONE);
			}
			else {
				graphics.lineStyle();
			}
			if (fill && fillAlpha) {
				graphics.beginFill(fillColor, fillAlpha);
			}
			graphics.moveTo(0, 0);
			var p:Point;
			for each (var coord:Coordinate in coordinates.slice(1)) {
				p = grid.coordinatePoint(coord);
				graphics.lineTo(p.x-firstPoint.x, p.y-firstPoint.y);
			}
/* 			if (loc.lat != location.lat && loc.lon != location.lon) {
				graphics.lineTo(0, 0);
			} */
			if (fillAlpha) {
				graphics.endFill();
			}
		}
				
	}
}