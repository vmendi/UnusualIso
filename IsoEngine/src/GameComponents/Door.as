package GameComponents
{
	import Model.IsoBounds;
	
	/**
	 * Componente para emular el comportamiento de una puerta. 
	 */
	public final class Door extends GameComponent
	{
		public var ToggleOnCharacterInteraction : Boolean = true;
		public var ToggleOnClickInteraction : Boolean = false;
		
		override public function OnCharacterInteraction():void
		{
			if (ToggleOnCharacterInteraction)
				Toggle();	
		}
		
		override public function OnClickInteraction() : void
		{
			if (ToggleOnClickInteraction)
				Toggle();	
		}
		
		public function Toggle() : Boolean
		{
			var newWalkable : Boolean = !TheIsoComponent.Walkable;
			var bounds : IsoBounds = TheIsoComponent.Bounds;
			
			TheGameModel.TheAStartSpace.SetWalkable(bounds, newWalkable);
			
			if (newWalkable)
				TheVisualObject.gotoAndStop("abierta");
			else
				TheVisualObject.gotoAndStop("cerrada");
			
			TheIsoComponent.Walkable = newWalkable;
			
			return newWalkable;	
		}
	}
}