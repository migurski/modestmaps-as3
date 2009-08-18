package
{
	import com.adobe.viewsource.ViewSource;
	import com.modestmaps.Map;
	import com.modestmaps.TweenMap;
	import com.modestmaps.core.MapExtent;
	import com.modestmaps.extras.MapControls;
	import com.modestmaps.mapproviders.IMapProvider;
	import com.modestmaps.mapproviders.WMSMapProvider;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	[SWF(backgroundColor="#eeeeee")]
	public class HelloWMS extends Sprite
	{
		public var map:Map;
		public var currentProvider:IMapProvider;
		public var providers:Array = [];
		
		public function HelloWMS()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;	

			ViewSource.addMenuItem(this, 'srcview/index.html', true);
			
			var wmsProvider:WMSMapProvider = new WMSMapProvider("http://labs.metacarta.com/wms/vmap0",
											{
												LAYERS: 'basic',
												SERVICE: 'WMS',
												VERSION: '1.1.1',
												REQUEST: 'GetMap',
												STYLES: '',
												SRS: WMSMapProvider.EPSG_900913,
												EXCEPTIONS: 'application/vnd.ogc.se_inimage',
												FORMAT: 'image/jpeg',
												WIDTH: '256',
												HEIGHT: '256'
											});
			providers.push(wmsProvider); 

/*  			wmsProvider = new WMSMapProvider("http://labs.metacarta.com/wms/vmap0",
											{
												LAYERS: 'basic',
												SERVICE: 'WMS',
												VERSION: '1.1.1',
												REQUEST: 'GetMap',
												STYLES: '',
												SRS: WMSMapProvider.EPSG_900913,
												EXCEPTIONS: 'application/vnd.ogc.se_inimage',
												FORMAT: 'image/jpeg',
												WIDTH: '256',
												HEIGHT: '256'
											});
			providers.push(wmsProvider); */

			map = new TweenMap(stage.stageWidth, stage.stageHeight, true, providers[0], new MapExtent(48.383, 43.300,5.367, -4.500));
			map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);
			addChild(map);
			
			map.addChild(new MapControls(map));
			
			stage.addEventListener(Event.RESIZE, onStageResize);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}

		protected function onKeyUp(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.SPACE) {
				var provider:IMapProvider = map.getMapProvider();
				var index:int = providers.indexOf(provider);
				index = (index + 1) % providers.length;
				map.setMapProvider(providers[index]);
			}
		}
		
		protected function onStageResize(event:Event):void
		{
			map.setSize(stage.stageWidth, stage.stageHeight);
		}

	}
}