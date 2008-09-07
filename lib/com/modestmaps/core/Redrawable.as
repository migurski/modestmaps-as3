package com.modestmaps.core
{
	import flash.events.Event;
	
	public interface Redrawable
	{
		function redraw(event:Event=null):void;
	}
}