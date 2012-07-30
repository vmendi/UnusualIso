package GameComponents.Quiz
{
	import GameComponents.GameComponent;
	
	import Quiz.QuizGame;
	import Quiz.QuizModel;
	import Quiz.QuizNode;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import gs.TweenLite;
	
	import utils.GenericEvent;
	import utils.RandUtils;
	import utils.TextFieldFormatter;


	public class QuizController extends GameComponent
	{
		public var Url : String = "";

		public var AnswerMidDelay : Number = 300;
		public var AnswerCoordX : Number = -300;
		public var AnswerCoordYStart : Number = -200;
		public var AnswerCoordYGap : Number = 75;

		public var QuestionDelay : Number = 50;

		public var TotalQuestions : Number = 3;

		public var PointsPerQuestion : Number = 1000;
		public var PointsTimeFactor : Number = 0.1;

		public var BlinkMethod : Boolean = true;

		override public function OnStart():void
		{
			mQuizModel = new QuizModel();
			mQuizModel.addEventListener("ModelLoaded", OnQuizModelLoaded, false, 0, true);
			mQuizModel.Load(IsoEngine.BaseUrl+Url);

			TheVisualObject.alpha = 0.0;
			TheVisualObject.visible = false;

			mBackground = TheGameModel.FindGameComponentByShortName("QuizBackground") as QuizBackground;
			mBackground.addEventListener("AnimResultEnd", OnResultEnd, false, 0, true);
			mBackground.addEventListener("AnimPreguntaEnd", OnAnimPreguntaEnd, false, 0, true);
		}

		override public function OnStop():void
		{
			DestroyAnswers();
			mBackground.removeEventListener("AnimResultEnd", OnResultEnd);
			mBackground.removeEventListener("AnimPreguntaEnd", OnAnimPreguntaEnd);
			mBackground = null;
		}


		private function OnQuizModelLoaded(event:Event):void
		{
			// Tenemos que hacerlo así porque estamos cargando assets individualmente. Desde fuera se tienen que enterar que ya podemos comenzar.
			dispatchEvent(new Event("ControllerReady"));
		}

		public function StartGame() : void
		{
			mQuizGame = new QuizGame(mQuizModel, this);

			mNumSuccess = 0;
			mFinalScore = -1;

			mScore = TheGameModel.CreateSceneObjectFromMovieClip("mcMarcador", "QuizScore") as QuizScore;
			mScore.addEventListener("TimeEnd", OnTimeEnd, false, 0, true);

			TheVisualObject.visible = true;

			// Vamos a la primera pregunta (el Start se habrá ejecutado ya, no obstante)
			mQuizGame.GotoRandomNonVisitedNodeWithExits();

			SetupCurrentQuestion();
		}

		private function OnTimeEnd(event:Event):void
		{
			for (var c:int=0; c < mAnswers.length; c++)
			{
				if ((mAnswers[c].TheQuizNode.NodeID == mCorrectAnswer) && !BlinkMethod)
					mAnswers[c].GoRight();
				else
					mAnswers[c].GoInvisible();
			}
			
			TheVisualObject.ctTextArea.text = "";
			TweenLite.to(TheVisualObject, 0.5, { alpha:0.0 } );

			mBackground.GotoAndPlay("Error");
		}

		public function EndGame():void
		{
			mFinalScore = Math.floor(mScore.GetScore()) as int;

			DestroyAnswers();

			TheGameModel.DeleteSceneObject(mScore.TheSceneObject);
			mScore = null;

			TheVisualObject.visible = false;

			var success : Boolean = mNumSuccess == TotalQuestions;
			dispatchEvent(new GenericEvent("GameEnd", { Success:success }));
		}


		private function SetupCurrentQuestion() : void
		{
			// Borramos las anteriores si las hubiera
			DestroyAnswers();

			// Aparecemos
			TweenLite.to(TheVisualObject, 0.5, { alpha:1.0 } );
			ShowQuestionText(mQuizGame.CurrentNode.QuestionText);

			mScore.ShowTimer();
			mScore.ClearTimer();

			mBackground.GotoAndPlay("Pregunta");
		}

		private function ShowQuestionText(text : String) : void
		{
			if (mBufferQuestionText == "")
			{
				text = TextFieldFormatter.InsertReturns(TheVisualObject.ctTextArea, text);
				TheVisualObject.ctTextArea.text = "";
			}

			var nextIdx : int = mBufferQuestionText.length + 1;

			if (nextIdx <= text.length)
			{
				mBufferQuestionText = text.substr(0, nextIdx);
				TheVisualObject.ctTextArea.text = mBufferQuestionText;

				TweenLite.delayedCall(QuestionDelay / 1000, ShowQuestionText, [ text ]);
			}
			else
			{
				mBufferQuestionText = "";
				ShowAnswers();
			}
		}

		private function ShowAnswers():void
		{
			var answers : Array = mQuizGame.GetAvailableAnswers();			
			answers = RandUtils.Shuffle(answers);

			for (var c:int = 0; c < answers.length; c++)
			{
				var currAnswer : QuizAnswer = TheGameModel.CreateSceneObjectFromMovieClip("mcAnswer", "QuizAnswer") as QuizAnswer;
				var currPos : Point = new Point();
				currPos.x = AnswerCoordX;
				currPos.y = c*AnswerCoordYGap + AnswerCoordYStart;

				currAnswer.TheAssetObject.TheRender2DComponent.ScreenPos = currPos;

				currAnswer.InitAnswer(mQuizModel, answers[c], c*AnswerMidDelay);
				currAnswer.addEventListener("AnswerClick", OnAnswerClicked, false, 0, true);

				mAnswers.push(currAnswer);
			}

			mScore.StartTimer();
		}

		private function OnAnswerClicked(event:Event):void
		{
			var answer : QuizAnswer = (event.target as QuizAnswer);
			var node : QuizNode = answer.TheQuizNode;

			mQuizGame.SelectAnswer(node.NodeID);

			mScore.StopTimer();
			mScore.HideTimer();

			TheVisualObject.ctTextArea.text = "";

			TweenLite.to(TheVisualObject, 0.5, { alpha:0.0 } );

			if (BlinkMethod)
			{
				for each (var otherAnswer : QuizAnswer in mAnswers)
				{
					if (otherAnswer != event.target)
						otherAnswer.GoInvisible();
					else
					{
						otherAnswer.addEventListener("AnswerBlinkEnd", OnAnswerBlinkEnd, false, 0, true);
						otherAnswer.Blink();
					}
				}
			}
			else
			{
				ResolveAnswer(node.NodeID);

				if (mCorrectAnswer != node.NodeID)
					answer.GoError();
				else
					answer.GoSuccess();

				for each (otherAnswer in mAnswers)
				{
					if (otherAnswer == event.target)
						continue;

					if (otherAnswer.TheQuizNode.NodeID == mCorrectAnswer)
						otherAnswer.GoRight();
					else
						otherAnswer.GoInvisible();
				}
			}
		}

		private function OnAnswerBlinkEnd(event:Event):void
		{
			ResolveAnswer((event.target as QuizAnswer).TheQuizNode.NodeID);
		}

		private function ResolveAnswer(nodeID : String):void
		{
			// Al ejecutar el código de salida, como somos el contexto, se nos configurará la CorrectAnswer
			if (mCorrectAnswer == nodeID)
			{
				var score : Number = PointsPerQuestion + PointsTimeFactor*mScore.RemainingTime;
				mScore.AddScore(score);

				mBackground.GotoAndPlay("Acierto");
				mNumSuccess++;
			}
			else
				mBackground.GotoAndPlay("Error");
		}

		// Aquí se llama el mBackground al acabar la animación "Acierto" / "Error"
		private function OnResultEnd(event:Event):void
		{
			if (mQuizGame.GetNumVisitedNodesWithExits() == TotalQuestions)
			{
				EndGame();
			}
			else
			{
				mQuizGame.GotoRandomNonVisitedNodeWithExits();
				SetupCurrentQuestion();
			}
		}

		private function OnAnimPreguntaEnd(event:Event):void
		{
			mBackground.GotoAndPlay("Espera");
		}

		private function DestroyAnswers() : void
		{
			for (var c:int = 0; c < mAnswers.length; c++)
			{
				TheGameModel.DeleteSceneObject(mAnswers[c].TheSceneObject);
			}

			mAnswers = new Array();
		}

		public function SetCorrectAnswer(nodeID : String):void
		{
			mCorrectAnswer = nodeID;
		}


		public function GetFinalScore() : int
		{
			if (mScore != null)
				throw "El juego todavía no está acabado";

			return mFinalScore;
		}

		public function get NumSuccess() : int { return mNumSuccess; }



		[ArrayElementType("QuizAnswer")]
		private var mAnswers : Array = new Array();

		private var mQuizGame : QuizGame;
		private var mQuizModel : QuizModel;

		private var mCorrectAnswer : String = "";
		private var mBufferQuestionText : String = "";

		private var mBackground : QuizBackground;
		private var mScore : QuizScore;

		private var mNumSuccess : int = 0;
		private var mFinalScore : int = -1;
	}
}