/**
 * @author darren
 */
package com.modestmaps.io
{
	import flash.events.IEventDispatcher;
	
	public interface IRequest extends IEventDispatcher
	{
		function send():void;
		function execute():void;
		function isBlocking():Boolean;
	}
}