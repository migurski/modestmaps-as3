package com.modestmaps.events
{
	import com.modestmaps.core.Coordinate;

	import flash.display.Sprite;
	import flash.events.Event;

	public class MapProviderEvent extends Event
	{
		public static const PAINT_COMPLETE:String = "paintComplete";

		protected var _sprite:Sprite;
		protected var _coord:Coordinate;

		public function MapProviderEvent(type:String, sprite:Sprite, coord:Coordinate, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_sprite = sprite;
			_coord = coord;
		}
		
		public function get sprite():Sprite
		{
			return _sprite;
		}
		
		public function get coord():Coordinate
		{
			return _coord;
		}
	}
}