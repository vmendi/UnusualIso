package Quiz
{
	import r1.deval.D;
	
	public class QuizGame
	{
		public function QuizGame(quizModel : QuizModel, executionContext:Object)
		{
			mModel = quizModel;
			mExecutionContext = executionContext;
			
			GotoNode(mModel.FindNodeByID("Start"));
		}
		
		public function SelectAnswer(nodeID : String) : void
		{
			var idxToAnswer : int = mCurrentNode.Answers.getItemIndex(nodeID);
			
			if (idxToAnswer == -1)
				throw new Error("Respuesta no existe en el nodo actual");
				
			var targetNode : QuizNode = mModel.FindNodeByID(nodeID);
			
			if (targetNode == null)
				throw new Error("Nodo no existente");	// Y sin embargo la respuesta existe...
			
			GotoNode(targetNode);
		}
		
		public function GotoNodeByID(nodeID : String):void
		{
			GotoNode(mModel.FindNodeByID(nodeID));
		}
		
		private function GotoNode(node : QuizNode):void
		{
			if (mCurrentNode != null)
				D.eval(mCurrentNode.ExitCode, mExecutionContext);
			
			mCurrentNode = node;
			
			if (mCurrentNode != null)
			{
				D.eval(mCurrentNode.EnterCode, mExecutionContext);
			
				if (mVisited.indexOf(mCurrentNode) == -1)
					mVisited.push(mCurrentNode);
			}
		}
		
		public function GetAvailableAnswers() : Array
		{
			// TODO: devolver sólo las que su Condición de Visibilidad evalue a true
			return mCurrentNode.Answers.toArray();
		}
		
		public function GotoRandomNonVisitedNodeWithExits() : void
		{
			var nonVisited : Array = new Array();
			
			for (var c:int=0; c < mModel.Nodes.length; c++)
			{
				var curr : QuizNode = mModel.Nodes[c];
				
				if (mVisited.indexOf(curr) == -1 && (curr.Answers.length != 0))
					nonVisited.push(curr);
			}
			
			if (nonVisited.length != 0)
			{
				var idxToNode : int = Math.floor(nonVisited.length*Math.random()) as int;
				GotoNode(nonVisited[idxToNode]);
			}
		}
		
		public function GetNumVisitedNodesWithExits() : int
		{
			var ret : int = 0;
			
			for (var c:int=0; c < mVisited.length; c++)
			{
				if (mVisited[c].Answers.length != 0)
					ret++;
			}
			 
			return ret;
		}
		
		public function get CurrentNode() : QuizNode { return mCurrentNode; }
				
		private var mExecutionContext : Object = new Object();
		
		private var mCurrentNode : QuizNode;
		private var mModel : QuizModel;
		
		private var mVisited : Array = new Array;
	}
}