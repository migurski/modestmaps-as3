/**
 *  Poly line renderer for Modest Maps
 * 
 *  @author simonoliver
 */

package com.modestmaps.extras {

	import com.modestmaps.Map;
	import com.modestmaps.events.MapEvent;
	import com.modestmaps.events.MarkerEvent;
	import com.modestmaps.geo.Location;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	

	public class PolyLinesClip extends Sprite
	{
		
	    protected var map:Map;
	    private var starting:Point;
	    
	    protected var polyLines:Array = []; // all markers
	    private var polylinesByName:Object = {};

        // enable this if you want intermediate zooming steps to
        // stretch your graphics instead of reprojecting the points
        // it looks worse and probably isn't faster, but there it is :)
        public var scaleZoom:Boolean = false;
	
	    public function PolyLinesClip(map:Map)
	    {
	    	this.map = map;
	    	this.x = map.getWidth() / 2;
	    	this.y = map.getHeight() / 2;
	       
	        map.addEventListener(MapEvent.START_ZOOMING, onMapStartZooming);
	        map.addEventListener(MapEvent.STOP_ZOOMING, onMapStopZooming);
	        map.addEventListener(MapEvent.ZOOMED_BY, onMapZoomedBy);
	        map.addEventListener(MapEvent.START_PANNING, onMapStartPanning);
	        map.addEventListener(MapEvent.STOP_PANNING, onMapStopPanning);
	        map.addEventListener(MapEvent.PANNED, onMapPanned);
	        map.addEventListener(MapEvent.RESIZED, onMapResized);
	        map.addEventListener(MapEvent.EXTENT_CHANGED, updatePolyLines);
	    }
	    
	    public function addPolyLine(polyLine:PolyLine):void
	    {
	        
	        polylinesByName[polyLine.id] = polyLine;	       
	        polyLines.push(polyLine);	      
	    }
	    
	    public function getPolyLine(id:String):PolyLine
	    {
	    	
	        return polylinesByName[id] as PolyLine;
	    }
	    
	    public function removePolyLine(id:String):void
	    {	        
	    	var polyLine:PolyLine = getPolyLine(id);
	    	if (polyLine) {
	    		
    	    	
    	    	var index:int = polyLines.indexOf(polyLine);
    	    	if (index >= 0) {
    	    		polyLines.splice(index,1);
    	    	}
    	    	
    	    	delete polylinesByName[polyLine.id];
    	    }    	  
	    }
	        
	    /**
	    * Redraw each active polyLine
	    */ 
	    public function updatePolyLines(event:Event=null):void
	    {	    	
	        this.graphics.clear();	        	       
	    	for each (var polyLine:PolyLine in polyLines) {	    	   
	            updatePolyLine(polyLine);        	       
	    	}	    	
	    }
	    /**
	    * Update an individual polyLine - determine its visibility and draw if so
	    */
	    public function updatePolyLine(polyLine:PolyLine):void
	    {
	    	var w:Number = map.getWidth() * 2;
	        var h:Number = map.getHeight() * 2;
	        	       	        
	        var localPointsArray:Array=new Array();	    
	        var i:uint=0;
	        
	        this.graphics.lineStyle(polyLine.lineThickness,polyLine.lineColor,polyLine.lineAlpha,polyLine.pixelHinting,polyLine.scaleMode,polyLine.caps,polyLine.joints,polyLine.miterLimit);
	        	        
	        var boundaryWindow:Rectangle=new Rectangle(-w/2,-h/2,w,h);
	        
	        // Calculate local coordinates for each point
	        for (i=0;i<polyLine.locationsArray.length;i++)
	        {	        	
	        	var tLocation:Location=polyLine.locationsArray[i];
	        	var point:Point = map.locationPoint(tLocation, this);
	        	localPointsArray.push(point);	
	        }
	        
	        for (i=1;i<polyLine.locationsArray.length;i++)
	        {
	        	// Create duplicates of each point for clipping
	        	var tPoint1:Point=new Point(localPointsArray[i-1].x,localPointsArray[i-1].y);
	        	var tPoint2:Point=new Point(localPointsArray[i].x,localPointsArray[i].y);
	        	
	        	// Clip each point and draw if visible
	        	if (clipLineToRect(tPoint1,tPoint2,boundaryWindow))
	        	{
	        		this.graphics.moveTo(tPoint1.x,tPoint1.y);
	        		this.graphics.lineTo(tPoint2.x,tPoint2.y);
	        	}
	        }
	    }
	    
	    /**
	    * Test for a line intersection. TODO - tidy up as no need to calc line equation twice
	    */
		private function lineIntersectLine( v1:Point, v2:Point, v3:Point, v4:Point ):Boolean
		{
		    var denom:Number = ((v4.y - v3.y) * (v2.x - v1.x)) - ((v4.x - v3.x) * (v2.y - v1.y));
		    var numerator:Number = ((v4.x - v3.x) * (v1.y - v3.y)) - ((v4.y - v3.y) * (v1.x - v3.x));		
		    var numerator2:Number = ((v2.x - v1.x) * (v1.y - v3.y)) - ((v2.y - v1.y) * (v1.x - v3.x));		
		    if ( denom == 0.0 )
		    {
		        if ( numerator == 0.0 && numerator2 == 0.0 ) return false;//COINCIDENT;		     
		        return false;// PARALLEL;
		    }
		    var ua:Number = numerator / denom;
		    var ub:Number = numerator2/ denom;		
		    return (ua >= 0.0 && ua <= 1.0 && ub >= 0.0 && ub <= 1.0);
		}
		
		
		/**
		 * Clips a line (passed as 2 points) to a rectangle. Returns true if the line is at all visible, false if not
		 */
		private function clipLineToRect( v1:Point, v2:Point, r:Rectangle ):Boolean
		{
		        var lowerLeft:Point=new Point( r.x, r.y+r.height );
		        var upperRight:Point=new Point( r.x+r.width, r.y );
		        var upperLeft:Point=new Point( r.x, r.y );
		        var lowerRight:Point=new Point( r.x+r.width, r.y+r.height);
		        
		        // Check completely out the box
		        if (v1.x>upperRight.x && v2.x>upperRight.x) return false;
		        if (v1.x<upperLeft.x && v2.x<upperLeft.x) return false;
		        if (v1.y<upperRight.y && v2.y<upperRight.y) return false;
		        if (v1.y>lowerRight.y && v2.y>lowerRight.y) return false;
		        
		     
		        // check if it is inside
		        if (v1.x > lowerLeft.x && v1.x < upperRight.x && v1.y < lowerLeft.y && v1.y > upperRight.y &&
		            v2.x > lowerLeft.x && v2.x < upperRight.x && v2.y < lowerLeft.y && v2.y > upperRight.y )
		        {   
		            return true;
		        }
		        
		        // Calc gradient
		        var gradient:Number=(v2.y-v1.y)/(v2.x-v1.x);
		        // Calc constant
		        var lineConstant:Number=v1.y-gradient*v1.x;
		        		        		       
		        // Check intersection with left of viewbox and clip
		        if (lineIntersectLine(v1,v2, upperLeft, lowerLeft ) ) 
		        {
		       		if (v1.x<v2.x) {v1.x=lowerLeft.x;v1.y=v1.x*gradient+lineConstant;}
		       		else {v2.x=lowerLeft.x;v2.y=v2.x*gradient+lineConstant;}		        	
		        }
		        // Check intersection with bottom of viewbox and clip	        		        
		        if (lineIntersectLine(v1,v2, lowerLeft, lowerRight))
		        {
		        	if (v1.y>v2.y) {v1.y=lowerRight.y;v1.x=(v1.y-lineConstant)/gradient;}
		       		else {v2.y=lowerRight.y;v2.x=(v2.y-lineConstant)/gradient;}
		        }
		        // Check intersection with top of viewbox and clip
		        if (lineIntersectLine(v1,v2, upperLeft, upperRight))
		        {
		        	if (v1.y<v2.y) {v1.y=upperLeft.y;v1.x=(v1.y-lineConstant)/gradient;}
		       		else {v2.y=upperLeft.y;v2.x=(v2.y-lineConstant)/gradient;}		        	
		        }
		        // Check intersection with right of viewbox and clip
		        if (lineIntersectLine(v1,v2, upperRight, lowerRight) ) 
		        {
		        	if (v1.x>v2.x) {v1.x=lowerRight.x;v1.y=v1.x*gradient+lineConstant;}
		       		else {v2.x=lowerRight.x;v2.y=v2.x*gradient+lineConstant;}		        	
		        }
		        return true;
		}
	    
	     
	    private function onMapStartPanning(event:MapEvent):void
	    {
	        starting = new Point(x, y);
	    }
	    
	    private function onMapPanned(event:MapEvent):void
	    {
	        if (starting) {
	            x = starting.x + event.panDelta.x;
	            y = starting.y + event.panDelta.y;
	        }
	        else {
	            x = event.panDelta.x;
	            y = event.panDelta.y;	            
	        }
	    }
	    
	    private function onMapStopPanning(event:MapEvent):void
	    {
	    	if (starting) {
		        x = starting.x;
		        y = starting.y;
		    }
	        updatePolyLines();
	    }
	    
	    private function onMapResized(event:MapEvent):void
	    {
	        x = event.newSize[0]/2;
	        y = event.newSize[1]/2;
	        updatePolyLines();
	    }
	    
	    private function onMapStartZooming(event:MapEvent):void
	    {
	        updatePolyLines(); 
	    }
	    
	    private function onMapStopZooming(event:MapEvent):void
	    {
	        if (scaleZoom) {
	            scaleX = scaleY = 1.0;
	        }
            updatePolyLines();
	    }
	    
	    private function onMapZoomedBy(event:MapEvent):void
	    {
	        if (scaleZoom) {
    	        scaleX = scaleY = Math.pow(2, event.zoomDelta);
	        }
	        else {
                updatePolyLines();
	        }
	    }
	    
	}
	
}