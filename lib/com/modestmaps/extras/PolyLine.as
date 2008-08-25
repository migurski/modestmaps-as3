/**
 *  PolyLine class. Polylines can be added using map.putPolyLine()
 * 
 *  @author simonoliver
 */
 package com.modestmaps.extras
{
	public class PolyLine
	{
		
		public var id:String;
		public var locationsArray:Array;
		public var lineThickness:Number;
		public var lineColor:Number;
		public var lineAlpha:Number;
		public var pixelHinting:Boolean;
	    public var scaleMode:String;
	    public var caps:String;
	    public var joints:String;
	    public var miterLimit:Number;
	        
		public function PolyLine(id:String,locationsArray:Array,lineThickness:Number=3,lineColor:Number=0xFF0000,lineAlpha:Number=1,pixelHinting:Boolean=false,scaleMode:String="normal",caps:String=null,joints:String=null,miterLimit:Number=3)
		{
			this.id=id;
			this.locationsArray=locationsArray;
			this.lineThickness=lineThickness;
			this.lineColor=lineColor;
			this.lineAlpha=lineAlpha;
			this.pixelHinting=pixelHinting;
			this.scaleMode=scaleMode;
			this.caps=caps;
			this.joints=joints;
			this.miterLimit=miterLimit;
		}
	}
}