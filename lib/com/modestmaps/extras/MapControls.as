package com.modestmaps.extras
{
    import flash.display.Sprite;
    import flash.events.Event;
    import com.modestmaps.Map;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;
    import flash.events.MouseEvent;
    import flash.geom.ColorTransform;

    public class MapControls extends Sprite
    {
        public var leftButton:Sprite = new Sprite();
        public var rightButton:Sprite = new Sprite();
        public var upButton:Sprite = new Sprite();
        public var downButton:Sprite = new Sprite();

        public var inButton:Sprite = new Sprite();
        public var outButton:Sprite = new Sprite();

        private var map:Map;
        private var keyboard:Boolean;

        public function MapControls(map:Map, keyboard:Boolean=true)
        {
            this.map = map;
            this.keyboard = keyboard;
            
            var buttons:Sprite = new Sprite();
            addChild(buttons);
            
            var onButtonMouseOver:Function = function(event:MouseEvent):void {
                var b:Sprite = (event.target as Sprite);
                b.transform.colorTransform = new ColorTransform();
                b.scaleX = b.scaleY = 1.1;
            };
            var onButtonMouseOut:Function = function (event:MouseEvent):void {
                var b:Sprite = (event.target as Sprite);
                b.transform.colorTransform = new ColorTransform(0.9,0.9,0.8);
                b.scaleX = b.scaleY = 1.0;
            };
            
            var actions:Array = [ map.panLeft, map.panRight, map.panUp, map.panDown, map.zoomIn, map.zoomOut ];

            for each (var button:Sprite in [leftButton, rightButton, upButton, downButton, inButton, outButton]) {
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
                button.transform.colorTransform = new ColorTransform(0.9,0.9,0.8);
                button.addEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver);
                button.addEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut);
                buttons.addChild(button);                
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
        
        private function onAddedToStage(event:Event):void
        {
            if (keyboard) stage.addEventListener(KeyboardEvent.KEY_UP, onStageKeyUp);
            stage.addEventListener(Event.RESIZE, onStageResize);    
            onStageResize(null);
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
        }
        
    }
}