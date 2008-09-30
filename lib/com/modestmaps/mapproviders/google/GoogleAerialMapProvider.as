package com.modestmaps.mapproviders.google
{
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.mapproviders.IMapProvider;
	import com.modestmaps.util.BinaryUtil;
	
	/**
	 * @author darren
	 * $Id$
	 */
	public class GoogleAerialMapProvider 
		extends AbstractGoogleMapProvider
		implements IMapProvider
	{
	    public function GoogleAerialMapProvider(minZoom:int=MIN_ZOOM, maxZoom:int=MAX_ZOOM)
	    {
	        super(minZoom, maxZoom);
	    }
	    
		public function toString():String
		{
			return "GOOGLE_AERIAL";
		}

		public function getTileUrls(coord:Coordinate):Array
		{
			// TODO: http://khm1.google.com/kh?v=32&hl=en&x=10513&s=&y=25304&z=16&s=Gal
			return [ "http://kh" + Math.floor(Math.random() * 4) + ".google.com/kh?n=404&v=" + __aerialVersion + "&t=" + getZoomString(sourceCoordinate(coord)) ];
		}
		
		protected function getZoomString(coord:Coordinate):String
		{		
	        var gCoord:Coordinate = new Coordinate((Math.pow(2, coord.zoom) - coord.row - 1),
	                                    		   coord.column, coord.zoom + 1);
	
			// convert row + col to zoom string
			var rowBinaryString:String = BinaryUtil.convertToBinary(gCoord.row);
			rowBinaryString = rowBinaryString.substring(rowBinaryString.length - gCoord.zoom);
			
			var colBinaryString:String = BinaryUtil.convertToBinary(gCoord.column);
			colBinaryString = colBinaryString.substring(colBinaryString.length - gCoord.zoom);
	
			// generate zoom string by combining strings
			var urlChars:String = 'tsqr';
			var zoomString:String = "";
	
			for(var i:Number = 0; i < gCoord.zoom; i += 1)
			    zoomString += urlChars.charAt(BinaryUtil.convertToDecimal(rowBinaryString.charAt(i) + colBinaryString.charAt(i)));
	                         
			return zoomString; 
		}
	}
}