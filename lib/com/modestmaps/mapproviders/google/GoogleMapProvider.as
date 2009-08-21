package com.modestmaps.mapproviders.google
{
	import com.google.maps.Map;
	import com.google.maps.MapEvent;
	import com.google.maps.MapOptions;
	import com.google.maps.MapType;
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.core.painter.GoogleTilePainter;
	import com.modestmaps.core.painter.ITilePainter;
	import com.modestmaps.mapproviders.AbstractMapProvider;
	import com.modestmaps.mapproviders.IMapProvider;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class GoogleMapProvider extends AbstractMapProvider implements IEventDispatcher, IMapProvider, ITilePainterOverride
	{
		public static const ROAD:String = 'road';
		public static const AERIAL:String = 'aerial';
		public static const HYBRID:String = 'hybrid';
		public static const TERRAIN:String = 'terrain';
		
		protected var googleMap:Map;
		protected var dispatcher:EventDispatcher;
		protected var tilePainter:GoogleTilePainter;
		protected var type:String; 
		
		public function GoogleMapProvider(key:String, stage:Stage)
		{
			this.dispatcher = new EventDispatcher(this);
			googleMap = new Map();
			googleMap.key = key;
        	googleMap.addEventListener(MapEvent.MAP_READY, onMapReady);
        	googleMap.visible = false;			
        	stage.addChild(googleMap);			
		}

		public function getMapType():String
		{
			return type;
		}

		public function setMapType(type:String):void
		{
			this.type = type;
			switch (type) {
				case ROAD:
					googleMap.setMapType(MapType.NORMAL_MAP_TYPE);
					break;
				case AERIAL:
					googleMap.setMapType(MapType.SATELLITE_MAP_TYPE);
					break;
				case HYBRID:
					googleMap.setMapType(MapType.HYBRID_MAP_TYPE);
					break;
				case TERRAIN:
					googleMap.setMapType(MapType.PHYSICAL_MAP_TYPE);
					break;				
			}
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		protected function onMapReady(event:MapEvent):void
		{
			googleMap.setInitOptions(new MapOptions({
				mapType: MapType.NORMAL_MAP_TYPE
			}));
			type = ROAD;
			dispatchEvent(new Event(Event.COMPLETE));
		}
				
		public function getTilePainter():ITilePainter
		{
			if (!tilePainter) tilePainter = new GoogleTilePainter(googleMap);
			return tilePainter
		}
		
		public function toString():String
		{
			return "GOOGLE_"+type.toUpperCase()+"_PROVIDER";
		}
		
		public function getTileUrls(coord:Coordinate):Array
		{
			return [];
		}
		
		// I, EventDispatcher...

		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return dispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return dispatcher.hasEventListener(type);
		}
		
		public function willTrigger(type:String):Boolean
		{
			return dispatcher.willTrigger(type);
		}
		
	}
}