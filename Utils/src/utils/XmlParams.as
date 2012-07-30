package utils
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	public class XmlParams
	{
		public var TheParams : Dictionary = new Dictionary();
		
		public function XmlParams()
		{
			// Para forzar al linkado de todos los tipos que reconocemos, necesitamos listarlos aquí
			var forceLink : Curve = null;
		}


		public function LoadFromXML(xmlData:XML):void
		{
			for each(var paramXML : XML in xmlData.child("Param"))
			{
				var paramName : String = paramXML.Name.toString();
				var paramType : String = paramXML.Type.toString();
				var daParam : Object = null;
				
				// Manejamos los tipos básicos del sistema
				if (paramType == "Number")
				{
					daParam = parseFloat(paramXML.Value.toString());
				}
				else if(paramType == "Boolean")
				{
					daParam = (paramXML.Value.toString() == "true")? true : false;
				}
				else
				{
					// Instanciemos el tipo, tiene que estar en nuestro App Domain
					daParam = new (getDefinitionByName(paramType) as Class);
					
					// Tiene que existir esta funcion
					daParam.LoadFromXML(paramXML.child("Value")[0]);
				}
				
				TheParams[paramName] = daParam;
			}
		}
		
	}
}