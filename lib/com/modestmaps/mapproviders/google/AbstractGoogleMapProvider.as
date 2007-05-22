package com.modestmaps.mapproviders.google
{
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.geo.MercatorProjection;
	import com.modestmaps.geo.Transformation;
	import com.modestmaps.mapproviders.AbstractImageBasedMapProvider;
	import com.modestmaps.io.XmlThrottledRequest;
	import com.modestmaps.events.*;
	import flash.display.Sprite;
	
	/**
	 * @author darren
	 */
	public class AbstractGoogleMapProvider 
		extends AbstractImageBasedMapProvider 
	{
		protected var __paintQueue:Array;
	
	    // Google often updates its tiles and expires old sets.
	    // The version numbers here are recent, but may change.
		protected static var __roadVersion:String = "w2.46";
		protected static var __hybridVersion:String = "w2t.47";
		protected static var __aerialVersion:String = "17";
	
	    // An XML file is checked for up-to-date version numbers.
	    // Check for updates at http://modestmaps.com for current versions.
		protected static var __versionSource:String = "google_version.xml";
		protected static var __versionRequested:Boolean = false;
		
		public function AbstractGoogleMapProvider() 
		{
			super();
	
		    // see: http://modestmaps.mapstraction.com/trac/wiki/TileCoordinateComparisons#TileGeolocations
		    var t:Transformation = new Transformation(1.068070779e7, 0, 3.355443185e7,
			                                          0, -1.068070890e7, 3.355443057e7);
			                                          
	        __projection = new MercatorProjection(26, t);
	
	        __topLeftOutLimit = new Coordinate(0, Number.NEGATIVE_INFINITY, 0);
	        __bottomRightInLimit = (new Coordinate(1, Number.POSITIVE_INFINITY, 0)).zoomTo(Coordinate.MAX_ZOOM);
		}
	
	    override public function sourceCoordinate(coord:Coordinate):Coordinate
	    {
		    var wrappedColumn:Number = coord.column % Math.pow(2, coord.zoom);
	
		    while(wrappedColumn < 0)
		        wrappedColumn += Math.pow(2, coord.zoom);
		        
	        return new Coordinate(coord.row, wrappedColumn, coord.zoom);
	    }
	    
	    override public function paint( sprite:Sprite, coord:Coordinate ):void 
		{
			checkVersionRequested();
			
			if (__roadVersion && __hybridVersion && __aerialVersion)
				super.paint(sprite, coord);
			else
				enqueuePaintRequest(sprite, coord);					
		}
		
		// Private Methods
		
		protected function checkVersionRequested():void
		{
			if ( !AbstractGoogleMapProvider.__versionRequested )
			{
				trace ("  checkVersionRequested(): " + AbstractGoogleMapProvider.__versionRequested );
				// we need to create a blocking request to load our version number
				AbstractGoogleMapProvider.__versionRequested = true;
			
				__paintQueue = new Array();
	
				var request:XmlThrottledRequest = new XmlThrottledRequest(__versionSource, true);
				request.addEventListener(ThrottledRequestEvent.RESPONSE_COMPLETE, onVersionResponseComplete);
				request.addEventListener(ThrottledRequestEvent.RESPONSE_ERROR, onVersionResponseError);
				request.send();
			}
		}
		
		protected function enqueuePaintRequest( sprite:Sprite, coord:Coordinate ):void
		{
			__paintQueue.push( { sprite:sprite, coord:coord } );
		}
		
		protected function processQueue():void
		{
			var paintRequest:Object;
			while ( __paintQueue.length )
			{
				paintRequest = __paintQueue.shift();
				paint( paintRequest.sprite, paintRequest.coord ); 	
			}
		}
	
		// Event Handlers
		
		protected function onVersionResponseComplete(event:ThrottledRequestEvent):void
		{
	        __roadVersion = event.xml.firstChild.attributes.road;
	        __hybridVersion = event.xml.firstChild.attributes.hybrid;
	        __aerialVersion = event.xml.firstChild.attributes.aerial;
			processQueue();
		}
		
		protected function onVersionResponseError(event:ThrottledRequestEvent):void
		{
		    // just use the defaults, I guess.
			processQueue();
		}		
	}
}