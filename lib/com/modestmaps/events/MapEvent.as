package com.modestmaps.events
{
	import flash.events.Event;
	import flash.geom.Point;
	import com.modestmaps.core.MapExtent;
	import com.modestmaps.geo.Location;
	import com.modestmaps.core.Coordinate;

	public class MapEvent extends Event
	{
	    public static const START_ZOOMING:String = 'startZooming';
	    public static const STOP_ZOOMING:String = 'stopZooming';
		public var zoomLevel:Number;

	    public static const ZOOMED_BY:String = 'zoomedBy';
		public var zoomDelta:Number;
	    
	    public static const START_PANNING:String = 'startPanning';
	    public static const STOP_PANNING:String = 'stopPanning';
//	    public var centerLocation:Location;
//	    public var centerCoordinate:Coordinate;

	    public static const PANNED:String = 'pannedBy';
		public var panDelta:Point;
	    
	    public static const RESIZED:String = 'resized';
	    public var newSize:Array;
	    	    
	    public static const COPYRIGHT_CHANGED:String = 'copyright changed';
	    public var newCopyright:String;
	    
	    public static const EXTENT_CHANGED:String = 'extent changed';
		public var newExtent:MapExtent;

		public function MapEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}