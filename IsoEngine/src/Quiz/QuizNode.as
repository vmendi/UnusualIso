package Quiz
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class QuizNode
	{
		public var NodeID : String = "DefaultID";
		public var AnswerText : String = "Answer";
		public var QuestionText : String = "Question";			
		public var EnterCode : String = "";
		public var ConditionCode : String = "return true;";
		public var ExitCode : String = "";
		public var Answers : ArrayCollection = new ArrayCollection();
		
		public function QuizNode(id : String):void
		{
			NodeID = id;
		}
		
		public function AddAnswer(nodeID : String):void
		{
			if (!Answers.contains(nodeID))
				Answers.addItem(nodeID);
		}
		
		public function get AnswersString() : String
		{ 
			var ret : String = "";
			
			for (var c:int=0; c < Answers.length; c++)
			{
				if (c != 0)
					ret += ";";
				
				ret += Answers[c];
			}

			return ret;
		}
		
		public function set AnswersString(str : String) : void
		{
			Answers = new ArrayCollection();
						
			var strings : Array = str.split(";");
			for each (var str : String in strings)
			{
				if (str != "")
					Answers.addItem(str);
			}
		}

	}
}