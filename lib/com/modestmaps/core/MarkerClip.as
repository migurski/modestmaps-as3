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
	
	/** This is different from the as2 version for now, because
	 *  it makes more sense to me if you give it a Sprite 
	 *  (or DisplayObject) to take care of rather than ask it to
	 *  make one for you.
	 */
	public class MarkerClip extends Sprite
	{
		// TODO: mask me!
	    private var map:Map;
	    private var starting:Point;
	    private var locations:Dictionary = new Dictionary();
	    private var markers:Array = [];
	    private var markersByName:Object = {};
	
	    public function MarkerClip(map:Map)
	    {
	    	this.map = map;
	        map.addEventListener(MarkerEvent.ENTER, onMapMarkerEnters);
	        map.addEventListener(MarkerEvent.LEAVE, onMapMarkerLeaves);
	        map.addEventListener(MapEvent.START_ZOOMING, updateClips);
	        map.addEventListener(MapEvent.STOP_ZOOMING, updateClips);
	        map.addEventListener(MapEvent.ZOOMED_BY, updateClips);
	        map.addEventListener(MapEvent.START_PANNING, onMapStartPanning);
	        map.addEventListener(MapEvent.STOP_PANNING, onMapStopPanning);
	        map.addEventListener(MapEvent.PANNED, onMapPanned);
	        map.addEventListener(MapEvent.RESIZED, onMapResized);
	        map.addEventListener(MapEvent.EXTENT_CHANGED, updateClips);
	    }
	    
	    public function attachMarker(marker:DisplayObject, location:Location):void
	    {
	        locations[marker] = location;
	        markersByName[marker.name] = marker;
	        markers.push(marker);
	        
	        var point:Point = map.locationPoint(location, this);
	        marker.x = point.x;
	        marker.y = point.y;
	        
	        // TODO: check if it should be added now?
	        addChild(marker);
	    }
	    
	    public function getMarker(id:String):DisplayObject
	    {
	        return markersByName[id] as DisplayObject;
	    }
	    
	    public function removeMarker(id:String):void
	    {
	    	var marker:DisplayObject = getMarker(id);
	    	if (this.getChildByName(id)) removeChild(marker);
	    	var index:int = markers.indexOf(marker);
	    	if (index >= 0) {
	    		markers.splice(index,1);
	    	}
	    	delete locations[marker];
	    }
	        
	    private function updateClips(event:Event=null):void
	    {
	    	for each (var marker:DisplayObject in markers) {
	    		updateClip(marker);
	    	}
	    }
	    
	    private function updateClip(marker:DisplayObject):void
	    {
	        var location:Location = locations[marker];
	        var point:Point = map.locationPoint(location,this);
	        marker.x = point.x;
	        marker.y = point.y;
	    }
	    	    
	    public function onMapMarkerEnters(event:MarkerEvent):void
	    {
/* 	    	if (!getChildByName(event.marker)) {
	    		addChild(getMarker(event.marker));
	    	} */
	    }
	    
	    public function onMapMarkerLeaves(event:MarkerEvent):void
	    {
/* 	    	if (getChildByName(event.marker)) {
	    		removeChild(getMarker(event.marker));
	    	} */
	    }
	    	    
	    public function onMapStartPanning(event:MapEvent):void
	    {
	        starting = new Point(x, y);
	    }
	    
	    public function onMapPanned(event:MapEvent):void
	    {
	        x = starting.x + event.panDelta.x;
	        y = starting.y + event.panDelta.y;
	    }
	    
	    public function onMapStopPanning(event:MapEvent):void
	    {
	        x = starting.x;
	        y = starting.y;
	        updateClips();
	    }
	    
	    public function onMapResized(event:MapEvent):void
	    {
	        x = event.newSize[0]/2;
	        y = event.newSize[1]/2;
	        updateClips();
	    }
	    
	}
	
}