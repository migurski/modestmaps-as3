package com.modestmaps.mapproviders.microsoft
{
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.geo.MercatorProjection;
	import com.modestmaps.geo.Transformation;
	import com.modestmaps.mapproviders.AbstractImageBasedMapProvider;
	import com.modestmaps.util.BinaryUtil;
	
	/**
	 * @author darren
	 */
	public class AbstractMicrosoftMapProvider 
		extends AbstractImageBasedMapProvider 
	{
		public function AbstractMicrosoftMapProvider() 
		{
			super();
	
		    // see: http://modestmaps.mapstraction.com/trac/wiki/TileCoordinateComparisons#TileGeolocations
		    var t:Transformation = new Transformation(1.068070779e7, 0, 3.355443185e7,
			                                          0, -1.068070890e7, 3.355443057e7);
			                                          
	        __projection = new MercatorProjection(26, t);
	
	        __topLeftOutLimit = new Coordinate(0, Number.NEGATIVE_INFINITY, 0);
	        __bottomRightInLimit = (new Coordinate(1, Number.POSITIVE_INFINITY, 0)).zoomTo(Coordinate.MAX_ZOOM);
		}
		
		protected function getZoomString(coord:Coordinate):String
		{
	        var sourceCoord:Coordinate = sourceCoordinate(coord);
		    
			// convert row + col to zoom string
			var rowBinaryString : String = BinaryUtil.convertToBinary(sourceCoord.row);		
			rowBinaryString = rowBinaryString.substring(rowBinaryString.length - sourceCoord.zoom);
			
			var colBinaryString : String = BinaryUtil.convertToBinary(sourceCoord.column);
			colBinaryString = colBinaryString.substring(colBinaryString.length - sourceCoord.zoom);
	
			// generate zoom string by combining strings
			var zoomString : String = "";
	
			for(var i:Number = 0; i < sourceCoord.zoom; i += 1)
				zoomString += BinaryUtil.convertToDecimal( rowBinaryString.charAt( i ) + colBinaryString.charAt( i ) ).toString();
			
			return zoomString; 
		}
	
	    override public function sourceCoordinate(coord:Coordinate):Coordinate
	    {
		    var wrappedColumn:Number = coord.column % Math.pow(2, coord.zoom);
	
		    while (wrappedColumn < 0)
		    {
		        wrappedColumn += Math.pow(2, coord.zoom);
		    }
		        
	        return new Coordinate(coord.row, wrappedColumn, coord.zoom);
	    }
	}
}