package com.modestmaps.mapproviders.google
{
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.mapproviders.IMapProvider;
	
	/**
	 * @author darren
	 * $Id$
	 */
	public class GoogleRoadMapProvider 
		extends AbstractGoogleMapProvider 
		implements IMapProvider
	{		
        public function GoogleRoadMapProvider(minZoom:int=MIN_ZOOM, maxZoom:int=MAX_ZOOM)
        {
            super(minZoom, maxZoom);
        }
        
		public function toString():String
		{
			return "GOOGLE_ROAD";
		}
	
		public function getTileUrls(coord:Coordinate):Array
		{		
			return [ "http://mt" + Math.floor(Math.random() * 4) + ".google.com/mt?n=404&v=" + __roadVersion + getZoomString(sourceCoordinate(coord)) ];		
		}
		
		protected function getZoomString(coord:Coordinate):String
		{
	        return "&x=" + coord.column + "&y=" + coord.row + "&zoom=" + (17 - coord.zoom);
		}	
	}
}