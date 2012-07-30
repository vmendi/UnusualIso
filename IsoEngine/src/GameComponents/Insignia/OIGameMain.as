package GameComponents.Insignia
{
	import GameComponents.GameComponent;
	import GameComponents.Quiz.QuizScore;
	
	import Model.AssetObject;
	import Model.SceneObject;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import gs.TweenMax;
	
	import utils.GenericEvent;
	import utils.RandUtils;

	public class OIGameMain extends GameComponent
	{
		private const TOTAL_LIFES : int = 5;
		
		
		override public function OnStart():void
		{
			mPaused = false;	
		}
		
		override public function OnStop():void
		{
			Stop();
		}
		
		override public function OnPause():void
		{
			mPaused = true;
			TweenMax.pauseAll(true, true);
		}
		
		override public function OnResume():void
		{
			mPaused = false;
			TweenMax.resumeAll(true, true);
		}
		
		public function StartGame() : void
		{
			mTrail = TheGameModel.FindGameComponentByShortName("OITrail") as OITrail;
			mGirl = TheGameModel.FindGameComponentByShortName("OIChica") as OIChica;			
			mInterface = TheGameModel.FindGameComponentByShortName("OIInterface") as OIInterface;
			
			mScore = CreateMarcador();
			mScore.addEventListener("TimeEnd", OnTimeEnd, false, 0, true);
			
			mScore.SetNumLifes(mNumLifes);
			mScore.SetScore(mTotalScore);
						
			// Control de visibilidad
			TheVisualObject.visible = true;
			mGirl.TheVisualObject.visible = true;
			
			mTrail.SetRenderingEnabled(true);
					
			// Y nos subscribimos a las notificaciones de animación de la chica
			SubscribeToGirl();
			
			// Un sector por posible posición. De momento aceptamos una relación 1-1-1 entre Shot, Posición del Shot y Gesture.
			mSectors = [ { Position:"RightDock", AcceptsShotName:["FOREHAND"], GestureController:null, IsBusy:false},
					     { Position:"LeftDock", AcceptsShotName:["BACKHAND"], GestureController:null, IsBusy:false},
						 { Position:"TopDock", AcceptsShotName:["SMASH"], GestureController:null, IsBusy:false},
						 { Position:"BottomDock", AcceptsShotName:["LOB"], GestureController:null, IsBusy:false}];
			
			// Creamos los posibles controladores, uno por sector
			for (var c:int = 0; c < mSectors.length; c++)
			{			
				var theGesture : OIGestureController = CreateGestureController();
			
				mSectors[c].GestureController = theGesture;
				 
				theGesture.addEventListener("ShotDoneOK", OnShotOK, false, 0, true);
				theGesture.addEventListener("ShotDoneKO", OnShotKO, false, 0, true);
				theGesture.addEventListener("ResultAnimEnd", ResultAnimEnd, false, 0, true);
			}
			
			// Cada vez que nos llaman a empezar, aumentamos el nivel de dificultad.
			mDiffLevel++;
			
			GotoDificultyLevel(mDiffLevel);
			
			// Creamos el botón de salir
			mExitButton = TheGameModel.TheAssetLibrary.CreateMovieClip("mcBotonSalir");
			mExitButton.addEventListener(MouseEvent.CLICK, OnExitButtonClick, false, 0, true);
			TheGameModel.TheRender2DCamera.addChild(mExitButton);
			mExitButton.x = 370;
			mExitButton.y = 208;
		}
		
		private function OnExitButtonClick(event:Event):void
		{
			mTrail.SetRenderingEnabled(false);
			mInterface.GotoFinFracaso(null);
		
			Stop();
		}
		
		public function ResetGame(): void
		{
			mDiffLevel = -1;
			mTotalScore = 0;
			mNumLifes = TOTAL_LIFES;
		}
				
		private function CreateMarcador() : QuizScore
		{
			var gestureAssetObj : AssetObject = TheGameModel.TheAssetLibrary.FindAssetObjectByMovieClipName("mcMarcador");
			var gestureSceneObj : SceneObject = TheGameModel.CreateSceneObject(gestureAssetObj);
						
			return gestureSceneObj.TheAssetObject.FindGameComponentByShortName("QuizScore") as QuizScore;
		}
		
		private function CreateGestureController() : OIGestureController
		{
			var gestureAssetObj : AssetObject = TheGameModel.TheAssetLibrary.FindAssetObjectByMovieClipName("mcGizmo");
			var gestureSceneObj : SceneObject = TheGameModel.CreateSceneObject(gestureAssetObj);
			
			return gestureSceneObj.TheAssetObject.FindGameComponentByShortName("OIGestureController") as OIGestureController;
		}
				
		private function GotoDificultyLevel(level : int) : void
		{
			mDiffLevel =  level;
			
			mScore.TotalTime = DIFFICULTY_LEVELS[mDiffLevel].LevelTime;
			mScore.StartTimer();
			
			NextShot();
		}
		
		private function NextShot() : void
		{	
			var currLevel : Object = DIFFICULTY_LEVELS[mDiffLevel];
			
			mGirl.PlayVideo("Serve");

			TweenMax.delayedCall(currLevel.TimeBetweenShots/1000, NextShot);
		}
		
		private function OnTimeEnd(event:Event):void
		{
			mTrail.SetRenderingEnabled(false);
			
			// Hemos hecho todos los niveles?
			if (mDiffLevel+1 >= DIFFICULTY_LEVELS.length)
			{
				mInterface.GotoFinExito(null);
			}
			else
			{
				// Vamos a la pantalla intermedia, que nos volvera a llamar a StartGame
				mInterface.GotoEntreFases(null);
			}
			
			Stop();
		}

		
		private function OnAnimHit(event:Event) : void
		{
			var currLevel : Object = DIFFICULTY_LEVELS[mDiffLevel];
			
			var startX : Number = mGirl.TheVisualObject.x + mGirl.TheVisualObject.mcBall.x;
			var startY : Number = mGirl.TheVisualObject.y + mGirl.TheVisualObject.mcBall.y;
			
			var numFree : int = GetNumFreeSectors();
			var randSector : Number = numFree * Math.random();
			var idxToFreeSector : int = GetIdxToFreeSector(Math.floor(randSector));
			
			if (idxToFreeSector == -1)
			{
				trace("Todos los sectores ocupados");
			}
			else
			{
				mSectors[idxToFreeSector].IsBusy = true;
				
				var endPos : Point = GetCoordForSector(mSectors[idxToFreeSector]);

				var endX : Number = endPos.x;
				var endY : Number = endPos.y;
				
				var shots : Array = mSectors[idxToFreeSector].AcceptsShotName; 
				
				var theGesture : OIGestureController = mSectors[idxToFreeSector].GestureController;
				
				theGesture.Time = currLevel.FlyTime;
				theGesture.Tolerance = currLevel.Tolerance;
				theGesture.NewShot(shots, true, true, true, new Point(endX, endY), new Point(startX,startY));
			}
		}
		
		private function GetCoordForSector(sector:Object) : Point
		{
			var ret : Point = null;
			
			if (sector.Position == "LeftDock")
			{
				var varX : Number = utils.RandUtils.RandMinusPlus()*30;
				var varY : Number = utils.RandUtils.RandMinusPlus()*140;
				ret = new Point(-260 + varX, varY); 
			}
			else
			if (sector.Position == "RightDock")
			{
				varX = utils.RandUtils.RandMinusPlus()*30;
				varY = utils.RandUtils.RandMinusPlus()*140;
				ret = new Point(260 + varX, varY);
			}
			else
			if (sector.Position == "TopDock")
			{
				varX = utils.RandUtils.RandMinusPlus()*150;
				varY = utils.RandUtils.RandMinusPlus()*50;
				ret = new Point(varX, -130 + varY);
			}
			else
			if (sector.Position == "BottomDock")
			{
				varX = utils.RandUtils.RandMinusPlus()*150;
				varY = utils.RandUtils.RandMinusPlus()*50;
				ret = new Point(varX, 130+varY);
			}
			
			return ret;
		}
		
		private function GetIdxToFreeSector(freeSector:int):int
		{
			var ret:int = -1;
						
			for (var c:int = 0; c < mSectors.length; c++)
			{
				if (!mSectors[c].IsBusy)
				{
					ret++;
					if (freeSector == ret)
						break;
				}
			}
			
			return (c == mSectors.length)? -1 : c;
		}
		
		private function GetNumFreeSectors() : int
		{
			var ret:int = 0;
			
			for (var c:int = 0; c < mSectors.length; c++)
			{
				if (!mSectors[c].IsBusy)
					ret++;
			}
			
			return ret;
		}

		private function GetSectorIdxOf(gestureController:OIGestureController):int
		{
			var ret:int = -1;
			
			for (var c:int=0; c < mSectors.length; c++)
			{
				if (mSectors[c].GestureController == gestureController)
				{
					ret = c;
					break;
				}
			}
			
			return ret;
		}
		
		private function SubscribeToGirl() : void
		{
			mGirl.addEventListener("AnimHit", OnAnimHit, false, 0, true);
		}
				
		private function UnsubscribeToGirl() : void
		{
			mGirl.removeEventListener("AnimHit", OnAnimHit);
		}
		
		private function Stop() : void
		{
			TweenMax.killDelayedCallsTo(NextShot);

			mTrail = null;
			mInterface = null;

			// Borramos los sectores
			if (mSectors != null)
			{
				for (var c:int = 0; c < mSectors.length; c++)
				{
					var theGesture : OIGestureController = mSectors[c].GestureController;
					TheGameModel.DeleteSceneObject(theGesture.TheSceneObject);
				}
								
				mSectors = null;
			}

			if (mGirl)
			{
				mGirl.Stop();
				UnsubscribeToGirl();
				mGirl = null;
			}
			
			if (mExitButton)
			{
				TheGameModel.TheRender2DCamera.removeChild(mExitButton);
				mExitButton = null;
			}
			
			if (mScore)
			{
				TheGameModel.DeleteSceneObject(mScore.TheSceneObject);
				mScore = null;
			}
		}
		
		private function OnShotOK(event:GenericEvent) : void
		{		
			var theGesture : OIGestureController = event.target as OIGestureController;
			
			mTotalScore += event.Data.TimePrecision;
			
			mScore.SetScore(mTotalScore);
		}
		
		private function OnShotKO(event:Event) : void
		{
			var theGesture : OIGestureController = event.target as OIGestureController;
			
			mNumLifes--;
			
			if (mNumLifes != 0)
			{
				// Restamos una vida, pero continuamos
				mScore.SetNumLifes(mNumLifes);
			}
			else
			{
				// Salimos fracasados
				mTrail.SetRenderingEnabled(false);
				mInterface.GotoFinFracaso(null);
			
				Stop();
			}
				
		}
		
		private function ResultAnimEnd(event:Event):void
		{	
			var theGesture : OIGestureController = event.target as OIGestureController;
			var idxToSector : int = GetSectorIdxOf(theGesture);
			
			mSectors[idxToSector].IsBusy = false;
		}
		
		public function get DiffLevel() : int { return mDiffLevel; }
		public function get TotalScore() : int { return mTotalScore; }
		
		private var mPaused : Boolean = false;
		
		private var mTrail : OITrail;
		private var mGirl : OIChica;
		private var mInterface : OIInterface;
		private var mScore : QuizScore;
		private var mSectors : Array = null;
		
		private var mDiffLevel : int = -1;
		private var mTotalScore : int = 0;
		private var mNumLifes : int = TOTAL_LIFES;
		
		private var mExitButton : MovieClip;
				
		private const DIFFICULTY_LEVELS : Array = [ { TimeBetweenShots:2000, FlyTime:1500, Tolerance:500, LevelTime:30000 }, 
													{ TimeBetweenShots:750, FlyTime:1100, Tolerance:350, LevelTime:30000 },
													{ TimeBetweenShots:1200, FlyTime:500,  Tolerance:250, LevelTime:30000 },
													{ TimeBetweenShots:800, FlyTime:600,  Tolerance:250, LevelTime:60000 }
												  ]
	}
}