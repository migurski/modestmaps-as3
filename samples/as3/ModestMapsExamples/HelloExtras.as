package {
	import com.modestmaps.TweenMap;
	import com.modestmaps.extras.MapControls;
	import com.modestmaps.extras.MapCopyright;
	import com.modestmaps.extras.MapScale;
	import com.modestmaps.extras.NavigatorWindow;
	import com.modestmaps.extras.ZoomBox;
	import com.modestmaps.extras.ZoomSlider;
	import com.pixelbreaker.ui.osx.MacMouseWheel;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;

	[SWF(backgroundColor="#ffffff")]
	public class HelloExtras extends Sprite
	{
		public function HelloExtras()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			// see http://blog.pixelbreaker.com/flash/swfmacmousewheel/
			try {
				MacMouseWheel.setup(stage);
			}
			catch (error:Error) {
				trace("NO MAC MOUSEWHEEL SUPPORT!");
			}			
			
			var map:TweenMap = new TweenMap(stage.stageWidth, stage.stageHeight, true);
			map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);
			map.addEventListener(MouseEvent.MOUSE_WHEEL, map.onMouseWheel); 
			addChild(map);
			
			map.addChild(new MapCopyright(map, 143, 10));
			map.addChild(new ZoomBox(map));
			map.addChild(new ZoomSlider(map));
			map.addChild(new NavigatorWindow(map));
			map.addChild(new MapControls(map, true, true));
			map.addChild(new MapScale(map, 140));
			
			stage.addEventListener(Event.RESIZE, function(event:Event):void { map.setSize(stage.stageWidth, stage.stageHeight) } );
		}
	}
}
