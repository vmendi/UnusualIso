package Quiz
{	
	import flash.events.*;
	import flash.net.*;
	
	import mx.collections.ArrayCollection;
	
	/**
		- ModelLoaded: Se ha terminado de cargar el XML del modelo.
		- UrlChanged: Ha cambiado la URL del modelo (puede haberse cargado un nuevo nivel o no).
		- ModelLoadError: Cualquier error durante la carga o el refresco.
	 */
	[Bindable]
	public dynamic class QuizModel extends  EventDispatcher
	{
		public var Nodes : ArrayCollection;
		public var Texts : ArrayCollection;
		
		
		// Path+fileName (miCarpeta/Level.xml) relativo al directorio workspace desde el que se cargó el modelo
		public function get Url() : String { return mUrl; }
		public function set Url(url : String) : void
		{
			mUrl = url;
			dispatchEvent(new Event("UrlChanged"));
		}
		
		public function QuizModel() : void
		{
			Nodes = new ArrayCollection();
			Texts = new ArrayCollection();
			
			mUrl = "Nuevo";
		}
		
		public function AddText(id : String = null) : Object
		{
			if (id == null)
				id = GetBestID(Texts, "Text");
				
			var newText : Object = new Object;
			newText.TextID = id;
			newText.Text = "Default text";
			
			Texts.addItem(newText);
			
			return newText;
		}
		
		public function RemoveText(text : Object) : void
		{
			var idx : int = Texts.getItemIndex(text);
			Texts.removeItemAt(idx);
		}
			
		public function AddNode(id : String = null) : QuizNode
		{
			if (id == null)
				id = GetBestID(Nodes, "Node");

			var newNode : QuizNode = new QuizNode(id);
			Nodes.addItem(newNode);
			
			return newNode;
		}
		
		public function RemoveNode(node : QuizNode) : void
		{
			var idx : int = Nodes.getItemIndex(node);
        	Nodes.removeItemAt(idx);
		}
		
		public function MoveNodeToIdx(nodeID:String, idx:int) : void
		{
			var quizNode : Object = FindNodeByID(nodeID);
			Nodes.removeItemAt(Nodes.getItemIndex(quizNode));
			
			while (idx < Nodes.length)
			{
				quizNode = Nodes.setItemAt(quizNode, idx);
				idx++;
			}
			
			Nodes.addItem(quizNode);
		}
		
		
		public function FindNodeByID(id : String) : QuizNode
		{
			var ret : QuizNode = null;
			for each(var node : QuizNode in Nodes)
			{
				if (node.NodeID == id)
				{
					ret = node;
					break;
				}
			}			
			return ret;
		}
	
		public function FindTextByID(id : String) : String
		{
			var ret:String = id;
			
			for each (var txt : Object in Texts)
			{
				if (txt.TextID == id)
				{
					ret = txt.Text;
					break;
				}
			}
			return ret;
		}
		
		public function Load(url : String) : void
		{			
			var myXMLURL:URLRequest = new URLRequest(url);
			var myLoader:URLLoader = new URLLoader();
			myLoader.addEventListener("complete", xmlLoaded);
			myLoader.addEventListener("ioError", xmlIOError);
			myLoader.addEventListener("securityError", securityError);
			myLoader.load(myXMLURL);
						
			function xmlLoaded(event:Event):void
			{
				var myXML:XML = XML(myLoader.data);
				Nodes = new ArrayCollection();
								
				for each(var nodeXML : XML in myXML.child("Node"))
				{
					var node : QuizNode = new QuizNode(nodeXML.NodeID.toString());

					node.AnswerText = nodeXML.AnswerText.toString();
					node.QuestionText = nodeXML.QuestionText.toString();
					node.EnterCode = nodeXML.EnterCode.toString();
					node.ConditionCode = nodeXML.ConditionCode.toString();
					node.ExitCode = nodeXML.ExitCode.toString();

					// Lectura de las referencias a las respuestas según San Mateo					
					for each (var answerXML : XML in nodeXML.Answers.child("Answer"))
					{
						var nodeID : String = answerXML.NodeID.toString();
						node.Answers.addItem(nodeID);
					}
					
					Nodes.addItem(node);
				}
				
				Texts = new ArrayCollection();
				
				for each(var textXML : XML in myXML.child("DaText"))
				{
					var text : Object = new Object();
					text.TextID = textXML.TextID.toString();
					text.Text = textXML.Text.toString();
					
					Texts.addItem(text);
				}
				
				// Ya hemos cargado, cambiamos la URL
			    Url = url;
			    
			    // Notificamos
			    dispatchEvent(new Event("ModelLoaded"));
			}
			
			function xmlIOError(event:IOErrorEvent):void
			{
				dispatchEvent(new ErrorEvent("ModelError", false, false, "Error Cargando " + myXMLURL.url));
			}
			
			function securityError(event:SecurityErrorEvent):void
			{
				dispatchEvent(new ErrorEvent("ModelError", false, false, "Error de seguridad cargando " + myXMLURL.url));
			}
		}
		
		public function GetXML() : XML
		{
			var saveXML:XML = <QuizModel></QuizModel>

			for (var c : int = 0; c < Nodes.length; c++)
			{
				var nodeXML : XML = 
								<Node>
									<NodeID>{Nodes[c].NodeID}</NodeID>
									<AnswerText>{Nodes[c].AnswerText}</AnswerText>
									<QuestionText>{Nodes[c].QuestionText}</QuestionText>
									<EnterCode>{Nodes[c].EnterCode}</EnterCode>
									<ConditionCode>{Nodes[c].ConditionCode}</ConditionCode>
									<ExitCode>{Nodes[c].ExitCode}</ExitCode>
									<Answers></Answers>
								</Node>
				for (var d : int = 0; d < Nodes[c].Answers.length; d++)
				{
					var answerXML : XML = <Answer>
										  		<NodeID>{Nodes[c].Answers[d]}</NodeID>
										  </Answer>
					
					nodeXML.Answers.appendChild(answerXML);
				}

				saveXML.appendChild(nodeXML);
			}
			
			for (c = 0; c < Texts.length; c++)
			{
				var textXML : XML =	<DaText>
										<TextID>{Texts[c].TextID}</TextID>
										<Text>{Texts[c].Text}</Text>
									</DaText>
									
				saveXML.appendChild(textXML);					
			}
			

			return saveXML;
		}
		
		
		/* Un capricho, realmente se permiten IDs duplicados, no se hace nada por comprobarlo */
		static private function GetBestID(where:ArrayCollection, field:String):String
		{
			var biggestID : int = 0;
			for (var c:int = 0; c < where.length; c++)
			{
				// Match de 1 o más números
				var anyDigitRegExp : RegExp = /\d+/
				var digit : Array = where[c][field+"ID"].match(anyDigitRegExp);
				if (digit != null && digit.length > 0)
				{
					var digitString : String = digit[digit.length-1]
					var id : int = parseInt(digitString);
					if (id >= biggestID)
						biggestID = id+1;
				}
			}
			
			if (biggestID < 10)
				return field+"0"+biggestID.toString();
			else
				return field+biggestID.toString();
		}
		
		private var mUrl : String;
	}
}