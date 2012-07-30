package utils
{
	public final class MovieClipListener
	{
		import flash.display.*;
		import flash.system.*;
		import flash.utils.*;
		import flash.text.*;
		import flash.events.*;
	
		private var mListening : Array = new Array();
		
		static public function AddFrameScript(mc:MovieClip, labelName:String, func : Function) : void
		{
			for (var i:int=0;i < mc.currentLabels.length;i++)
			{
				if (mc.currentLabels[i].name==labelName)
				{
					mc.addFrameScript(mc.currentLabels[i].frame-1, func);
				}
			}
		}
		
		
		public function listenToAnimEnd(target : MovieClip, callback : Function, once : Boolean, numLoops : int) : void
		{
			target.addEventListener(Event.ENTER_FRAME, OnEnterFrame);
			
			var listening : Object = new Object();
			listening["target"] = target;
			listening["callback"] = callback;
			listening["once"] = once;
			listening["numLoops"] = numLoops;
			
			mListening.push(listening);
		}
		
		public function listenToLabel(target:MovieClip, label:String, callback:Function, once:Boolean, numLoops:int) : void
		{
			target.addEventListener(Event.ENTER_FRAME, OnEnterFrame);
			
			var listening : Object = new Object();
			listening["label"] = label;
			listening["target"] = target;
			listening["callback"] = callback;
			listening["once"] = once;
			listening["numLoops"] = numLoops;
			
			mListening.push(listening);
		}
		
		private function OnEnterFrame(event : Event) : void
		{
			var daTarget : MovieClip = event.target as MovieClip;
			
			var idx : int = FindIndexOf(daTarget);
			var obj : Object = mListening[idx];
			
			if (obj.hasOwnProperty("label"))
			{
				if (daTarget.currentLabel == obj["label"])
					Trigger(obj, idx);
			}
			else			
			if (daTarget.currentFrame == daTarget.totalFrames)
			{
				Trigger(obj, idx);	
			}
		}
		
		private function Trigger(obj : Object, idx : int):void
		{
			mCurrLoops++;
			
			var daTarget : MovieClip = obj["target"] as MovieClip;						
			var once : Boolean = obj["once"] as Boolean;
			var numLoops : int = obj["numLoops"] as int;
				
			if (once)
			{
				if (numLoops != 0)
				{
					if (mCurrLoops == numLoops)
					{							
						daTarget.removeEventListener(Event.ENTER_FRAME, OnEnterFrame);
						mListening.splice(idx, 1);
						var func : Function = obj["callback"] as Function;
						func(daTarget);
						mCurrLoops = 0;
					}	
				}
				else
				{
					daTarget.removeEventListener(Event.ENTER_FRAME, OnEnterFrame);
					mListening.splice(idx, 1);
					func = obj["callback"] as Function;
					func(daTarget);
					mCurrLoops = 0;
				}
			}
			else
			{
				if (numLoops != 0)
				{
					if (mCurrLoops == numLoops)
					{							
						func = obj["callback"] as Function;
						func(daTarget);
						mCurrLoops = 0;
					}
				}
				else
				{
					func = obj["callback"] as Function;
					func(daTarget);
					mCurrLoops = 0;
				}
			}
		}
		
		private function FindIndexOf(target : MovieClip) : int
		{
			for (var c : int = 0; c < mListening.length; c++)
			{
				var curr : Object = mListening[c];
				if ((curr["target"] as MovieClip) == target)
					break;
			}
			
			if (c == mListening.length)
				throw "Movieclip desconocido";
			else
				return c;
		}
		
		private var mCurrLoops : int = 0;
	}

}