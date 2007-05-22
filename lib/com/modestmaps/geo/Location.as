package com.modestmaps.geo
{
	public class Location
	{
	    // Latitude, longitude, _IN DEGREES_.
	    public var lat:Number;
	    public var lon:Number;
	
		public static function fromString(str:String):Location
		{
			var parts:Array = str.split(/\s*,\s*/, 2);
			return new Location(parseFloat(parts[0]), parseFloat(parts[1]));
		}

	    public function Location(lat:Number, lon:Number)
	    {
	        this.lat = lat;
	        this.lon = lon;
	    }
	    
	    public function toString():String
	    {
	        return '(' + lat.toFixed(3) + ',' + lon.toFixed(3) + ')';
	    }
	}
}