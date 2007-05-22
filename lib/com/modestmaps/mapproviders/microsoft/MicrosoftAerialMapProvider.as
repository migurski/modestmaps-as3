
package com.modestmaps.mapproviders.microsoft
{
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.mapproviders.IMapProvider;
	import com.modestmaps.mapproviders.microsoft.AbstractMicrosoftMapProvider;
	
	/**
	 * @author darren
	 */
	
	public class MicrosoftAerialMapProvider 
		extends AbstractMicrosoftMapProvider
		implements IMapProvider
	{
		override public function toString():String
		{
			return "MICROSOFT_AERIAL";
		}
		
		override public function getTileUrl(coord:Coordinate):String
		{		
	        return "http://a" + Math.floor(Math.random() * 4) + ".ortho.tiles.virtualearth.net/tiles/a" + getZoomString( coord ) + ".jpeg?g=45";
		}
	}
}