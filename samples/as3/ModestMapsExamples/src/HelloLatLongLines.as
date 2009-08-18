package {
	import com.adobe.viewsource.ViewSource;
	import com.modestmaps.Map;
	import com.modestmaps.TweenMap;
	import com.modestmaps.extras.MapControls;
	import com.modestmaps.extras.MapCopyright;
	import com.modestmaps.extras.ZoomSlider;
	import com.modestmaps.mapproviders.microsoft.MicrosoftHybridMapProvider;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	[SWF(backgroundColor="#ffffff")]
	public class HelloLatLongLines extends Sprite
	{
		public var map:Map;
		
		public function HelloLatLongLines()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			ViewSource.addMenuItem(this, 'srcview/index.html', true);
			
			map = new TweenMap(stage.stageWidth, stage.stageHeight, true, new MicrosoftHybridMapProvider());
			map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);
			addChild(map);

			map.addChild(new LatLongOverlay(map));
			map.addChild(new MapControls(map));
			map.addChild(new ZoomSlider(map));
			map.addChild(new MapCopyright(map));

			// make sure the map fills the screen:
			stage.addEventListener(Event.RESIZE, onStageResize);			
		}
		
		public function onStageResize(event:Event):void
		{
			map.setSize(stage.stageWidth, stage.stageHeight);
		}
	}
}

import flash.display.Sprite;
import flash.display.Shape;
import com.modestmaps.Map;
import com.modestmaps.events.MapEvent;
import com.modestmaps.core.MapExtent;
import flash.geom.Point;
import com.modestmaps.geo.Location;	

class LatLongOverlay extends Sprite
{
	public var map:Map;
	public var lines:Array = [];
	
	public function LatLongOverlay(map:Map):void
	{
		this.mouseEnabled = false;
		this.map = map;
		map.addEventListener(MapEvent.RENDERED, onMapRendered);
	}
	
	public function onMapRendered(event:MapEvent):void
	{
		var lineCount:int = 0;
		
		var extent:MapExtent = map.getExtent();
		
		var latSpan:Number = Math.abs(extent.north-extent.south);
		var lonSpan:Number = Math.abs(extent.west-extent.east);
		
		var step:Number = 10.0;
		
		var minLat:Number = Math.max(-80, Math.floor(extent.south/step) * step);
		var maxLat:Number = Math.min(80, Math.ceil(extent.north/step) * step);
		var minLon:Number = Math.floor(extent.west/step) * step;
		var maxLon:Number = Math.ceil(extent.east/step) * step;
		
		var line:Line;
		var p1:Point;
		var p2:Point;
		
		for (var lat:Number = minLat; lat <= maxLat; lat += step) {
			p1 = map.locationPoint(new Location(lat, minLon));
			p2 = map.locationPoint(new Location(lat, maxLon));
			line = getLine(lineCount);
			line.x = p1.x;
			line.y = p1.y;
			line.width = p2.x - p1.x;
			line.height = 0.01;
			lineCount++;
		} 

		for (var lon:Number = minLon; lon <= maxLon; lon += step) {
			p1 = map.locationPoint(new Location(maxLat, lon));
			p2 = map.locationPoint(new Location(minLat, lon));
			line = getLine(lineCount);
			line.x = p1.x;
			line.y = p1.y;
			line.width = 0.1;
			line.height = p2.y - p1.y;
			lineCount++;			
		} 
		
		while (numChildren > lineCount) {
			lines.pop();
			removeChildAt(numChildren-1);
		}
	}
	
	protected function getLine(num:int):Line
	{
		while (lines.length < num+1) {
			lines.push(addChild(new Line()));
		}
		return lines[num];
	}
}

class Line extends Shape
{
	public function Line()
	{
		graphics.lineStyle(0, 0xffffff, 0.2, false);
		graphics.moveTo(0,0);
		graphics.lineTo(1,1);
	}
}
