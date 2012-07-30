package PathFinding
{
	import de.polygonal.ds.IPrioritizable;
	
	/**
	 * Nodo de busqueda del A estrella.
	 */
	public class AStarNode extends IntPoint implements IPrioritizable
	{
		public var g:Number = 0;
		public var h:Number = 0;

		public var parent:AStarNode;
				
		public function AStarNode(x:int, y:int)
		{
			super(x,y);
		}
				
		// Coste total al destino
		public function get f() : Number
		{
			return g+h;
		}
				
		public function get priority() : int { return -(int)(g+h); }
		public function set priority(val : int):void { throw "WTF?"; }
	}
}