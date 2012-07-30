package GameComponents
{
	/**
	 * Componente de prueba, se puede borrar.
	 */
	public final class TestGameComponent extends GameComponent
	{
		public var UnaVariable : Boolean;
		public var OtraVariable : int;
		
		public var TheNumber : Number = 1232.12321;
		
		public function get TheNumberStepSize() : Number { return 0.1; }
		public function get TheNumberMaximum() : Number { return 2000; }
		public function get TheNumberMinimum() : Number { return 0; }
		
		public function get UnaPropiedad() : String { return mUnaPropiedad; }
		public function set UnaPropiedad(val : String) : void { mUnaPropiedad = val; }
		
		private var mUnaPropiedad : String = "";
	}
}