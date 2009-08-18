package {
	import com.adobe.viewsource.ViewSource;
	import com.modestmaps.TweenMap;
	import com.modestmaps.core.MapExtent;
	import com.modestmaps.extras.MapControls;
	import com.modestmaps.extras.MapCopyright;
	import com.modestmaps.extras.ZoomSlider;
	import com.modestmaps.geo.Location;
	import com.modestmaps.mapproviders.BlueMarbleMapProvider;
	import com.modestmaps.overlays.PolygonClip;
	import com.modestmaps.overlays.PolygonMarker;
	import com.pixelbreaker.ui.osx.MacMouseWheel;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	[SWF(backgroundColor="#ffffff")]
	public class HelloPolygons extends Sprite
	{
		public var map:TweenMap;
		
		public function HelloPolygons()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			MacMouseWheel.setup(stage);
			
			ViewSource.addMenuItem(this, 'srcview/index.html', true);
			
			map = new TweenMap(stage.stageWidth, stage.stageHeight, true, new BlueMarbleMapProvider());
			map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);
			map.addEventListener(MouseEvent.MOUSE_WHEEL, map.onMouseWheel);
			addChild(map);

			var polygonClip:PolygonClip = new PolygonClip(map);
			
			var locations:Array = [ new Location(37.83435,21.36860),
									new Location(37.83435,21.58489),
									new Location(37.78105,21.58489),
									new Location(37.78105,21.36860) ];
									
			var polygon:PolygonMarker = new PolygonMarker(map,locations,true); 
			
			polygonClip.attachMarker(polygon, polygon.location);
			
			map.addChild(polygonClip);
			
			map.setExtent(MapExtent.fromLocations(locations));

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
