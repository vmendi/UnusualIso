package GameComponents.Quiz
{
	import GameComponents.GameComponent;
	
	import Quiz.QuizModel;
	import Quiz.QuizNode;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import gs.TweenLite;
	
	import utils.MovieClipLabels;
	import utils.MovieClipMouseDisabler;
	
	public class QuizAnswer extends GameComponent
	{
		override public function OnStart() : void
		{
			MovieClipMouseDisabler.DisableMouse(TheVisualObject);
			TheVisualObject.addEventListener(MouseEvent.CLICK, OnClick, false, 0, true);
		}
		
		override public function OnStop() : void
		{
			TweenLite.killDelayedCallsTo(Blink);
			TweenLite.killTweensOf(TheVisualObject);
			
			TheVisualObject.removeEventListener(MouseEvent.CLICK, OnClick);
		}
				
		public function InitAnswer(quizModel:QuizModel, nodeID:String, milisecsShowDelay:int) : void
		{
			TheVisualObject.alpha = 0;
			
			TweenLite.to(TheVisualObject, 0.5, { alpha:1.0, delay:milisecsShowDelay/1000, onComplete:OnVisible } );
			
			mQuizModel = quizModel;
			mQuizNode = mQuizModel.FindNodeByID(nodeID);
			
			TheVisualObject.mcContenido.ctTextArea.text = mQuizNode.AnswerText;
		}
		
		private function OnVisible():void
		{
			MovieClipMouseDisabler.DisableMouse(TheVisualObject, false);	
		}
		
		public function GoInvisible() : void
		{
			MovieClipMouseDisabler.DisableMouse(TheVisualObject);
			TweenLite.to(TheVisualObject, 0.5, { alpha:0.0 } );
		}
		
		public function GoSuccess() : void
		{
			MovieClipMouseDisabler.DisableMouse(TheVisualObject);
			TheVisualObject.gotoAndPlay("Acierto");
			TheVisualObject.addFrameScript(MovieClipLabels.GetFrameOfLabel("AciertoEnd", TheVisualObject)-1, OnResultEnd);
		}
		
		public function GoError() : void
		{
			MovieClipMouseDisabler.DisableMouse(TheVisualObject);
			TheVisualObject.gotoAndPlay("Error");
			TheVisualObject.addFrameScript(MovieClipLabels.GetFrameOfLabel("ErrorEnd", TheVisualObject)-1, OnResultEnd);
		}
		
		public function GoRight() : void
		{
			MovieClipMouseDisabler.DisableMouse(TheVisualObject);
			TheVisualObject.gotoAndPlay("Correcta");
			TheVisualObject.addFrameScript(MovieClipLabels.GetFrameOfLabel("CorrectaEnd", TheVisualObject)-1, OnResultEnd);
		}
		
		private function OnResultEnd():void
		{
			TheVisualObject.addFrameScript(TheVisualObject.currentFrame-1, null);
			TheVisualObject.stop();			
			dispatchEvent(new Event("AnswerResultEnd"));
		}
		
		private function OnClick(event:MouseEvent):void
		{
			dispatchEvent(new Event("AnswerClick"));
			MovieClipMouseDisabler.DisableMouse(TheVisualObject);
		}
		
		public function Blink() : void
		{
			BlinkTimes(12);
		}
		
		private function BlinkTimes(numTimes : int) : void
		{
			TheVisualObject.visible = !TheVisualObject.visible;
		
			if (numTimes > 0)
				TweenLite.delayedCall(0.05, BlinkTimes, [numTimes-1]);
			else
				dispatchEvent(new Event("AnswerBlinkEnd"));
		}
		
		public function get TheQuizNode() : QuizNode { return mQuizNode; }
		
		private var mQuizNode : QuizNode;
		private var mQuizModel : QuizModel;
	}
}