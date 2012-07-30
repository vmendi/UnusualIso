package GameComponents.MmoGirl
{
	import GameComponents.GameComponent;
	
	/**
	 * Componente para emular el comportamiento de una puerta. 
	 */
	public final class CityChicaBolera extends GameComponent
	{
		//public var ToggleOnInteraction : Boolean = true;
		
		override public function OnStart():void
		{
			TheVisualObject.gotoAndStop("stop");
			mCharacterBehavior = TheGameModel.FindGameComponentByShortName("CharacterBehavior") as CharacterBehavior;
		}
		
		override public function OnCharacterInteraction():void
		{
			if (!mCharacterBehavior.EntradaBolera)
			{
				TheVisualObject.gotoAndStop("Bienvenida");
			}
		}
		
		private var mCharacterBehavior : CharacterBehavior;
		
	}
}