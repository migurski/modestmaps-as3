package {
	import com.adobe.viewsource.ViewSource;
	import com.modestmaps.TweenMap;
	import com.modestmaps.extras.MapControls;
	import com.modestmaps.extras.MapCopyright;
	import com.modestmaps.extras.ZoomSlider;
	import com.modestmaps.mapproviders.BlueMarbleMapProvider;
	import com.pixelbreaker.ui.osx.MacMouseWheel;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	[SWF(backgroundColor="#ffffff")]
	public class HelloMap extends Sprite
	{
		public var map:TweenMap;
		
		public function HelloMap()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			MacMouseWheel.setup(stage);

			ViewSource.addMenuItem(this, 'srcview/index.html', true);
			
			map = new TweenMap(stage.stageWidth, stage.stageHeight, true, new BlueMarbleMapProvider());
			map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);
			map.addEventListener(MouseEvent.MOUSE_WHEEL, map.onMouseWheel);
			addChild(map);

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
