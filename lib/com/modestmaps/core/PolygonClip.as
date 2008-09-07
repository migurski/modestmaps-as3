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
			//this.scaleZoom = true;
			this.markerSortFunction = null
		}

		override protected function markerInBounds(marker:DisplayObject, w:Number, h:Number):Boolean
		{
 			var rect:Rectangle = new Rectangle(-w, -h, w*2, h*2);
			return rect.intersects(marker.getBounds(this));
		}		
		
	}
}