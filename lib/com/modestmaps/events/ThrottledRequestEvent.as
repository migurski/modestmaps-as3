package com.modestmaps.events
{
	import com.modestmaps.core.Coordinate;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;

	dynamic public class ThrottledRequestEvent extends Event
	{
		public static const REQUEST_ERROR:String = "requestError";
		public static const RESPONSE_COMPLETE:String = "responseComplete";
		public static const RESPONSE_ERROR:String = "responseError";

		public var coord:Coordinate;
		public var sprite:Sprite;
		public var message:String;
		public var status:int;
		public var request:URLRequest;

		public function ThrottledRequestEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}