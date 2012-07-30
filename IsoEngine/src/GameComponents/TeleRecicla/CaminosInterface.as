package GameComponents.TeleRecicla
{
	import GameComponents.GameComponent;

	import flash.events.Event;
	import flash.events.MouseEvent;

	import utils.MovieClipLabels;

	public class CaminosInterface extends GameComponent
	{
		override public function OnStart():void
		{
			MovieClipLabels.AddFrameScripts(FRAME_SCRIPTS, TheVisualObject);

			GotoIntro(null);
		}

		override public function OnStop():void
		{
			if (mCaminosGame != null)
				TheGameModel.DeleteSceneObject(mCaminosGame.TheSceneObject);
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
			TheVisualObject.visible = false;
			mCaminosGame = TheGameModel.CreateSceneObjectFromMovieClip("mcStage", "CaminosGame") as CaminosGame;
			
			if (TheGameModel.TheIsoEngine.GameDef.F2FCommunicate != null)
				TheGameModel.TheIsoEngine.GameDef.F2FCommunicate.RequestStart();
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

		private function OnFin(success:Boolean):void
		{
			TheVisualObject.stop();
			TheVisualObject.btContinuar.addEventListener(MouseEvent.CLICK, GotoIntro, false, 0, true);

			if (TheGameModel.TheIsoEngine.GameDef.F2FCommunicate)
				TheGameModel.TheIsoEngine.GameDef.F2FCommunicate.SaveScoreToServer(mCaminosGame.GetFinalScore(), success);

			TheVisualObject.ctPuntos.text = mCaminosGame.GetFinalScore().toString();
			TheGameModel.DeleteSceneObject(mCaminosGame.TheSceneObject);
			mCaminosGame = null;
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



		private var mCaminosGame : CaminosGame;

		private const FRAME_SCRIPTS : Array = [ {label: "IntroEnd", func: OnIntroEndFrame},
												{label: "FinEnd", func: OnFinEndFrame},
												{label: "FinExitoEnd", func: OnFinExitoEndFrame},
												{label: "InstruccionesEnd", func: OnInstruccionesEndFrame}
											  ]

	}
}