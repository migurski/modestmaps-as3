/*
com.bigspaceship.utils.Delegate.as -- Flash Actionscript 2 Delegate class (based on mx.utils.Delegate courtesy Macromedia/Adobe)
Copyright (C) 2006 Big Spaceship, LLC

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

To contact Big Spaceship, email info@bigspaceship.com or write to us at 45 Main Street #716, Brooklyn, NY, 11201.


*/


class com.bigspaceship.utils.Delegate extends Object
{
	/**
	Creates a functions wrapper for the original function so that it runs 
	in the provided context.
	@parameter obj Context in which to run the function.
	@paramater func Function to run.
	*/
	static function create(obj:Object, func:Function):Function
	{
		var f = function()
		{
			var target = arguments.callee.target;
			var func2  = arguments.callee.func;
			var args   = arguments.callee.args;
			
			return func.apply(target, args.concat(arguments));
		};

		f.target = arguments.shift();
		f.func2  = arguments.shift();
		f.args   = arguments;
		
		return f;
	}

	function Delegate(f:Function)
	{
		func = f;
	}

	private var func:Function;

	function createDelegate(obj:Object):Function
	{
		return create(obj, func);
	}	
}