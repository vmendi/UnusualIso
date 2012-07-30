package PathFinding
{
	/**
	 * Punto 2D de coordenadas enteras.
	 */
	public class IntPoint
	{
		public var x:int;
		public var y:int;
		
		function IntPoint(x:int=0, y:int=0)
		{
			this.x = x;
			this.y = y;
		}	
		
		public function Add(p:IntPoint):void
		{
			x += p.x;
			y += p.y;
		}
		
		public function AddNew(p:IntPoint):IntPoint 
		{
			return new IntPoint(x+p.x, y+p.y);
		}
		
		public function IsEqual(other:IntPoint):Boolean
		{
			return (x == other.x) && (y == other.y);
		}

		public function toString():String
		{
			return "IntPoint("+x+", "+y+")";
		}
				
	}
}