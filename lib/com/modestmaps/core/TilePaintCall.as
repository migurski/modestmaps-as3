
package com.modestmaps.core
{
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.mapproviders.IMapProvider;
	import com.stamen.twisted.DelayedCall;
	
	public class TilePaintCall extends Object
	{
	    protected var _call:DelayedCall;
	    protected var _mapProvider:IMapProvider;
	    protected var _tileCoord:Coordinate;

	    public function TilePaintCall(call:DelayedCall, provider:IMapProvider, coord:Coordinate)
	    {
	        _call = call;
	        _mapProvider = provider;
	        _tileCoord = coord;
	    }

	    public function toString():String
	    {
	        return _mapProvider.toString() + ', ' + _tileCoord.toString(); 
	    }

	    public function match(provider:IMapProvider, coord:Coordinate):Boolean
	    {
	        return (_mapProvider == provider)
	            && (_tileCoord.toString() == coord.toString());
	    }

	    public function pending():Boolean
	    {
	        return _call.pending();
	    }

	    public function cancel():void
	    {
	        _call.cancel();
	    }
	}
}