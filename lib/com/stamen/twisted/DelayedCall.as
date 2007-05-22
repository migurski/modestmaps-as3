/**
 * Inspired by:
 *  http://twistedmatrix.com/documents/current/api/twisted.internet.base.DelayedCall.html
 */
package com.stamen.twisted
{
	public class DelayedCall extends Object
	{
	    public var due:int;
	    public var func:Function;
	    public var args:Array;
	    
	    private var called:Boolean;
	    private var cancelled:Boolean;
	
	   /**
	    * Construct delayed call with time due, function to call, and arguments to pass.
	    */
	    public function DelayedCall(d:int, f:Function, a:Array)
	    {
	        due  = d;
	        func = f;
	        args = a;
	        
	        called = false;
	        cancelled = false;
	    }
	    
	   /**
	    * Call previously-delayed call.
	    */
	    public function call():void
	    {
//	        try
//	    	{
	            if (pending())
	            {
//          		    trace('DelayedCall.call(): calling with ' + args.length + ' args...');
	                func.apply(null, args);
	            }
//	        } catch(e:Error) {
//	            // do nothing
//	        }
	            
	        called = true;
	    }
	    
	   /**
	    * Cancel not-yet-called, previously-delayed call.
	    */
	    public function cancel():void
	    {
	        cancelled = true;
	    }
	    
	   /**
	    * Check if this call is still pending.
	    */
	    public function pending():Boolean
	    {
	        return !called && !cancelled;
	    }
	}
}