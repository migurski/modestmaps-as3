/*
 * $Id$
 */

package com.modestmaps.core
{
	import com.modestmaps.geo.Location;
	
	public class MapExtent extends Object
	{
		// TODO: OK for rectangular projections, but we need a better way for other projections
		public var north:Number;
		public var south:Number;
		public var east:Number;
		public var west:Number;
		
		/** Creates a new MapExtent from the given String.
		 * @param str "north, south, east, west"
		 * @return a new MapExtent from the given string */
		public static function fromString(str:String):MapExtent
		{
			var parts:Array = str.split(/\s*,\s*/, 4);
			return new MapExtent(parseFloat(parts[0]),
								 parseFloat(parts[1]),
								 parseFloat(parts[2]),
								 parseFloat(parts[3]));
		}

		/** @param n the most northerly latitude
		 *  @param s the southern latitude
		 *  @param e the eastern-most longitude
		 *  @param w the westest longitude */
		public function MapExtent(n:Number=0, s:Number=0, e:Number=0, w:Number=0)
		{
			north = n;
			south = s;
			east = e;
			west = w;
		}
		
		/** enlarges this extent so that the given extent is inside it */
		public function encloseExtent(extent:MapExtent):void
		{
		    north = Math.max(extent.north, north);
		    south = Math.min(extent.south, south);
		    east = Math.max(extent.east, east);
		    west = Math.min(extent.west, west);		    
		}
		
		/** enlarges this extent so that the given location is inside it */
		public function enclose(location:Location):void
		{
		    north = Math.max(location.lat, north);
		    south = Math.min(location.lat, south);
		    east = Math.max(location.lon, east);
		    west = Math.min(location.lon, west);
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
		
		public function get center():Location
		{
		    return new Location(south + (north - south) / 2, east + (west - east) / 2);
		}

        public function set center(value:Location):void
        {
            var w:Number = east - west;
            var h:Number = north - south;
            north = value.lat - h / 2;
            south = value.lat + h / 2;
            east = value.lon + w / 2;
            west = value.lon - w / 2;
        }

		/** @return "north, south, east, west" */
		public function toString():String
		{
			return [north, west, south, east].toString();
		}
	}
}