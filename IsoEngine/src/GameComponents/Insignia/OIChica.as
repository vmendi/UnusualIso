package GameComponents.Insignia
{
	import GameComponents.GameComponent;
	
	import flash.events.Event;
	
	import utils.MovieClipLabels;
	
	/**
	 * Etiquetas:
	 * 	Idle
	 * 	Serve
	 * 	Forehand
	 * 	Backhand
	 * 	Smash
	 * 	Lob
	 * 
	 * Cada una de las etiquetas tiene otras dos versiones: "Hit" y "End".
	 * "Hit" es el momento en el que, en la animación, se producirá el verdadero "contacto" con la bola.
	 * "End" determina el final de la animación
	 */
	public class OIChica extends GameComponent
	{
		override public function OnStart():void
		{
			TheVisualObject.visible = false;
			MovieClipLabels.AddFrameScripts(FRAME_SCRIPTS, TheVisualObject);
		}
		
		override public function OnStop():void
		{
			TheVisualObject.gotoAndStop(0);
			TheVisualObject.visible = true;
			TheVisualObject.stop();
			MovieClipLabels.RemoveFrameScripts(FRAME_SCRIPTS, TheVisualObject);
		}
		
		override public function OnPause():void
		{
			TheVisualObject.stop();
		}
		
		override public function OnResume():void
		{
			TheVisualObject.play();
		}
		
		public function PlayVideo(label : String) : void
		{
			TheVisualObject.gotoAndPlay(label);
		}
		
		public function Stop():void
		{
			TheVisualObject.visible = false;
			TheVisualObject.stop();
		}

		private function ResultAnimEnd() : void
		{
			TheVisualObject.stop();
			dispatchEvent(new Event("ResultAnimEnd"));
		}
		
		private function ShotAnimEnd() : void
		{
			TheVisualObject.stop();
			dispatchEvent(new Event("ShotAnimEnd"));
		}
		
		private function AnimHit() : void
		{
			dispatchEvent(new Event("AnimHit"));
		}
		
		private const FRAME_SCRIPTS : Array = [ {label: "ShotOKEnd", func: ResultAnimEnd}, 
												{label: "ShotKOEnd", func: ResultAnimEnd},
												{label: "ForehandEnd", func: ShotAnimEnd},
												{label: "BackhandEnd", func: ShotAnimEnd},
												{label: "LobEnd", func: ShotAnimEnd},
												{label: "ServeEnd", func: ShotAnimEnd},
												{label: "SmashEnd", func: ShotAnimEnd},
												{label: "SoftServeEnd", func: ShotAnimEnd},
												{label: "SoftServeHit", func: AnimHit},
												{label: "ServeHit", func: AnimHit}];
	}
}