package GameComponents.MmoGirl
{
	import GameComponents.GameComponent;
	import utils.Point3;
	
	/**
	 * Componente para teleportar de un nivel a otro
	 */
	public final class MmoTeleport extends GameComponent
	{
		public var Where : String = "MmoGirls02City";
		public var NextStartPointX : Number = 0;
		public var NextStartPointY : Number = 0;
		public var NextStartPointZ : Number = 0;
		public var NextOrientation : String = "SE";
		
		override public function OnStart():void
		{
			
		}
		
		override public function OnCharacterInteraction():void
		{
			TheGameModel.TheIsoEngine.GameDef.NextStartWorldPos = new Point3(NextStartPointX, NextStartPointY, NextStartPointZ);
			TheGameModel.TheIsoEngine.GameDef.NextOrientation = NextOrientation;
			TheGameModel.TheIsoEngine.Load("Maps/"+Where+".xml");		
		}
		 	
	}
}