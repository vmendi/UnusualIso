package
{
	import Editor.ILoadSaveHelper;
	
	import EditorUtils.FileUtils;
	import EditorUtils.XMLLoadSave;
	
	import Model.GameModel;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	import utils.Delegate;
	import utils.GenericEvent;
	
	public class LoadSaveHelperAIR extends EventDispatcher implements ILoadSaveHelper
	{
		public function LoadSaveHelperAIR()
		{
		}
        
        public function GetFileURLForOpen() : void
        {
        	var directory:File = File.applicationDirectory;
			
			try
			{
				directory.browseForOpen("Selección de fichero...");
				directory.addEventListener(Event.SELECT, OnFileUrlSelectedForLoad);
				directory.addEventListener(Event.CANCEL, OnFileUrlCancelledForLoad);
			}
			catch (error:Error)
			{
				dispatchEvent(new GenericEvent("FileUrlForOpenSelected", null));
			}
        }
        
        private function OnFileUrlCancelledForLoad(event:Event):void
        {
        	dispatchEvent(new GenericEvent("FileUrlForOpenSelected", null));
        }
        
        private function OnFileUrlSelectedForLoad(event:Event):void 
		{
			var daFile : File = event.target as File;
			
		    dispatchEvent(new GenericEvent("FileUrlForOpenSelected", 
		    			  EditorUtils.FileUtils.GetPathRelativeToWorkSpace(daFile)));
		}
		
		public function SaveStringToFile(textToSave : String, url : String = null) : void
		{
			// Hay que consultar al usuario?
			if (url == null)
			{
				var directory:File = EditorUtils.FileUtils.GetApplicationDirAbsolute();
	
				try
				{
				    directory.browseForSave("Selección de fichero...");
				    directory.addEventListener(Event.SELECT, Delegate.create(OnFileUrlSelectedForSave, textToSave));
				    directory.addEventListener(Event.CANCEL, OnFileUrlCancelledForSave);
				}
				catch (error:Error)
				{
					dispatchEvent(new GenericEvent("FileUrlSaved", null));
				}
			}
			else
			{
				EditorUtils.XMLLoadSave.Save(EditorUtils.FileUtils.GetAbsolutePath(url).url, textToSave);
				dispatchEvent(new GenericEvent("FileUrlSaved", url));
			}
		}
		
		private function OnFileUrlCancelledForSave(event:Event):void
		{
			dispatchEvent(new GenericEvent("FileUrlSaved", null));
		}
		
		private function OnFileUrlSelectedForSave(event:Event, textToSave : String):void
		{
			var daFile : File = event.target as File;
        	if (daFile.extension == null)
				daFile = new File(daFile.nativePath + ".xml");

			EditorUtils.XMLLoadSave.Save(daFile.url, textToSave);
			dispatchEvent(new GenericEvent("FileUrlSaved", EditorUtils.FileUtils.GetPathRelativeToWorkSpace(daFile)));
		}
        
        private var mGameModel : GameModel;
	}
}