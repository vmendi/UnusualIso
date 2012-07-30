package GameComponents.MmoGirl
{
	import GameComponents.GameComponent;
	import utils.Point3;
	
	/**
	 * Componente para emular el comportamiento de una puerta. 
	 */
	public final class ParquePuestoLimonada extends GameComponent
	{
		
		override public function OnStart():void
		{
			//mCharacterBehavior = TheGameModel.FindGameComponentByShortName("CharacterNonInteractive") as CharacterNonInteractive;
			mListaCharacters = TheGameModel.FindAllGameComponentsByShortName("CharacterNonInteractive");
			
		}
		
		override public function OnCharacterInteraction():void
		{
			var mPoint3 : Point3 = new Point3(2.8062653117622363, 0, 5.775839587037192);
			for (var i:Number=0; i < mListaCharacters.length; i++)
			{
				mListaCharacters[i].GoPoint(mPoint3);
			}
		}
		
		private var mListaCharacters : Array;
		
	}
}