package com.modestmaps.io
{
	import com.modestmaps.io.IRequest;
	import com.modestmaps.io.ThrottledRequest;
	import flash.net.*;
	import com.modestmaps.events.*;
	import flash.events.Event;
	import flash.xml.XMLDocument;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
	/**
	 * @author darren
	 */
	public class XmlThrottledRequest
		extends ThrottledRequest 
		implements IRequest 
	{
		private var _loader:URLLoader;
		protected var _request:URLRequest;

		public function XmlThrottledRequest(url:String, blocking:Boolean) 
		{
			super(url, blocking);
		}
	
		override public function send():void
		{
			if (_url)
			{
				super.send();
			}
			else
			{
				var event:ThrottledRequestErrorEvent = new ThrottledRequestErrorEvent(ThrottledRequestEvent.REQUEST_ERROR);
				event.message = "No URL provided!";
				dispatchEvent(event);
			}			
		}
	
		override public function execute():void
		{
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, onXMLComplete);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);

			_request = new URLRequest(_url);
			_loader.load(_request);
		}
	
		private function onXMLComplete(event:Event):void
		{
			var dispatch:ThrottledRequestEvent = new ThrottledRequestEvent(ThrottledRequestEvent.RESPONSE_COMPLETE);
			dispatch.xml = new XMLDocument(_loader.data);
			dispatchEvent(dispatch);
		}
		
		private function onIOError(event:Event):void
		{
			var dispatch:ThrottledRequestEvent = new ThrottledRequestEvent(ThrottledRequestEvent.RESPONSE_ERROR);
			dispatchEvent(dispatch);
		}
		
		private function onSecurityError(event:Event):void
		{
			var dispatch:ThrottledRequestEvent = new ThrottledRequestEvent(ThrottledRequestEvent.RESPONSE_ERROR);
			dispatchEvent(dispatch);
		}
	}
}