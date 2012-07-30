package GameComponents.MmoGirl
{
	import GameComponents.GameComponent;
	
	/**
	 * Componente para emular el comportamiento de una puerta. 
	 */
	public final class PuestoHelados extends GameComponent
	{
		public var ToggleOnInteraction : Boolean = true;
		
		override public function OnStart():void
		{
			mCharacterBehavior = TheGameModel.FindGameComponentByShortName("CharacterBehavior") as CharacterBehavior;
		}
		
		override public function OnCharacterInteraction():void
		{
			mCharacterBehavior.OnCompraHelado();
		}
		
		private var mCharacterBehavior : CharacterBehavior;
		
	}
}