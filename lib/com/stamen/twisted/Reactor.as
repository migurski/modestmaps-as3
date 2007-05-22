/**
 * @author migurski
 *
 * com.stamen.twisted.Reactor is inspired by the Reactor class of Twisted Python.
 *
 * It is a static class that can schedule events via a single onEnterFrame loop.
 * The Reactor is well-suited to setting up delayed function calls complete with
 * arguments, and scheduling their execution some number of milliseconds into the
 * future. It is also useful for helping to maintain framerate, by only executing
 * as many calls as can fit in a pre-determined time limit.
 *
 * @see http://twistedmatrix.com/projects/core/documentation/howto/reactor-basics.html
 *
 * @usage <code>
 *          import com.stamen.twisted.Reactor;
 *          ...
 *          Reactor.run(_root, null, 50);
 *          Reactor.callLater(1000, trace, "A message in the mysterious future");
 *        </code>
 */
package com.stamen.twisted
{
	import com.stamen.twisted.DelayedCall;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	public class Reactor
	{
	    protected static var display:DisplayObject;
	    protected static var start:int;    // timestamp at start
	    protected static var limit:int;    // time limit for mainLoop() to maintain fps
	
	    protected static var calls:/*DelayedCall*/Array;
	    protected static var nextFrameCalls:/*DelayedCall*/Array;
	    protected static var __running:Boolean;
	
	   /**
	    * Run Reactor with clip that will host onEnterFrame, a log function, and limit value for main loop duration.
	    */
	    public static function run(_display:DisplayObject, lim:int):void
	    {
	        // log = lg;
	        log('Starting Reactor...');
	
	        if (__running)
			{
	            log('Warning: possible that reactor was already started?');
	            throw new Error('Warning: possible that reactor was already started?');
	        }

	        display = _display;
	        limit = lim;
	        start = getTime();
	        calls = [];
	        nextFrameCalls = [];
	
	        display.addEventListener(Event.ENTER_FRAME, mainLoop);
	        __running = true;
	        log('Started Reactor at ' + start + '.');
	    }

		private static function log(message:String):void
		{
//			trace(message);
		}

	   /**
	    * Determine whether the reactor is currently running.
	    */
	    public static function running():Boolean
	    {
	        return __running;
	    }
	    
	   /**
	    * Stop running Reactor.
	    */
	    public static function stop():void
	    {
	        log('Stopping Reactor...');
	
	        if (!__running) {
	            log('Warning: possible that reactor had not been stopped?');
	            throw new Error('Warning: possible that reactor had not been stopped?');
	        }

			display.removeEventListener(Event.ENTER_FRAME, mainLoop);
	        log('Stopped Reactor.');
	    }
	    
	    private static function getTime():Number
	    {
	        return getTimer();
	    }
	    
	    private static function sortCalls(a:DelayedCall, b:DelayedCall):Number
	    {
	        // Sort with the most urgent calls at the beginning
	        return a.due - b.due;
	    }
	    
	    private static function mainLoop(event:Event):void
	    {
	        // log('...Reactor main loop...');
	        
	        var loopStop:Number = getTime() + limit;
	        
	        while (nextFrameCalls.length)
	            addCall(nextFrameCalls.shift() as DelayedCall);
	        
	        while (calls.length)
			{
	            // Stop as soon as we encounter one that's not due
	            // Calls are kept in order by callLater()
	            if (calls[0].due > getTime())
	                break;
	
//	            try
//				{
	                // Shift n' call first in the list, most urgent!
	                calls.shift().call();
//	            }
//				catch(e:Error)
//				{
//					trace(e.getStackTrace());
	                // do nothing
//	            }
	            
	            // Stop if the limit is exceeded
	            if (getTime() > loopStop)
	                break;
	        }
	    }
	    
	    private static function addCall(call:DelayedCall):void
	    {
	        calls.push(call);
	        
	        // Most-urgent calls go to the front.
	        // Hopefully cheap, since these will generally stay in order.
	        calls.sort(sortCalls);
	    }
	    
	   /**
	    * Schedule a call for later, with time in the future, a function to call, and optional arguments to pass.
	    */
	    public static function callLater(delay:Number, func:Function, ... args):DelayedCall
	    {
	        var due:Number = getTime() + delay;     // due <delay> msec from now
	        var call:DelayedCall = new DelayedCall(due, func, args);

			log('Adding delayed call for later, due @ ' + call.due + '...');
//			call.call();
//			return call;


//	        log('Adding delayed call with '+call.args.length+' arguments at '+call.due+'...');
	        addCall(call);
	        return call;
	    }
	    
	   /**
	    * Schedule a call for the next frame, with a function to call and optional arguments to pass.
	    */
	    public static function callNextFrame(func:Function, ... args):DelayedCall
	    {
	        var due:Number = getTime();             // due ASAP
	        var call:DelayedCall = new DelayedCall(due, func, args);
	
	        log('Adding delayed call for next frame with ' + call.args.length + ' arguments, due @ ' + call.due + '...');
	        //call.call();
	        //return call;

	        nextFrameCalls.push(call);
	        return call;	        
	    }
	}
}