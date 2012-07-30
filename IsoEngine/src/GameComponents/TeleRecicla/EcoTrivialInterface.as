package GameComponents.TeleRecicla
{
	import GameComponents.GameComponent;
	import GameComponents.Quiz.QuizController;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import utils.GenericEvent;
	import utils.MovieClipLabels;
	

	public class EcoTrivialInterface extends GameComponent
	{
		override public function OnStart():void
		{
			MovieClipLabels.AddFrameScripts(FRAME_SCRIPTS, TheVisualObject);			

			GotoIntro(null);
		}
		
		private function CreateQuizController() : QuizController
		{
			var ret : QuizController = TheGameModel.CreateSceneObjectFromMovieClip("mcQuestion", "QuizController") as QuizController;
			ret.TheAssetObject.TheRender2DComponent.ScreenPos = new Point(-390, -208);
			ret.addEventListener("GameEnd", OnGameEnd, false, 0, true);
			
			return ret;
		}
		
		private function OnGameEnd(event:GenericEvent):void
		{
			if (event.Data.Success)
			{
				GotoFinExito(null);
			}
			else
			{
				if (mQuizController.NumSuccess == 0)
					GotoFinFracaso(null);
				else
					GotoFin(null);
			}
		}
				
		//
		// PANTALLA: INTRO
		//		
		private function OnIntroEndFrame():void
		{
			TheVisualObject.stop();
			
			TheVisualObject.btJugar.addEventListener(MouseEvent.CLICK, OnJugarClick, false, 0, true);
			TheVisualObject.btInstrucciones.addEventListener(MouseEvent.CLICK, GotoInstrucciones, false, 0, true);
		}
		
		public function GotoIntro(event:Event):void
		{
			TheVisualObject.gotoAndPlay("Intro");
		}
		
		private function OnJugarClick(event:MouseEvent):void
		{
			mQuizController = CreateQuizController();			
			mQuizController.addEventListener("ControllerReady", OnQuizControllerReady, false, 0, true);
			
			if (TheGameModel.TheIsoEngine.GameDef.F2FCommunicate != null)
				TheGameModel.TheIsoEngine.GameDef.F2FCommunicate.RequestStart();
		}
		
		private function OnQuizControllerReady(event:Event):void
		{
			mQuizController.StartGame();
			TheVisualObject.visible = false;
		}
		
		//
		// PANTALLA: FIN FRACASO
		//
		private function OnFinFracasoEndFrame():void
		{
			OnFin(false);
		}
		
		public function GotoFinFracaso(event:Event):void
		{
			TheVisualObject.visible = true;
			TheVisualObject.gotoAndPlay("FinFracaso");
		}
		
		//
		// PANTALLA: FIN
		//
		private function OnFinEndFrame():void
		{
			OnFin(false);
		}
		
		public function GotoFin(event:Event):void
		{
			TheVisualObject.visible = true;
			TheVisualObject.gotoAndPlay("Fin");
		}
		
		//
		// PANTALLA: FIN EXITO
		//
		private function OnFinExitoEndFrame():void
		{
			OnFin(true);
		}

		public function GotoFinExito(event:Event):void
		{
			TheVisualObject.visible = true;
			TheVisualObject.gotoAndPlay("FinExito");
		}
		
		//
		// El fin común para todas las pantallas
		//
		private function OnFin(success:Boolean):void
		{
			TheVisualObject.stop();
			TheVisualObject.btContinuar.addEventListener(MouseEvent.CLICK, GotoIntro, false, 0, true);

			if (TheGameModel.TheIsoEngine.GameDef.F2FCommunicate)
				TheGameModel.TheIsoEngine.GameDef.F2FCommunicate.SaveScoreToServer(mQuizController.GetFinalScore(), success);
						
			TheVisualObject.ctPuntos.text = mQuizController.GetFinalScore().toString();
						
			TheGameModel.DeleteSceneObject(mQuizController.TheSceneObject);
			mQuizController = null;
		}
		
		//
		// PANTALLA: INSTRUCCIONES
		//
		private function OnInstruccionesEndFrame():void
		{
			TheVisualObject.stop();
			TheVisualObject.btSalir.addEventListener(MouseEvent.CLICK, GotoIntro);
		} 
		
		public function GotoInstrucciones(event:Event):void
		{
			TheVisualObject.gotoAndPlay("Instrucciones");
		}


		private var mQuizController : QuizController;
				
		private const FRAME_SCRIPTS : Array = [ {label: "IntroEnd", func: OnIntroEndFrame},
												{label: "FinEnd", func: OnFinEndFrame},
												{label: "FinFracasoEnd", func: OnFinFracasoEndFrame},
												{label: "FinExitoEnd", func: OnFinExitoEndFrame},
												{label: "InstruccionesEnd", func: OnInstruccionesEndFrame}
											  ]	
	}
}