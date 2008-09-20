package {
	import com.adobe.viewsource.ViewSource;
	import com.modestmaps.Map;
	import com.modestmaps.TweenMap;
	import com.modestmaps.extras.MapControls;
	import com.modestmaps.extras.MapCopyright;
	import com.modestmaps.extras.ZoomSlider;
	import com.modestmaps.geo.Location;
	import com.modestmaps.mapproviders.microsoft.MicrosoftHybridMapProvider;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;

	[SWF(backgroundColor="#ffffff")]
	public class HelloMarkers extends Sprite
	{
		public var map:Map;
		
		public function HelloMarkers()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			ViewSource.addMenuItem(this, 'srcview/index.html', true);
			
			// make a draggable TweenMap so that we have smooth zooming and panning animation
			// use Microsoft's Hybrid tiles.
			map = new TweenMap(stage.stageWidth, stage.stageHeight, true, new MicrosoftHybridMapProvider());
			map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);
			
			// add some basic controls
			// you're free to use these, but I'd make my own if I was a Flash coder :)
			map.addChild(new MapControls(map));
			map.addChild(new ZoomSlider(map));
			
			// add a copyright handler
			// (this is a bit of a hack, but works well enough for now)
			map.addChild(new MapCopyright(map));

			// create an instance of the Marker class defined below
			// (location from getlatlon.com, thanks Simon!)
			var marker:Marker = new Marker(new Location(37.645614, -120.993705), "Modesto, CA");

			// add the marker to the map's default MarkerClip
			// (later on you can make your own MarkerClips and layer them if you want)
			map.putMarker(marker.location, marker);			
			
			// show the marker
			// 11 seems like a good zoom level...
			map.setCenterZoom(marker.location, 11);

			// add map to stage last, so as to avoid markers jumping around
			addChild(map);

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
import com.modestmaps.geo.Location;	

class Marker extends Sprite
{
	public var text:String;
	public var location:Location;
	
	public function Marker(location:Location, text:String)
	{
		this.location = location;
		this.text = text;
		
		graphics.beginFill(0x000000);
		graphics.drawCircle(0,0,12);
		graphics.beginFill(0xff9900);
		graphics.drawCircle(0,0,10);
		graphics.beginFill(0xffff00);
		graphics.drawCircle(0,0,5);
	}
}
