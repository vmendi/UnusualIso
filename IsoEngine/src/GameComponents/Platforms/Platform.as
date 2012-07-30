package GameComponents.Platforms
{
	import GameComponents.GameComponent;
	import Model.UpdateEvent;
	
	public final class Platform extends GameComponent
	{
		
		public var width : Number = 100;
		public var height : Number = 50;
		public var xMov : Number = 0;
		public var yMov : Number = 0;
		
		override public function OnStart():void
		{
			//mCharacterBehavior = TheGameModel.FindGameComponentByShortName("CharacterBehavior") as CharacterBehavior;
		}
		
		override public function OnUpdate(event:UpdateEvent):void
		{
			TheVisualObject.x += xMov;
			TheVisualObject.y += yMov;
		}
		
		public function get x() : Number
		{
			return TheVisualObject.x;
		}
		
		public function get y() : Number
		{
			return TheVisualObject.y;
		}
		
	}
}