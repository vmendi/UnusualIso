package GameComponents.Insignia
{
	import GameComponents.GameComponent;
	
	import Model.AssetObject;
	import Model.SceneObject;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;	

	/**
	 * Control del tutorial
	 */	 
	public final class OITutorialMain extends GameComponent
	{
		override public function OnStart() : void
		{
			mPaused = false;
			
			TheVisualObject.visible = false;
		}
		
		override public function OnPause():void
		{
			mPaused = true;
		}
		
		override public function OnResume():void
		{
			mPaused = false;
		}
		
		override public function OnStop():void 
		{
			TheVisualObject.visible = true;
			
			Stop();
		}

		//		
		// Tutorial
		//
		
		public function StartTutorial() : void
		{
			// Creación del controlador
			var gestureAssetObj : AssetObject = TheGameModel.TheAssetLibrary.FindAssetObjectByMovieClipName("mcGizmo");
			var gestureSceneObj : SceneObject = TheGameModel.CreateSceneObject(gestureAssetObj);
			
			mController = gestureSceneObj.TheAssetObject.FindGameComponentByShortName("OIGestureController") as OIGestureController;
			mController.addEventListener("ShotDoneOK",OnShotOK);
			mController.addEventListener("ShotDoneKO",OnShotKO);
						
			// Referencia al interface
			mInterface = TheGameModel.FindGameComponentByShortName("OIInterface") as OIInterface;
			
			// Referencia a la única chica y trail que hay en el juego
			mGirl = TheGameModel.FindGameComponentByShortName("OIChica") as OIChica;
			mTrail = TheGameModel.FindGameComponentByShortName("OITrail") as OITrail;
						
			// Nuestros clips hijos
			TheVisualObject.btNext.addEventListener(MouseEvent.CLICK, OnNextClickHandler);
			mClipInstrucciones = TheVisualObject.mcInstrucciones;
			mClipResultado = TheVisualObject.mcResultado;
			
			SubscribeToGirl();
			
			// Nos hacemos visibles nosotros y a la chica
			TheVisualObject.visible = true;
			mGirl.TheVisualObject.visible = true;

			mTrail.SetRenderingEnabled(true);

			mTutorialStep = 0;
			PlayTutorial();
			
			// Creamos el botón de salir
			mExitButton = TheGameModel.TheAssetLibrary.CreateMovieClip("mcBotonSalir");
			mExitButton.addEventListener(MouseEvent.CLICK, OnExitButtonClick, false, 0, true);
			TheGameModel.TheRender2DCamera.addChild(mExitButton);
			mExitButton.x = 370;
			mExitButton.y = 208;
		}
		
		private function OnExitButtonClick(event:Event):void
		{
			TheVisualObject.visible = false;
			mGirl.TheVisualObject.visible = false;
			
			mTrail.SetRenderingEnabled(false);
			 
			mInterface.GotoPerfil(null);
			
			Stop();
		}
		
		private function EndTutorial() : void
		{
			TheVisualObject.visible = false;
			mGirl.TheVisualObject.visible = false;
			
			mTrail.SetRenderingEnabled(false);
			
			// Mostramos la pantalla de fin de tutorial, o lo que quiera poner el interface... 
			mInterface.GotoEntrenamientoEnd();
			
			Stop();
		}
		
		private function Stop() : void
		{
			if (mGirl)
			{
				UnsubscribeToGirl();
				mGirl = null;
			}
			
			if (mExitButton)
			{
				TheGameModel.TheRender2DCamera.removeChild(mExitButton);
				mExitButton = null;
			}
			
			mTrail = null;
			mClipInstrucciones = null;
			mClipResultado = null;
			mInterface = null;
			
			// Destruimos nuestro GestureController
			if (mController != null)
			{
				TheGameModel.DeleteSceneObject(mController.TheSceneObject);
				mController = null;
			}
		}
		
		private function SubscribeToGirl() : void
		{
			mGirl.addEventListener("ResultAnimEnd", ResultAnimEnd, false, 0, true);
			mGirl.addEventListener("AnimHit", AnimHit, false, 0, true);
		}
		
		private function UnsubscribeToGirl() : void
		{
			mGirl.removeEventListener("ResultAnimEnd", ResultAnimEnd);
			mGirl.removeEventListener("AnimHit", AnimHit);
		}
		
		private function PlayTutorial() : void
		{
			if (mPaused)
				throw "No se debería llamar aquí - Páusate!";
			
			var newX : Number;
			var newY : Number;
			var startPosX : Number;
			var startPosY : Number;
			
			switch (mTutorialStep)
			{
				case 0:
					mClipInstrucciones.gotoAndStop("INIT_SHOT");
					mTutorialStep++
					TheVisualObject.btNext.visible = true;
				break;
				case 1:
					TheVisualObject.btNext.visible = false;
					mClipInstrucciones.gotoAndStop("FOREHAND_ONLYMOVE");
					mGirl.PlayVideo("Forehand");
					mController.NewShot(["FOREHAND"], false, false, false, null, null);
				break;
				case 2:
					mClipInstrucciones.gotoAndStop("BACKHAND_ONLYMOVE");
					mGirl.PlayVideo("Backhand");
					mController.NewShot(["BACKHAND"], false, false, false, null, null);
				break;
				case 3:
					mClipInstrucciones.gotoAndStop("LOB_ONLYMOVE");
					mGirl.PlayVideo("Lob");
					mController.NewShot(["LOB"], false, false, false, null, null);
				break;
				case 4:
					mClipInstrucciones.gotoAndStop("SMASH_ONLYMOVE");
					mGirl.PlayVideo("Smash");
					mController.NewShot(["SMASH"], false, false, false, null, null);
				break;
				case 5:
					mClipInstrucciones.gotoAndStop("INIT_HELP");
					mTutorialStep++
					TheVisualObject.btNext.visible = true;
				break;
				case 6:
					mClipResultado.visible = false;
					TheVisualObject.btNext.visible = false;
					mClipInstrucciones.gotoAndStop("BALL_HELP");
					mGirl.PlayVideo("SoftServe");
				break;
				case 7:
					mTutorialStep--;
					newX = 275;
					newY = -50;
					startPosX = mGirl.TheVisualObject.x + mGirl.TheVisualObject.mcBall.x;
					startPosY = mGirl.TheVisualObject.y + mGirl.TheVisualObject.mcBall.y;
					mController.NewShot(["FOREHAND"], true, true, true, new Point(newX, newY), new Point(startPosX,startPosY));
				break;
				case 8:
					mGirl.PlayVideo("SoftServe");
				break;
				case 9:
					mTutorialStep--;
					newX = -275;
					newY = -50;
					startPosX = mGirl.TheVisualObject.x + mGirl.TheVisualObject.mcBall.x;
					startPosY = mGirl.TheVisualObject.y + mGirl.TheVisualObject.mcBall.y;
					mController.NewShot(["BACKHAND"], true, true, true, new Point(newX, newY), new Point(startPosX,startPosY));				
				break;
				case 10:
					mGirl.PlayVideo("SoftServe");
				break;
				case 11:
					mTutorialStep--;
					newX = 0;
					newY = -175;
					startPosX = mGirl.TheVisualObject.x + mGirl.TheVisualObject.mcBall.x;
					startPosY = mGirl.TheVisualObject.y + mGirl.TheVisualObject.mcBall.y;
					mController.NewShot(["SMASH"], true, true, true, new Point(newX, newY), new Point(startPosX,startPosY));	
				break;
				case 12:
					mGirl.PlayVideo("SoftServe");
				break;
				case 13:
					mTutorialStep--;
					newX = 0;
					newY = 100;
					startPosX = mGirl.TheVisualObject.x + mGirl.TheVisualObject.mcBall.x;
					startPosY = mGirl.TheVisualObject.y + mGirl.TheVisualObject.mcBall.y;
					mController.NewShot(["LOB"], true, true, true, new Point(newX, newY), new Point(startPosX,startPosY));	
				break;
				case 14:
					mClipInstrucciones.gotoAndStop("INIT_RETO");
					mTutorialStep = 50;
					TheVisualObject.btNext.visible = true;
				break;				
				case 50:
					EndTutorial();
				break;
			}
		}
		
		// Funciones que llamará el controller
		
		private function OnShotOK(event:Event) : void
		{
			mClipResultado.gotoAndPlay("OK");
			mGirl.PlayVideo("ShotOK");
			
			if (mTutorialStep != 50)
			{
				if (mTutorialStep >= 6)
					mTutorialStep+=2;
				else
					mTutorialStep++;
			}
		}

		private function OnShotKO(event:Event) : void
		{
			mClipResultado.gotoAndPlay("KO");
			mGirl.PlayVideo("ShotKO");
		}
						
		private function AnimHit(event:Event) : void
		{
			mTutorialStep++;
			PlayTutorial();
		}
		
		private function ResultAnimEnd(event:Event) : void
		{
			PlayTutorial();
		}
		
		private function OnNextClickHandler(e:MouseEvent) : void
		{
			PlayTutorial();
		}
		
		// Variables
		
		private var mInterface : OIInterface;
		private var mGirl : OIChica;
		private var mTrail : OITrail;
		private var mController : OIGestureController;
		private var mClipInstrucciones : MovieClip;
		private var mClipResultado : MovieClip;
		private var mTutorialStep : Number;
		
		private var mPaused : Boolean;
		
		private var mExitButton : MovieClip;
	}
	
}