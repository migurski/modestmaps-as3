package {
	
	import com.modestmaps.core.MapExtent;
	import com.modestmaps.geo.Location;
	import com.modestmaps.Map;
	import com.modestmaps.mapproviders.*;
	import com.modestmaps.mapproviders.google.*;
	import com.modestmaps.mapproviders.yahoo.*;
	import com.modestmaps.mapproviders.microsoft.*;
	import com.stamen.twisted.Reactor;
	import flash.geom.Point;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import com.modestmaps.events.MapEvent;
	import com.modestmaps.events.MarkerEvent;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.filters.GlowFilter;
	import flash.filters.BlurFilter;
	
	[SWF(backgroundColor="#ffffff", frameRate="24")]
	
	public class ModestMapsSample extends Sprite
	{
		private var map:Map;
		private var navButtons:Sprite;
		private var mapButtons:Sprite;
		private var status:TextField;
		private var copyright:TextField;
		
	    public function ModestMapsSample()
	    {
	        Reactor.run(this, 50);

	        map = new Map();
	        addChild(map);
	        map.init(stage.stageWidth-256, stage.stageHeight-256, true, new MicrosoftRoadMapProvider());
	        map.addEventListener(MapEvent.ZOOMED_BY, onZoomed);
	        map.addEventListener(MapEvent.STOP_ZOOMING, onStopZoom);
	        map.addEventListener(MapEvent.PANNED, onPanned);
	        map.addEventListener(MapEvent.STOP_PANNING, onStopPan);
	        map.addEventListener(MapEvent.RESIZED, onResized);
	        map.addEventListener(MapEvent.COPYRIGHT_CHANGED, onCopyrightChanged);
	        
	        status = new TextField();
	        status.selectable = false;
	        status.textColor = 0x000000;
	        status.text = '...';
	        status.width = 600;
	        status.height = status.textHeight + 2;
	        addChild(status);

	        copyright = new TextField();
	        copyright.selectable = false;
	        copyright.textColor = 0x000000;
	        var tf:TextFormat = new TextFormat();
	        tf.align = TextFormatAlign.RIGHT;
	        copyright.defaultTextFormat = tf;
	        copyright.text = '...';
	        copyright.height = copyright.textHeight + 2;
	        addChild(copyright);
/* 	        var filts:Array = copyright.filters;
	        filts.push(new GlowFilter(0xff0000));
	        copyright.filters = filts;
 */	
	        map.setExtent(new MapExtent(37.829853, 37.700121, -122.212601, -122.514725));
	
	        //Reactor.callLater(2000, Delegate.create(map, map.setNewCenter), new Location(37.811411, -122.360916), 14);
	        
	        map.addEventListener(MarkerEvent.ENTER, onMarkerEnters);
	        map.addEventListener(MarkerEvent.LEAVE, onMarkerLeaves);
	        
	        map.putMarker('Rochdale', new Location(37.865571, -122.259679));
	        map.putMarker('Parker Ave.', new Location(37.780492, -122.453731));
	        map.putMarker('Pepper Dr.', new Location(37.623443, -122.426577));
	        map.putMarker('3rd St.', new Location(37.779297, -122.392877));
	        map.putMarker('Divisadero St.', new Location(37.771919, -122.437413));
	        map.putMarker('Market St.', new Location(37.812734, -122.280064));
	        map.putMarker('17th St.', new Location(37.804274, -122.262940));
	        
	        stage.scaleMode = StageScaleMode.NO_SCALE;
	        stage.align = StageAlign.TOP_LEFT;
	        stage.addEventListener(Event.RESIZE, onResize);
	        
	        Reactor.callNextFrame(onResize, null);
	        
	        var buttons:Array = new Array();
	        
	        navButtons = new Sprite();
	        addChild(navButtons);
	        
	        buttons.push(makeButton(navButtons, 'plus', 'zoom in', map.zoomIn));
	        buttons.push(makeButton(navButtons, 'minus', 'zoom out', map.zoomOut));
	        buttons.push(makeButton(navButtons, 'left', 'pan left', map.panLeft));
	        buttons.push(makeButton(navButtons, 'up', 'pan up', map.panUp));
	        buttons.push(makeButton(navButtons, 'down', 'pan down', map.panDown));
	        buttons.push(makeButton(navButtons, 'left', 'pan right', map.panRight));
	
			//navButtons._x = navButtons._y = 50;
			
			var nextX:Number = 0;
			
			for(var i:Number = 0; i < buttons.length; i++) {
				buttons[i].x = nextX;
				nextX += Sprite(buttons[i]).getChildByName('label').width + 5;	
			}
	
			// mapProvider buttons
	
			mapButtons = new Sprite();
			addChild(mapButtons);
	
	        buttons = new Array();
			
			buttons.push(makeButton(mapButtons, 'MICROSOFT_ROAD', 'ms road', switchMapProvider));
	        buttons.push(makeButton(mapButtons, 'MICROSOFT_AERIAL', 'ms aerial', switchMapProvider));
	        buttons.push(makeButton(mapButtons, 'MICROSOFT_HYBRID', 'ms hybrid', switchMapProvider));
	
			buttons.push(makeButton(mapButtons, 'GOOGLE_ROAD', 'google road', switchMapProvider));
	        buttons.push(makeButton(mapButtons, 'GOOGLE_AERIAL', 'google aerial', switchMapProvider));
	        buttons.push(makeButton(mapButtons, 'GOOGLE_HYBRID', 'google hybrid', switchMapProvider));
	
			buttons.push(makeButton(mapButtons, 'YAHOO_ROAD', 'yahoo road', switchMapProvider));
	        buttons.push(makeButton(mapButtons, 'YAHOO_AERIAL', 'yahoo aerial', switchMapProvider));
	        buttons.push(makeButton(mapButtons, 'YAHOO_HYBRID', 'yahoo hybrid', switchMapProvider));
	
	        buttons.push(makeButton(mapButtons, 'BLUE_MARBLE', 'blue marble', switchMapProvider));
	        buttons.push(makeButton(mapButtons, 'OPEN_STREET_MAP', 'open street map', switchMapProvider));
	
			var nextY : Number = 0;
			
			for(var i:Number = 0; i < buttons.length; i++) {
				buttons[i].y = nextY;
				nextY += Sprite(buttons[i]).getChildByName('label').height + 5;
				buttons[i].alpha = 0.60;
			}
	
	        //_root.createEmptyMovieClip('marks', _root.getNextHighestDepth());
	    }
	    
	    
	    private function switchMapProvider(event:Event):void
	    {
	    	var button:Sprite = event.target as Sprite;
	        switch(button.name) {
				case 'VANILLA':
					map.setMapProvider(new VanillaMapProvider());
					break;
	
				case 'BLUE_MARBLE':
					map.setMapProvider(new BlueMarbleMapProvider());
					break;
	
				case 'OPEN_STREET_MAP':
					map.setMapProvider(new OpenStreetMapProvider());
					break;
	
				case 'MICROSOFT_ROAD':
					map.setMapProvider(new MicrosoftRoadMapProvider());
					break;
	
				case 'MICROSOFT_AERIAL':
					map.setMapProvider(new MicrosoftAerialMapProvider());
					break;
	
				case 'MICROSOFT_HYBRID':
					map.setMapProvider(new MicrosoftHybridMapProvider());
					break;
					
				case 'GOOGLE_ROAD':
					map.setMapProvider(new GoogleRoadMapProvider());
					break;
	
				case 'GOOGLE_AERIAL':
					map.setMapProvider(new GoogleAerialMapProvider());
					break;
	
				case 'GOOGLE_HYBRID':
					map.setMapProvider(new GoogleHybridMapProvider());
					break;
	
				case 'YAHOO_ROAD':
					map.setMapProvider(new YahooRoadMapProvider());
					break;
	
				case 'YAHOO_AERIAL':
					map.setMapProvider(new YahooAerialMapProvider());
					break;
	
				case 'YAHOO_HYBRID':
					map.setMapProvider(new YahooHybridMapProvider());
					break;
	        }
	    }
	    
	    public function makeButton(clip:Sprite, name:String, labelText:String, action:Function):Sprite
	    {
	        var button:Sprite = new Sprite();
	        button.name = name;
	        clip.addChild(button);
	        
	        var label:TextField = new TextField();
	        label.name = 'label';
	        label.selectable = false;
	        label.textColor = 0xffffff;
	        label.text = labelText;
	        label.width = label.textWidth + 4;
	        label.height = label.textHeight + 2;
	        button.addChild(label);
	        
	        button.graphics.moveTo(0, 0);
	        button.graphics.beginFill(0x000000, 1.0);
	        button.graphics.drawRect(0, 0, label.width, label.height);
	        button.graphics.endFill();

			button.addEventListener(MouseEvent.CLICK, action);
			button.useHandCursor = true;
			button.mouseChildren = false;
			button.buttonMode = true;
	        
	        return button;
	    }
	    
	    public function output(str:String):void
	    {
	    	trace(str);	
	    }
	    
	    // Event Handlers
	    
	    private function onResize(event:Event):void
	    {
	        map.x = map.y = 50;
	        map.setSize(stage.stageWidth - 2*map.x, stage.stageHeight - 2*map.y);
	
			navButtons.x = map.x;
	        navButtons.y = map.y - navButtons.height - 10;
	
			mapButtons.x = map.x + (stage.stageWidth - 2*map.x) - mapButtons.width - 10;
			mapButtons.y = map.y + 10;
	
			status.width = map.getSize()[0];
			status.x = map.x + 2;
			status.y = map.y + map.getSize()[1];

			copyright.width = map.getSize()[0];
			copyright.x = map.x + map.getSize()[0] - copyright.width;
			copyright.y = map.y + map.getSize()[1] - copyright.height;
			trace(copyright.x + " " + copyright.y + " " + copyright.width);
		}
	    
	    private function onPanned(event:MapEvent):void
	    {
	        status.text = 'Panned by '+ event.panDelta.toString() +', top left: '+map.getExtent().northWest.toString()+', bottom right: '+map.getExtent().southEast.toString();
	    }
	    
	    private function onStopPan(event:MapEvent):void
	    {
	        status.text = 'Stopped panning, top left: '+map.getExtent().northWest.toString()+', center: '+map.getCenterZoom()[0].toString()+', bottom right: '+map.getExtent().southEast.toString()+', zoom: '+map.getCenterZoom()[1];
	    }
	    
	    private function onZoomed(event:MapEvent):void
	    {
	        status.text = 'Zoomed by '+event.zoomDelta.toString()+', top left: '+map.getExtent().northWest.toString()+', bottom right: '+map.getExtent().southEast.toString();
	    }
	    
	    private function onStopZoom(event:MapEvent):void
	    {
	        status.text = 'Stopped zooming, top left: '+map.getExtent().northWest.toString()+', center: '+map.getCenterZoom()[0].toString()+', bottom right: '+map.getExtent().southEast.toString()+', zoom: '+map.getCenterZoom()[1];
	    }
	    
	    private function onResized(event:MapEvent):void
	    {
	        status.text = 'Resized to: '+ event.newSize[0] +' x '+ event.newSize[1];
	    }

	    private function onCopyrightChanged(event:MapEvent):void
	    {
	        copyright.text = map.copyright;
//	    	trace(copyright.text);
	    }
	    
	    private function onMarkerEnters(event:MarkerEvent):void
	    {
	        trace('+ '+event.marker+' =)');
	    }
	    
	    private function onMarkerLeaves(event:MarkerEvent):void
	    {
	        trace('- '+event.marker+' =(');
	    }
	}
	
}
