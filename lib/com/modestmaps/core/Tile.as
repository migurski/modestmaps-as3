
package com.modestmaps.core
{
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.core.TileGrid;
	import com.modestmaps.core.TilePaintCall;
	import com.modestmaps.events.MapProviderEvent;
	import com.modestmaps.mapproviders.AbstractMapProvider;
	import com.modestmaps.mapproviders.IMapProvider;
	import com.stamen.twisted.Reactor;

	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class Tile extends Sprite
	{
		// hacked in tide fading, set Tile.FADE_STEPS to e.g. 10
		// TODO: hook this into the Reactor and backport to AS2
		public static var FADE_STEPS:int = 0;
		
	    public var grid:TileGrid;
	
	    protected var _coord:Coordinate;	
		// Keeps track of all sprites awaiting painting.
		protected var _displayClips : Array;
		protected var _paintCall : TilePaintCall;		
		protected var _active:Boolean;
	
		private var timer:Timer;
	
	    public function Tile(grid:TileGrid, coord:Coordinate, x:Number, y:Number)
	    {
	    	super();
	    	this.grid = grid;
	    	this._coord = coord;
	    	this.x = x;
	    	this.y = y;
	    	_active = true;
	    	_displayClips = new Array();  	
	    }

	    public function get coord():Coordinate
	    {
	    	return _coord;	
	    }

	    public function set coord(coord:Coordinate):void
	    {
	    	_coord = coord;
	    	redraw();	
	    }
	    
	    public function isActive():Boolean
	    {
	        return _active;
	    }
	        
	    public function expire():void
	    {
	        cancelDraw();
	        _active = false;
	    }
	        
	    public function center():Point
	    {
	        return new Point(x + TileGrid.TILE_WIDTH / 2, y + TileGrid.TILE_HEIGHT / 2);
	    }
	    
	    public function zoomOut():void
	    {
	        coord = new Coordinate(Math.floor(coord.row / 2), Math.floor(coord.column / 2), coord.zoom + 1);
	    }
	
	    public function zoomInTopLeft():void
	    {
	        coord = new Coordinate(coord.row * 2, coord.column * 2, coord.zoom - 1);
	    }
	
	    public function zoomInTopRight():void
	    {
	        coord = new Coordinate(coord.row * 2, coord.column * 2 + 1, coord.zoom - 1);
	    }
	
	    public function zoomInBottomLeft():void
	    {
	        coord = new Coordinate(coord.row * 2 + 1, coord.column * 2, coord.zoom - 1);
	    }
	
	    public function zoomInBottomRight():void
	    {
	        coord = new Coordinate(coord.row * 2 + 1, coord.column * 2 + 1, coord.zoom - 1);
	    }
	
	    public function panUp(distance:Number):void
	    {
	        coord = coord.up(distance);
	    }
	
	    public function panRight(distance:Number):void
	    {
	        coord = coord.right(distance);
	    }
	
	    public function panDown(distance:Number):void
	    {
	        coord = coord.down(distance);
	    }
	
	    public function panLeft(distance:Number):void
	    {
	        coord = coord.left(distance);
	    }
	
	    override public function toString():String
	    {
	        return id();
	    }
	
	    public function id():String
	    {
	        return 'Tile' + coord.toString();
	    }
	
	    public function redraw():void
	    {
	    	
	    	// any need to repeat ourselves?
	    	if (_paintCall && _paintCall.match(grid.getMapProvider(), coord.copy()) && _paintCall.pending()) {
	            return;
	    	}
	    	
	        // are we even allowed to paint ourselves?
	        if (!grid || !grid.paintingAllowed()) {
	            return;
	        }
			
	    	// cancel existing call, if any...
	    	if (_paintCall) {
	    	    _paintCall.cancel();
	    	}
	    	
	   		// hide all other displayClips to avoid weird "repaint" effect
  	   		var count:Number = _displayClips.length;
	   		while (count--)
	   		{
	   			_displayClips[count].sprite.visible = false;
	   		}
	   		 
	   		if (coord) 
	   		{
		    	// fire up a new call for the next frame...
		    	_paintCall = new TilePaintCall(Reactor.callNextFrame(paint, grid.getMapProvider(), coord.copy()),
									     grid.getMapProvider(), coord.copy());
		    }
	    }
	    
	    public function paint(mapProvider:IMapProvider, tileCoord:Coordinate):void
	    {
	    	// set up the proper sprite to paint here
		grid.getMapProvider().addEventListener(MapProviderEvent.PAINT_COMPLETE, onPaintComplete);
	    	
	    	var spriteId:Number = _displayClips.length;
	    	var sprite:Sprite = new Sprite();
	    	sprite.name = "display" + spriteId;
	    	if (Tile.FADE_STEPS > 0) {
		    	sprite.alpha = 0.0;
	    		timer = new Timer(1000.0/stage.frameRate,FADE_STEPS);
	    		timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {
	    			for each (var obj:Object in _displayClips) {
	    				obj.sprite.alpha = event.target.currentCount/event.target.repeatCount;
	    			}
	    		});
	    		timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent):void {
	    			for each (var obj:Object in _displayClips) {
	    				obj.sprite.alpha = 1.0;
	    			}
	    		});		    	
		    }
	    	addChild(sprite);
	   		
	   		_displayClips.push({sprite: sprite, coord: tileCoord});
	   	
	    	mapProvider.paint(sprite, tileCoord);
	    }
	    
	    public function cancelDraw():void
	    {
	    	if (_paintCall) {
		        _paintCall.cancel();
		    }
	    }
	    
	    // Event Handlers
	    
	    protected function onPaintComplete(event:MapProviderEvent):void
	    {
	    	if (coord.equalTo(event.coord))
	    	{
	    		grid.getMapProvider().removeEventListener(MapProviderEvent.PAINT_COMPLETE, onPaintComplete);
	    		
	    		// remove all other displayClips /below/ this sprite   		
	    		var dcCoord:Coordinate;
	    		for (var i:int = 0; i < _displayClips.length; i++)
	    		{
	    			dcCoord = _displayClips[i].coord as Coordinate;
	    			    			
	    			if (dcCoord.equalTo(coord))
	    			{
						break; // only removing *below* this sprite
	    			}
	    			else
	    			{
	    				var sprite:Sprite = _displayClips[i].sprite as Sprite;
	    				removeChild(sprite);
	    				_displayClips.splice(i, 1);
	    				i--;
	    			}
	    		}
	    		
	    		if (Tile.FADE_STEPS > 0 && !timer.running) {
		    		timer.start();
	    		}

			dispatchEvent(event);
	    	}   	
	    }   
	}
}
