package com.modestmaps.core
{
	import com.modestmaps.Map;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;

	public class PolygonClip extends MarkerClip
	{
		public function PolygonClip(map:Map)
		{
			super(map);
			this.scaleZoom = true;
			this.markerSortFunction = null
		}

		override protected function markerInBounds(marker:DisplayObject, w:Number, h:Number):Boolean
		{
			return true;
/* 			var rect:Rectangle = new Rectangle(-map.width/2, -map.height/2, map.width, map.height);
			return rect.intersects(marker.getBounds(this)); */
		}		
		
	}
}