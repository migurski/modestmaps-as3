package com.modestmaps.events
{
	import flash.events.Event;
	import com.modestmaps.core.Coordinate;

	public class TilePaintEvent extends Event
	{
		public static const COMPLETE:String = "paintComplete";
		public static const CANCELLED:String = "paintCancelled";

		private var _coord:Coordinate;

		public function TilePaintEvent(type:String, coord:Coordinate, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_coord = coord;
		}
		
		public function get coord():Coordinate
		{
			return _coord;
		}
	}
}