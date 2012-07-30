package GameComponents.Insignia
{
	import GameComponents.GameComponent;
	import GameComponents.Quiz.QuizController;
	
	import Model.AssetObject;
	import Model.SceneObject;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLVariables;
	
	import utils.GenericEvent;
	import utils.MovieClipLabels;
	import utils.Server;
	
	

	public class OIQuizInterface extends GameComponent
	{
		override public function OnStart():void
		{
			MovieClipLabels.AddFrameScripts(FRAME_SCRIPTS, TheVisualObject);
			
			GotoIntro(null);
		}
				
		override public function OnStop():void
		{
		}
		
		private function CreateQuizController() : QuizController
		{
			var gestureAssetObj : AssetObject = TheGameModel.TheAssetLibrary.FindAssetObjectByMovieClipName("mcQuestion");
			var gestureSceneObj : SceneObject = TheGameModel.CreateSceneObject(gestureAssetObj);
						
			var ret : QuizController = gestureSceneObj.TheAssetObject.FindGameComponentByShortName("QuizController") as QuizController;
			ret.TheAssetObject.TheRender2DComponent.ScreenPos = new Point(-365, -209);
			ret.addEventListener("GameEnd", OnGameEnd, false, 0, true);
			
			return ret;
		}
		
		private function OnGameEnd(event:GenericEvent):void
		{
			if (event.Data.Success)
				GotoFinExito(null);
			else
				GotoFinFracaso(null);
		}
				
		//
		// PANTALLA: INTRO
		//		
		private function OnIntroEndFrame():void
		{
			TheVisualObject.stop();
			
			TheVisualObject.btJugar.addEventListener(MouseEvent.CLICK, OnJugarClick, false, 0, true);
			TheVisualObject.btSalir.addEventListener(MouseEvent.CLICK, OnSalirClick, false, 0, true);
		}
		
		public function GotoIntro(event:Event):void
		{
			TheVisualObject.gotoAndPlay("Intro");
		}
		
		
		private function OnJugarClick(event:MouseEvent):void
		{
			mQuizController = CreateQuizController();			
			mQuizController.addEventListener("ControllerReady", OnQuizControllerReady, false, 0, true);
			
			// Creamos el botón de salir
			mExitButton = TheGameModel.TheAssetLibrary.CreateMovieClip("mcBotonSalir");
			mExitButton.addEventListener(MouseEvent.CLICK, OnSalirClick, false, 0, true);
			TheGameModel.TheRender2DCamera.addChild(mExitButton);
			mExitButton.x = 370;
			mExitButton.y = 208;
		}
				
		private function OnQuizControllerReady(event:Event):void
		{
			mQuizController.StartGame();			
			TheVisualObject.visible = false;
		}
		
		private function OnSalirClick(event:MouseEvent):void
		{
			TheGameModel.TheIsoEngine.Load("Maps/OpelInsignia/OIPruebas.xml");
		}
		
		//
		// PANTALLA: FIN
		//
		private function OnFinEndFrame():void
		{
			TheVisualObject.stop();
			TheVisualObject.btJugar.addEventListener(MouseEvent.CLICK, OnJugarClick, false, 0, true);			
			TheVisualObject.btSalir.addEventListener(MouseEvent.CLICK, OnSalirClick, false, 0, true);
			
			TheVisualObject.ctPuntos.text = mQuizController.GetFinalScore().toString();
			TheGameModel.DeleteSceneObject(mQuizController.TheSceneObject);
			mQuizController = null;
		}
		
		public function GotoFinFracaso(event:Event):void
		{
			TheVisualObject.visible = true;
			TheVisualObject.gotoAndPlay("Fin");
			
			SendScoreToServer(mQuizController.GetFinalScore());
		}


		//
		// PANTALLA: FIN EXITO
		//		
		private function OnFinExitoEndFrame():void
		{
			TheVisualObject.stop();
			TheVisualObject.btJugar.addEventListener(MouseEvent.CLICK, OnJugarClick, false, 0, true);
			TheVisualObject.btSalir.addEventListener(MouseEvent.CLICK, OnSalirClick, false, 0, true);
			
			TheVisualObject.ctPuntos.text = mQuizController.GetFinalScore().toString();			
			TheGameModel.DeleteSceneObject(mQuizController.TheSceneObject);
			mQuizController = null;			
		}
		
		public function GotoFinExito(event:Event):void
		{
			TheVisualObject.visible = true;
			TheVisualObject.gotoAndPlay("FinExito");
			
			SendScoreToServer(mQuizController.GetFinalScore());
		}
		

		private function SendScoreToServer(score:int):void
		{
			var vars : URLVariables = new URLVariables();

			vars.id_juego = 2;
			vars.puntos = score;

			mServer = CreateServer();
			mServer.addEventListener("RequestComplete", OnScoreSendComplete);
			mServer.Request(vars, "/private/services/newpoint.php");
		}

		private function OnScoreSendComplete(event:GenericEvent):void
		{
		}
		
		private function CreateServer() : Server
		{
			var server : Server = new Server("http://www.elfuturoesnuestrapista.com");
			server.addEventListener("RequestError", OnRequestError, false, 0, true);
			return server;
		}

		private function OnRequestError(event:Event):void
		{
			mServer = null;
		}


		private var mServer : Server;
		private var mQuizController : QuizController;
		private var mExitButton : MovieClip;
				
		private const FRAME_SCRIPTS : Array = [ {label: "IntroEnd", func: OnIntroEndFrame},
												{label: "FinEnd", func: OnFinEndFrame},
												{label: "FinExitoEnd", func: OnFinExitoEndFrame}
											  ]	
	}
}