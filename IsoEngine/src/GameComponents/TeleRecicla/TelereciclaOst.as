package GameComponents.TeleRecicla
{
	import GameComponents.Bso;
	import GameComponents.GameComponent;
	
	import flash.events.MouseEvent;

	/**
	 * 
	 */
	public final class TelereciclaOst extends GameComponent
	{
		
		override public function OnStart() : void
		{
			mBso = TheGameModel.FindGameComponentByShortName("Bso") as Bso;
			TheVisualObject.btOnOff.addEventListener(MouseEvent.CLICK, OnBotonOnOffHandler);
			// Play
			mPlaying = true;
			mBso.Play();
		}
		
		override public function OnPause():void
		{
		}
		
		override public function OnResume():void
		{
		}
		
		override public function OnStop():void
		{
			mBso = null;
			TheVisualObject.btOnOff.removeEventListener(MouseEvent.CLICK, OnBotonOnOffHandler);
		}
		
		//
		// Handlers
		//
		
		private function OnBotonOnOffHandler(e:MouseEvent) : void
		{
			if (mPlaying)
			{
				mBso.Stop();
				TheVisualObject.gotoAndStop("off");
				mPlaying = false;
			}
			else
			{
				mBso.Play();
				TheVisualObject.gotoAndStop("on");
				mPlaying = true;
			}
		}

        //
        // Variables
		//
		
		private var mBso : Bso;
		private var mPlaying : Boolean;

	}
}