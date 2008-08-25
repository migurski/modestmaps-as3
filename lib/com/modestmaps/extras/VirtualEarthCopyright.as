package com.modestmaps.extras
{
	import com.modestmaps.Map;
	import com.modestmaps.events.MapEvent;
	
	import flash.display.Bitmap;
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextFormat;

	public class VirtualEarthCopyright extends MapCopyright
	{
		// required by MS to use Flash to show tiles
	    [Embed(source='ve_logo.png')]
	    public var VirtualEarthLogo:Class;	
		
		public var veLogo:Bitmap;
		
		public var offsetX:Number = 10;
		public var offsetY:Number = 10;
		
		public function VirtualEarthCopyright(map:Map, offsetX:Number=undefined, offsetY:Number=undefined):void
		{	
			super(map);
			
			if (offsetX) {
				this.offsetX = offsetX;
			}
			if (offsetY) {
				this.offsetY = offsetY;
			}
			
			copyrightField.embedFonts = true;
			copyrightField.antiAliasType = AntiAliasType.ADVANCED;
			copyrightField.defaultTextFormat = new TextFormat("Helvetica", 10, 0x202020);
			copyrightField.wordWrap = false;
			copyrightField.selectable = false;
			copyrightField.htmlText = "Copyright goes here...";
			copyrightField.width = copyrightField.textWidth + 4;
			copyrightField.height = copyrightField.textHeight + 4;		
			copyrightField.x = map.getWidth() - this.offsetX - copyrightField.width;
			copyrightField.y = map.getHeight() - this.offsetY - copyrightField.height;
			copyrightField.filters = [new GlowFilter(0xffffff,0.5,4,4,4)];
			
			veLogo = new VirtualEarthLogo();
			addChild(veLogo);
			
			onMapResized(null);
		}
	
		override protected function onMapResized(event:MapEvent):void
		{
			copyrightField.x = map.getWidth() - this.offsetX - copyrightField.width;
			copyrightField.y = map.getHeight() - this.offsetY - copyrightField.height;
			veLogo.x = map.getWidth() - veLogo.width - 10;
			veLogo.y = copyrightField.y - veLogo.height - 10;
		}		
	}
}

