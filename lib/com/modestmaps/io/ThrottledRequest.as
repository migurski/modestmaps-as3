package com.modestmaps.io
{
	import com.modestmaps.io.IRequest;
	import com.modestmaps.io.RequestThrottler;
	import flash.events.EventDispatcher;

	/**
	 * @author darren
	 */
	public class ThrottledRequest 
		extends EventDispatcher
		implements IRequest
	{
		protected var _url:String;
		protected var _blocking:Boolean;
		
		public function ThrottledRequest(url:String, blocking:Boolean=false)
		{
			super();
			_url = url;
			_blocking = blocking;
		}
		
		/*
		 * Called by the invoker when we the request is to be started.
		 */
		public function send():void
		{
			var throttler:RequestThrottler = RequestThrottler.getInstance();
			throttler.enqueue( this );
		}	
		
		/*
		 * Abstract method, to be implemented by subclass.
		 */
		public function execute():void
		{
			throw new Error( "Abstract method not implemented by subclass." );	
		}
		
		public function isBlocking():Boolean
		{
			return _blocking;	
		}
	}
}