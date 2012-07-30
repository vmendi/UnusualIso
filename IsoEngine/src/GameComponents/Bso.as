package GameComponents
{
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * 
	 */
	public final class Bso extends GameComponent
	{
		
		public var Song : String = "Assets/FirstSnow.mp3";
		public var PlayOnStart : Boolean = false;
		
		override public function OnStart() : void
		{
			//TheVisualObject.visible = false;
			mSoundRequest = new URLRequest(IsoEngine.BaseUrl+Song);
			mSound = new Sound();
			mSoundControl = new SoundChannel();
			mSoundTransform = new SoundTransform();
			mLoader = new URLLoader();
            mLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
            mLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
            mPlaying = false;
            mPaused = false;
            
        	mSoundOk = true;
			try
			{
				mLoader.load(mSoundRequest);
			}
 			catch (error:Error)
 			{
                //trace("Unable to load requested document.");
                mSoundOk = false;
            }
			if (mSoundOk)
			{
				mSound.load(mSoundRequest);
			}
			            
            // Play
            if(PlayOnStart)
            	Play();
		}
		
		override public function OnPause():void
		{
			Pause();
		}
		
		override public function OnResume():void
		{
			Resume();
		}
		
		override public function OnStop():void
		{
			Stop();
			//TheVisualObject.visible = true;
			mSoundRequest = null;
			mSound = null;
			mSoundControl = null;
			mSoundTransform = null;
			mLoader = null;
       }
		
		// Handlers de los errores
		
        private function securityErrorHandler(event:SecurityErrorEvent):void {
            //trace("securityErrorHandler: " + event);
            mPlaying = false;
        }

        private function ioErrorHandler(event:IOErrorEvent):void {
            //trace("ioErrorHandler: " + event);
            mPlaying = false;
        }
        
        // Interface
        
        public function Play() : void
        {
        	if (mPlaying)
        		return;

			// Play
			if (mSoundOk)
			{
				mSoundControl = mSound.play();
				mPlaying = true;
				mPaused = false;
			}

        }
        
        public function Stop() : void
        {
			if (mPlaying)
			{
				mSoundControl.stop();
				mPlaying = false;
				mPaused = false;
			}
        }
        
        public function Pause() : void
        {
			if (mPlaying)
			{
				mSoundControl.stop();
				mPaused = true;
   			}
        }
        
        public function Resume() : void
        {
			if (mPaused)
			{
				mSoundControl = mSound.play();
				mPaused = false;
			}
        }
        
        // Variables
		
		private var mSoundRequest : URLRequest;
		private var mSound : Sound;
		private var mSoundControl : SoundChannel;
		private var mSoundTransform : SoundTransform;
		private var mLoader : URLLoader;
		private var mPlaying : Boolean;
		private var mPaused : Boolean;
		private var mSoundOk : Boolean;

	}
}


