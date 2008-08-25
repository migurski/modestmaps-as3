package com.modestmaps.mapproviders.google
{
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.mapproviders.IMapProvider;
	
	/**
	 * @author darren
	 * $Id$
	 */
	public class GoogleHybridMapProvider 
		extends GoogleAerialMapProvider 
	{
        public function GoogleHybridMapProvider(minZoom:int=MIN_ZOOM, maxZoom:int=MAX_ZOOM)
        {
            super(minZoom, maxZoom);
        }

		override public function toString():String
		{
			return "GOOGLE_HYBRID";
		}
	
		override public function getTileUrls(coord:Coordinate):Array
		{
	        var sourceCoord:Coordinate = sourceCoordinate(coord);
	        var zoomString:String = "&x=" + sourceCoord.column + "&y=" + sourceCoord.row + "&zoom=" + (17 - sourceCoord.zoom);
	        var url:String = "http://mt" + Math.floor(Math.random() * 4) + ".google.com/mt?n=404&v=" + __hybridVersion + zoomString;
			return super.getTileUrls(coord).concat(url);
		}
		
	}
}