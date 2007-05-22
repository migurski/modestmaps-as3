package com.modestmaps.events
{
	import flash.events.Event;
	import com.modestmaps.geo.Location;

	public class MarkerEvent extends Event
	{
	    public static const ENTER:String = 'markerEnter';
	    public static const LEAVE:String = 'markerLeave';

		protected var _markerID:String;
		protected var _location:Location;
		
		public function MarkerEvent(type:String, markerID:String, location:Location, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_markerID = markerID;
			_location = location;
		}

		public function get marker():String
		{
			return _markerID;
		}

		public function get location():Location
		{
			return _location;
		}
	}
}