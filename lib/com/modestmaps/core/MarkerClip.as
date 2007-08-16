/*
 * vim:et sts=4 sw=4 cindent:
 * $Id$
 */

package com.modestmaps.core {

	import flash.display.Sprite;
	import com.modestmaps.Map;
	import com.modestmaps.geo.Location;
	import com.modestmaps.core.MapExtent;
	import com.modestmaps.events.MapEvent;
	import flash.geom.Point;
	import com.modestmaps.events.MarkerEvent;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.display.DisplayObject;
	import flash.utils.getTimer;
	import flash.geom.Rectangle;
	
	/** This is different from the as2 version for now, because
	 *  it makes more sense to me if you give it a Sprite 
	 *  (or DisplayObject) to take care of rather than ask it to
	 *  make one for you.
	 */
	public class MarkerClip extends Sprite
	{
		// TODO: mask me?
	    private var map:Map;
	    private var starting:Point;
	    private var locations:Dictionary = new Dictionary();
	    private var markers:Array = []; // all markers
	    private var markersByName:Object = {};

        // enable this if you want intermediate zooming steps to
        // stretch your graphics instead of reprojecting the points
        // it looks worse and probably isn't faster, but there it is :)
        public var scaleZoom:Boolean = false;
	
	    public function MarkerClip(map:Map)
	    {
	    	this.map = map;
	    	this.x = map.getWidth() / 2;
	    	this.y = map.getHeight() / 2;
	        map.addEventListener(MarkerEvent.ENTER, onMapMarkerEnters);
	        map.addEventListener(MarkerEvent.LEAVE, onMapMarkerLeaves);
	        map.addEventListener(MapEvent.START_ZOOMING, onMapStartZooming);
	        map.addEventListener(MapEvent.STOP_ZOOMING, onMapStopZooming);
	        map.addEventListener(MapEvent.ZOOMED_BY, onMapZoomedBy);
	        map.addEventListener(MapEvent.START_PANNING, onMapStartPanning);
	        map.addEventListener(MapEvent.STOP_PANNING, onMapStopPanning);
	        map.addEventListener(MapEvent.PANNED, onMapPanned);
	        map.addEventListener(MapEvent.RESIZED, onMapResized);
	        map.addEventListener(MapEvent.EXTENT_CHANGED, updateClips);
	    }
	    
	    public function attachMarker(marker:DisplayObject, location:Location):void
	    {
	        //map.grid.putMarker(marker.name, map.getMapProvider().locationCoordinate(location), location);
	        
	        locations[marker] = location;
	        markersByName[marker.name] = marker;
	        markers.push(marker);
	        
	        var point:Point = map.locationPoint(location, this);
	        marker.x = Math.round(point.x);
	        marker.y = Math.round(point.y);
	        
	        var w:Number = map.getWidth() * 2;
	        var h:Number = map.getHeight() * 2;
	        if (marker.x > -w/2 && marker.x < w/2 && marker.y > -h/2 && marker.y < h/2) {
                addChild(marker);
            }
	    }
	    
	    public function getMarker(id:String):DisplayObject
	    {
	        return markersByName[id] as DisplayObject;
	    }
	    
	    public function removeMarker(id:String):void
	    {
	        //map.grid.removeMarker(id);
	    	var marker:DisplayObject = getMarker(id);
	    	if (marker) {
    	    	if (this.getChildByName(id)) removeChild(marker);
    	    	var index:int = markers.indexOf(marker);
    	    	if (index >= 0) {
    	    		markers.splice(index,1);
    	    	}
    	    	delete locations[marker];
    	    	delete markersByName[marker.name];
    	    }
	    }
	        
	    private function updateClips(event:Event=null):void
	    {
	    	//var t:int = flash.utils.getTimer();
	        var w:Number = map.getWidth() * 2;
	        var h:Number = map.getHeight() * 2;
	    	for each (var marker:DisplayObject in markers) {
	    	    if (marker.visible) {
	                updateClip(marker);
        	        if (marker.x > -w/2 && marker.x < w/2 && marker.y > -h/2 && marker.y < h/2) {
        	            if (!contains(marker)) {
        	                addChild(marker);
        	            }
        	        }
        	        else if (contains(marker)) {
        	            removeChild(marker);
        	        }
	            }
	    	}
	    	//trace("reprojected all markers in " + (flash.utils.getTimer() - t) + "ms");
	    }
	    
	    public function updateClip(marker:DisplayObject):void
	    {
	        var location:Location = locations[marker];
	        var point:Point = map.locationPoint(location, this);
	        marker.x = point.x;
	        marker.y = point.y;
	    }
	    	    
	    /** This uses addChild, and onMapMarkerLeaves uses removeChild, 
	     *  so that you're free to mess with .visible=true/false
	     *  yourself if you want to filter markers 
	     */
	    private function onMapMarkerEnters(event:MarkerEvent):void
	    {
 	    	if (!getChildByName(event.marker)) {
 	    		var marker:DisplayObject = getMarker(event.marker);
 	    		if (marker) {
	    		    addChild(marker);
	    		}
	    	} 
	    }

	    /** This uses removeChild, and onMapMarkerEnters uses removeChild, 
	     *  so that you're free to mess with .visible=true/false
	     *  yourself if you want to filter markers 
	     */
	    private function onMapMarkerLeaves(event:MarkerEvent):void
	    {
 	    	if (getChildByName(event.marker)) {
 	    		var marker:DisplayObject = getMarker(event.marker);
	    		removeChild(marker);
	    	} 
	    }
	    	    
	    public function onMapStartPanning(event:MapEvent):void
	    {
	        starting = new Point(x, y);
	    }
	    
	    public function onMapPanned(event:MapEvent):void
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
	    
	    public function onMapStopPanning(event:MapEvent):void
	    {
	    	if (starting) {
		        x = starting.x;
		        y = starting.y;
		    }
	        updateClips();
	    }
	    
	    public function onMapResized(event:MapEvent):void
	    {
	        x = event.newSize[0]/2;
	        y = event.newSize[1]/2;
	        updateClips();
	    }
	    
	    public function onMapStartZooming(event:MapEvent):void
	    {
	        // updateClips(); 
	    }
	    
	    public function onMapStopZooming(event:MapEvent):void
	    {
	        if (scaleZoom) {
	            scaleX = scaleY = 1.0;
	        }
            updateClips();
	    }
	    
	    public function onMapZoomedBy(event:MapEvent):void
	    {
	        if (scaleZoom) {
    	        scaleX = scaleY = Math.pow(2, event.zoomDelta);
	        }
	        else {
                updateClips();
	        }
	    }
	    
	}
	
}