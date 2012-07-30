package GameComponents.Insignia
{
	import GameComponents.GameComponent;
	
	import Model.AssetObject;
	import Model.SceneObject;
	import Model.UpdateEvent;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import mouseGestures.*;
	
	import utils.GenericEvent;
	import utils.MovieClipLabels;

	/**
	 * Componente para ...
	 */
	public final class OIGestureController extends GameComponent
	{
		public var Time : Number = 1000;
		public var Size : Number = 2;
		public var Tolerance : Number = 0.1;
		public var Ayudas : Boolean = false;
		
		private const SCORE_SCALE : Number = 0.5;
		private const SCORE_BASE : Number = 50;
		
		override public function OnStart() : void
		{		
			mPlaying = false;
			mEventosActivos = false;
			mRecEventosActivos = false;
			
			AddFrameScripts();
			
			// La visibilidad se controlará durante el Shot
			TheVisualObject.visible = false;
						
			// Gestos
			mMg = new MouseGesture(TheVisualObject.stage);
			mMg.addGesture("FOREHAND","4");
			mMg.addGesture("BACKHAND","0");
			mMg.addGesture("LOB","6");
			mMg.addGesture("SMASH","2");
			mMg.addGesture("SERVE","62");

			// Creación de la bola
			var ballAssetObj : AssetObject = TheGameModel.TheAssetLibrary.FindAssetObjectByMovieClipName("mcBall");
			var ballSceneObj : SceneObject = TheGameModel.CreateSceneObject(ballAssetObj);
			
			mBall = ballSceneObj.TheAssetObject.FindGameComponentByShortName("OIBall") as OIBall;		
		}
		
		private function AddFrameScripts():void
		{
			var frame : int = MovieClipLabels.GetFrameOfLabel("OKEnd", TheVisualObject);
			TheVisualObject.addFrameScript(frame-1, ResultAnimEnd);
			frame = MovieClipLabels.GetFrameOfLabel("KOEnd", TheVisualObject);
			TheVisualObject.addFrameScript(frame-1, ResultAnimEnd);	
		}
		
		private function RemoveFrameScripts():void
		{
			var frame : int = MovieClipLabels.GetFrameOfLabel("OKEnd", TheVisualObject);
			TheVisualObject.addFrameScript(frame-1, null);
			frame = MovieClipLabels.GetFrameOfLabel("KOEnd", TheVisualObject);
			TheVisualObject.addFrameScript(frame-1, null);
		}
		
		override public function OnPause():void
		{
			if (mEventosActivos)
			{
				mRecEventosActivos = true;
				RemoveGestureEventListeners();
			}
			else
			{
				mRecEventosActivos = false;
			}
		}
		
		override public function OnResume():void
		{
			if (mRecEventosActivos)
			{
				AddGestureEventListeners();
			}
		}
				
		override public function OnStop():void
		{			
			// Si nos quedamos al editor, somos visibles
			TheVisualObject.visible = true;

			RemoveFrameScripts();
			RemoveGestureEventListeners();
			
			mMg = null;
			
			// Destruimos nuestra bola
			TheGameModel.DeleteSceneObject(mBall.TheSceneObject);
			mBall = null;
			
			mPlaying = false;
		}
						
		override public function OnUpdate(event:UpdateEvent):void
		{	
			if (mPlaying)
			{
				if (mTime)
					mTotalElapsedTime += event.ElapsedTime;
									
				// Si estamos procesando un OK, paramos de escalar
				if (mGestureStartElapsedTime == -1)
				{
					var togoSize : Number = mSize - 1;
					var vSize : Number = togoSize / (Time - mTotalElapsedTime);
					mSize -= (vSize*event.ElapsedTime);
					TheVisualObject.mcOut.scaleX = mSize;
					TheVisualObject.mcOut.scaleY = mSize;
				}
				
				if (mTotalElapsedTime > mLimDn && !mCapturing)
					ShotEnd(false);
			}
		}
		
		/**
		 * Nuevo disparo
		 */				
		public function NewShot(requiredShot : Array, time : Boolean, visible : Boolean, arrow : Boolean, coords : Point, startPos : Point) : void
		{
			mCapturing = false;
			mShotOnTime = false;
			mPlaying = true;
			mSize = Size;
			mTotalElapsedTime = 0;
			mGestureStartElapsedTime = -1;
			TheVisualObject.mcArrow.gotoAndStop("Stop");
			var newX : Number = 0;
			var newY : Number = 0;
			
			mRequiredShot = requiredShot;
			TheVisualObject.visible = visible;
			TheVisualObject.mcArrow.visible = arrow;
			
			if (arrow)
				TheVisualObject.mcArrow.gotoAndStop(mRequiredShot[0]);
			
			if (time)
			{
				mLimUp = Time - Tolerance;
			}
			else
			{
				mLimUp = 0;
			}
			mLimDn = Time + Tolerance;
			
			if (coords != null)
			{
				newX = coords.x;
				newY = coords.y;
			}
			
			// Visual
			TheVisualObject.x = newX;
			TheVisualObject.y = newY;
			TheVisualObject.mcOut.scaleX = TheVisualObject.mcOut.scaleY = Size;

			mTime = time;
			if (mTime)
			{
				var incoming : OIBallTrajectory = new OIBallTrajectory();
				incoming.StartPos = startPos;
				incoming.EndPos = new Point(TheVisualObject.x, TheVisualObject.y);
				incoming.FlyTime = Time;
				incoming.EndDelayTime = Tolerance;
				mBall.StartMovement(incoming, true);
			}
						
			// Listeners
			AddGestureEventListeners();			
		}
				
		private function ShotEnd(resultado:Boolean):void
		{	
			RemoveGestureEventListeners();
			mPlaying = false;
			
			if (resultado)
			{
				TheVisualObject.gotoAndPlay("OK");
				
				// El score se calculará a partir de la precisión temporal	
				var diff : Number = Math.abs(mGestureStartElapsedTime - Time);
				var timePrecision : int = (Math.round(Tolerance - diff) * SCORE_SCALE) + SCORE_BASE;
				dispatchEvent(new GenericEvent("ShotDoneOK", { TimePrecision: timePrecision } ));
				
				TheVisualObject.mcPuntos.ctPuntos.text = timePrecision;
				
				if (mTime)
				{
					var outgoing : OIBallTrajectory = new OIBallTrajectory();
					outgoing.StartPos = new Point(mBall.TheVisualObject.x, mBall.TheVisualObject.y);
					outgoing.EndPos = new Point(0,0);
					outgoing.FlyTime = 1000;
					// El punto final dependerá del tipo de golpe, también el tiempo de vuelo
					var endX : Number;
					var endY : Number = 10;
					switch (mRequiredShot[0])
					{
						case "FOREHAND":
							endX = TheVisualObject.x - Math.round(Math.random() * 100);
							outgoing.EndPos = new Point(endX,endY);
							outgoing.FlyTime = 1000;
						break;
						case "BACKHAND":
							endX = TheVisualObject.x + Math.round(Math.random() * 100);
							outgoing.EndPos = new Point(endX,endY);
							outgoing.FlyTime = 1000;
						break;
						case "LOB":
							endX = - 275 + (Math.round(Math.random()) * 450) + Math.round(Math.random() * 100);
							outgoing.EndPos = new Point(endX,endY);
							outgoing.FlyTime = 1500;
						break;
						case "SMASH":
							endX = -125 + (Math.round(Math.random()) * 250) + Math.round(Math.random() * 25);
							outgoing.EndPos = new Point(endX,endY);
							outgoing.FlyTime = 500;
						break;
					}
					outgoing.EndDelayTime = 0;
					mBall.StartMovement(outgoing, false);
				}
			}
			else
			{
				TheVisualObject.mcPuntos.ctPuntos.text = "0";
				
				TheVisualObject.gotoAndPlay("KO");
				dispatchEvent(new Event("ShotDoneKO"));
			}
		}
		
		private function ResultAnimEnd() : void
		{
			// Al final de la animación, ocultamos el objeto
			TheVisualObject.visible = false;
			TheVisualObject.gotoAndStop("Stop");
			
			// Para que nos puedan destruir...
			dispatchEvent(new Event("ResultAnimEnd"));
		}

		//
		// Handlers de los gestos
		//
		
		private function MatchHandler(e:GestureEvent):void
		{
			if (!mCapturing)
				return;
				
			mCapturing = false;
			
			var acierto : Boolean = false;
			
			if (mShotOnTime)
			{
				for (var i : Number = 0; i < mRequiredShot.length ; i++)
				{
					if (e.datas == mRequiredShot[i])
					{
						acierto = true;
						break;
					}
				}
			}
			
			ShotEnd(acierto);
		}			

		private function NoMatchHandler(e:GestureEvent):void
		{
			if (!mCapturing)
				return;
				
			mCapturing = false;	
			ShotEnd(false);
		}
		
		private function StartHandler(e:GestureEvent):void
		{
			if ( Math.pow(TheVisualObject.mouseX,2) + Math.pow(TheVisualObject.mouseY,2) <= Math.pow(TheVisualObject.mcCentro.width*0.5,2) || !TheVisualObject.visible )
			{
				mCapturing = true;
				mCaptureCounter = 0;
							
				if (mTotalElapsedTime >= mLimUp && mTotalElapsedTime <= mLimDn)
				{
					mShotOnTime = true;
					mGestureStartElapsedTime = mTotalElapsedTime;
				}
				else
				{
					mShotOnTime = false;
					mGestureStartElapsedTime = -1;
				}
			}
		}	
		
		private function CapturingHandler(e:GestureEvent) : void
		{
			mCaptureCounter++;
			if (mCaptureCounter > 15)
			{
				mMg.ForceStopCapture();
			}
		}	

		//
		// Listeners
		//
		
		private function AddGestureEventListeners() : void
		{
			mEventosActivos = true;
			mMg.addEventListener(GestureEvent.GESTURE_MATCH, MatchHandler, false, 0, true);
			mMg.addEventListener(GestureEvent.NO_MATCH, NoMatchHandler, false, 0, true);
			mMg.addEventListener(GestureEvent.START_CAPTURE, StartHandler, false, 0, true);
			mMg.addEventListener(GestureEvent.CAPTURING,CapturingHandler,false, 0, true);
		}
		
		private function RemoveGestureEventListeners() : void
		{
			mEventosActivos = false;
			mMg.removeEventListener(GestureEvent.GESTURE_MATCH, MatchHandler);
			mMg.removeEventListener(GestureEvent.NO_MATCH, NoMatchHandler);
			mMg.removeEventListener(GestureEvent.START_CAPTURE, StartHandler);
			mMg.removeEventListener(GestureEvent.CAPTURING, CapturingHandler);
		}
				
		// Variables

		private var mMg : MouseGesture;
		private var mBall : OIBall;
		private var mPlaying : Boolean;
		private var mSize : Number; 					// Tamaño inicial del círculo 
		private var mLimUp : Number;
		private var mLimDn : Number;
		private var mRequiredShot : Array; 				// Disparo que tiene que realizar 
		private var mCapturing : Boolean; 				// Controla si se está realizando un disparo (movimiento del mouse)
		private var mShotOnTime : Boolean; 				// Controla si el disparo se ha hecho a tiempo
		private var mTotalElapsedTime : Number; 		// Tiempo total que ha transcurrido de disparo
		private var mGestureStartElapsedTime : Number;	// Tiempo en el que empezó a hacerse el gesto
		private var mEventosActivos : Boolean;
		private var mRecEventosActivos : Boolean;
		private var mTime : Boolean;
		private var mCaptureCounter : Number;
	}
	
}