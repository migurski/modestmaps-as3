/*
 * $Id$
 */

package com.modestmaps.geo
{
	public class Location
	{
	    // Latitude, longitude, _IN DEGREES_.
	    public var lat:Number;
	    public var lon:Number;
	
		public static function fromString(str:String, lonlat:Boolean=false):Location
		{
			var parts:Array = str.split(/\s*,\s*/, 2);
			if (lonlat) parts = parts.reverse();
			return new Location(parseFloat(parts[0]), parseFloat(parts[1]));
		}

	    public function Location(lat:Number, lon:Number)
	    {
	        this.lat = lat;
	        this.lon = lon;
	    }
	    
	    public function clone():Location
	    {
	        return new Location(lat, lon);
	    }

        /**
         * This function normalizes latitude and longitude values to a sensible range
         * (±84°N, ±180°E), and returns a new Location instance.
         */
        public function normalize():Location
        {
            var loc:Location = clone();
            loc.lat = Math.max(-84, Math.min(84, loc.lat));
            while (loc.lon > 180) loc.lon -= 360;
            while (loc.lon < -180) loc.lon += 360;
            return loc;
        }

	    public function toString(precision:int=5):String
	    {
	        return [lat.toFixed(precision), lon.toFixed(precision)].join(',');
	    }
	}
}