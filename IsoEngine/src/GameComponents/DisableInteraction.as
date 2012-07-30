package GameComponents
{
	/**
	 * Componente para desactivar la interacción del ratón con el IsoObject al que pertenezca.
	 */
	public final class DisableInteraction extends GameComponent
	{
		override public function OnStart() : void
		{
			TheVisualObject.mouseEnabled = false;
			TheVisualObject.mouseChildren = false;
		}
		
		override public function OnStop() : void
		{
			TheVisualObject.mouseEnabled = true;
			TheVisualObject.mouseChildren = true;
		}		
	}
}