/**
 * Provides the simplest possible graphic for a Tile, useful for debugging purposes.
 * 
 * @author darren
 */

package com.modestmaps.mapproviders
{
	import com.modestmaps.core.Coordinate;
	import com.modestmaps.mapproviders.AbstractMapProvider;
	import com.modestmaps.mapproviders.IMapProvider;
	import flash.display.Sprite;
	
	public class VanillaMapProvider
		extends AbstractMapProvider
		implements IMapProvider
	{
		override public function paint(sprite:Sprite, coord:Coordinate):void
		{
		   	super.paint(sprite, coord);
	
			with (sprite.graphics)
			{
				clear();
			    lineStyle(0, 0x0099FF, 100);
			    beginFill(0x000000, 20);
			    drawRect(0, 0, 256, 256);
			    endFill();
			}
	
		    // createLabel(sprite, coord.toString());
			raisePaintComplete(sprite, coord);
		}
	}
}