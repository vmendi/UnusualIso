package GameComponents.Quiz
{
	import GameComponents.GameComponent;
	
	import flash.events.Event;
	import flash.utils.getTimer;

	public class QuizScore extends GameComponent
	{
		public var TotalTime : Number = 10000;
		public var CircleMethod : Boolean = false;
		

		override public function OnStart() : void
		{			
			mIsTimerRunning = false;
			TheVisualObject.mcTiempo.stop();
		}

		override public function OnStop() : void
		{
			if (mIsTimerRunning)
			{
				TheVisualObject.removeEventListener(Event.ENTER_FRAME, UpdateTimer);
				mIsTimerRunning = false;
			}
		}

		override public function OnPause() : void
		{
			if (mIsTimerRunning)
				TheVisualObject.removeEventListener(Event.ENTER_FRAME, UpdateTimer);
		}

		override public function OnResume():void
		{
			if (mIsTimerRunning)
			{
				mLastTime = getTimer();
				TheVisualObject.addEventListener(Event.ENTER_FRAME, UpdateTimer, false, 0, true);
			}
		}

		public function StartTimer():void
		{
			// Permitimos multiples llamadas sin efecto
			if (!mIsTimerRunning)
			{
				mRemainingTime = TotalTime;
				mIsTimerRunning = true;
				OnResume();
			}
		}
		
		public function StopTimer():void
		{
			if (mIsTimerRunning)
			{
				mIsTimerRunning = false;
				TheVisualObject.removeEventListener(Event.ENTER_FRAME, UpdateTimer);
			}
		}
		
		public function ClearTimer():void
		{
			mRemainingTime = 0;
			TheVisualObject.mcTiempo.gotoAndStop(1);
		}
		
		public function HideTimer() : void
		{
			TheVisualObject.mcTiempo.visible = false;
		}
		
		public function ShowTimer() : void
		{
			TheVisualObject.mcTiempo.visible = true;
		}

		private function UpdateTimer(event:Event) : void
		{
			if (!mIsTimerRunning)
				throw "WTF?";
				
			var currTime : Number = getTimer(); 
			mRemainingTime -= (currTime-mLastTime);
			
			if (mRemainingTime < 0)
			{
				StopTimer();
				dispatchEvent(new Event("TimeEnd"));
			}
			else
			{
				if (CircleMethod)
				{
					var percentRemaining : Number = Math.floor(500 * mRemainingTime / TotalTime);
					TheVisualObject.mcTiempo.gotoAndStop(percentRemaining+1);
				}
				else
				{
					TheVisualObject.mcTiempo.ctTiempo.text = ConvertTimeToString(mRemainingTime);
				}					
			}

			mLastTime = currTime;
		}
		
		private function ConvertTimeToString(milisecs:Number):String
		{
			var totalSeconds : Number = milisecs/1000;
			var minutes : Number = Math.floor(totalSeconds / 60);
			var seconds : Number = Math.floor(totalSeconds % 60);
			
			var secondsStr : String = seconds < 10? "0"+seconds.toString() : seconds.toString();
			
			return minutes.toString() + ":" + secondsStr;	
		}
		
		public function SetNumLifes(num:int):void
		{
			TheVisualObject.mcVidas.gotoAndStop(num);
		}
		
		public function SetScore(score:Number):void
		{
			mScore = score;
			TheVisualObject.mcPuntos.ctPuntos.text = Math.floor(mScore).toString();
		}
		
		public function GetScore() : Number
		{ 
			return mScore;
		}
		
		public function AddScore(diff:Number):void
		{
			mScore += diff;
			TheVisualObject.mcPuntos.ctPuntos.text = Math.floor(mScore).toString();
		}
		
		
		public function get RemainingTime() : Number { return mRemainingTime; }

		private var mScore : Number = 0;		
		private var mLastTime : Number = -1;
		private var mRemainingTime : Number;
		
		private var mIsTimerRunning : Boolean = false;
	}
}