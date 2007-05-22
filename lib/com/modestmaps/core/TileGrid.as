/*
 * vim:et sts=4 sw=4 cindent:
 * $Id$
 */

package com.modestmaps.core
{
	import com.modestmaps.Map;
	import com.modestmaps.mapproviders.IMapProvider;
	import com.modestmaps.core.*;
	import com.modestmaps.geo.Location;
	import com.stamen.twisted.*;

	import flash.geom.Point;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	import flash.geom.Transform;
	import flash.geom.Matrix;
	import flash.events.Event;
	import flash.display.Stage;
	
	public class TileGrid extends Sprite
	{
	    // Real maps use 256.
	    public static const TILE_WIDTH:Number = 256;
	    public static const TILE_HEIGHT:Number = 256;
	
	    protected var _map:Map;
	
	    protected var _width:Number;
	    protected var _height:Number;
		protected var _draggable:Boolean;	    
	
	    // Row and column counts are kept up-to-date.
	    protected var _rows:int;
	    protected var _columns:int;
	    protected var _tiles:/*Tile*/Array;
	    
	    // overlay markers
	    protected var markers:MarkerSet;
	    
	    // Markers overlapping the currently-included set of tiles, hash of booleans
	    protected var _overlappingMarkers:Dictionary;
	
	    // Allow (true) or prevent (false) tiles to paint themselves.
	    protected var _paintingAllowed:Boolean;
	    
	    // Starting point for the very first tile
	    protected var _initTilePoint:Point;
	    protected var _initTileCoord:Coordinate;
	    
	    // the currently-native zoom level
	    public var zoomLevel:int;
	    
	    // some limits on scrolling distance, initially set to none
	    protected var topLeftOutLimit:Coordinate;
	    protected var bottomRightInLimit:Coordinate;
	    
	    protected var _startingWellPosition:Point;
	
	    // Tiles attach to the well.
	    protected var _well:Sprite;
	    
	    // Mask clip to hide outside edges of tiles.
	    protected var _mask:Sprite;
	
	    // Active when the well is being dragged on the stage.
	    protected var _wellDragTask:DelayedCall;
	    
	    // Defines a ring of extra, masked-out tiles around
	    // the edges of the well, acting as a pre-fetching cache.
	    // High tileBuffer may hurt performance.
	    protected var _tileBuffer:int = 0;
	
	    // Who do we get our Map graphics from?
	    protected var _mapProvider:IMapProvider;
	
		protected var _drawWell:Boolean = true;
		protected var _drawGridArea:Boolean = true;
	
	    public function init(width:Number, height:Number, draggable:Boolean, provider:IMapProvider, map:Map):void
	    {
	        if (!Reactor.running())
	            throw new Error('com.modestmaps.core.TileGrid.init(): com.stamen.Twisted.Reactor really ought to be running at this point. Seriously.');
	
	        _map = map;
	        _width = width;
	        _height = height;
	        _draggable = draggable;
	        _mapProvider = provider;
	    
	        buildWell();
	        buildMask();
	        allowPainting(true);
	        redraw();   
	        
	        _overlappingMarkers = new Dictionary(true);
	        markers = new MarkerSet(this);
	        
	        setInitialTile(new Coordinate(0,0,1), new Point(-TILE_WIDTH, -TILE_HEIGHT));
	       	initializeTiles();
	    }
	    
	   /**
	    * Set initTileCoord and initTilePoint for use by initializeTiles().
	    */
	    public function setInitialTile(coord:Coordinate, point:Point):void
	    {
	        _initTileCoord = coord;
	        _initTilePoint = point;
//	        Reactor.callNextFrame(initializeTiles);
	    }
	    
	   /**
	    * Reset tile grid with a new initial tile, and expire old tiles in the background.
	    */
	    public function resetTiles(coord:Coordinate, point:Point):void
	    {
//	    	trace('resetting tiles...');
	        if (!_tiles)
			{
//				trace("no _tiles for resetTiles() yet");
	            setInitialTile(coord, point);
	            return;
	        }
	    
//	    	trace('REALLY resetting tiles...');

			try {
		        var initTile:Tile;
		        var condemnedTiles:/*Tile*/Array = activeTiles();
		
		        for (var i:int = 0; i < condemnedTiles.length; i++)
		        {
		            condemnedTiles[i].expire();
		        }
		
		        Reactor.callLater(condemnationDelay(), destroyTiles, condemnedTiles);

				zoomLevel = coord.zoom;				
		        initTile = createTile(this, coord, point.x, point.y);
		                                                                  
		        centerWell(true);
		
		        _rows = 1;
		        _columns = 1;
		
		        allocateTiles();
		 	}
		    catch(e:Error) {
		    	trace(e.getStackTrace());
		    }
	        
	    }
	    
	   /**
	    * Create the first tiles, based on initTileCoord and initTilePoint.
	    */
	    protected function initializeTiles():void
	    {
	        var initTile:Tile;
	        
//	        trace('initializing...');

            if (!_initTileCoord) {
                trace("no _initTileCoord");
                return;			
            }	       
			 	        
	        // impose some limits
	        zoomLevel = _initTileCoord.zoom;
	        topLeftOutLimit = _mapProvider.outerLimits()[0];
	        bottomRightInLimit = _mapProvider.outerLimits()[1];
	        
//	        trace('REALLY initializing, like _tiles and shit...');
	        
            _tiles = [];
	        initTile = createTile(this, _initTileCoord, _initTilePoint.x, _initTilePoint.y);
	                                                                  
	        centerWell(false);
	
	        _rows = 1;
	        _columns = 1;
	        
	        // buffer must not be negative!
	        _tileBuffer = Math.max(0, _tileBuffer);
	        
	        allocateTiles();
	        
	        // let 'em know we're coming
	        markers.indexAtZoom(zoomLevel);
	        
	        updateMarkers();
	    }
	    
	    public function putMarker(id:String, coord:Coordinate, location:Location):Marker
	    {
	        var marker:Marker = new Marker(id, coord, location);
	        //trace('Marker '+id+': '+coord.toString());
	        markers.put(marker);
	
	        updateMarkers();
	        return marker;
	    }
	
	    public function removeMarker(id:String):void
	    {
	        var marker:Marker = markers.getMarker(id);
	        if (marker)
	            markers.remove(marker);
	    }
		
	   /**
	    * Create the well clip, assign event handlers.
	    */
	    protected function buildWell():void
	    {
	        _well = new Sprite();
	        _well.name = 'well';
	        
			if (_draggable) {
				_well.mouseChildren = false;
				_well.addEventListener(MouseEvent.MOUSE_DOWN, startWellDrag);
				_well.addEventListener(MouseEvent.MOUSE_UP, stopWellDrag);
			}
	        
	        addChild(_well);	        
	        centerWell(false);
	    }
	    
	   /**
	    * Create the mask clip.
	    */
	    protected function buildMask():void
	    {
	        _mask = new Sprite();
	        _mask.name = 'mask';
	        // as3 masks need to be child, so add the mask to the grid not the well
                // because well children are all tiles
                addChild(_mask);
	        this.mask = _mask;
	    }
	    
	    
	    public function getMapProvider():IMapProvider
	    {
	        return _mapProvider; 
	    }
	
	    public function setMapProvider(mapProvider:IMapProvider):void
	    {
	        var previousGeometry:String = _mapProvider.geometry();
	
	        _mapProvider = mapProvider; 
	        topLeftOutLimit = _mapProvider.outerLimits()[0];
	        bottomRightInLimit = _mapProvider.outerLimits()[1];
	
	        if (_mapProvider.geometry() != previousGeometry)
			{
	            markers.initializeIndex();
	            markers.indexAtZoom(zoomLevel);
	            updateMarkers();
	        }
	    }
	    
	    
	   /**
	    * Create a new tile, add it to _tiles array, and return it.
	    */
	    protected function createTile(grid:TileGrid, coord:Coordinate, x:Number, y:Number):Tile
	    {
	        var tile:Tile = new Tile(grid, coord, x, y);
	        tile.name = 'tile' + _tiles.length;
	        _well.addChild(tile);
	        	        
	        tile.redraw();
	        _tiles.push(tile);
	        
	        return tile;
	    }
	
	   /**
	    * Remove an old tile from the _tiles array, then destroy it.
	    */
	    protected function destroyTile(tile:Tile):void
	    {
//	        trace('Destroying tile: '+tile.toString());
	        _tiles.splice(tileIndex(tile), 1);
	        tile.cancelDraw();
	        _well.removeChild(tile);
	    }
	    
	   /*
	    * Slowly mete out destruction to a list of tiles.
	    */
	    protected function destroyTiles(tiles:/*Tile*/Array):void
	    {
	        if (tiles.length)
			{
	            destroyTile(Tile(tiles.shift()));
	            Reactor.callLater(0, destroyTiles, tiles);
	        }
	    }
	
	   /*
	    * Reposition tiles and schedule a recursive call for the next frame.
	    */
	    protected function onWellDrag(previousPosition:Point):void
	    {
	        if(positionTiles())
	            updateMarkers();
	
	        if(previousPosition.x != _well.x || previousPosition.y != _well.y)
	            _map.onPanned(new Point(_well.x - _startingWellPosition.x, _well.y - _startingWellPosition.y));
	        
	        _wellDragTask = Reactor.callNextFrame(onWellDrag, new Point(_well.x, _well.y));
	    }
	    
	   /*
	    * Return the point position of a tile with the given coordinate in the
	    * context of the given movie clip.
	    *
	    * Respect infinite rows or columns, to bind movement on one (or no) axis.
	    */
	    public function coordinatePoint(coord:Coordinate, context:Sprite, fearBigNumbers:Boolean=false):Point
	    {
	        // pick a reference tile, an arbitrary choice
	        // but known to exist regardless of grid size.
	        var tile:Tile = activeTiles()[0];
	    
	        // get the position of the reference tile.
	        var point:Point = new Point(tile.x, tile.y);
	        
	        // make sure coord is using the same zoom level
	        coord = coord.zoomTo(tile.coord.zoom);
	        
	        // store the infinite
	        var force:Point = new Point(0, 0);
	        
	        if(coord.column == Number.POSITIVE_INFINITY || coord.column == Number.NEGATIVE_INFINITY) {
	            force.x = coord.column;
	        } else {
	            point.x += TILE_WIDTH * (coord.column - tile.coord.column);	        
	        }
	        
	        if(coord.row == Number.POSITIVE_INFINITY || coord.row == Number.NEGATIVE_INFINITY) {
	            force.y = coord.row;
	        } else {
	            point.y += TILE_HEIGHT * (coord.row - tile.coord.row);
	        }
	        
	        if(fearBigNumbers) {
	            if(point.x < -1e6) {
	                force.x = Number.NEGATIVE_INFINITY;
	            }
	            if(point.x > 1e6) {
	                force.x = Number.POSITIVE_INFINITY;
	            }
	            if(point.y < -1e6) {
	                force.y = Number.NEGATIVE_INFINITY;
	            }
	            if(point.y > 1e6) {
	                force.y = Number.POSITIVE_INFINITY;
	            }
	        }
	        
	        point = _well.localToGlobal(point);
	        point = context.globalToLocal(point);
	
	        if(force.x) {
	            point.x = force.x;
	        }
	        if(force.y) {
	            point.y = force.y;
	        }
	        return point;
	    }
	    
	    public function pointCoordinate(point:Point, context:Sprite=null):Coordinate
	    {
	        var tile:Tile;
	        var tileCoord:Coordinate;
	        var pointCoord:Coordinate;
	        
	        if (null == context) context = this;
	        // point is assumed to be in tile grid local coordinates
	        point = context.localToGlobal(point);
	        point = _well.globalToLocal(point);
	
	        // an arbitrary reference tile, zoomed to the maximum
	        tile = activeTiles()[0];
	        tileCoord = tile.coord.zoomTo(Coordinate.MAX_ZOOM);
	        
	        // distance in tile widths from reference tile to point
	        var xTiles:Number = (point.x - tile.x) / TILE_WIDTH;
	        var yTiles:Number = (point.y - tile.y) / TILE_HEIGHT;
	
	        // distance in rows & columns at maximum zoom
	        var xDistance:Number = xTiles * Math.pow(2, (Coordinate.MAX_ZOOM - tile.coord.zoom));
	        var yDistance:Number = yTiles * Math.pow(2, (Coordinate.MAX_ZOOM - tile.coord.zoom));
	        
	        // new point coordinate reflecting that distance
	        pointCoord = new Coordinate(Math.round(tileCoord.row + yDistance),
	                                    Math.round(tileCoord.column + xDistance),
	                                    tileCoord.zoom);
	        
	        return pointCoord.zoomTo(tile.coord.zoom);
	    }
	    
	    public function topLeftCoordinate():Coordinate
	    {
	        var point:Point = new Point(0, 0);
	        return pointCoordinate(point);
	    }
	    
	    public function centerCoordinate():Coordinate
	    {
	        var point:Point = new Point(_width/2, _height/2);
	        return pointCoordinate(point);
	    }
	    
	    public function bottomRightCoordinate():Coordinate
	    {
	        var point:Point = new Point(_width, _height);
	        return pointCoordinate(point);
	    }
	    
	   /*
	    * Start dragging the well with the mouse.
	    * Calls onWellDrag().
	    */
	    protected function getWellBounds(fearBigNumbers:Boolean):Bounds
	    {
	        var min:Point, max:Point;
	
	        // "min" = furthest well position left & up,
	        // use the location of the bottom-right limit
	        min = coordinatePoint(bottomRightInLimit, this, fearBigNumbers);
	        min.x = _well.x - min.x + _width;
	        min.y = _well.y - min.y + _height;
	        
	        // "max" = furthest well position right & down,
	        // use the location of the top-left limit
	        max = coordinatePoint(topLeftOutLimit, this, fearBigNumbers);
	        max.x = _well.x - max.x;
	        max.y = _well.y - max.y;
	        
///	        trace('min/max for drag: '+min+', '+max+' ('+topLeftOutLimit+', '+bottomRightInLimit+')');
	        
	        // weird negative edge conditions, limit all movement on an axis
	        if(min.x > max.x)
	            min.x = max.x = _well.x;
	
	        if(min.y > max.y)
	            min.y = max.y = _well.y;
	            
	        return new Bounds(min, max);
	    }
	    
	   /*
	    * Start dragging the well with the mouse.
	    * Calls onWellDrag().
	    */
	    public function startWellDrag(event:MouseEvent):void
	    {
			stage.addEventListener(MouseEvent.MOUSE_UP, stopWellDrag);	    	
	    	stage.addEventListener(MouseEvent.MOUSE_OUT, stopWellDrag);

	        var bounds:Bounds = getWellBounds(true);
	        
	        // startDrag seems to hate the infinities,
	        // so we'll fudge it with some implausibly large numbers.
	        
	        var xMin:Number = (bounds.min.x == Number.POSITIVE_INFINITY)
	                            ? 100000
	                            : ((bounds.min.x == Number.NEGATIVE_INFINITY)
	                                ? -100000
	                                : bounds.min.x);
	        
	        var yMin:Number = (bounds.min.y == Number.POSITIVE_INFINITY)
	                            ? 100000
	                            : ((bounds.min.y == Number.NEGATIVE_INFINITY)
	                                ? -100000
	                                : bounds.min.y);
	        
	        var xMax:Number = (bounds.max.x == Number.POSITIVE_INFINITY)
	                            ? 100000
	                            : ((bounds.max.x == Number.NEGATIVE_INFINITY)
	                                ? -100000
	                                : bounds.max.x);
	        
	        var yMax:Number = (bounds.max.y == Number.POSITIVE_INFINITY)
	                            ? 100000
	                            : ((bounds.max.y == Number.NEGATIVE_INFINITY)
	                                ? -100000
	                                : bounds.max.y);
	                                
//	        trace('Drag bounds would be: '+xMin+', '+yMin+', '+xMax+', '+yMax);
	        
	        _startingWellPosition = new Point(_well.x, _well.y);
//	        trace('Starting well position: '+_startingWellPosition.toString());
	        
	        _map.onStartPan();
	        var rect:Rectangle = new Rectangle(xMin, yMin, xMax - xMin, yMax - yMin);
	        _well.startDrag(false, rect);
	        onWellDrag(_startingWellPosition.clone());
	    }
	    
	   /*
	    * Stop dragging the well with the mouse.
	    * Halts _wellDragTask.
	    */
	    public function stopWellDrag(event:MouseEvent):void
	    {
	    	stage.removeEventListener(MouseEvent.MOUSE_OUT, stopWellDrag);

	        _map.onStopPan();
	        if (_wellDragTask) {
                    _wellDragTask.call(); // issue final onPan, notify markers, etc.
                    _wellDragTask.cancel(); // but cancel the follow-on call
                }
	        _well.stopDrag();
	
	        if(positionTiles())
	            updateMarkers();
	
	        centerWell(true);
	    }
	    
	    public function zoomBy(amount:Number, redraw:Boolean):void
	    {
	        if(!_tiles)
	            return;
	        
	        var roundScale:Number = Math.round(_well.scaleX * 10000.0) / 10000.0;
	        if(amount > 0 && zoomLevel >= bottomRightInLimit.zoom && roundScale)
	            return;
	    
	        if(amount < 0 && zoomLevel <= topLeftOutLimit.zoom && roundScale)
	            return;
	    
	        _well.scaleX *= Math.pow(2, amount);
	        _well.scaleY *= Math.pow(2, amount);
	        
	        boundWell();
	        
	        if(redraw) {
	            normalizeWell();
	            allocateTiles();
//	            trace('New well scale: '+_well.scaleX.toString());
	        }
	    }
	    
	    public function resizeTo(bottomRight:Point):void
	    {
	        _width = bottomRight.x;
	        _height = bottomRight.y;
	
	        redraw();
	
	        if(!_tiles)
	            return;
	        
	        centerWell(false);
	        allocateTiles();
	    }
	    
	    public function panRight(pixels:Number):void
	    {
	        if(!_tiles)
	            return;
	        
	        _well.x -= pixels;
	
	        if(positionTiles())
	            updateMarkers();
	
	        centerWell(true);
	    }
	 
	    public function panLeft(pixels:Number):void
	    {
	        if(!_tiles)
	            return;
	        
	        _well.x += pixels;
	
	        if(positionTiles())
	            updateMarkers();
	
	        centerWell(true);
	    } 
	 
	    public function panUp(pixels:Number):void
	    {
	        if(!_tiles)
	            return;
	        
	        _well.y += pixels;
	
	        if(positionTiles())
	            updateMarkers();
	
	        centerWell(true);
	    }      
	    
	    public function panDown(pixels:Number):void
	    {
	        if(!_tiles)
	            return;
	        
	        _well.y -= pixels;
	
	        if(positionTiles())
	            updateMarkers();
	
	        centerWell(true);
	    }
	
	   /**
	    * Get the subset of still-active tiles.
	    */
	    protected function activeTiles():/*Tile*/Array
	    {
	    	var matches:Array = new Array();
	    	if (_tiles) {
		        matches = _tiles.filter(function(item:Tile, index:int, list:Array):Boolean { return item.isActive();} );
				if (matches.length == 0) {
					trace("no matches for active tiles... DOOM!");
				}
		    }
	        return matches;
	    }
	
	   /**
	    * Find the given tile in the tiles array.
	    */
	    protected function tileIndex(tile:Tile):Number
	    {
	        return _tiles.indexOf(tile);
	    }
	
	   /**
	    * Determine the number of tiles needed to cover the current grid,
	    * and add rows and columns if necessary. Finally, position new tiles.
	    */
	    protected function allocateTiles():void
	    {
	        if(!_tiles)
	            return;
	        
	        // internal pixel dimensions of well, compensating for scale
	        var wellWidth:Number  = _well.scaleX * _width;
	        var wellHeight:Number = _well.scaleY * _height;
	
	        var targetCols:Number = Math.ceil(wellWidth  / TILE_WIDTH)  + 1 + 2 * _tileBuffer;
	        var targetRows:Number = Math.ceil(wellHeight / TILE_HEIGHT) + 1 + 2 * _tileBuffer;
	
	        // grid can't drop below 1 x 1
	        targetCols = Math.max(1, targetCols);
	        targetRows = Math.max(1, targetRows);
	
	        // change column count to match target
	        while(_columns != targetCols) {
	            if(_columns < targetCols) {
	                pushTileColumn();
	            } else if(_columns > targetCols) {
	                popTileColumn();
	            }
	        }
	
	        // change row count to match target
	        while(_rows != targetRows) {
	            if(_rows < targetRows) {
	                pushTileRow();
	            } else if(_rows > targetRows) {
	                popTileRow();
	            }
	        }
	
	        if(positionTiles())
	            updateMarkers();
	            
	        trace("allocateTiles(): " + _tiles.length);
	    }
	    
	   /**
	    * Adjust position of the well, so it does not stray outside the provider boundaries.
	    */
	    protected function boundWell():void
	    {
	        var bounds:Bounds = getWellBounds(true);
	        
	        _well.x = Math.min(bounds.max.x, Math.max(bounds.min.x, _well.x));
	        _well.y = Math.min(bounds.max.y, Math.max(bounds.min.y, _well.y));
	    }
	    
	   /**
	    * Adjust position of the well, so it stays in the center.
	    * Optionally, compensate tile positions to prevent
	    * visual discontinuity.
	    */
	    protected function centerWell(adjustTiles:Boolean):void
	    {
	        var center:Point = new Point(_width/2, _height/2);
	        
	        var xAdjustment:Number = _well.x - center.x;
	        var yAdjustment:Number = _well.y - center.y;
	
	        _well.x -= xAdjustment;
	        _well.y -= yAdjustment;
	        
	        if(!_tiles)
	            return;
	        
	        if(adjustTiles) {
	            for (var i:int = 0; i < _tiles.length; i += 1) {
	                _tiles[i].x += xAdjustment / _well.scaleX;
	                _tiles[i].y += yAdjustment / _well.scaleX;
	            }
	        }
	    }
	    
	   /**
	    * Adjust position and scale of the well, so it stays
	    * in the center and within reason.  Compensate tile
	    * zoom and positions to prevent visual discontinuity.
	    */
	    protected function normalizeWell():void
	    {
	    	trace("normalizing well");
	        if(!_tiles) {
	        	return;
	        }
	        
	        var zoomAdjust:Number, scaleAdjust:Number;
	        var active:/*Tile*/Array;
	        
	        // just in case?
	        centerWell(true);
	
			trace("well scale: " + _well.scaleX + " " + _well.scaleY);
	        if(Math.abs(_well.scaleX - 1.0) < 0.01) {
	            active = activeTiles();
	        
	            // set to 100% if within 99% - 101%
	            trace("scaling well to 100% from " + _well.scaleX*100 + "%");
	            _well.scaleX = _well.scaleY = 1.0;
	            
	            active.sort(compareTileRowColumn);
	            
	            // lock the tiles back to round-pixel positions
	            active[0].x = Math.floor(active[0].x);
	            active[0].y = Math.floor(active[0].y);
	            
	            for(var i:int = 1; i < active.length; i += 1) {
	                active[i].x = active[0].x + (active[i].coord.column - active[0].coord.column) * TILE_WIDTH;
	                active[i].y = active[0].y + (active[i].coord.row    - active[0].coord.row)    * TILE_HEIGHT;
	            
	                //trace(active[i].toString()+' at '+active[i].x+', '+active[i].y+' vs. '+active[0].toString());
	            }
	
	        } else if(_well.scaleX <= 0.6 || _well.scaleX >= 1.65) {
	            // split or merge tiles if outside of 60% - 165%
	
	            // zoom adjust: base-2 logarithm of the scale
	            // see http://mathworld.wolfram.com/Logarithm.html (15)
	            zoomAdjust = Math.round(Math.log(_well.scaleX) / Math.log(2));
	            scaleAdjust = Math.pow(2, zoomAdjust);
	        
	            //trace('This is where we scale the whole well by '+zoomAdjust+' zoom levels: '+(100 / scaleAdjust)+'%');

				var n:int;
	            for (n  = 0; n < zoomAdjust; n += 1)
				{
	                splitTiles();
	                zoomLevel += 1;
	            }
	                
	            for (n = 0; n > zoomAdjust; n -= 1)
				{
	                mergeTiles();
	                zoomLevel -= 1;
	            }
	
	            _well.scaleX = _well.scaleX / scaleAdjust;
	            _well.scaleY = _well.scaleY / scaleAdjust;
	
	            for (var j:int = 0; j < _tiles.length; j += 1) {
	                _tiles[j].x = _tiles[j].x * scaleAdjust;
	                _tiles[j].y = _tiles[j].y * scaleAdjust;
	                _tiles[j].scaleX = _tiles[j].scaleX * scaleAdjust;
	                _tiles[j].scaleY = _tiles[j].scaleY * scaleAdjust;
	            }
	        
	            trace('Scaled to '+zoomLevel+', '+(_well.scaleX*100.0)+'%');
	            markers.indexAtZoom(zoomLevel);
	        }
	    }
	    
	   /**
	    * How many milliseconds before condemned tiles are destroyed?
	    */
	    protected function condemnationDelay():Number
	    {
	        // half a second for each tile, plus five seconds overhead
	        return (5 + .5 * _rows * _columns) * 1000;
	    }
	    
	   /**
	    * Do a 1-to-4 tile split: pick a reference tile and use it
	    * as a position for four new tiles at a higher zoom level.
	    * Expire all existing tiles, and trust that allocateTiles() and
	    * positionTiles() will take care of filling the remaining space.
	    */
	    protected function splitTiles():void
	    {
	    	trace("splitting tiles");
	        var condemnedTiles:/*Tile*/Array = [];
	        var referenceTile:Tile, newTile:Tile;
	        var xOffset:Number, yOffset:Number;
	        
	        for(var i:int = _tiles.length - 1; i >= 0; i -= 1) {
	            if(_tiles[i].isActive()) {
	                // remove old tile
	                _tiles[i].expire();
	                condemnedTiles.push(_tiles[i]);
	
	                // save for later (you only need one)
	                referenceTile = _tiles[i];
	            }
	        }
	
	        Reactor.callLater(condemnationDelay(), destroyTiles, condemnedTiles);

	        // this should never happen
	        if(!referenceTile) {
	        	trace("TileGrid problem - no reference tile");
	            return;
	        }
	    
	        // this should never happen either
	        if(!referenceTile.coord) {
	        	trace("TileGrid problem - no coord in reference tile");
	            return;
	        }
	
	        for(var q:Number = 0; q < 4; q += 1) {
	            // two-bit value into two one-bit values
	            xOffset = q & 1;
	            yOffset = (q >> 1) & 1;
	            
	            newTile = createTile(referenceTile.grid, referenceTile.coord, referenceTile.x, referenceTile.y);
	            newTile.coord = newTile.coord.zoomBy(1);
	            
	            if(xOffset)
	                newTile.coord = newTile.coord.right();
	            
	            if(yOffset)
	                newTile.coord = newTile.coord.down();
	
	            newTile.x = referenceTile.x + (xOffset * TILE_WIDTH / 2);
	            newTile.y = referenceTile.y + (yOffset * TILE_HEIGHT / 2);

	            newTile.scaleX = newTile.scaleY = referenceTile.scaleX / 2;
	            newTile.redraw();
	        }
	
	        // The remaining tiles get taken care of later
	        _rows = 2;
	        _columns = 2;
	    }
	    
	   /**
	    * Do a 4-to-1 tile merge: pick a reference tile and use it
	    * as a position for the upper-left-hand corder of one new tile
	    * at a higher zoom level. Expire all existing tiles, and trust
	    * that allocateTiles() and positionTiles() will take care of
	    * filling the remaining space.
	    */
	    protected function mergeTiles():void
	    {
	    	trace("merging tiles");
	        var condemnedTiles:/*Tile*/Array = [];
	        var referenceTile:Tile, newTile:Tile;
	    
	        _tiles.sort(compareTileRowColumn);
	
	        for(var i:int = _tiles.length - 1; i >= 0; i -= 1) {
	            if(_tiles[i].isActive()) {
	                // remove old tile
	                _tiles[i].expire();
	                condemnedTiles.push(_tiles[i]);
	
	                if(_tiles[i].coord.zoomBy(-1).isEdge()) {
	                    // save for later (you only need one)
	                    referenceTile = _tiles[i];
	                }
	            }
	        }
	
	        Reactor.callLater(condemnationDelay(), destroyTiles, condemnedTiles);
	    
	        // this should never happen
	        if(!referenceTile) {
	        	throw new Error("no reference tile in mergeTiles()");
	        }

	        // this should never happen either
	        if(!referenceTile.coord) {
	        	throw new Error("no reference tile coord in mergeTiles()");
	        }
	
	        // we are only interested in tiles that are edges for this zoom
	        newTile = createTile(referenceTile.grid, referenceTile.coord, referenceTile.x, referenceTile.y);
	        newTile.coord = newTile.coord.zoomBy(-1);
	        	
	        newTile.scaleX = newTile.scaleY = referenceTile.scaleX * 2;
	        newTile.redraw();
	
	        // The remaining tiles get taken care of later
	        _rows = 1;
	        _columns = 1;
	    }
	    
	   /**
	    * Determine if any tiles have wandered too far to the right, left,
	    * top, or bottom, and shunt them to the opposite side if needed.
	    * Return true if any tiles have been repositioned.
	    */
	    protected function positionTiles():Boolean
	    {
	        if(!_tiles)
	            return false;
	        
	        var tile:Tile;
	        var point:Point;
	        var active:/*Tile*/Array = activeTiles();
	        
	        // if any tile is moved...
	        var touched:Boolean = false;
	        
	        point = new Point(0, 0);
	        point = this.localToGlobal(point);
	        point = _well.globalToLocal(point); // all tiles are attached to well
	        
	        var xMin:Number = point.x - (1 + _tileBuffer) * TILE_WIDTH;
	        var yMin:Number = point.y - (1 + _tileBuffer) * TILE_HEIGHT;
	        
	        point = new Point(_width, _height);
	        point = this.localToGlobal(point);
	        point = _well.globalToLocal(point); // all tiles are attached to well
	        
	        var xMax:Number = point.x + (0 + _tileBuffer) * TILE_WIDTH;
	        var yMax:Number = point.y + (0 + _tileBuffer) * TILE_HEIGHT;
	        
	        for(var i:int = 0; i < active.length; i += 1) {
	        
	            tile = active[i];
	            
	            // only interested in moving active tiles
	            if(!tile.isActive())
	                break; // shouldn't happen, TODO: perhaps a case for throwing an Error?
	            
	            if(tile.y < yMin) {
	                // too far up
	                tile.panDown(_rows);
	                tile.y += _rows * TILE_HEIGHT;
	                touched = true;
	
	            } else if(tile.y > yMax) {
	                // too far down
	                if((tile.y - _rows * TILE_HEIGHT) > yMin) {
	                    // moving up wouldn't put us too far
	                    tile.panUp(_rows);
	                    tile.y -= _rows * TILE_HEIGHT;
	                    touched = true;
	                }
	            }
	            
	            if(tile.x < xMin) {
	                // too far left
	                tile.panRight(_columns);
	                tile.x += _columns * TILE_WIDTH;
	                touched = true;
	
	            } else if(tile.x > xMax) {
	                // too far right
	                if((tile.x - _columns * TILE_WIDTH) > xMin) {
	                    // moving left wouldn't put us too far
	                    tile.panLeft(_columns);
	                    tile.x -= _columns * TILE_WIDTH;
	                    touched = true;
	                }
	            }
	        }
	        
	        return touched;
	    }
	    
	    protected function updateMarkers():void
	    {
	        var visible:/*Marker*/Array = markers.overlapping(activeTiles());
	        var newOverlappingMarkers:Object = {};
	        
	        for(var i:int = 0; i < visible.length; i += 1)
	            newOverlappingMarkers[visible[i].id] = visible[i];
	
			var id:String;
	        // check for newly-visible markers
	        for (id in newOverlappingMarkers) {
	            if(newOverlappingMarkers[id] && !_overlappingMarkers[id]) {
	                _map.onMarkerEnters(id, markers.getMarker(id).location);
	                _overlappingMarkers[id] = true;
	            }
	        }
	        
	        for (id in _overlappingMarkers) {
	            if(!newOverlappingMarkers[id] && _overlappingMarkers[id]) {
	                _map.onMarkerLeaves(id, markers.getMarker(id).location);
	                delete _overlappingMarkers[id];
	            }
	        }
	    }
	    
	   /**
	    * Add a new row of tiles, adjust other rows so that visual transition is seamless.
	    */
	    protected function pushTileRow():void
	    {
	        var lastTile:Tile;
	        var active:/*Tile*/Array = activeTiles();
	        
	        active.sort(compareTileRowColumn);
	        
	        for(var i:int = active.length - _columns; i < _rows * _columns; i += 1)
	        {
	            lastTile = active[i];
	            // TODO: wondering when lastTile.grid isn't just 'this'?
	            createTile(lastTile.grid, lastTile.coord.down(), lastTile.x, lastTile.y + TILE_HEIGHT);
	        }
	        
	        _rows += 1;
	    }
	
	   /**
	    * Remove a row of tiles, adjust other rows so that visual transition is seamless.
	    */
	    protected function popTileRow():void
	    {
	        var active:/*Tile*/Array = activeTiles();
	
	        active.sort(compareTileRowColumn);
	
	        while(active.length > _columns * (_rows - 1))
	            destroyTile(Tile(active.pop()));
	                                         
	        _rows -= 1;
	    }
	
	   /**
	    * Add a new column of tiles, adjust other columns so that visual transition is seamless.
	    */
	    protected function pushTileColumn():void
	    {
	        var lastTile:Tile;
	        var active:/*Tile*/Array = activeTiles();
	        
	        active.sort(compareTileColumnRow);
	        
	        for(var i:int = active.length - _rows; i < _rows * _columns; i += 1)
	        {
	            lastTile = active[i];
	            createTile(lastTile.grid, lastTile.coord.right(), lastTile.x + TILE_WIDTH, lastTile.y);
	        }
	        
	        _columns += 1;
	    }
	
	   /**
	    * Remove a column of tiles, adjust other columns so that visual transition is seamless.
	    */
	    protected function popTileColumn():void
	    {
	        var active:/*Tile*/Array = activeTiles();
	
	        active.sort(compareTileColumnRow);
	
	        while(active.length > _rows * (_columns - 1))
	            destroyTile(Tile(active.pop()));
	
	        _columns -= 1;
	    }
	    
	   /**
	    * Comparison function for sorting tiles by distance from a point.
	    */
	    protected static function compareTileDistanceFrom(p:Point):Function
	    {
	        return function(a:Tile, b:Tile):Number
	        {
	        	// TODO: can probably nix the sqrt if we're just sorting by distance
	        	// FYI: this whole method isn't really ever used, it can probably just go away entirely
	            var aDist:Number = Math.sqrt(Math.pow(a.center().x - p.x, 2) + Math.pow(a.center().y - p.y, 2));
	            var bDist:Number = Math.sqrt(Math.pow(b.center().x - p.x, 2) + Math.pow(b.center().y - p.y, 2));
	            return aDist - bDist;
	        };
	    }
	    
	   /**
	    * Comparison function for sorting tiles by row, then column, i.e. horizontally.
	    */
	    protected static function compareTileRowColumn(a:Tile, b:Tile):Number
	    {
	        if(a.coord.row == b.coord.row) {
	            return a.coord.column - b.coord.column;
	            
	        } else {
	            return a.coord.row - b.coord.row;
	            
	        }
	    }
	    
	   /**
	    * Comparison function for sorting tiles by column, then row, i.e. vertically.
	    */
	    protected static function compareTileColumnRow(a:Tile, b:Tile):Number
	    {
	        if(a.coord.column == b.coord.column) {
	            return a.coord.row - b.coord.row;
	            
	        } else {
	            return a.coord.column - b.coord.column;
	            
	        }
	    }
	    
	    public function repaintTiles():void
	    {
	        var active:/*Tile*/Array = activeTiles();
	        
	        for(var i:int = 0; i < active.length; i += 1)
	            active[i].paint(_mapProvider, active[i].coord);
	    }
	    
	   /**
	    * Allow (true) or prevent (false) tiles to paint themselves.
	    * See Tile.redraw().
	    */
	    public function allowPainting(allow:Boolean):void
	    {
	        _paintingAllowed = allow;
	    }
	    
	   /**
	    * Can tiles paint themselves? See Tile.redraw().
	    */
	    public function paintingAllowed():Boolean
	    {
	        return _paintingAllowed;
	    }

		// set to false, and set drawGridArea to false, if you want the background swf color to show through
		public function set drawWell(draw:Boolean):void {
			_drawWell = draw;
			redrawWell();
		}
		// set to false, and set drawWell to false, if you want the background swf color to show through
		public function set drawGridArea(draw:Boolean):void {
			_drawGridArea = draw;
			redrawGridArea();
		}
	    
	    protected function redraw():void {
   		    redrawGridArea();
		    redrawMask();
		    redrawWell();
	    } 
	    
	    protected function redrawGridArea():void
	    {
	    	with (graphics)
	    	{
		        clear();
		    	if (_drawGridArea) {
			        moveTo(0, 0);
			        // lineStyle(2, 0x990099, 100);
			        beginFill(0x666666, 0.2);
			        lineTo(0, _height);
			        lineTo(_width, _height);
			        lineTo(_width, 0);
			        lineTo(0, 0);
			        endFill();
			    }
	    	}
	    }
	    
	    protected function redrawMask():void
		{
 	        with (_mask.graphics)
	        {
		        clear();
		        moveTo(0, 0);
//		        lineStyle(2, 0x990099, 100);
		        lineStyle();
		        beginFill(0x000000, 0);
		        lineTo(0, _height);
		        lineTo(_width, _height);
		        lineTo(_width, 0);
		        lineTo(0, 0);
		        endFill();
		    }
	    }

	    protected function redrawWell():void
		{
	        // note that _well (0, 0) is grid center.
	        with (_well.graphics)
	        {
	        	clear();
		        if (_drawWell) {
		            moveTo(_width/-2, _height/-2);
		            lineStyle();
		            beginFill(0x666666, 0.2);
		            lineTo(_width/-2, _height/2);
		            lineTo(_width/2, _height/2);
		            lineTo(_width/2, _height/-2);
		            lineTo(_width/-2, _height/-2);
		            endFill();
		        }
	        }
	    }
	}
}
