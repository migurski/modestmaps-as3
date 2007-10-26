package com.modestmaps.extras
{
    import com.modestmaps.Map;
    
    import flash.display.CapsStyle;
    import flash.display.JointStyle;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.ColorTransform;
    import flash.ui.Keyboard;

    public class MapControls extends Sprite
    {
        public var leftButton:Sprite = new Sprite();
        public var rightButton:Sprite = new Sprite();
        public var upButton:Sprite = new Sprite();
        public var downButton:Sprite = new Sprite();

        public var inButton:Sprite = new Sprite();
        public var outButton:Sprite = new Sprite();

        public var fullScreenButton:FullScreenButton = new FullScreenButton();

        private var map:Map;
        private var keyboard:Boolean;
        private var fullScreen:Boolean;
        
        private var overTransform:ColorTransform = new ColorTransform(1,1,1);
        private var outTransform:ColorTransform = new ColorTransform(1,1,0);

        private var buttons:Array;

        public function MapControls(map:Map, keyboard:Boolean=true, fullScreen:Boolean=false)
        {
            this.map = map;
            this.keyboard = keyboard;
            this.fullScreen = fullScreen;
            
            var buttonSprite:Sprite = new Sprite();
            addChild(buttonSprite);
            
            var actions:Array = [ map.panLeft, map.panRight, map.panUp, map.panDown, map.zoomIn, map.zoomOut ];
            buttons = [leftButton, rightButton, upButton, downButton, inButton, outButton];
            
            if (fullScreen) {
                buttons.push(fullScreenButton);
                actions.push(fullScreenButton.toggleFullScreen);
            }   

            for each (var button:Sprite in buttons) {
                button.addEventListener(MouseEvent.CLICK, actions.shift());
                button.useHandCursor = true;
                button.buttonMode = true;
                button.cacheAsBitmap = true;
                button.graphics.clear();
                button.graphics.beginFill(0xdddddd);
                button.graphics.drawRoundRect(-10, -10, 20, 20, 9, 9);
                button.graphics.beginFill(0xffffff);
                button.graphics.drawRoundRect(-10, -10, 18, 18, 9, 9);
                button.graphics.beginFill(0xbbbbbb);
                button.graphics.drawRoundRect(-8, -8, 18, 18, 9, 9);
                button.graphics.beginFill(0xdddddd);
                button.graphics.drawRoundRect(-9, -9, 18, 18, 9, 9);
                button.transform.colorTransform = outTransform;
                button.addEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver);
                button.addEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut);
                buttonSprite.addChild(button);                
            }

            // draw arrows...
            leftButton.graphics.beginFill(0x000000);
            leftButton.graphics.moveTo(4,-4);
            leftButton.graphics.lineTo(-4,0);
            leftButton.graphics.lineTo(4,4);
            leftButton.graphics.lineTo(4,-4);

            rightButton.graphics.beginFill(0x000000);
            rightButton.graphics.moveTo(-4,-4);
            rightButton.graphics.lineTo(4,0);
            rightButton.graphics.lineTo(-4,4);
            rightButton.graphics.lineTo(-4,-4);
            
            upButton.graphics.beginFill(0x000000);
            upButton.graphics.moveTo(-4,4);
            upButton.graphics.lineTo(0,-4);
            upButton.graphics.lineTo(4,4);
            upButton.graphics.lineTo(-4,4);

            downButton.graphics.beginFill(0x000000);
            downButton.graphics.moveTo(-4,-4);
            downButton.graphics.lineTo(0,4);
            downButton.graphics.lineTo(4,-4);            
            downButton.graphics.lineTo(-4,-4);

            // draw plus...
            inButton.graphics.lineStyle(2, 0x000000, 1.0, true);
            inButton.graphics.moveTo(-3,0);
            inButton.graphics.lineTo(3,0);
            inButton.graphics.lineTo(-3,0);
            inButton.graphics.moveTo(0,-3);
            inButton.graphics.lineTo(0,3);
            inButton.graphics.lineTo(0,-3);
            
            // draw minus...
            outButton.graphics.lineStyle(2, 0x000000, 1.0, true);
            outButton.graphics.moveTo(-3,0);
            outButton.graphics.lineTo(3,0);
            outButton.graphics.lineTo(-3,0);
            
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        }
        
        public function setButtonTransforms(overTransform:ColorTransform, outTransform:ColorTransform):void
        {
            this.overTransform = overTransform;
            this.outTransform = outTransform;
            
            for each (var button:Sprite in buttons) {
                button.transform.colorTransform = outTransform;
            }
        }
        
        private function onAddedToStage(event:Event):void
        {
            if (keyboard) stage.addEventListener(KeyboardEvent.KEY_UP, onStageKeyUp);
            if (fullScreen) stage.addEventListener(FullScreenButton.FULL_SCREEN, onFullScreenEvent);
            stage.addEventListener(Event.RESIZE, onStageResize);    
            onStageResize(null);
        }

        private function onButtonMouseOver(event:MouseEvent):void
        {
            var b:Sprite = (event.target as Sprite);
            b.transform.colorTransform = overTransform;
            b.scaleX = b.scaleY = 1.1;
        }
        private function onButtonMouseOut(event:MouseEvent):void
        {
            var b:Sprite = (event.target as Sprite);
            b.transform.colorTransform = outTransform;
            b.scaleX = b.scaleY = 1.0;
        }
        
        private function onStageKeyUp(event:KeyboardEvent):void
        {
            switch(String.fromCharCode(event.charCode)) {
                case '+':
                case '=':
                    map.zoomIn();
                    return;
                case '_':
                case '-':
                    map.zoomOut();                    
                    return;
            }
            switch(event.keyCode) {
                 case Keyboard.LEFT:
                    map.panLeft();
                    return;
                 case Keyboard.RIGHT:
                    map.panRight();
                    return;
                 case Keyboard.UP:
                    map.panUp();
                    return;
                 case Keyboard.DOWN:
                    map.panDown();
                    return;
             }
        }
        
        private function onStageResize(event:Event):void
        {
            var w:Number = map.getWidth();
            var h:Number = map.getHeight();
            
            leftButton.x = 25;
            rightButton.x = w - 25;
            upButton.x = w/2;
            downButton.x = w/2;
            leftButton.y = h/2;
            rightButton.y = h/2;
            upButton.y = 25;
            downButton.y = h - 25;

            outButton.x = 25;
            inButton.x = 50;
            outButton.y = 25;            
            inButton.y = 25;
            
            fullScreenButton.x = w - 25;
            fullScreenButton.y = 25;
        }

    	public function onFullScreenEvent(event:Event):void
    	{
            onStageResize(null);
    	}

        
    }
}


import flash.display.Sprite;
import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.Shape;

class FullScreenButton extends Sprite
{
	// because StageDisplayState and FullScreenEvent seem to be missing from my
	// build of Flex Builder:
	public static const FULL_SCREEN:String = "fullScreen";
	public static const NORMAL:String = "normal";
	
	private var outIcon:Shape = new Shape();
	private var inIcon:Shape = new Shape();
	
	public function FullScreenButton()
	{
        // draw out arrows
        outIcon.graphics.lineStyle(1, 0x000000, 1.0, true, "normal", CapsStyle.NONE, JointStyle.BEVEL);
        outIcon.graphics.moveTo(-2,-5);
        outIcon.graphics.lineTo(-6,-6);
        outIcon.graphics.lineTo(-5,-2);

        outIcon.graphics.moveTo(1,-5);
        outIcon.graphics.lineTo(5,-6);
        outIcon.graphics.lineTo(4,-2);

        outIcon.graphics.moveTo(-2,4);
        outIcon.graphics.lineTo(-6,5);
        outIcon.graphics.lineTo(-5,1);

        outIcon.graphics.moveTo(1,4);
        outIcon.graphics.lineTo(5,5);
        outIcon.graphics.lineTo(4,1);
        addChild(outIcon);

        // draw out arrows
        inIcon.graphics.lineStyle(1, 0x000000, 1.0, true, "normal", CapsStyle.NONE, JointStyle.BEVEL);
        inIcon.graphics.moveTo(-3,-6);
        inIcon.graphics.lineTo(-2,-2);
        inIcon.graphics.lineTo(-6,-3);

        inIcon.graphics.moveTo(2,-6);
        inIcon.graphics.lineTo(1,-2);
        inIcon.graphics.lineTo(5,-3);

        inIcon.graphics.moveTo(-3,5);
        inIcon.graphics.lineTo(-2,1);
        inIcon.graphics.lineTo(-6,2);

        inIcon.graphics.moveTo(2,5);
        inIcon.graphics.lineTo(1,1);
        inIcon.graphics.lineTo(5,2);
        //addChild(inIcon);
	    
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	private function onAddedToStage(event:Event):void
	{
		stage.addEventListener(FULL_SCREEN, onFullScreenEvent);
		
		// create the context menu, remove the built-in items,
		// and add our custom items
		var fullScreenCM:ContextMenu = new ContextMenu();
		fullScreenCM.hideBuiltInItems();

		var fs:ContextMenuItem = new ContextMenuItem("Go Full Screen" );
		fs.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, goFullScreen);
		fullScreenCM.customItems.push(fs);

		var xfs:ContextMenuItem = new ContextMenuItem("Exit Full Screen");
		xfs.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, exitFullScreen);
		fullScreenCM.customItems.push(xfs);
		
		// finally, attach the context menu to the parent
		this.parent.contextMenu = fullScreenCM;
	}
	
	public function toggleFullScreen(event:Event=null):void
	{
		if (stage.displayState == FULL_SCREEN) {
			exitFullScreen();
		}
		else {
			goFullScreen();
		}
	}
	
 	// functions to enter and leave full screen mode
	public function goFullScreen(event:Event=null):void
	{
		try {
			stage.displayState = FULL_SCREEN;
		}
		catch(err:Error) {
			trace("Dang fullScreen is not allowed here");
		}
	}
	public function exitFullScreen(event:Event=null):void
	{
		try {
    		stage.displayState = NORMAL;
		}
		catch(err:Error) {
		    trace("Problem setting displayState to normal, sorry");
		}
	}
	
	// function to enable and disable the context menu items,
	// based on what mode we are in.
	public function onFullScreenEvent(event:Event):void
	{
	   	if (stage.displayState == FULL_SCREEN)
	   	{
	   	    if (contains(outIcon)) {
	   	        removeChild(outIcon);
	   	    }
	   	    if (!contains(inIcon)) {
	   	        addChild(inIcon);
	   	    }
	    	this.parent.contextMenu.customItems[0].enabled = false;
	    	this.parent.contextMenu.customItems[1].enabled = true;
		}
	   	else
	   	{
	   	    if (!contains(outIcon)) {
	   	        addChild(outIcon);
	   	    }
	   	    if (contains(inIcon)) {
	   	        removeChild(inIcon);
	   	    }
	    	this.parent.contextMenu.customItems[0].enabled = true;
	    	this.parent.contextMenu.customItems[1].enabled = false;
	   	}
	}	
}
