package {
	import com.adobe.viewsource.ViewSource;
	import com.modestmaps.Map;
	import com.modestmaps.TweenMap;
	import com.modestmaps.events.MapEvent;
	import com.modestmaps.extras.MapControls;
	import com.modestmaps.mapproviders.microsoft.MicrosoftAerialMapProvider;
	import com.modestmaps.mapproviders.yahoo.YahooAerialMapProvider;
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	[SWF(backgroundColor="#000000")]
	public class HelloLayers extends Sprite
	{
		public var map:Map;
		public var overlay:Map;
		
		public function HelloLayers()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			ViewSource.addMenuItem(this, 'srcview/index.html', true);
			
			map = new TweenMap(stage.stageWidth, stage.stageHeight, true, new MicrosoftAerialMapProvider());
			map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);
			addChild(map);
			
			overlay = new TweenMap(stage.stageWidth, stage.stageHeight, false, new YahooAerialMapProvider());
			overlay.mouseChildren = overlay.mouseEnabled = false; // pass thru to map
			addChild(overlay);
			
			// you could adjust the alpha of your overlay here:
			//overlay.alpha = 1;
			
			// but I want to see how Microsoft and Yahoo's aerial imagery differs, so:
			overlay.blendMode = BlendMode.DIFFERENCE;
			
			// these *should* be all the events you need to watch out for
			// fingers crossed!
			map.addEventListener(MapEvent.EXTENT_CHANGED, syncMaps);
			map.addEventListener(MapEvent.PANNED, syncMaps);
			map.addEventListener(MapEvent.ZOOMED_BY, syncMaps);
			map.addEventListener(MapEvent.STOP_ZOOMING, syncMaps);
			map.addEventListener(MapEvent.STOP_PANNING, syncMaps);

			// add these to the stage so they're on top of our overlay too
			addChild(new MapControls(map));

			// make sure the map fills the screen:
			stage.addEventListener(Event.RESIZE, onStageResize);			
		}
		
		private function syncMaps(event:MapEvent=null):void
		{
			// if you're using TweenMap then you need to 
			// do this to get the animations synced:
			overlay.grid.setMatrix(map.grid.getMatrix());

			// if you're using 'Map' you can just do
			// overlay.setCenterZoom(map.getCenter(), map.getZoom());
		}
		
		private function onStageResize(event:Event):void
		{
			map.setSize(stage.stageWidth, stage.stageHeight);
			overlay.setSize(stage.stageWidth, stage.stageHeight);
			syncMaps(); // just to be sure
		}
	}
}
