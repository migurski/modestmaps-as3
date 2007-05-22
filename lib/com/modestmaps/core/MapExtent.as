package com.modestmaps.core
{
	import flash.geom.Point;
	import com.modestmaps.geo.Location;
	import flash.net.LocalConnection;
	
	public class MapExtent extends Object
	{
		// TODO: OK for rectangular projections, but we need a better way for other projections
		public var north:Number;
		public var south:Number;
		public var east:Number;
		public var west:Number;
		
		public static function fromString(str:String):MapExtent
		{
			var parts:Array = str.split(/\s*,\s*/, 4);
			return new MapExtent(parseFloat(parts[0]),
								 parseFloat(parts[1]),
								 parseFloat(parts[2]),
								 parseFloat(parts[3]));
		}

		public function MapExtent(n:Number=0, s:Number=0, e:Number=0, w:Number=0)
		{
			north = n;
			south = s;
			east = e;
			west = w;
		}
		
		public function get northWest():Location
		{
			return new Location(north, west);
		}
		
		public function get southWest():Location
		{
			return new Location(south, west);
		}
		
		public function get northEast():Location
		{
			return new Location(north, east);
		}
		
		public function get southEast():Location
		{
			return new Location(south, east);
		}
		
		public function set northWest(nw:Location):void
		{
			north = nw.lat;
			west = nw.lon;
		}
		
		public function set southWest(sw:Location):void
		{
			south = sw.lat;
			west = sw.lon;
		}
		
		public function set northEast(ne:Location):void
		{
			north = ne.lat;
			east = ne.lon;
		}
		
		public function set southEast(se:Location):void
		{
			south = se.lat;
			east = se.lon;
		}
		
		public function toString():String
		{
			return [north, west, south, east].toString();
		}
	}
}