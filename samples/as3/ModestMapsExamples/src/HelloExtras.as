package {
	import com.adobe.viewsource.ViewSource;
	import com.modestmaps.TweenMap;
	import com.modestmaps.extras.MapControls;
	import com.modestmaps.extras.MapCopyright;
	import com.modestmaps.extras.MapScale;
	import com.modestmaps.extras.NavigatorWindow;
	import com.modestmaps.extras.ZoomBox;
	import com.modestmaps.extras.ZoomSlider;
	import com.modestmaps.mapproviders.OpenStreetMapProvider;
	import com.pixelbreaker.ui.osx.MacMouseWheel;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	[SWF(backgroundColor="#ffffff", frameRate="30")]
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

			ViewSource.addMenuItem(this, 'srcview/index.html', true);
			
			var map:TweenMap = new TweenMap(stage.stageWidth, stage.stageHeight, true, new OpenStreetMapProvider());
			map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);
			map.addEventListener(MouseEvent.MOUSE_WHEEL, map.onMouseWheel); 
			addChild(map);
			
/* 			map.grid.maxChildSearch = 1;
			map.grid.maxParentSearch = 5;
			map.grid.maxParentLoad = 0;
			map.grid.maxOpenRequests = 4;
			map.grid.tileBuffer = 0; */
			//map.grid.roundPositionsEnabled = true;
			//map.grid.roundScalesEnabled = true;
			//map.grid.smoothContent = true;
			
			//map.addChild(map.grid.debugField);
			
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
