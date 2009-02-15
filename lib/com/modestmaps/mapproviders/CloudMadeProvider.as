package com.modestmaps.mapproviders
{
	import com.modestmaps.core.Coordinate;
	
	public class CloudMadeProvider extends OpenStreetMapProvider
	{
		public var key:String;
		public var style:String;
		
		/** see http://developers.cloudmade.com/projects to get hold of an API key */
		public function CloudMadeProvider(key:String, style:String='1')
		{
			super();
			this.key = key;
			this.style = style;
		}
		
		override public function getTileUrls(coord:Coordinate):Array
		{
			var worldSize:int = Math.pow(2, coord.zoom);
			if (coord.row < 0 || coord.row >= worldSize) {
				return [];
			}
			coord = sourceCoordinate(coord);
			var server:String = [ 'a.', 'b.', 'c.', '' ][int(worldSize * coord.row + coord.column) % 4];
			var url:String = 'http://' + server + 'tile.cloudmade.com/' + [ key, style, tileWidth, coord.zoom, coord.column, coord.row ].join('/') + '.png'; 
			return [ url ];
		}
		
		override public function toString():String
		{
			return 'CLOUDMADE';
		}	
	}
}