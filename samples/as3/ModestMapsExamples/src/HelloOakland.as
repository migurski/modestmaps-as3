package {
	import com.adobe.viewsource.ViewSource;
	import com.modestmaps.Map;
	import com.modestmaps.TweenMap;
	import com.modestmaps.events.MapEvent;
	import com.modestmaps.extras.MapControls;
	import com.modestmaps.geo.Location;
	import com.modestmaps.mapproviders.CloudMadeProvider;
	import com.modestmaps.mapproviders.IMapProvider;
	import com.pixelbreaker.ui.osx.MacMouseWheel;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;

	[SWF(backgroundColor="#000000")]
	public class HelloOakland extends Sprite
	{
		public var maps:Array = [];
		
		public function HelloOakland()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			ViewSource.addMenuItem(this, 'srcview/index.html', true);

			MacMouseWheel.setup(stage);

			var providers:Array = [
				new OaklandProvider('http://osm-bayarea.s3.amazonaws.com/', '.png'),
				new OaklandProvider('http://oakland-1967.s3.amazonaws.com/'),
				new OaklandProvider('http://oakland-1950s.s3.amazonaws.com/'),
				new OaklandProvider('http://oakland-sf-1936.s3.amazonaws.com/'),
				new OaklandProvider('http://oakland-1912.s3.amazonaws.com/'),
				new OaklandProvider('http://oakland-1877.s3.amazonaws.com/'),
				//new OaklandProvider('http://hills-bayarea.s3.amazonaws.com/', '.png'),
				new CloudMadeProvider('1a914755a77758e49e19a26e799268b7', CloudMadeProvider.FRESH),
				new CloudMadeProvider('1a914755a77758e49e19a26e799268b7', CloudMadeProvider.MIDNIGHT_COMMANDER),
				new CloudMadeProvider('1a914755a77758e49e19a26e799268b7', CloudMadeProvider.PALE_DAWN)				
			];

			for each (var provider:IMapProvider in providers) {
				var map:TweenMap = new TweenMap(stage.stageWidth, stage.stageHeight, true, provider);
				map.grid.maxOpenRequests = 1;
				map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);
				map.addEventListener(MouseEvent.MOUSE_WHEEL, map.onMouseWheel); 
				addChild(map);
				maps.push(map);
			}
			
			for each (map in maps) {
				map.addEventListener(MapEvent.START_PANNING, onMapStartChange);
				map.addEventListener(MapEvent.START_ZOOMING, onMapStartChange);
				map.addEventListener(MapEvent.BEGIN_EXTENT_CHANGE, onMapStartChange);
				map.addEventListener(MapEvent.STOP_PANNING, clearMaster);
				map.addEventListener(MapEvent.STOP_ZOOMING, clearMaster);
				map.addEventListener(MapEvent.EXTENT_CHANGED, clearMaster);
				map.addEventListener(MapEvent.RESIZED, onMapChange);
			}
			
			maps[6].addChild(new MapControls(maps[6], true, true));
			maps[4].setCenterZoom(new Location(37.804, -122.258), 13);
			
			stage.addEventListener(Event.RESIZE, onStageResize);
			onStageResize(null);			
		}
		
		private var master:Map;
		
		public function onMapStartChange(event:MapEvent):void
		{
			master = event.currentTarget as Map;
			addEventListener(Event.ENTER_FRAME, onMapChange);
		}
		
		public function onMapChange(event:Event):void
		{
			if (!master) {
				return;
			}
			
			syncMapsWith(master);
		}
		
		public function syncMapsWith(leaderMap:Map):void
		{
			var masterIndex:int = maps.indexOf(leaderMap);
			var masterX:int = masterIndex % 3;
			var masterY:int = Math.floor(masterIndex / 3);
			
			var i:int = 0;
			for (var my:int = 0; my < 3; my++) {
				for (var mx:int = 0; mx < 3; mx++) {
					if (i != masterIndex) {
						var dx:int = masterX - mx;
						var dy:int = masterY - my;
						
						var map:Map = maps[i] as Map;
						
						var matrix:Matrix = leaderMap.grid.getMatrix();
						
						matrix.tx += dx * stage.stageWidth/3;
						matrix.ty += dy * stage.stageHeight/3;;
						
						map.grid.setMatrix(matrix);
					}
					
					i++;
				}
			}
		}
		
		public function clearMaster(event:Event):void
		{
			if (master == event.currentTarget) {
				onMapChange(event);				
				master = null;
			}
		}
				
		public function onStageResize(event:Event):void
		{
			var i:int = 0;
			for (var my:int = 0; my < 3; my++) {
				for (var mx:int = 0; mx < 3; mx++) {
					var map:Map = maps[i] as Map;
					map.setSize(-2 + stage.stageWidth/3, -2 + stage.stageHeight/3);
					map.x = mx * stage.stageWidth/3;
					map.y = my * stage.stageHeight/3;
					i++;
				}
			}
			syncMapsWith(maps[4]);
		}
	}
}

import com.modestmaps.core.Coordinate;
import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.mapproviders.AbstractMapProvider;	

class OaklandProvider extends AbstractMapProvider implements IMapProvider
{
	public var base:String;
	public var extension:String;
	
	public function OaklandProvider(base:String, extension:String='.jpg')
	{
		this.base = base;
		this.extension = extension;
	}
	
    public function getTileUrls(coord:Coordinate):Array
    {
    	return [ base + int(coord.zoom).toString() + '-r' + int(coord.row).toString() + '-c' + int(coord.column).toString() + extension ];
    }
    
    public function toString():String
    {
    	return "OAKLAND_PROVIDER";
    }    
}
