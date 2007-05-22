/**
 * vim:et sts=4 sw=4 cindent:
 * @ignore
 *
 * @author migurski
 * @author darren
 *
 * com.modestmaps.Map is the base class and interface for Modest Maps.
 *
 * @description Map is the base class and interface for Modest Maps.
 * 				Correctly attaching an instance of this Sprite subclass 
 * 				should result in a pannable map. Controls and event 
 * 				handlers must be added separately.
 *
 * @usage <code>
 *          import com.modestmaps.Map;
 *          import com.modestmaps.geo.Location;
 *          import com.modestmaps.mapproviders.BlueMarbleMapProvider;
 *          import com.stamen.twisted.Reactor;
 *          ...
 *          Reactor.run(clip, null, 50);
 *          var map:Map = Map(clip.attachMovie(Map.symbolName, 'map', clip.getNextHighestDepth()));
 *          map.init(640, 480, true, new BlueMarbleMapProvider());
 *        </code>
 */
package com.modestmaps
{
	import com.modestmaps.core.*;
	import com.modestmaps.events.MapEvent;
	import com.modestmaps.events.MarkerEvent;
	import com.modestmaps.geo.Location;
	import com.modestmaps.mapproviders.IMapProvider;
	import com.stamen.twisted.DelayedCall;
	import com.stamen.twisted.Reactor;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.events.Event;
	
	public class Map extends Sprite
	{
		public static const PAN:String = 'pan';
		public static const ZOOM:String = 'zoom';

	    protected var __width:Number = 320;
	    protected var __height:Number = 240;
	    protected var __draggable:Boolean = true;
	    
	    // pending animation steps, array of {type:'pan'/'zoom', amount:Point/Number, redraw:Boolean}
	    protected var __animSteps:Array;
	
	    // associated animation call
	    protected var __animTask:DelayedCall;
	
	    // frames-per-2x-zoom
	    public var zoomFrames:Number = 6;
	    
	    // frames-per-full-pan
	    public var panFrames:Number = 12;
	    
	    protected var __startingPosition:Point;
	    protected var __currentPosition:Point;
	    protected var __startingZoom:Number;
	    protected var __currentZoom:Number;
	
	    // das grid
	    public var grid:TileGrid;
	
	    // Who do we get our Map graphics from?
	    protected var __mapProvider:IMapProvider;
	
		/** htmlText to be added to a label - listen for MapEvent.COPYRIGHT_CHANGED */
		public var copyright:String = "";
	
	   /*
	    * Initialize the map: set properties, add a tile grid, draw it.
	    * This method must be called before the map can be used!
	    * Default extent covers the entire globe, (+/-85, +/-180).
	    *
	    * @param    Width of map, in pixels.
	    * @param    Height of map, in pixels.
	    * @param    Whether the map can be dragged or not.
	    * @param    Desired map provider, e.g. Blue Marble.
	    *
	    * @see com.modestmaps.core.TileGrid
	    */
	    public function init(width:Number, height:Number, draggable:Boolean, provider:IMapProvider):void
	    {
	    	if (!Reactor.running())
	    	{
	    		// should this really be fatal?
	    		trace('com.modestmaps.Map.init(): com.stamen.Twisted.Reactor ought to be running at this point.');
	    		Reactor.run(this, 100);
	    	}

			try {
		        ExternalInterface.addCallback("setCopyright", setCopyright);
		 	}
		 	catch (error:Error) {
		 		trace("problem adding setCopyright as callback in Map.as");
		 		trace(error.getStackTrace());
		 	}
		 

	        __animSteps = new Array();

	        setSize(width, height);

			grid = new TileGrid();
	        addChild(grid); // before init, so init can add mouse handlers to stage
	        grid.init(__width, __height, draggable, provider, this);

	        setMapProvider(provider);

			var extent:MapExtent = new MapExtent(85, -85, 180, -180);
	        setExtent(extent);
	        
	    }
	
	   /*
	    * Based on an array of locations, determine appropriate map
	    * bounds using calculateMapExtent(), and inform the grid of
	    * tile coordinate and point by calling grid.resetTiles().
	    * Resulting map extent will ensure that all passed locations
	    * are visible.
	    *
	    * @param    Array of locations.
	    *
	    * @see com.modestmaps.Map#calculateMapExtent
	    * @see com.modestmaps.core.TileGrid#resetTiles
	    */
	    public function setExtent(extent:MapExtent):void
	    {
	        var position:MapPosition = extentPosition(extent);
	        // tell grid what the rock is cooking
	        grid.resetTiles(position.coord, position.point);
	        onExtentChanged(this.getExtent());
            Reactor.callNextFrame(callCopyright);
	    }
	    
	   /*
	    * Based on a location and zoom level, determine appropriate initial
	    * tile coordinate and point using calculateMapCenter(), and inform
	    * the grid of tile coordinate and point by calling grid.resetTiles().
	    *
	    * @param    Location of center.
	    * @param    Desired zoom level.
	    *
	    * @see com.modestmaps.Map#calculateMapExtent
	    * @see com.modestmaps.core.TileGrid#resetTiles
	    */
	    public function setCenterZoom(location:Location, zoom:Number):void
	    {
	        var center:MapPosition = coordinatePosition(__mapProvider.locationCoordinate(location).zoomTo(zoom));
	        // tell grid what the rock is cooking
	        grid.resetTiles(center.coord, center.point);
	        onExtentChanged(this.getExtent());
	        Reactor.callNextFrame(callCopyright);
	    }
	   
            /*
             * Based on a zoom level, determine appropriate initial
             * tile coordinate and point using calculateMapCenter(), and inform
             * the grid of tile coordinate and point by calling grid.resetTiles().
             *
             * @param    Desired zoom level.
             *
             * @see com.modestmaps.Map#calculateMapExtent
             * @see com.modestmaps.core.TileGrid#resetTiles
             */
            public function setZoom(zoom:Number):void
            {
               if (zoom == grid.zoomLevel) { // do nothing!
                  return;
               }
               else if (zoom - grid.zoomLevel == 1) { // if 1 step in, delegate to zoomIn animation
                  zoomIn();
               }
               else if (zoom - grid.zoomLevel == -1) {  // if 1 step out, delegate to zoomOut animation
                  zoomOut();
               }
               else { // else hard reset
                  var center:MapPosition = coordinatePosition(grid.centerCoordinate().zoomTo(zoom));
                  // tell grid what the rock is cooking
                  grid.resetTiles(center.coord, center.point);
                  onExtentChanged(this.getExtent());
                  Reactor.callNextFrame(callCopyright);
               }
            }
                
	   /*
	    * Based on a coordinate, determine appropriate starting tile and position,
	    * and return a two-element object with a coord and a point.
	    */
	    protected function coordinatePosition(centerCoord:Coordinate):MapPosition
	    {
	        // initial tile coordinate
	        var initTileCoord:Coordinate = new Coordinate( Math.floor(centerCoord.row),
                                                               Math.floor(centerCoord.column),
							       Math.floor(centerCoord.zoom));
	
	        // initial tile position, assuming centered tile well in grid
	        var initX:Number = (initTileCoord.column - centerCoord.column) * TileGrid.TILE_WIDTH;
	        var initY:Number = (initTileCoord.row - centerCoord.row) * TileGrid.TILE_HEIGHT;
	        var initPoint:Point = new Point(Math.round(initX), Math.round(initY));
	        
	        return new MapPosition(initTileCoord, initPoint);
	    }


		public function locationsPosition(locations:Array):MapPosition
		{
	        // my kingdom for a decent map() function in AS2
	        var coordinates:Array = new Array();
	        
	        for(var i:Number = 0; i < locations.length; i += 1)
	            coordinates.unshift(__mapProvider.locationCoordinate(locations[i]));
	    
	        // get outermost top left and bottom right coordinates to cover all locations
	        var TL:Coordinate = new Coordinate(coordinates[0].row, coordinates[0].column, coordinates[0].zoom);
	        var BR:Coordinate = new Coordinate(coordinates[0].row, coordinates[0].column, coordinates[0].zoom);
	        
	        while (coordinates.length)
			{
	            TL = new Coordinate(Math.min(TL.row, coordinates[0].row),
									Math.min(TL.column, coordinates[0].column),
									Math.min(TL.zoom, coordinates[0].zoom));
	            BR = new Coordinate(Math.max(BR.row, coordinates[0].row),
									Math.max(BR.column, coordinates[0].column),
									Math.max(BR.zoom, coordinates[0].zoom));
	            coordinates.shift();
	        }
	
	        // multiplication factor between horizontal span and map width
	        var hFactor:Number = (BR.column - TL.column) / (__width / TileGrid.TILE_WIDTH);
	        
	        // multiplication factor expressed as base-2 logarithm, for zoom difference
	        var hZoomDiff:Number = Math.log(hFactor) / Math.log(2);
	        
	        // possible horizontal zoom to fit geographical extent in map width
	        var hPossibleZoom:Number = TL.zoom - Math.ceil(hZoomDiff);
	        
	        // multiplication factor between vertical span and map height
	        var vFactor:Number = (BR.row - TL.row) / (__height / TileGrid.TILE_HEIGHT);
	        
	        // multiplication factor expressed as base-2 logarithm, for zoom difference
	        var vZoomDiff:Number = Math.log(vFactor) / Math.log(2);
	        
	        // possible vertical zoom to fit geographical extent in map height
	        var vPossibleZoom:Number = TL.zoom - Math.ceil(vZoomDiff);
	        
	        // initial zoom to fit extent vertically and horizontally
	        // additionally, make sure it's not outside the boundaries set by provider limits
	        var initZoom:Number = Math.min(hPossibleZoom, vPossibleZoom);
	        initZoom = Math.min(initZoom, __mapProvider.outerLimits()[1].zoom);
	        initZoom = Math.max(initZoom, __mapProvider.outerLimits()[0].zoom);
	
	        // coordinate of extent center
	        var centerRow:Number = (TL.row + BR.row) / 2;
	        var centerColumn:Number = (TL.column + BR.column) / 2;
	        var centerZoom:Number = (TL.zoom + BR.zoom) / 2;
	        var centerCoord:Coordinate = (new Coordinate(centerRow, centerColumn, centerZoom)).zoomTo(initZoom);
	        
	        return coordinatePosition(centerCoord);
		}

	   /*
	    * Based on an array of locations, determine appropriate map bounds
	    * in terms of tile grid, and return a two-element object with a coord
	    * and a point from calculateMapCenter().
	    */
	    protected function extentPosition(extent:MapExtent):MapPosition
	    {
//	    	trace("calculateMapCenterFromExtent" + extent);
//	    	trace(new Error().getStackTrace());
	    	var locations:Array = new Array(extent.northWest, extent.southEast);
	    	return locationsPosition(locations);
	    }

	   /*
	    * Return a MapExtent for the current map view.
	    * TODO: MapExtent needs adapting to deal with non-rectangular map projections
	    *
	    * @return   MapExtent object
	    */
	    public function getExtent():MapExtent
	    {
	        var extent:MapExtent = new MapExtent();
	        
	        if(!__mapProvider)
	            return extent;
	
	        var TL:Coordinate = grid.topLeftCoordinate();
	        var BR:Coordinate = grid.bottomRightCoordinate();
	
	        extent.northWest = __mapProvider.coordinateLocation(TL);
	        extent.southEast = __mapProvider.coordinateLocation(BR);
	        return extent;
	    }
	
	   /*
	    * Return the current center location and zoom of the map.
	    *
	    * @return   Array of center and zoom: [center location, zoom number].
	    */
	    public function getCenterZoom():Array
	    {
	        return [__mapProvider.coordinateLocation(grid.centerCoordinate()), grid.zoomLevel];
	    }

	   /*
	    * Return the current center location of the map.
	    *
	    * @return center Location
	    */
	    public function getCenter():Location
	    {
	        return __mapProvider.coordinateLocation(grid.centerCoordinate());
	    }

	   /*
	    * Return the current zoom level of the map.
	    *
	    * @return   zoom number
	    */
	    public function getZoom():int
	    {
	        return grid.zoomLevel;
	    }

	
	   /**
	    * Set new map size, call onResized().
	    *
	    * @param    New map width.
	    * @param    New map height.
	    *
	    * @see com.modestmaps.Map#onResized
	    */
	    public function setSize(width:Number, height:Number):void
	    {
	        __width = width;
	        __height = height;
	        if (grid)
	        {
	        	grid.resizeTo(new Point(__width, __height));
	        }
	        onResized();
	    }
	
	   /**
	    * Get map size.
	    *
	    * @return   Array of [width, height].
	    */
	    public function getSize():/*Number*/Array
	    {
	        var size:/*Number*/Array = [__width, __height];
	        return size;
	    }

	   /** Get map width. */
	    public function getWidth():Number
	    {
	        return __width;
	    }

	   /** Get map height. */
	    public function getHeight():Number
	    {
	        return __height;
	    }
	
	   /**
	    * Get a reference to the current map provider.
	    *
	    * @return   Map provider.
	    *
	    * @see com.modestmaps.mapproviders.IMapProvider
	    */
	    public function getMapProvider():IMapProvider
	    {
	        return __mapProvider;
	    }
	
	   /**
	    * Set a new map provider, repainting tiles and changing bounding box if necessary.
	    *
	    * @param   Map provider.
	    *
	    * @see com.modestmaps.mapproviders.IMapProvider
	    */
	    public function setMapProvider(newProvider:IMapProvider):void
	    {
	        var previousGeometry:String;
	        if (__mapProvider)
	        {
	        	previousGeometry = __mapProvider.geometry();
	        }
	    	var extent:MapExtent = getExtent();

	        __mapProvider = newProvider;
	        if (grid)
	        {
	        	grid.setMapProvider(__mapProvider);
	        }
	        
	        if (__mapProvider.geometry() == previousGeometry)
			{
				if (grid)
		        	grid.repaintTiles();	
	        }
			else
			{
	        	setExtent(extent);
	        }
	        
	        Reactor.callLater(1000,callCopyright);
	    }
	    
	   /**
	    * Get a point (x, y) for a location (lat, lon) in the context of a given clip.
	    *
	    * @param    Location to match.
	    * @param    Movie clip context in which returned point should make sense.
	    *
	    * @return   Matching point.
	    */
	    public function locationPoint(location:Location, context:Sprite):Point
	    {
	        var coord:Coordinate = __mapProvider.locationCoordinate(location);
	        return grid.coordinatePoint(coord, context);
	    }
	    
	   /**
	    * Get a location (lat, lon) for a point (x, y) in the context of a given clip.
	    *
	    * @param    Point to match.
	    * @param    Movie clip context in which passed point should make sense.
	    *
	    * @return   Matching location.
	    */
	    public function pointLocation(point:Point, context:Sprite):Location
	    {
	        var coord:Coordinate = grid.pointCoordinate(point, context);
	        return __mapProvider.coordinateLocation(coord);
	    }
	    
	   /**
	    * Pan up by 2/3 of the map height.
	    * @see com.modestmaps.Map#panMap
	    */
	    public function panUp(event:Event=null):void
	    {
	        var distance:Number = -2 * __height / 3;
	        panMap(new Point(0, Math.round(distance/panFrames)));
	    }      
	
	   /**
	    * Pan down by 2/3 of the map height.
	    * @see com.modestmaps.Map#panMap
	    */
	    public function panDown(event:Event=null):void
	    {
	        var distance:Number = 2 * __height / 3;
	        panMap(new Point(0, Math.round(distance/panFrames)));
	    }
	    
	   /**
	    * Pan to the left by 2/3 of the map width.
	    * @see com.modestmaps.Map#panMap
	    */
	    public function panLeft(event:Event=null):void
	    {
	        var distance:Number = -2*__width / 3;
	        panMap(new Point(Math.round(distance/panFrames), 0));
	    }      
	
	   /**
	    * Pan to the right by 2/3 of the map width.
	    * @see com.modestmaps.Map#panMap
	    */
	    public function panRight(event:Event=null):void
	    {
	        var distance:Number = 2*__width / 3;
	        panMap(new Point(Math.round(distance/panFrames), 0));
	    }
	    
	    protected function panMap(perFrame:Point):void
	    {
	        for (var i:uint = 1; i <= panFrames; i += 1)
	        {
	            __animSteps.push( new PanAnimationStep(PAN, perFrame));
	        }
	            
	        if (!__animTask)
			{
	            __startingPosition = new Point(grid.x, grid.y);
	            __currentPosition = new Point(grid.x, grid.y);
	            onStartPan();
	            animationProcess();
	        }
	    }
	    
	   /**
	    * Zoom in by 200% over the course of several frames.
	    * @see com.modestmaps.Map#zoomFrames
	    */
	    public function zoomIn(event:Event=null):void
	    {
	    	zoom(1);
	    }

	   /**
	    * Zoom out by 50% over the course of several frames.
	    * @see com.modestmaps.Map#zoomFrames
	    */
	    public function zoomOut(event:Event=null):void
	    {
	    	zoom(-1);
	    }
	    	
	    // keeping it DRY, as they say    
	  	// dir should be 1, for in, or -1, for out
	    private function zoom(dir:int):void
	    {
	    	for(var i:uint = 1; i <= zoomFrames; i += 1)
	        {
	            __animSteps.push(new ZoomAnimationStep(ZOOM, dir/zoomFrames, i == zoomFrames));
	        }
	        if(!__animTask) {
	            __startingZoom = grid.zoomLevel;
	            __currentZoom = grid.zoomLevel;
	            onStartZoom();
	            animationProcess();
	        }	    	
	    }
	    
	    // TODO:
	    // animation steps should probably have an 'apply' method that does the work
	    // rather than check for changes in animation step type, 
	    // perhaps chain animation steps together (linked list maybe) 
	    // and call a 'finish' method to trigger the appropriate event
	    // (and a 'start' event for the first element in a list)
	    protected function animationProcess(lastType:String=null):void
	    {
	    	trace("animationProcess('" + lastType + "')");
	    	
	        if (__animSteps.length)
			{
	            var step:AnimationStep = __animSteps.shift();
	            if (step.type == PAN)
				{
	                //grid.allowPainting(__animSteps.length <= 1);
	                var pan:PanAnimationStep = step as PanAnimationStep;
	                grid.panRight(pan.amount.x);
	                grid.panDown(pan.amount.y);
	    
	                __currentPosition.x -= pan.amount.x; // panning right actually moves the map left
	                __currentPosition.y -= pan.amount.y; // panning up actually moves the map down
	                onPanned(new Point(__currentPosition.x-__startingPosition.x, __currentPosition.y-__startingPosition.y));
	            }
				else if (step.type == ZOOM)
				{
					var zoom:ZoomAnimationStep = step as ZoomAnimationStep;
	                grid.allowPainting(__animSteps.length <= 1);
	                grid.zoomBy(zoom.amount, zoom.redraw);
	    
	                __currentZoom += zoom.amount;
	                onZoomed(__currentZoom - __startingZoom);
	            }

	            __animTask = Reactor.callNextFrame(animationProcess, step.type);
	            
	            if (lastType == PAN && step.type == ZOOM)
	            {
	                onStopPan();
	                onStartZoom();
	            }
	            else if (lastType == ZOOM && step.type == PAN)
	            {
	                onStopZoom();
	                onStartPan();
	            }
	        }
			else
			{
	            grid.allowPainting(true);
	            __animTask = null;
	
	            if (lastType == PAN)
	            {
	                onStopPan();
	            }
	            else if (lastType == ZOOM)
	            {
	                onStopZoom();
	            }
	        }
	    }
	
	   /**
	    * Add a marker with the given id and location (lat, lon).
	    *
	    * @param    ID of marker, opaque string.
	    * @param    Location of marker.
	    */
	    public function putMarker(id:String, location:Location):void
	    {
	        //trace('Marker '+id+': '+location.toString());
	        grid.putMarker(id, __mapProvider.locationCoordinate(location), location);
	    }
	
	   /**
	    * Remove a marker with the given id.
	    *
	    * @param    ID of marker, opaque string.
	    */
	    public function removeMarker(id:String):void
	    {
	        grid.removeMarker(id);
	    }
	    
	   /**
 	    * Call javascript:modestMaps.copyright() with details about current view.
 	    * See js/copyright.js.
 	    */
 	    private function callCopyright():void
 	    {
 	        var cenP:Point = new Point(__width/2, __height/2);
 	        var minP:Point = new Point(__width/5, __height/5);
 	        var maxP:Point = new Point(__width*4/5, __height*4/5);
 	       
 	        var cenC:Coordinate = grid.pointCoordinate(cenP, this);
 	        var minC:Coordinate = grid.pointCoordinate(minP, this);
 	        var maxC:Coordinate = grid.pointCoordinate(maxP, this);
 	       
 	        var cenL:Location = __mapProvider.coordinateLocation(__mapProvider.sourceCoordinate(cenC));
 	        var minL:Location = __mapProvider.coordinateLocation(__mapProvider.sourceCoordinate(minC));
 	        var maxL:Location = __mapProvider.coordinateLocation(__mapProvider.sourceCoordinate(maxC));
 	   
 	        var minLat:Number = Math.min(minL.lat, maxL.lat);
 	        var minLon:Number = Math.min(minL.lon, maxL.lon);
 	        var maxLat:Number = Math.max(minL.lat, maxL.lat);
 	        var maxLon:Number = Math.max(minL.lon, maxL.lon);
 	       
 	       	try {
 	    	    ExternalInterface.call("modestMaps.copyright", __mapProvider.toString(), cenL.lat, cenL.lon, minLat, minLon, maxLat, maxLon, grid.zoomLevel);
 	    	}
 	    	catch (error:Error) {
 	    		trace("problem setting copyright in Map.as");
 	    		trace(error.getStackTrace());	
 	    	}
 	    }
	    
	   /**  this function gets exposed to javascript as a callback, to use it
	    *   include copyright.js and override the modestMaps.copyright function to call
	    *   swfname.setCopyright("&copy blah blah")
	    * 
	    *   e.g. in the head of your html page, where your SWF is embedded with the name MyMap
	    * 
	    *   <script type="text/javascript" src="copyright.js">
	    *   <script type="text/javascript">
	    *     modestMaps.copyrightCallback = function(holdersHTML) {
        *       MyMap.setCopyright(holdersHTML);
        *     }
        *   </script>
        * 
        *   to display the copyright string in your flash piece, you then need to listen for 
        *   the COPYRIGHT_CHANGED MapEvent
	    */
	    public function setCopyright(copyright:String):void {
	    	this.copyright = copyright;
	    	this.copyright = this.copyright.replace(/&copy;/g,"©");
	    	var event:MapEvent = new MapEvent(MapEvent.COPYRIGHT_CHANGED);
	    	event.newCopyright = this.copyright;
	    	dispatchEvent(event);
	    }
	    
	   /**
	    * Dispatches MapEvent.MARKER_ENTERS when a given marker enters the tile coverage area.
	    * Event object includes id:String and location:Location.
	    *
	    * @param    ID of marker.
	    * @param    Location of marker.
	    *
	    * @see com.modestmaps.Map#MapEvent.MARKER_ENTERS
	    */
	    public function onMarkerEnters(id:String, location:Location):void
	    {
	    	trace('+ ' + id);
	        dispatchEvent(new MarkerEvent(MarkerEvent.ENTER, id, location));
	    }
	    
	   /**
	    * Dispatches MapEvent.MARKER_LEAVES when a given marker leaves the tile coverage area.
	    * Event object includes id:String and location:Location.
	    *
	    * @param    ID of marker.
	    * @param    Location of marker.
	    *
	    * @see com.modestmaps.Map#MapEvent.MARKER_LEAVES
	    */
	    public function onMarkerLeaves(id:String, location:Location):void
	    {
	    	trace('- ' + id);
	        dispatchEvent(new MarkerEvent(MarkerEvent.LEAVE, id, location));
	    }
	    
	   /**
	    * Dispatches MapEvent.START_ZOOMING when the map starts zooming.
	    * Event object includes level:Number.
	    *
	    * @see com.modestmaps.Map#MapEvent.START_ZOOMING
	    */
	    public function onStartZoom():void
	    {
	        trace('Leaving zoom level '+grid.zoomLevel+'...');
	        var event:MapEvent = new MapEvent(MapEvent.START_ZOOMING);
	        event.zoomLevel = grid.zoomLevel;
	        dispatchEvent(event);
	    }
	    
	   /**
	    * Dispatches MapEvent.STOP_ZOOMING when the map stops zooming.
	    * Callback arguments includes level:Number.
	    *
	    * @see com.modestmaps.Map#MapEvent.STOP_ZOOMING
	    */
	    public function onStopZoom():void
	    {
	        trace('...Entering zoom level '+grid.zoomLevel);
	        var event:MapEvent = new MapEvent(MapEvent.STOP_ZOOMING);
	        event.zoomLevel = grid.zoomLevel;
	        dispatchEvent(event);
			Reactor.callNextFrame(callCopyright);	        
	    }
	    
	   /**
	    * Dispatches MapEvent.ZOOMED_BY when the map is zooomed.
	    * Callback arguments includes delta:Number, difference in levels from zoom start.
	    *
	    * @param    Change in level since beginning of zoom.
	    *
	    * @see com.modestmaps.events.MapEvent.ZOOMED_BY
	    */
	    public function onZoomed(delta:Number):void
	    {
	        trace('Current well offset from start: ' + delta.toString());
	        var event:MapEvent = new MapEvent(MapEvent.ZOOMED_BY);
	        event.zoomDelta = delta;
	        dispatchEvent(event);
	    }
	    
	   /**
	    * Dispatches MapEvent.START_PANNING when the map starts to be panned.
	    *
	    * @see com.modestmaps.Map#MapEvent.START_PANNING
	    */
	    public function onStartPan():void
	    {
	        trace('Starting pan...');
	        dispatchEvent(new MapEvent(MapEvent.START_PANNING));
	    }
	    
	   /**
	    * Dispatches MapEvent.STOP_PANNING when the map stops being panned.
	    *
	    * @see com.modestmaps.Map#MapEvent.STOP_PANNING
	    */
	    public function onStopPan():void
	    {
	    	trace('Stopping pan...');
	        dispatchEvent(new MapEvent(MapEvent.STOP_PANNING));
            Reactor.callNextFrame(callCopyright);	        
	    }
	    
	   /**
	    * Dispatches MapEvent.PANNED when the map is panned.
	    * Callback arguments includes delta:Point, difference in pixels from pan start.
	    *
	    * @param    Change in position since beginning of pan.
	    *
	    * @see com.modestmaps.events.MapEvent.PANNED
	    */
	    public function onPanned(delta:Point):void
	    {
	    	var event:MapEvent = new MapEvent(MapEvent.PANNED);
	    	event.panDelta = delta;
	        dispatchEvent(event);
	    }
	    
	   /**
	    * Dispatches MapEvent.RESIZED when the map is resized.
	    * The MapEvent includes the newSize.
	    *
	    * @see com.modestmaps.events.MapEvent.RESIZED
	    */
	    public function onResized():void
	    {
	    	var event:MapEvent = new MapEvent(MapEvent.RESIZED);
	    	event.newSize = this.getSize();
	        dispatchEvent(event);
	    }
	    
	   /**
	    * Dispatches MapEvent.EXTENT_CHANGED when the map is resized.
	    * The MapEvent includes the newExtent.
	    *
	    * @see com.modestmaps.events.MapEvent.EXTENT_CHANGED
	    */
	    public function onExtentChanged(extent:MapExtent):void
	    {
	    	var event:MapEvent = new MapEvent(MapEvent.EXTENT_CHANGED);
	    	event.newExtent = extent;
	        dispatchEvent(event);
	    }

	}
}


import flash.geom.Point;
	

class AnimationStep extends Object
{
	public var type:String;
	public var redraw:Boolean;
	
	public function AnimationStep(type:String, redraw:Boolean)
	{
		this.type = type;
		this.redraw = redraw;
	}
}

class PanAnimationStep extends AnimationStep
{
	public var amount:Point;

	public function PanAnimationStep(type:String, amount:Point, redraw:Boolean=false)
	{
		super(type, redraw);
		this.amount = amount;
	}
}

class ZoomAnimationStep extends AnimationStep
{
	public var amount:Number;

	public function ZoomAnimationStep(type:String, amount:Number, redraw:Boolean=false)
	{
		super(type, redraw);
		this.amount = amount;
	}
}
