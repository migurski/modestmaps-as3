package
{
	import com.adobe.viewsource.ViewSource;
	import com.modestmaps.core.MapExtent;
	import com.modestmaps.events.MarkerEvent;
	import com.modestmaps.extras.MapCopyright;
	import com.modestmaps.geo.Location;
	import com.modestmaps.mapproviders.CloudMadeProvider;
	import com.pixelbreaker.ui.osx.MacMouseWheel;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;	
	[SWF(backgroundColor="#ffffff")]
	public class HelloInfoBubbles extends Sprite
	{
		[Embed(source="images/001_09.png")]
		protected var MarkerImage:Class
		
		public var map:InfoMap

		public function HelloInfoBubbles()
		{
			stage.align = StageAlign.TOP_LEFT
			stage.scaleMode = StageScaleMode.NO_SCALE
			
			MacMouseWheel.setup(stage)

			ViewSource.addMenuItem(this, 'srcview/index.html', true);
			
			// NB:- please use your own API key, see http://developers.cloudmade.com/projects for more details
			map = new InfoMap(stage.stageWidth, stage.stageHeight, true, new CloudMadeProvider('1a914755a77758e49e19a26e799268b7', '1'))
			map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick)
			map.addEventListener(MouseEvent.MOUSE_WHEEL, map.onMouseWheel)
			addChild(map)

			map.addChild(new IconControls(map))
			map.addChild(new MapCopyright(map))
			
			// cloudmade cities, from http://www.getlatlon.com/
			var locations:Array = [ new Location(51.50757, -0.1078), new Location(50.4363, 30.5390), new Location(37.47794, -122.15110) ]
			
			map.setExtent(MapExtent.fromLocations(locations))
			
			var names:Array = [ 'London', 'Kiev', 'Menlo Park' ]
			for each (var location:Location in locations) {
				var marker:Sprite = new Sprite()
				marker.name = names.shift()
				marker.buttonMode = marker.useHandCursor = true
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

import com.modestmaps.Map
import com.modestmaps.mapproviders.IMapProvider
import com.modestmaps.geo.Location
import com.modestmaps.overlays.MarkerClip
import com.modestmaps.core.MapExtent
import com.modestmaps.events.MapEvent
import com.modestmaps.TweenMap	
import com.modestmaps.events.MarkerEvent

import flash.display.Sprite
import flash.display.Shape
import flash.display.Bitmap
import flash.display.Graphics
import flash.filters.BlurFilter
import flash.geom.Point
import flash.geom.Matrix
import flash.geom.Rectangle
import flash.text.TextField
import flash.events.Event
import flash.events.MouseEvent

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

class InfoBubble extends Sprite
{
	public var textField:TextField
	public var background:Shape
	public var shadow:Shape
	
	public function InfoBubble(text:String)
	{
		this.name = text
		
		this.mouseEnabled = true
		this.mouseChildren = false
		
		shadow = new Shape()
		shadow.filters = [ new BlurFilter(16, 16) ]
		shadow.transform.matrix = new Matrix(1, 0, -0.5, 0.5, 0, 0)    
		addChild(shadow)
		
		background = new Shape()
		addChild(background)
		
		textField = new TextField()
		textField.selectable = false
		textField.text = text
		textField.width = textField.textWidth+6
		textField.height = textField.textHeight+4
		addChild(textField)
		
		// remember that things in marker clips are positioned with (0,0) at the given location
		textField.y = -textField.height - 15
		textField.x = -10
		
		var rect:Rectangle = textField.getRect(this)
		
		// get your graph paper ready, here's a "speech bubble"
		background.graphics.beginFill(0xffffff)
		shadow.graphics.beginFill(0x000000)
		
		for each (var g:Graphics in [ background.graphics, shadow.graphics ] ) {
			g.moveTo(rect.left, rect.top)
			g.lineTo(rect.right, rect.top)
			g.lineTo(rect.right, rect.bottom)
			g.lineTo(rect.left+15, rect.bottom)
			g.lineTo(rect.left+10, rect.bottom+15)
			g.lineTo(rect.left+5, rect.bottom)
			g.lineTo(rect.left, rect.bottom)
			g.lineTo(rect.left, rect.top)
			g.endFill()
		}		
	}
}

class InfoMap extends TweenMap
{
	public var infoClip:MarkerClip
	public var infoBubble:InfoBubble		

	public function InfoMap(width:Number=320, height:Number=240, draggable:Boolean=true, provider:IMapProvider=null)
	{
		super(width, height, draggable, provider)

		// map has one markerclip built-in, but let's make another one for info-bubbles:
		infoClip = new MarkerClip(this)
		addChild(infoClip)
		
		addEventListener(MarkerEvent.MARKER_CLICK, onMarkerClick)
	}

	public function onMarkerClick(event:MarkerEvent):void
	{
		showInfoBubble(event.marker.name, event.location)
	}
	
	override public function zoomIn(event:Event=null):void
	{
		if (infoBubble) {
			var point:Point = new Point(infoBubble.x, infoBubble.y)
			point = globalToLocal(infoClip.localToGlobal(point))
			zoomInAbout(point)
		}
		else {
			super.zoomIn(event)
		}
	}
	
	override public function zoomOut(event:Event=null):void
	{
		if (infoBubble) {
			var point:Point = new Point(infoBubble.x, infoBubble.y)
			point = globalToLocal(infoClip.localToGlobal(point))
			zoomOutAbout(point)
		}
		else {
			super.zoomOut(event)
		}
	}
	
	public function showInfoBubble(name:String, location:Location):void
	{
		if (infoBubble) {
			infoClip.removeMarkerObject(infoBubble)
			infoBubble = null
		}
		infoBubble = new InfoBubble(name)
		infoClip.attachMarker(infoBubble, location)
	}
}
