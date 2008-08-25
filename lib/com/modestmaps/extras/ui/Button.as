package com.modestmaps.extras.ui {

	import flash.display.Sprite;	import flash.events.MouseEvent;	import flash.geom.ColorTransform;
	
	public class Button extends Sprite
	{
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		public static const UP:String = "up";
		public static const DOWN:String = "down";
		public static const IN:String = "in";
		public static const OUT:String = "out";
		
	    public var overTransform:ColorTransform = new ColorTransform(1,1,1);
	    public var outTransform:ColorTransform = new ColorTransform(1,.9,.6);
	
		public function Button(type:String=null)
		{
	        useHandCursor = true;
	        buttonMode = true;
	        cacheAsBitmap = true;
	        
	        addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
	        addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
	        
	        graphics.clear();
	        graphics.beginFill(0xdddddd);
	        graphics.drawRoundRect(0, 0, 20, 20, 9, 9);
	        graphics.beginFill(0xffffff);
	        graphics.drawRoundRect(0, 0, 18, 18, 9, 9);
	        graphics.beginFill(0xbbbbbb);
	        graphics.drawRoundRect(2, 2, 18, 18, 9, 9);
	        graphics.beginFill(0xdddddd);
	        graphics.drawRoundRect(1, 1, 18, 18, 9, 9);
	        
	        switch(type) {
	
	        	// draw arrows...
	        	case LEFT:
		            graphics.beginFill(0x000000);
		            graphics.moveTo(14,6);
		            graphics.lineTo(6,10);
		            graphics.lineTo(14,14);
		            graphics.lineTo(14,6);
		            break;
		
	        	case RIGHT:
		            graphics.beginFill(0x000000);
		            graphics.moveTo(6,6);
		            graphics.lineTo(14,10);
		            graphics.lineTo(6,14);
		            graphics.lineTo(6,6);
		            break;
		            
	        	case UP:
		            graphics.beginFill(0x000000);
		            graphics.moveTo(6,14);
		            graphics.lineTo(10,6);
		            graphics.lineTo(14,14);
		            graphics.lineTo(6,14);
		            break;
		
	        	case DOWN:
		            graphics.beginFill(0x000000);
		            graphics.moveTo(6,6);
		            graphics.lineTo(10,14);
		            graphics.lineTo(14,6);            
		            graphics.lineTo(6,6);
		            break;
		
	        	case IN:
		            // draw plus...
		            graphics.lineStyle(2, 0x000000, 1.0, true);
		            graphics.moveTo(7,10);
		            graphics.lineTo(13,10);
		            graphics.lineTo(7,10);
		            graphics.moveTo(10,7);
		            graphics.lineTo(10,13);
		            graphics.lineTo(10,7);
		            break;
		            
	        	case OUT:
		            // draw minus...
		            graphics.lineStyle(2, 0x000000, 1.0, true);
		            graphics.moveTo(7,10);
		            graphics.lineTo(13,10);
		            graphics.lineTo(7,10);
		            break;
	           
	        }
	        
	        transform.colorTransform = outTransform;		
		}
		
	    public function onMouseOver(event:MouseEvent=null):void
	    {
	        transform.colorTransform = overTransform;
	    }
	    
	    public function onMouseOut(event:MouseEvent=null):void
	    {
	        transform.colorTransform = outTransform;
	    }
	
	}

}