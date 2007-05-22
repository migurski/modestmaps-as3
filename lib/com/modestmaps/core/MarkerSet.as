/*
 * vim:et sts=4 sw=4 cindent:
 */

package com.modestmaps.core
{
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.core.Marker;
	import com.modestmaps.core.Tile;
	import com.modestmaps.core.TileGrid;

	import flash.utils.Dictionary;
	
	public class MarkerSet extends Object
	{
	    protected var _lastZoom:Number;
	    
	    // markers hashed by id
	    protected var _markers:Dictionary;
	    
	    // marker lists hashed by containing tile id
	    protected var _tileMarkers:Dictionary;
	    
	    // tile id's hashed by marker id
	    protected var _markerTiles:Dictionary;
	    
	    // for finding which is visible
	    protected var _grid:TileGrid;
	
	    function MarkerSet(grid:TileGrid)
	    {
	        _grid = grid;
	        initializeIndex();
	    }
	    
	    /**
	     * Put a marker on the grid.
	     */
	    public function put(marker:Marker):void
	    {
	        _markers[marker.id] = marker;
	        indexMarker(marker.id);
	    }
	    
	    /**
	     * Remove a marker added via put().
	     */
	    public function remove(marker:Marker):void
	    {
	        unIndexMarker(marker.id);
	        delete _markers[marker.id];
	    }
	
	    public function initializeIndex():void
	    {
	        _lastZoom = 0;
	
	        _markers = new Dictionary(true);
	        _tileMarkers = new Dictionary(true);
	        _markerTiles = new Dictionary(true);
	    }
	
	    public function indexAtZoom(level:Number):void
	    {
	        _lastZoom = level;
	    
	        for(var markerId:String in _markers)
	            indexMarker(markerId);
	    }
	
	   /**
	    * Add a new marker to the internal index.
	    */
	    protected function indexMarker(markerId:String):void
	    {
	        var tileKey:String = _markers[markerId].coord.zoomTo(_lastZoom).container().toString();
	        
	        if (_tileMarkers[tileKey] == null)
	        {
	            _tileMarkers[tileKey] = new Dictionary(true);
	        }
	            
	        _tileMarkers[tileKey][markerId] = true;
	        
	        if (_markerTiles[markerId] == null)
	        {
	            _markerTiles[markerId] = new Dictionary(true);
	        }
	            
	        _markerTiles[markerId][tileKey] = true;
	        
	        //trace('Marker '+markerId+' in '+tileKey);
	    }
	
	    /**
	     * Remove a marker from the internal index.
	     */
	    protected function unIndexMarker(markerId:String):void
	    {
	        for(var tileKey:String in _markerTiles[markerId])
	        {
	            delete _tileMarkers[tileKey][markerId];
	        }
	
	        delete _markerTiles[markerId];
	    }
	
	   /**
	    * Fetch a single marker by ID.
	    */
	    public function getMarker(id:String):Marker
	    {
	        return _markers[id];
	    }
	
	   /**
	    * Fetch a list of markers within currently-visible tiles.
	    */
	    public function overlapping(tiles:/*Tile*/Array):/*Marker*/Array
	    {
	        var ids:Array = new Array();
	        var touched:/*Marker*/Array = new Array();
	        var sourceCoord:Coordinate;
	        
	        for(var i:Number = 0; i < tiles.length; i += 1)
			{
	            sourceCoord = _grid.getMapProvider().sourceCoordinate(tiles[i].coord);
	        
	            if(_tileMarkers[sourceCoord.toString()] != undefined)
	            {
	                for (var markerId:String in _tileMarkers[sourceCoord.toString()])
					{
	                    ids.push(markerId);
	                    touched.push(_markers[markerId]);
	                }
	            }
	        }
	        
	        //trace('Touched markers: '+ids.toString());
	        return touched;
	    }
	}
}