package
{
	import com.adobe.viewsource.ViewSource;
	import com.modestmaps.TweenMap;
	import com.modestmaps.extras.MapCopyright;
	import com.modestmaps.geo.Location;
	import com.modestmaps.mapproviders.BlueMarbleMapProvider;
	import com.pixelbreaker.ui.osx.MacMouseWheel;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	[SWF(backgroundColor="#ffffff")]
	public class HelloIcons extends Sprite
	{
		public var map:TweenMap

		[Embed(source="images/001_09.png")]
		protected var MarkerImage:Class
		
		public function HelloIcons()
		{
			stage.align = StageAlign.TOP_LEFT
			stage.scaleMode = StageScaleMode.NO_SCALE
			
			MacMouseWheel.setup(stage)

			ViewSource.addMenuItem(this, 'srcview/index.html', true);
			
			map = new TweenMap(stage.stageWidth, stage.stageHeight, true, new BlueMarbleMapProvider())
			map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick)
			map.addEventListener(MouseEvent.MOUSE_WHEEL, map.onMouseWheel)
			addChild(map)

			map.addChild(new IconControls(map))
			map.addChild(new MapCopyright(map))
			
			// my cities, from http://www.getlatlon.com/
			var locations:Array = [ new Location(51.5001524, -0.1262362), new Location(37.775196, -122.419204) ]
			for each (var location:Location in locations) {
				var marker:Sprite = new Sprite()
				var markerImage:Bitmap = new MarkerImage() as Bitmap
				markerImage.x = -markerImage.width/2
				markerImage.y = -markerImage.height/2
				marker.addChild(markerImage)
				map.putMarker(location, marker)
			}

			// make sure the map fills the screen:
			stage.addEventListener(Event.RESIZE, onStageResize)			
		}
		
		public function onStageResize(event:Event):void
		{
			map.setSize(stage.stageWidth, stage.stageHeight)
		}
	}
}

import flash.display.Sprite
import com.modestmaps.Map
import flash.display.Bitmap
import flash.events.MouseEvent
import com.modestmaps.core.MapExtent
import flash.geom.Rectangle
import mx.controls.Image
import com.modestmaps.events.MapEvent
import com.modestmaps.TweenMap	

class IconControls extends Sprite
{
	// icons "free to use in any kind of project unlimited times" from http://www.icojoy.com/articles/26/
	[Embed(source="images/001_21.png")]
	protected var RightImage:Class

	[Embed(source="images/001_22.png")]
	protected var DownImage:Class

	[Embed(source="images/001_23.png")]
	protected var LeftImage:Class

	[Embed(source="images/001_24.png")]
	protected var UpImage:Class

	[Embed(source="images/001_04.png")]
	protected var OutImage:Class

	[Embed(source="images/001_03.png")]
	protected var InImage:Class

	[Embed(source="images/001_20.png")]
	protected var HomeImage:Class
	
	protected var map:TweenMap
	
	public function IconControls(map:TweenMap):void
	{
		this.map = map
		
		this.mouseEnabled = false
		this.mouseChildren = true
		
		var right:Sprite = new Sprite()
		var down:Sprite = new Sprite()
		var left:Sprite = new Sprite()
		var up:Sprite = new Sprite()
		var zout:Sprite = new Sprite()
		var zin:Sprite = new Sprite()
		var home:Sprite = new Sprite()

		var buttons:Array = [ right, down, left, up, zout, zin, home ]
		var imageClasses:Array = [ RightImage, DownImage, LeftImage, UpImage, OutImage, InImage, HomeImage ]
		var actions:Array = [ map.panRight, map.panDown, map.panLeft, map.panUp, map.zoomOut, map.zoomIn, onHomeClick ]
		for each (var sprite:Sprite in buttons) {
			var ImageClass:Class = imageClasses.shift() as Class
			sprite.addChild(new ImageClass() as Bitmap)
			sprite.useHandCursor = sprite.buttonMode = true
			sprite.addEventListener(MouseEvent.CLICK, actions.shift(), false, 0, true)
			addChild(sprite)
		}
	
		left.x = 5
		up.x = down.x = left.x + left.width + 5
		right.x = down.x + down.width + 5
		
		up.y = 5
		left.y = down.y = right.y = up.y + up.height + 5
		
		zout.x = zin.x = right.x + right.width + 10
		zin.y = up.y
		zout.y = zin.y + zin.height + 5
		
		home.x = zout.x + zout.width + 10
		home.y = zout.y
		
		var rect:Rectangle = getRect(this)
		rect.inflate(rect.x, rect.y)
		
		graphics.beginFill(0xff0000, 0)
		graphics.drawRect(rect.x, rect.y, rect.width, rect.height)
		graphics.endFill()		
		
		map.addEventListener(MapEvent.RESIZED, onMapResize)
		onMapResize(null)
	}
	
	protected function onMapResize(event:MapEvent):void
	{
		this.x = 10
		this.y = map.getHeight() - this.height - 10		
	}
	
	protected function onHomeClick(event:MouseEvent):void
	{
		map.tweenExtent(new MapExtent(85, -85, 180, -180))
	}
}
