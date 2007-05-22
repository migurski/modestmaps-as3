/**
 * vim:et sts=4 sw=4 cindent:
 * $Id$
 * @author allens
 */
package com.modestmaps.flex
{
	/**
	 * The flex.Map class is an ActionScript UI component. To use it in your application,
	 * simply specify a new namespace in the root node of your application. As long as the
	 * com.modestmaps.flex namespace is in your path, Flex Builder should find the class
	 * and auto-complete the element name once you've opened a new tag and typed the namespace.
	 * 
	 * <mx:Application xmlns:modest="com.modestmaps.flex.*" ...>
	 *   <modest:Map provider="BLUE_MARBLE" zoom="5" center="37.5, -122.0"
	 * 		top="0" left="0" bottom="0" right="0" />
	 * </mx:Application>
	 * 
	 * The MXML component doesn't currently support the full com.modestmaps.Map API, but the
	 * instance of that class is accessible via the (read-only) "map" getter if you need to
	 * call any of its methods.
	 */
	import com.modestmaps.Map;
	import com.modestmaps.core.*;
	import com.modestmaps.events.MapEvent;
	import com.modestmaps.geo.*;
	import com.modestmaps.mapproviders.*;
	import com.modestmaps.mapproviders.microsoft.*;
	import com.modestmaps.mapproviders.google.*;
	import com.modestmaps.mapproviders.yahoo.*;
	
	import flash.events.Event;
	import mx.core.UIComponent;

	/**
	 * There's something funky going on with coercion of these event types.
	 * I'll have to investigate before event attributes will work in MXML.
	 * - shawn
	 */
	/*
	[Event(name="startPanning", type="com.modestmaps.events.MapEvent")]
	[Event(name="pannedBy", type="com.modestmaps.events.MapEvent")]
	[Event(name="stopPanning", type="com.modestmaps.events.MapEvent")]
	[Event(name="startZooming", type="com.modestmaps.events.MapEvent")]
	[Event(name="zoomedBy", type="com.modestmaps.events.MapEvent")]
	[Event(name="stopZooming", type="com.modestmaps.events.MapEvent")]
	*/

	public class Map extends UIComponent
	{
		public static const DEFAULT_MEASURED_WIDTH:Number = 400;
	    public static const DEFAULT_MEASURED_MIN_WIDTH:Number = 100;
	    public static const DEFAULT_MEASURED_HEIGHT:Number = 400;
	    public static const DEFAULT_MEASURED_MIN_HEIGHT:Number = 100;
	    public static const DEFAULT_MAX_WIDTH:Number = 10000;
	    public static const DEFAULT_MAX_HEIGHT:Number = 10000;

	    public static const DEFAULT_MAP_PROVIDER:IMapProvider = new BlueMarbleMapProvider();
		
		protected var _map:com.modestmaps.Map;
		protected var mapInitDirty:Boolean = true;

		public function Map()
		{
			super();
		}

		/**
		 * Since we're not yet supporting the full Map interface,
		 * make the instance gettable, read-only.
		 */
		public function get map():com.modestmaps.Map
		{
			return _map;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();

			if (_map == null)
			{
				_map = new com.modestmaps.Map();
				_map.addEventListener(MapEvent.PANNED, onMapPanned);
				_map.addEventListener(MapEvent.RESIZED, onMapResized);
				_map.addEventListener(MapEvent.START_PANNING, onMapStartPanning);
				_map.addEventListener(MapEvent.STOP_PANNING, onMapStopPanning);
				_map.addEventListener(MapEvent.START_ZOOMING, onMapStartZooming);
				_map.addEventListener(MapEvent.STOP_ZOOMING, onMapStopZooming);
				_map.addEventListener(MapEvent.ZOOMED_BY, onMapZoomedBy);
				addChild(_map);
			}
		}

		/**
		 * Updates the map's provider, extent or center/zoom, and size. This is called
		 * by the Flex framework when necessary. There's probably some more optimization that
		 * could be done in the whole invalidation/validation/update process; for instance,
		 * a flag set in invalidateSize() could be used to determine whether or not we should
		 * call _map.setSize(), rather than just comparing the size.
		 */
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			trace("Map.updateDisplayList()");

			if (mapInitDirty && _map)
			{
				// TODO: implement draggable switch?
				trace(' * initializing map: ' + w + 'x' + h + ', ' + _draggable + ', provider: ' + _mapProvider.toString());
				_map.init(w, h, _draggable, _mapProvider || DEFAULT_MAP_PROVIDER);
				mapInitDirty = false;
			}
			else if (mapProviderDirty && _map)
			{
				trace(' * setting map provider: ' + _mapProvider.toString());
				_map.setMapProvider(_mapProvider);
				mapProviderDirty = false;
			}

			if (_extent && mapExtentDirty && _map)
			{
				trace(' * extent is dirty, setting to: ' + _extent);
				_map.setExtent(_extent);
				mapExtentDirty = false;
			}
			else if (mapCenterDirty && _map)
			{
				trace (' * center is dirty...');
				if (mapZoomDirty)
				{
					trace(' ** setting center and zoom: ' + _centerLocation + ', ' + _zoom);
					_map.setCenterZoom(_centerLocation, _zoom);
					mapZoomDirty = false;
				}
				else
				{
					var zoomLevel:int = int(_map.getCenterZoom()[1]);
					trace(' ** setting center: ' + _centerLocation + ' with implicit zoom: ' + zoomLevel);
					_map.setCenterZoom(_centerLocation, zoomLevel);
				}
				mapCenterDirty = false;
			}
			
			if (mapZoomDirty && _map)
			{
				trace(' * map zoom is still dirty! this should NOT happen.');
				// FIXME: this doesn't work during initialization
				// map.setCenterZoom(map.getCenter(), _zoom);
				mapZoomDirty = false;
			}

			if (_map.width != w || _map.height != h)
			{
				_map.setSize(w, h);
			}
			
			super.invalidateDisplayList();
		}

		protected var mapExtentDirty:Boolean = false;
		protected var _extent:MapExtent;
		protected var _mapExtentString:String;
		
		protected var mapCenterDirty:Boolean = true;
		protected var _centerLocation:Location = new Location(0, 0);
		protected var mapZoomDirty:Boolean = true;
		protected var _zoom:int = 1;

		/**
		 * The "extent" setter accepts either a MapExtent instance or a String;
		 * the latter is converted into a MapExtent using the static fromString()
		 * method. This allows the extent to be defined as a string in MXML
		 * attributes, a la "north, south, east, west".
		 */
		[Inspectable(category="Map")]
		public function set extent(mapExtent:*):void
		{
			if (mapExtent is String)
			{
				// TODO: try/catch MapExtent.fromString()
				mapExtent = MapExtent.fromString(mapExtent);
			}
			
			if (!(mapExtent is MapExtent))
			{
				throw new Error("Invalid extent supplied");
			}
			trace("got extent: " + mapExtent);
			
			_extent = mapExtent;
			mapExtentDirty = true;
			mapCenterDirty = false;
			mapZoomDirty = false;
			invalidateDisplayList();
		}

		public function get extent():MapExtent
		{
			return _map ? _map.getExtent() : _extent;
		}

		/**
		 * Like the "extent" setter, the "center" setter accepts a String in addition to
		 * a Location object, so that locations can be specified in MXML attributes as
		 * strings ("lat, lon").
		 */
		[Inspectable(category="Map", defaultValue="0,0")]		
		public function set center(location:*):void
		{
			if (location is String)
			{
				location = Location.fromString(location);
			}

			if (!(location is Location))
			{
				throw new Error("Invalid location supplied");
			}
			
			_centerLocation = location;
			mapCenterDirty = true;
			mapExtentDirty = false;
			invalidateProperties();
		}

		public function get center():Location
		{
			return _map ? _map.getCenter() : _centerLocation;
		}
		
		public function set zoom(zoomLevel:int):void
		{
			_zoom = zoomLevel;
			mapZoomDirty = true;
			mapExtentDirty = false;
			invalidateProperties();
		}

		protected var mapProviderDirty:Boolean = true;
		protected var _mapProvider:IMapProvider = DEFAULT_MAP_PROVIDER;

		/**
		 * The "provider" setter accepts either a String (Flex Builder should provide
		 * a list of valid values per the Inspectable() metadata tag) or an IMapProvider
		 * instance. You can specify the latter in MXML by wrapping the constructor in
		 * braces:
		 * 
		 * <modest:Map provider="{new FancyCustomMapProvider()}" .../>
		 */
		[Inspectable(category="Map",
					 enumeration="BLUE_MARBLE,GOOGLE_AERIAL,GOOGLE_ROAD,GOOGLE_HYBRID,MICROSOFT_AERIAL,MICROSOFT_ROAD,MICROSOFT_HYBRID,YAHOO_ROAD,YAHOO_AERIAL,YAHOO_HYBRID,ZOOMIFY,OPEN_STREET_MAP,VANILLA",
					 defaultValue="BLUE_MARBLE")]
		public function set provider(provider:*):void
		{
			if(provider is IMapProvider) {
				_mapProvider = provider;

			} else {
				switch(provider) {
					case "BLUE_MARBLE":
						_mapProvider = new BlueMarbleMapProvider();
						break;
					case "OPEN_STREET_MAP":
						_mapProvider = new OpenStreetMapProvider();
						break;
					case "MICROSOFT_AERIAL":
						_mapProvider = new MicrosoftAerialMapProvider();
						break;
					case "MICROSOFT_HYBRID":
						_mapProvider = new MicrosoftHybridMapProvider();
						break;
					case "MICROSOFT_ROAD":
						_mapProvider = new MicrosoftRoadMapProvider();
						break;
					case "GOOGLE_AERIAL":
						_mapProvider = new GoogleAerialMapProvider();
						break;
					case "GOOGLE_HYBRID":
						_mapProvider = new GoogleHybridMapProvider();
						break;
					case "GOOGLE_ROAD":
						_mapProvider = new GoogleRoadMapProvider();
						break;
					case "YAHOO_AERIAL":
						_mapProvider = new YahooAerialMapProvider();
						break;
					case "YAHOO_HYBRID":
						_mapProvider = new YahooHybridMapProvider();
						break;
					case "YAHOO_ROAD":
						_mapProvider = new YahooRoadMapProvider();
						break;
				}
			}
			mapProviderDirty = true;
			invalidateProperties();
		}

		public function get provider():IMapProvider
		{
			if (_map)
			{
				var provider:IMapProvider = _map.getMapProvider();
				return provider ? provider : _mapProvider;
			}
			else
			{
				return _mapProvider;
			}
		}

		protected var _draggable:Boolean = true;

		/**
		 * Currently the "draggable" setter will only work pre-initialization.
		 * In other words, setting draggable after the component has been
		 * initialized will have no effect; it's provided merely as a means for
		 * setting the property in MXML.
		 */
		[Inspectable(category="Map")]
		public function set draggable(isDraggable:Boolean):void
		{
			if (initialized)
			{
				throw new Error("'draggable' is not settable post initialization");
			}
			else
			{
				_draggable = isDraggable;
			}
		}
		
		public function get draggable():Boolean
		{
			return _draggable;
		}

		/**
		 * TODO: implement our own event dispatchers here,
		 * or simply let the events bubble up?
		 */
		protected function onMapPanned(event:MapEvent):void
		{
		}
		
		protected function onMapResized(event:MapEvent):void
		{
		}
		
		protected function onMapStartPanning(event:MapEvent):void
		{
		}
		
		protected function onMapStopPanning(event:MapEvent):void
		{
		}
		
		protected function onMapStartZooming(event:MapEvent):void
		{
		}
		
		protected function onMapStopZooming(event:MapEvent):void
		{
		}
		
		protected function onMapZoomedBy(event:MapEvent):void
		{
		}
	}	
}