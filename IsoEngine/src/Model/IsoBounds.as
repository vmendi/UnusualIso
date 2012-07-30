package Model
{
	import utils.Point3;
	
	/**
	 * Objeto auxiliar, representa un cuadrado 2D compuesto según sus 4 coordenadas.
	 */
	public final class IsoBounds
	{
		public function IsoBounds()
		{
		}
		
		/** 
		 * Transforma este cuadrado en la unión del él mismo y el "other". El resultado será un IsoBound 
		 * que envuelve a ambos IsoBounds. 
		 */
		public function Join(other : IsoBounds) : void
		{
			if (other.Left < Left)
				Left = other.Left;
			if (other.Right > Right)
				Right = other.Right;
			if (other.Front > Front)
				Front = other.Front;
			if (other.Back < Back)
				Back = other.Back;
		} 
		
		public function get Width() : Number { return Right-Left; }
		public function get Height() : Number { return Front-Back; }
		
		public function get LeftBackCorner() : Point3 { return new Point3(Left, 0, Back); }

		public var Right : Number = 0;
		public var Left : Number = 0;
		public var Front : Number = 0;
		public var Back : Number = 0; 
	}
}