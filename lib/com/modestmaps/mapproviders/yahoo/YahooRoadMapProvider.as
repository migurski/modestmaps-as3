package com.modestmaps.mapproviders.yahoo
{
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.mapproviders.IMapProvider;
	import com.modestmaps.mapproviders.yahoo.AbstractYahooMapProvider;
	
	/**
	 * @author darren
	 */
	public class YahooRoadMapProvider 
		extends AbstractYahooMapProvider 
		implements IMapProvider
	{	
		override public function toString():String
		{
			return "YAHOO_ROAD";
		}
	
		override public function getTileUrl(coord:Coordinate):String
		{		
	        return "http://us.maps2.yimg.com/us.png.maps.yimg.com/png?v=3.52&t=m" + getZoomString(sourceCoordinate(coord));
		}
		
		protected function getZoomString(coord:Coordinate):String
		{		
	        var row : Number = (Math.pow(2, coord.zoom) / 2) - coord.row - 1;
			return "&x=" + coord.column + "&y=" + row + "&z=" + (18 - coord.zoom);
		}	
	}
}