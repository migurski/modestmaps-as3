/**
 * Used to limit the number of requests per frame.
 * 
 * @author darren
 */
package com.modestmaps.io
{
	import com.modestmaps.io.IRequest;
	import com.modestmaps.io.ThrottledRequest;
	import com.modestmaps.events.ThrottledRequestEvent;
	import flash.display.Loader;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class RequestThrottler 
	{
		private static var _instance:RequestThrottler;
		
		private var _queue:Array;
			
		// How often do we want to process requests?
		private var _throttleSpeedMS:uint = 100;
	
		// How many requests do we process for each throttle tick?
		private var _requestsPerCycle:uint = 5;
		private var _throttleTimer:Timer;
		
		/* 
		 * Singleton, use getInstance().
		 */
		public function RequestThrottler()
		{
			if (_instance != null)
			{
				throw new Error("RequestThrottler is a singleton!");
			}

			_queue = new Array();
			startQueue();
		}
		
		public function toString():String
		{
			return "RequestThrottler[]";	
		}
		
		/*
		 * Returns an instance of the RequestQueue.
		 * 
		 * @return The RequestQueue singleton.
		 */
		public static function getInstance():RequestThrottler
		{
			if (!_instance) _instance = new RequestThrottler();
			return _instance;
		}
		
		
		public function enqueue(request:IRequest):void
		{
			_queue.push(request);
		}
		
		// Private Methods
	
		private function processQueue():void
		{
			var count:uint = _requestsPerCycle;
			while (_queue.length > 0 && count--)
			{
				var request:IRequest = _queue.shift() as IRequest;
				request.execute(); 
	
				if (request.isBlocking())
				{
					// we don't care what the response was, just that it's done blocking. let the primary listener
					// handle errors
					request.addEventListener(ThrottledRequestEvent.REQUEST_ERROR, onBlockingRequestComplete);
					request.addEventListener(ThrottledRequestEvent.RESPONSE_ERROR, onBlockingRequestComplete);
					request.addEventListener(ThrottledRequestEvent.RESPONSE_COMPLETE, onBlockingRequestComplete);
					
					// stop the queue and wait for resolution.
					stopQueue();		
					break;
				}
			}
		}
		
		/**
		 * Stops queue execution.
		 */
		private function stopQueue():void
		{
			_throttleTimer.stop();
		}
		
		/**
		 * Starts queue execution.
		 */
		private function startQueue():void
		{
			if (_throttleTimer == null)
			{
				_throttleTimer = new Timer(_throttleSpeedMS);
				_throttleTimer.addEventListener(TimerEvent.TIMER, onThrottleTimer);
			}
			_throttleTimer.start();
		}
		
		// Event Handlers
		
		private function onThrottleTimer(event:TimerEvent):void
		{	
			processQueue();
		}
		
		private function onBlockingRequestComplete(event:ThrottledRequestEvent):void
		{
			// clean up event listeneners
			var request:IRequest = event.target as IRequest;
			request.removeEventListener(ThrottledRequestEvent.REQUEST_ERROR, onBlockingRequestComplete);
			request.removeEventListener(ThrottledRequestEvent.RESPONSE_ERROR, onBlockingRequestComplete);
			request.removeEventListener(ThrottledRequestEvent.RESPONSE_COMPLETE, onBlockingRequestComplete);
			startQueue();
		}		
	}
}