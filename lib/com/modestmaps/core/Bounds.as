package com.modestmaps.core
{
	import flash.geom.Point;

	public class Bounds extends Object
	{
	    public var min:Point;
	    public var max:Point;
	
	    public function Bounds(min:Point, max:Point)
	    {
	        this.min = min;
	        this.max = max;
	    }
	}
}
