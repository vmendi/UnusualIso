package utils
{
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedSuperclassName;
	
	public class Type
	{
		//
		// Devuelve si una clase es hija del tipo parentTypeName. El nombre del tipo padre tiene que ser qualified, es decir,
		// flash.display::MovieClip. Se puede obtener por ejemplo con getQualifiedClassName(MovieClip).
		// No funcionará si es una herencia de interfaz (implements).
		//
		static public function IsSubclassOf(childClass : Class, parentQualifiedTypeName : String) : Boolean
		{
			var bRet : Boolean = false;
			var description : XML = flash.utils.describeType(childClass);
			var superclassQualifiedNames:XMLList = description.factory.extendsClass.@type;
						
			for (var c : int = 0; c < superclassQualifiedNames.length(); c++)
			{
				if (superclassQualifiedNames[c].toString() == parentQualifiedTypeName)
				{
					bRet = true;
					break;
				}
			}
			
			return bRet;
		}
	}
}