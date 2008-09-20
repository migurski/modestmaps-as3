package {
	import com.modestmaps.Map;
	import com.modestmaps.TweenMap;
	import com.modestmaps.events.MapEvent;
	import com.modestmaps.extras.MapControls;
	import com.modestmaps.extras.MapCopyright;
	import com.modestmaps.extras.ZoomSlider;
	import com.modestmaps.mapproviders.microsoft.MicrosoftHybridMapProvider;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;

	[SWF(backgroundColor="#ffffff")]
	public class HelloMap extends Sprite
	{
		public var map:Map;
		
		public function HelloMap()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			map = new TweenMap(stage.stageWidth, stage.stageHeight, true, new MicrosoftHybridMapProvider());
			map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);
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
