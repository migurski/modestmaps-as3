package com.modestmaps.mapproviders.google
{
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.mapproviders.google.AbstractGoogleMapProvider;
	import com.modestmaps.mapproviders.IMapProvider;
	
	/**
	 * @author darren
	 */
	public class GoogleRoadMapProvider 
		extends AbstractGoogleMapProvider 
		implements IMapProvider
	{
		override public function toString():String
		{
			return "GOOGLE_ROAD";
		}
	
		override public function getTileUrl(coord:Coordinate):String
		{		
			return "http://mt" + Math.floor(Math.random() * 4) + ".google.com/mt?n=404&v=" + __roadVersion + getZoomString(sourceCoordinate(coord));		
		}
		
		protected function getZoomString(coord:Coordinate):String
		{
	        return "&x=" + coord.column + "&y=" + coord.row + "&zoom=" + (17 - coord.zoom);
		}	
	}
}