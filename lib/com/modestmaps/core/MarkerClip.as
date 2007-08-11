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
	
	public class MarkerClip extends Sprite
	{
		// TODO: mask me!
	    private var map:Map;
	    private var starting:Point;
	    private var locations:Object = {};
	
	    public function MarkerClip(map:Map)
	    {
	    	this.map = map;
	        map.addEventListener(MarkerEvent.ENTER, onMapMarkerEnters);
	        map.addEventListener(MarkerEvent.LEAVE, onMapMarkerLeaves);
	        map.addEventListener(MapEvent.START_ZOOMING, onMapStartZooming);
	        map.addEventListener(MapEvent.STOP_ZOOMING, onMapStopZooming);
	        map.addEventListener(MapEvent.ZOOMED_BY, onMapZoomed);
	        map.addEventListener(MapEvent.START_PANNING, onMapStartPanning);
	        map.addEventListener(MapEvent.STOP_PANNING, onMapStopPanning);
	        map.addEventListener(MapEvent.PANNED, onMapPanned);
	        map.addEventListener(MapEvent.RESIZED, onMapResized);
	        map.addEventListener(MapEvent.EXTENT_CHANGED, onMapExtentChanged);
	    }
	    
	    public function attachMarker(id:String, location:Location):Sprite
	    {
	        var sprite:Sprite = addChild(new Sprite()) as Sprite;
	        sprite.name = id;
	
	        locations[id] = location;
	        
	        var point:Point = map.locationPoint(location, this);
	        sprite.x = point.x;
	        sprite.y = point.y;
	        
	        return sprite;
	    }
	    
	    public function getMarker(id:String):Sprite
	    {
	        return getChildByName(id) as Sprite;
	    }
	    
	    public function removeMarker(id:String):void
	    {
	    	removeChild(getMarker(id));
	    }
	        
	    private function updateClips():void
	    {
	    	for (var i:int = 0; i < numChildren; i++) {
	    		var sprite:Sprite = getChildAt(0) as Sprite;	
	    		updateClip(sprite);
	    	}
	    }
	    
	    private function updateClip(sprite:Sprite):void
	    {
	        var location:Location = locations[sprite.name];
	        var point:Point = map.locationPoint(location,this);
	        sprite.x = point.x;
	        sprite.y = point.y;
	    }
	    	    
	    public function onMapMarkerEnters(event:MarkerEvent):void
	    {
	        getChildByName(event.marker).visible = true;
	    }
	    
	    public function onMapMarkerLeaves(event:MarkerEvent):void
	    {
	        getChildByName(event.marker).visible = false;
	    }
	    
	    public function onMapStartZooming(event:MapEvent):void
	    {
	        updateClips();
	    }
	    
	    public function onMapZoomed(event:MapEvent):void
	    {
	        updateClips();
	    }
	    
	    public function onMapStopZooming(event:MapEvent):void
	    {
	        updateClips();
	    }
	    
	    public function onMapStartPanning(event:MapEvent):void
	    {
	        starting = new Point(x, y);
	    }
	    
	    public function onMapPanned(delta:Point):void
	    {
	        x = starting.x + delta.x;
	        y = starting.y + delta.y;
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
	    
	    public function onMapExtentChanged(event:MapEvent):void
	    {
	        updateClips();
	    }
	}
	
}