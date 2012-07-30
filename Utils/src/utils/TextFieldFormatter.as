package utils
{
	import flash.text.TextField;
	
	public final class TextFieldFormatter
	{
		static public function InsertReturns(ctTextField : TextField, input : String) : String
		{
			ctTextField.text = input;
			
			var numLines : int = ctTextField.numLines;
			
			// Vemos los indices donde va cada return
			var returnIndices : Array = new Array;
			var lengthSoFar : int = 0;
			
			for (var line:int = 0; line < numLines-1; line++)
			{
				var lineLength : int = ctTextField.getLineLength(line);
				returnIndices.push(lengthSoFar + lineLength);
				lengthSoFar += lineLength;
			}
			
			// Introducimos los retornos de carro 
			var withReturns : String = input.slice(0);
			for (line = returnIndices.length-1; line >= 0; line--)
			{
				withReturns = withReturns.slice(0, returnIndices[line]) + "\r" + withReturns.slice(returnIndices[line]);
			}
		
			return withReturns;
		}
	}
}