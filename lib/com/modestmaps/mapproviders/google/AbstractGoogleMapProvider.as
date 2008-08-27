package com.modestmaps.mapproviders.google
{
	import com.modestmaps.events.*;
	import com.modestmaps.mapproviders.AbstractMapProvider;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * @author darren
	 * @author tom
  	 * $Id$
	 */
	public class AbstractGoogleMapProvider 
		extends AbstractMapProvider
		implements IEventDispatcher
	{
		public static const READY:String = "ready";
		
	    // Google often updates its tiles and expires old sets.
	    // The version numbers here are recent, but may change.
		protected static var __roadVersion:String = "w2.80";
		protected static var __hybridVersion:String = "w2t.80";
		protected static var __aerialVersion:String = "30";
		protected static var __terrainVersion:String = "w2p.81";
	
	    // An XML file is checked for up-to-date version numbers.
	    // Check for updates at http://modestmaps.com for current versions.
	    // TODO: make this URL customizable in the constructor
		protected static var __versionSource:String = "google_version.xml";
		protected static var __versionRequested:Boolean = false;

		protected var eventDispatcher:EventDispatcher;
		
		public function AbstractGoogleMapProvider(minZoom:int=MIN_ZOOM, maxZoom:int=MAX_ZOOM) 
		{
			super(minZoom, maxZoom);
			
			eventDispatcher = new EventDispatcher(this);
			
			if (!__versionRequested) {
				try {
					var loader:URLLoader = new URLLoader(new URLRequest(__versionSource));
					loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
					loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
					loader.addEventListener(Event.COMPLETE, onLoadComplete);
					__versionRequested = true;
				}
				catch (error:Error) {
					onLoadError();
				}
			}
	   	}
	
		// Event Handlers
		
		protected function onLoadComplete(event:Event):void
		{			
			// <version road="w2.66" hybrid="w2t.66" aerial="24"/>
			var version:XML = XML((event.target as URLLoader).data);			
			
			if(version.@road.toString().length > 0) __roadVersion = version.@road;
	        if(version.@hybrid.toString().length > 0) __hybridVersion = version.@hybrid;
	        if(version.@aerial.toString().length > 0) __aerialVersion = version.@aerial;
	        if(version.@terrain.toString().length > 0) __terrainVersion = version.@terrain;
	        
			trace("Modest Maps: "+__versionSource+' loaded (road='+__roadVersion+' hybrid='+__hybridVersion+' aerial='+__aerialVersion+' terrain='+__terrainVersion+')');			
			
			dispatchEvent(new Event(AbstractGoogleMapProvider.READY));
		}
		
		protected function onLoadError(event:Event=null):void
		{
		    // just use the defaults, I guess.
			trace("Modest Maps: error loading " + __versionSource + ", using defaults from AbstractGoogleMapProvider.as");
			dispatchEvent(new Event(AbstractGoogleMapProvider.READY));
		}

		/** delegated to eventDispatcher */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/** delegated to eventDispatcher */
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			eventDispatcher.removeEventListener(type, listener, useCapture);			
		}
		
		/** delegated to eventDispatcher */
		public function hasEventListener(type:String):Boolean
		{
			return eventDispatcher.hasEventListener(type);
		}
		
		/** delegated to eventDispatcher */
		public function willTrigger(type:String):Boolean
		{
			return eventDispatcher.willTrigger(type);
		}
		
		/** delegated to eventDispatcher */
		public function dispatchEvent(event:Event):Boolean
		{
			return eventDispatcher.dispatchEvent(event);			
		}  
		
	}
}