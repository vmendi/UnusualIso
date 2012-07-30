package GameComponents.MmoGirl
{
	import Model.IsoBounds;
	import GameComponents.GameComponent;
	
	/**
	 * Componente para emular el comportamiento de una puerta. 
	 */
	public final class HallPuertaAscensor extends GameComponent
	{
		public var ToggleOnInteraction : Boolean = true;
		
		override public function OnStart():void
		{
			TheVisualObject.mcDoor.gotoAndStop("stop");
			var newWalkable : Boolean = false;
			var bounds : IsoBounds = TheIsoComponent.Bounds;
			TheGameModel.TheAStartSpace.SetWalkable(bounds, newWalkable);
			TheIsoComponent.Walkable = newWalkable;
		}
		
		override public function OnCharacterInteraction():void
		{
			if (ToggleOnInteraction)
				Toggle();
		}
		
		public function Toggle() : Boolean
		{
			var newWalkable : Boolean = !TheIsoComponent.Walkable;
			var bounds : IsoBounds = TheIsoComponent.Bounds;
			
			TheGameModel.TheAStartSpace.SetWalkable(bounds, newWalkable);
			
			if (newWalkable)
				TheVisualObject.mcDoor.gotoAndPlay("open");
			else
				TheVisualObject.mcDoor.gotoAndPlay("stop");
			
			TheIsoComponent.Walkable = newWalkable;
			
			return newWalkable;	
		}
	}
}