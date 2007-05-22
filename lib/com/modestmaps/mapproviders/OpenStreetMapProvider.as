/**
 * MapProvider for Open Street Map data.
 * 
 * @author migurski
 */
package com.modestmaps.mapproviders
{ 
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.geo.MercatorProjection;
	import com.modestmaps.geo.Transformation;
	import com.modestmaps.mapproviders.AbstractImageBasedMapProvider;
	import com.modestmaps.mapproviders.IMapProvider;
	
	public class OpenStreetMapProvider
		extends AbstractImageBasedMapProvider
		implements IMapProvider
	{
	    public function OpenStreetMapProvider()
	    {
	        super();
	
		    // see: http://modestmaps.mapstraction.com/trac/wiki/TileCoordinateComparisons#TileGeolocations
		    var t:Transformation = new Transformation(1.068070779e7, 0, 3.355443185e7,
			                                          0, -1.068070890e7, 3.355443057e7);
			                                          
	        __projection = new MercatorProjection(26, t);
	
	        __topLeftOutLimit = new Coordinate(0, Number.NEGATIVE_INFINITY, 0);
	        __bottomRightInLimit = (new Coordinate(1, Number.POSITIVE_INFINITY, 0)).zoomTo(17);
	    }
	
	    override public function toString() : String
	    {
	        return "OPEN_STREET_MAP";
	    }
	
	    override public function getTileUrl(coord:Coordinate):String
	    {
	        var sourceCoord:Coordinate = sourceCoordinate(coord);
	        return 'http://tile.openstreetmap.org/'+(sourceCoord.zoom)+'/'+(sourceCoord.column)+'/'+(sourceCoord.row)+'.png';
	    }
	
	    override public function sourceCoordinate(coord:Coordinate):Coordinate
	    {
		    var wrappedColumn:Number = coord.column % Math.pow(2, coord.zoom);
	
		    while(wrappedColumn < 0)
		        wrappedColumn += Math.pow(2, coord.zoom);
		        
	        return new Coordinate(coord.row, wrappedColumn, coord.zoom);
	    }
	}
}