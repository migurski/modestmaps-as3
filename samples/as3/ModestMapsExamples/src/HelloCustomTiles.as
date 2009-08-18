package {
	import com.adobe.viewsource.ViewSource;
	import com.modestmaps.Map;
	import com.modestmaps.TweenMap;
	import com.modestmaps.extras.MapControls;
	import com.modestmaps.extras.ZoomSlider;
	import com.modestmaps.geo.Location;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	[SWF(backgroundColor="#808080")]
	public class HelloCustomTiles extends Sprite
	{
		public var map:Map;
		
		public function HelloCustomTiles()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			ViewSource.addMenuItem(this, 'srcview/index.html', true);
			
			// make a draggable TweenMap so that we have smooth zooming and panning animation
			// use our blank provider, defined below:
			map = new TweenMap(stage.stageWidth, stage.stageHeight, true, new BlankProvider());
			map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);
			addChild(map);
			
			map.addChild(map.grid.debugField);
			
			// tell the map grid to make tiles using our custom class, defined below:
			map.grid.setTileClass(CustomTile);
			
			// add some basic controls
			// you're free to use these, but I'd make my own if I was a Flash coder :)
			map.addChild(new MapControls(map, true, true));
			map.addChild(new ZoomSlider(map));
			
			// start at 0,0
			// 11 seems like a good zoom level...
			map.setCenterZoom(new Location(0,0), 11);
			
			// make sure the map always fills the screen:
			stage.addEventListener(Event.RESIZE, onStageResize);			
		}
		
		public function onStageResize(event:Event):void
		{
			map.setSize(stage.stageWidth, stage.stageHeight);
		}
	}
}

import flash.display.Sprite;
import com.modestmaps.core.Tile;
import com.modestmaps.core.Coordinate;
import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.mapproviders.AbstractMapProvider;	

class CustomTile extends Tile
{
	public function CustomTile(column:int, row:int, zoom:int)
	{
		super(column, row, zoom);
	}

	override public function init(column:int, row:int, zoom:int):void
	{
		super.init(column, row, zoom);
		
		graphics.clear();
		graphics.beginFill(0xffffff);
		graphics.drawRect(0,0,32,32);
		graphics.endFill();
		
 		var r:int = Math.random() * 255;
		var g:int = Math.random() * 255;
		var b:int = Math.random() * 255;

		var c:int = 0xff000000 | r << 16 | g << 8 | b;
		
		graphics.beginFill(c);
		graphics.drawCircle(16,16,8);
		graphics.endFill();
	}
}

class BlankProvider extends AbstractMapProvider implements IMapProvider
{
    public function getTileUrls(coord:Coordinate):Array
    {
    	return [];
    }
    
    public function toString():String
    {
    	return "BLANK_PROVIDER";
    }
    
    override public function get tileWidth():Number
    {
    	return 32;
    }

    override public function get tileHeight():Number
    {
    	return 32;
    }
}
