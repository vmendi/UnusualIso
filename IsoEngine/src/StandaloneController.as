package
{
	import GameComponents.GameComponentEnumerator;
	
	import Model.GameModel;
	import Model.UpdateEvent;
	
	public class StandaloneController
	{
		public function StandaloneController(model : GameModel)
		{
			mModel = model;
			
			mGameCompEnumerator = new GameComponentEnumerator();

			// El modelo nos notifica de que ha transcurrido un frame para que nosotros decidamos qué hacer
			mModel.addEventListener("OnUpdate", OnUpdate, false, 0, true);
		}
		
		public function get TheGameModel() : GameModel { return mModel; }
		
		public function StartGame() : void
		{
			mModel.StartGame();
		}
		
		private function OnUpdate(event:UpdateEvent):void
		{
			//mModel.TheIsoCamera.MoveWithKeyboard(event.ElapsedTime, false);
			//mModel.TheRender2DCamera.MoveWithKeyboard(event.ElapsedTime, true);
		}

		
		private var mGameCompEnumerator : GameComponentEnumerator;
		private var mModel : GameModel;
	}
}