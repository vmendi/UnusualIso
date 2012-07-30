package GameComponents.Quiz
{
	import GameComponents.GameComponent;

	import flash.events.Event;

	import utils.MovieClipLabels;

	public class QuizBackground extends GameComponent
	{
		override public function OnStart():void
		{
			MovieClipLabels.AddFrameScripts(FRAME_SCRIPTS, TheVisualObject);
		}

		override public function OnStop():void
		{
			TheVisualObject.stop();
			MovieClipLabels.RemoveFrameScripts(FRAME_SCRIPTS, TheVisualObject);
		}

		private function AnimEnd() : void
		{
			TheVisualObject.stop();
		}

		private function ResultEnd() : void
		{
			TheVisualObject.stop();
			dispatchEvent(new Event("AnimResultEnd"));
		}

		private function PreguntaEnd() : void
		{
			TheVisualObject.stop();
			dispatchEvent(new Event("AnimPreguntaEnd"));
		}

		private function EsperaEnd() : void
		{
			TheVisualObject.gotoAndPlay("Espera");
		}

		public function GotoAndPlay(label:String):void
		{
			TheVisualObject.gotoAndPlay(label);
		}

		private const FRAME_SCRIPTS : Array = [ {label: "PreguntaEnd", func: PreguntaEnd},
												{label: "AciertoEnd", func: ResultEnd},
												{label: "ErrorEnd", func: ResultEnd},
												{label: "EsperaEnd", func: EsperaEnd},
											  ];
	}
}