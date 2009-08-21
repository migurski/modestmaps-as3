package com.modestmaps.core.painter
{
	import flash.events.IEventDispatcher;
	
	public interface ITilePainterOverride extends IEventDispatcher
	{
		function getTilePainter():ITilePainter;
	}
}