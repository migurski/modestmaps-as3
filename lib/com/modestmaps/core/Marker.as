
package com.modestmaps.core
{
	//import com.modestmaps.core.Point;
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.geo.Location;
	
	public class Marker extends Object
	{
	    // opaque identifier for external use
	    public var id:String;
	
	    public var coord:Coordinate;
	    public var location:Location;
	    //public var point:Point;
	
	    public function Marker(id:String, coord:Coordinate, location:Location/*, point:Point*/)
	    {
	        this.id = id;
	        this.coord = coord;
	        this.location = location;
	        //this.point = point;
	    }
	    
	    public function toString():String
	    {
	        return 'Marker(' + id + ' ' + location.toString() + ')';
	    }
	}
}