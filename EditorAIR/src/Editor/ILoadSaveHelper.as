package Editor
{
	import flash.events.IEventDispatcher;
	
	public interface ILoadSaveHelper extends IEventDispatcher
	{
		/*
		 * Dispatcha GenericEvent("FileUrlForOpenSelected") tanto en caso de exito como de fracaso, con Data siendo la url
		 * del archivo seleccionado o null en caso de fracaso.
		 * Está garantizado que hace Dispatch con el resultado que sea.
		 */  
		function GetFileURLForOpen() : void;
		
		/* 
		 * Graba a un fichero .xml el texto 'textToSave'. Si la url es null, pregunta al usuario.
		 * Dispatcha GenericEvent("FileUrlSaved") tanto en caso de exito como de fracaso, con data siendo la url o null.
		 * Está garantizado que hace Dispatch con el resultado que sea
		 */
		function SaveStringToFile(textToSave : String, url : String = null) : void;
	}
}