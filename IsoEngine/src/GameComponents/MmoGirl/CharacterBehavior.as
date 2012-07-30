package GameComponents.MmoGirl
{
	import Model.IsoBounds;
	import GameComponents.GameComponent;
	
	/**
	 * Componente que controla el comportamiento del personaje principal en un determinado nivel: las interacciones, etc. 
	 */
	public final class CharacterBehavior extends GameComponent
	{
		public var EntradaBolera : Boolean = false;
		
		
		override public function OnStart():void
		{
			
		}
		
		override public function OnCharacterInteraction():void
		{
			
		}
		
		public function OnCompraHelado():void
		{
			TheVisualObject.mcEmoticonos.gotoAndPlay("helado");
		}
		
		public function OnCompraGlobo():void
		{
			TheVisualObject.mcEmoticonos.gotoAndPlay("globo");
		}
		
		private var mEstado : String;
		
	}
}