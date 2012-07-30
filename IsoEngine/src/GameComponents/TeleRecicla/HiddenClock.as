package GameComponents.TeleRecicla
{
	import GameComponents.GameComponent;

	import flash.events.Event;
	import flash.utils.getTimer;

	public class HiddenClock extends GameComponent
	{
		public var TotalTime : Number = 10000;


		override public function OnStop():void
		{
			StopTimer();
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
			if (mIsTimerRunning)
				throw "WTF";

			mIsTimerRunning = true;
			mRemainingTime = TotalTime;
			OnResume();
		}

		public function StopTimer():void
		{
			if (mIsTimerRunning)
			{
				mIsTimerRunning = false;
				TheVisualObject.removeEventListener(Event.ENTER_FRAME, UpdateTimer);
			}
		}

		public function get IsRunning() : Boolean { return mIsTimerRunning; }

		private function UpdateTimer(event:Event) : void
		{
			if (!mIsTimerRunning)
				throw "WTF?";

			var currTime : Number = getTimer();
			mRemainingTime -= (currTime-mLastTime);

			if (mRemainingTime <= 0)
			{
				mRemainingTime = 0;
				StopTimer();
				dispatchEvent(new Event("TimeEnd"));
			}
			else
			{
				TheVisualObject.ctTiempo.text = ConvertTimeToString(mRemainingTime);
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

		public function get RemainingMiliseconds() : int { return mRemainingTime; }

		private var mLastTime : int = 0;
		private var mRemainingTime : int = 0;
		private var mIsTimerRunning : Boolean = false;
	}
}