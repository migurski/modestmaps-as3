/*
 * $Id$
 */

package com.modestmaps.events
{
	public class ThrottledRequestErrorEvent extends ThrottledRequestEvent
	{
		public function ThrottledRequestErrorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}