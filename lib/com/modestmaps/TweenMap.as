/**
 * vim:et sts=4 sw=4 cindent:
 * @ignore
 *
 * @author tom
 *
 * com.modestmaps.TweenMap adds smooth animated panning and zooming to the basic Map class
 *
 */
package com.modestmaps
{
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.core.MapExtent;
	import com.modestmaps.core.TweenTile;
	import com.modestmaps.geo.Location;
	import com.modestmaps.mapproviders.IMapProvider;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import gs.TweenLite;
	
    public class TweenMap extends Map
	{

		/** easing function used for panLeft, panRight, panUp, panDown */
		public var panEase:Function = quadraticEaseOut;
		/** time to pan using panLeft, panRight, panUp, panDown */
		public var panDuration:Number = 0.5;

		/** easing function used for zoomIn, zoomOut */
		public var zoomEase:Function = quadraticEaseOut;
		/** time to zoom using zoomIn, zoomOut */
		public var zoomDuration:Number = 0.2;

		/** time to pan and zoom using, uh, panAndZoom */
		public var panAndZoomDuration:Number = 0.3;

        /*
	    * Initialize the map: set properties, add a tile grid, draw it.
	    * Default extent covers the entire globe, (+/-85, +/-180).
	    *
	    * @param    Width of map, in pixels.
	    * @param    Height of map, in pixels.
	    * @param    Whether the map can be dragged or not.
	    * @param    Desired map provider, e.g. Blue Marble.
	    *
	    * @see com.modestmaps.core.TileGrid
	    */
	    public function TweenMap(width:Number=320, height:Number=240, draggable:Boolean=true, provider:IMapProvider=null, ... rest)
	    {
	    	super(width, height, draggable, provider, rest);
	    	grid.setTileClass(TweenTile);
        }

	   /** Pan by px and py, in panDuration (used by panLeft, panRight, panUp and panDown) */
	    override public function panBy(px:Number, py:Number):void
	    {
	    	if (!grid.panning && !grid.zooming) {
		    	grid.prepareForPanning();
	    	    TweenLite.to(grid, panDuration, { tx: grid.tx+px, ty: grid.ty+py, onComplete: grid.donePanning, ease: panEase });
	    	}
	    }      
		    
	    /** default easing function for panUp, panDown, panLeft, panRight and setCenter */
	    protected static function linearEaseOut(t:Number, b:Number, c:Number, d:Number):Number
	    {
			return c * t / d + b;
		}
		protected static function quadraticEaseOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return -c * (t /= d) * (t - 2) + b;
		}
		protected static function exponentialEaseOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return t == d ? b + c : c * (-Math.pow(2, -10 * t / d) + 1) + b;
		}
		
		/** zoom in or out by sc, moving the given location to the requested target */        
        override protected function panAndZoomBy(sc:Number, location:Location, targetPoint:Point=null, duration:Number=-1):void
        {
            if (duration < 0) duration = panAndZoomDuration;
            if (!targetPoint) targetPoint = new Point(mapWidth/2, mapHeight/2);        	
        	
			var p:Point = locationPoint(location);
			
			grid.prepareForZooming();
			grid.prepareForPanning();
			
			var m:Matrix = grid.getMatrix();
			
			m.translate(-p.x, -p.y);
			m.scale(sc, sc);
			m.translate(targetPoint.x, targetPoint.y);
			
			TweenLite.to(grid, panAndZoomDuration, { a: m.a, b: m.b, c: m.c, d: m.d, tx: m.tx, ty: m.ty, onComplete: panAndZoomComplete });
        }

		/** zoom in or out by zoomDelta, keeping the requested point in the same place */        
        override public function zoomByAbout(zoomDelta:int, targetPoint:Point=null, duration:Number=-1):void
        {
            if (duration < 0) duration = panAndZoomDuration;
            if (!targetPoint) targetPoint = new Point(mapWidth/2, mapHeight/2);        	

         	if (grid.zoomLevel + zoomDelta < grid.minZoom) {
        		zoomDelta = grid.minZoom - grid.zoomLevel;        		
        	}
        	else if (grid.zoomLevel + zoomDelta > grid.maxZoom) {
        		zoomDelta = grid.maxZoom - grid.zoomLevel; 
        	}
        	
        	// round the zoom delta up or down so that we end up at a power of 2
        	var preciseZoomDelta:Number = zoomDelta + (Math.round(grid.zoomLevel) - grid.zoomLevel)
        	
        	var sc:Number = Math.pow(2, preciseZoomDelta);
			
			grid.prepareForZooming();
			grid.prepareForPanning();
			
			var m:Matrix = grid.getMatrix();
			
			m.translate(-targetPoint.x, -targetPoint.y);
			m.scale(sc, sc);
			m.translate(targetPoint.x, targetPoint.y);
			
			TweenLite.to(grid, panAndZoomDuration, { a: m.a, b: m.b, c: m.c, d: m.d, tx: m.tx, ty: m.ty, onComplete: panAndZoomComplete }); 
        }
        
        /** EXPERIMENTAL! */
        public function tweenExtent(extent:MapExtent, duration:Number=-1):void
        {
            if (duration < 0) duration = panAndZoomDuration;

			var coord:Coordinate = locationsCoordinate([extent.northWest, extent.southEast]);

        	var sc:Number = Math.pow(2, coord.zoom-grid.zoomLevel);
			
			var p:Point = grid.coordinatePoint(coord, grid);
			
			grid.prepareForZooming();
			grid.prepareForPanning();
			
			var m:Matrix = grid.getMatrix();
			
			m.translate(-p.x, -p.y);
			m.scale(sc, sc);
			m.translate(mapWidth/2, mapHeight/2);
			
			TweenLite.to(grid, duration, { a: m.a, b: m.b, c: m.c, d: m.d, tx: m.tx, ty: m.ty, onComplete: panAndZoomComplete, ease: panEase });
        }

		/** call grid.donePanning() and grid.doneZooming(), used by tweenExtent, 
		 *  panAndZoomBy and zoomByAbout as a TweenLite onComplete function */
		protected function panAndZoomComplete():void
		{
			grid.donePanning();
			grid.doneZooming();
		}

	   /**
		 * Put the given location in the middle of the map, animated in panDuration using panEase.
		 * 
		 * Use setCenter or setCenterZoom for big jumps, set forceAnimate to true
		 * if you really want to animate to a location that's currently off screen.
		 * But no promises! 
		 * 
		 * @see com.modestmaps.TweenMap#panDuration
		 * @see com.modestmaps.TweenMap#panEase
  		 * @see com.modestmaps.TweenMap#tweenTo
  		 */
		public function panTo(location:Location, forceAnimate:Boolean=false):void
		{
			var p:Point = locationPoint(location, grid);

			if (forceAnimate || (p.x >= 0 && p.x <= mapWidth && p.y >= 0 && p.y <= mapHeight))
			{
	     		var centerPoint:Point = new Point(mapWidth / 2, mapHeight / 2);
	    		var pan:Point = centerPoint.subtract(p);

	    		// grid.prepareForPanning();
	    		TweenLite.to(grid, panDuration, {ty: grid.ty + pan.y,
	    		                                 tx: grid.tx + pan.x,
	    		                                 ease: panEase,
	    		                                 onStart: grid.prepareForPanning,
	    		                                 onComplete: grid.donePanning});
	    	}
			else
			{
				setCenter(location);
			}
		}

	   /**
		 * Animate to put the given location in the middle of the map.
		 * Use setCenter or setCenterZoom for big jumps, or panTo for pre-defined animation.
		 * 
		 * @see com.modestmaps.Map#panTo
		 */
		public function tweenTo(location:Location, duration:Number, easing:Function=null):void
		{
    		var pan:Point = new Point(mapWidth/2, mapHeight/2).subtract(locationPoint(location,grid));
    		// grid.prepareForPanning();
    		TweenLite.to(grid, duration, { ty: grid.ty + pan.y,
    		                               tx: grid.tx + pan.x,
    		                               ease: easing,
    		                               onStart: grid.prepareForPanning,
    		                               onComplete: grid.donePanning });
		}
		
	    // keeping it DRY, as they say    
	  	// dir should be 1, for in, or -1, for out
	    override protected function zoomBy(dir:int):void
	    {
	    	if (!grid.panning)
	    	{
		    	var target:Number = (dir < 0) ? Math.floor(grid.zoomLevel + dir) : Math.ceil(grid.zoomLevel + dir);
		    	target = Math.max(grid.minZoom, Math.min(grid.maxZoom, target));

		    	TweenLite.to(grid, zoomDuration, { zoomLevel: target,
		    	                                   onStart: grid.prepareForZooming,
		    	                                   onComplete: grid.doneZooming,
		    	                                   ease: zoomEase });
		    }
	    }

	}
}

