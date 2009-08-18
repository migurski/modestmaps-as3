package {
	import com.adobe.viewsource.ViewSource;
	import com.modestmaps.Map;
	import com.modestmaps.TweenMap;
	import com.modestmaps.core.MapExtent;
	import com.modestmaps.events.MapEvent;
	import com.modestmaps.extras.MapControls;
	import com.modestmaps.extras.MapCopyright;
	import com.modestmaps.geo.Location;
	import com.modestmaps.mapproviders.microsoft.MicrosoftHybridMapProvider;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	[SWF(backgroundColor="#ffffff")]
	public class HelloClusters extends Sprite
	{
		public var map:Map;

		public function HelloClusters()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			ViewSource.addMenuItem(this, 'srcview/index.html', true);
			
			// make a draggable TweenMap so that we have smooth zooming and panning animation
			// use Microsoft's Hybrid tiles.
			map = new TweenMap(stage.stageWidth, stage.stageHeight, true, new MicrosoftHybridMapProvider(), new Location(51.500152, -0.126236), 11);
			map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);
			
			// add some basic controls
			// you're free to use these, but I'd make my own if I was a Flash coder :)
			map.addChild(new MapControls(map));
			//map.addChild(new ZoomBox(map));
			
			// add a copyright handler
			// (this is a bit of a hack, but works well enough for now)
			map.addChild(new MapCopyright(map));

			var extent:MapExtent = map.getExtent();

			for (var i:int = 0; i < 200; i++) {
				// create an instance of the Marker class defined below
				var marker:Marker = new Marker(new Location(extent.south + Math.random() * (extent.north-extent.south), extent.west + Math.random() * (extent.east-extent.west)));
				features.push(marker);
				trace(marker.category);
			}			
			
			map.setZoom(5);

			map.addEventListener(MapEvent.STOP_ZOOMING, cluster);
			//map.addEventListener(MapEvent.EXTENT_CHANGED, cluster);
			map.addEventListener(MapEvent.STOP_PANNING, cluster);
			
			// add map to stage last, so as to avoid markers jumping around
			addChild(map);

			cluster(null);

			// make sure the map always fills the screen:
			stage.addEventListener(Event.RESIZE, onStageResize);			
		}
		
		protected var distance:Number = 20;
		
		protected var features:Array = [];

		protected var clusters:Array;
		
		protected var clustering:Boolean;

		protected var resolution:Number;

	    /**
	     * Method: cluster
	     * Cluster features based on some threshold distance.
	     */
	    protected function cluster(event:MapEvent):void
	    {
	        if(this.features && this.features.length > 1) {
	            var resolution:Number = map.getZoom();
	            var extent:MapExtent = map.getExtent();
	            if(resolution != this.resolution || !this.clustersExist()) {
	                this.resolution = resolution;
	                var clusters:Array = [];
	                var feature:Marker, clustered:Boolean, cluster:Object;
	                for(var i:int=0; i<this.features.length; ++i) {
	                    feature = this.features[i];
	                   	if (!extent.contains(feature.location)) continue;
	                    clustered = false;
	                    for(var j:int=0; j<clusters.length; ++j) {
	                        cluster = clusters[j];
	                        if(this.shouldCluster(cluster, feature)) {
	                            this.addToCluster(cluster, feature);
	                            clustered = true;
	                            break;
	                        }
	                    }
	                    if(!clustered) {
	                        clusters.push(this.createCluster(this.features[i]));
	                    }
	                }
	                map.markerClip.removeAllMarkers();
	                if(clusters.length > 0) {
	                    this.clustering = true;
	                    // A legitimate feature addition could occur during this
	                    // addFeatures call.  For clustering to behave well, features
	                    // should be removed from a layer before requesting a new batch.
	                    for each (cluster in clusters) {
	                    	var marker:ClusterMarker = new ClusterMarker(cluster.cluster);	                    	
	                    	map.putMarker(MapExtent.fromLocationProperties(cluster.cluster).center, marker);
	                    }
	                    this.clustering = false;
	                }
	                this.clusters = clusters;
	            }
	        }
	    }
	    
	    /**
	     * Method: clustersExist
	     * Determine whether calculated clusters are already on the layer.
	     *
	     * Returns:
	     * {Boolean} The calculated clusters are already on the layer.
	     */
	    protected function clustersExist():Boolean
	    {
	        var exist:Boolean = false;
	        if(this.clusters && this.clusters.length > 0 &&
	           this.clusters.length == map.markerClip.getMarkerCount()) {
	            exist = true;
	            for(var i:int=0; i<this.clusters.length; ++i) {
	                if(map.markerClip.getMarker(clusters[i].name) == null) {
	                    exist = false;
	                    break;
	                }
	            }
	        }
	        return exist;
	    }
	    
	    /**
	     * Method: shouldCluster
	     * Determine whether to include a feature in a given cluster.
	     *
	     * Parameters:
	     * cluster - {<OpenLayers.Feature.Vector>} A cluster.
	     * feature - {<OpenLayers.Feature.Vector>} A feature.
	     *
	     * Returns:
	     * {Boolean} The feature should be included in the cluster.
	     */
	    protected function shouldCluster(cluster:Object, feature:Marker):Boolean
	    {
	        var cc:Point = map.locationPoint(cluster.location);
	        var fc:Point = map.locationPoint(feature.location);
	        var distance:Number = Point.distance(cc, fc);
	        return (distance <= this.distance);
	    }
	    
	    /**
	     * Method: addToCluster
	     * Add a feature to a cluster.
	     *
	     * Parameters:
	     * cluster - {<OpenLayers.Feature.Vector>} A cluster.
	     * feature - {<OpenLayers.Feature.Vector>} A feature.
	     */
	    protected function addToCluster(cluster:Object, feature:Marker):void
	    {
	        cluster.cluster.push(feature);
	        cluster.count += 1;
	    }
	    
	    /**
	     * Method: createCluster
	     * Given a feature, create a cluster.
	     *
	     * Parameters:
	     * feature - {<OpenLayers.Feature.Vector>}
	     *
	     * Returns:
	     * {<OpenLayers.Feature.Vector>} A cluster.
	     */
	    protected function createCluster(feature:Marker):Object
	    {
	        return {
	            location: feature.location,
	            count: 1,
	            name: "cluster-"+Math.random().toString(),
	            cluster: [ feature ]
	        };
	    }

		
		public function onStageResize(event:Event):void
		{
			map.setSize(stage.stageWidth, stage.stageHeight);
		}
	}
}

import flash.display.Sprite;
import com.modestmaps.geo.Location;
import flash.utils.Dictionary;	

class Marker
{
	public var location:Location;
	public var category:String;
	
	public static var CATEGORIES:Array = [ 'Obama', 'Biden', 'McCain', 'Palin', 'Blair', 'Bush', 'Clinton' ];
	public static var colors:Object = {
		'Obama': 0xff9900,
		'Blair': 0x99ff00,
		'Biden': 0x0099ff,
		'McCain': 0xff0099,
		'Bush':   0x00ff99,
		'Palin':  0x9900ff,
		'Clinton': 0xffff00
	};
	
	public function Marker(location:Location)
	{
		this.location = location;
		this.category = CATEGORIES[int(Math.random()*CATEGORIES.length)];
	}	
}

class ClusterMarker extends Sprite
{
	public function ClusterMarker(markers:Array)
	{
		if (markers.length == 1) {
			graphics.beginFill(0x000000);
			graphics.drawCircle(0,0,12);
			graphics.beginFill(uint(Marker.colors[markers[0].category]));
			graphics.drawCircle(0,0,10);			
		} 
		else {
			
			var counts:Dictionary = new Dictionary();
			
			for each (var marker:Marker in markers) {
				counts[marker.category] = counts[marker.category] ? counts[marker.category] + 1 : 1; 
			}
			
			graphics.beginFill(0x000000);
			graphics.drawCircle(0,0,12);
	
			var startAngle:Number = 0;
			trace('');
			for each (var category:String in Marker.CATEGORIES) {
				if (counts[category]) {
					trace(uint(Marker.colors[category]).toString(16));
					graphics.beginFill(uint(Marker.colors[category]));
					graphics.moveTo(0,0);
					var prop:Number = Number(counts[category]) / markers.length;
					var angle:Number = startAngle + (Math.PI * 2 * prop);
					trace(angle);
					for (var a:Number = startAngle; a < angle; a += Math.PI / 20.0) {
						var px:Number = 10 * Math.cos(a); 
						var py:Number = 10 * Math.sin(a);
						graphics.lineTo(px,py);
					}
					px = 10 * Math.cos(angle); 
					py = 10 * Math.sin(angle);
					graphics.lineTo(px,py);
					graphics.lineTo(0,0);
					graphics.endFill();
					startAngle = angle;
				}
			}
			trace('');
		}	
		
	}
}
