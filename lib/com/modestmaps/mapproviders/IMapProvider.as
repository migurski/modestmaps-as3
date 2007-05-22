package com.modestmaps.mapproviders
{
	import com.modestmaps.core.Coordinate; 
	import com.modestmaps.geo.Location;
	import flash.display.Sprite;
	import flash.events.IEventDispatcher;
	 
	public interface IMapProvider extends IEventDispatcher
	{
		function paint(sprite:Sprite, coord:Coordinate):void;
	    
	   /*
	    * Return projected and transformed coordinate for a location.
	    */
	    function locationCoordinate(location:Location):Coordinate;
	    
	   /*
	    * Return untransformed and unprojected location for a coordinate.
	    */
	    function coordinateLocation(coordinate:Coordinate):Location;
	
	   /*
	    * Get top left outer-zoom limit and bottom right inner-zoom limits,
	    * as Coordinates in a two element array.
	    */
	    function outerLimits():/*Coordinate*/Array;
	
	   /*
	    * A string which describes the projection and transformation of a map provider.
	    */
	    function geometry():String;
	    
	    function toString():String;
	    
	   /*
	    * Munge coordinate for purposes of image selection and marker containment.
	    * E.g., useful for cylindical projections with infinite horizontal scroll.
	    */
	    function sourceCoordinate(coord:Coordinate):Coordinate;
	}
}