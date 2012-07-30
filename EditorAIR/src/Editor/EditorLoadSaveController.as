package Editor
{
	import Model.GameModel;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import utils.GenericEvent;
	
	public class EditorLoadSaveController extends EventDispatcher
	{
		public function EditorLoadSaveController(helper : ILoadSaveHelper)
		{
			mHelper = helper;		
			CreateNewGameModel();
		}
				
		private function CreateNewGameModel() : void
		{
			mGameModel = new GameModel(new EditorIsoEngine(this));

			mGameModel.addEventListener("GameModelLoaded", OnGameModelEvent, false, 0, true);
			mGameModel.addEventListener("LoadError", OnGameModelEvent, false, 0, true);
			
			// También nos queremos enterar y mostrar los errores de la librería
			mGameModel.TheAssetLibrary.addEventListener("LoadError", OnLibraryLoadError, false, 0, true);
		}
		
		public function get TheGameModel() : GameModel { return mGameModel; }
		public function get TheLoadSaveHelper() : ILoadSaveHelper { return mHelper; }

		public function LoadProjectUrl(url : String) : void
		{
			CreateNewGameModel();
			
		    mGameModel.Load(url);
		}
		
        public function OpenProject() : void
        {
        	mHelper.addEventListener("FileUrlForOpenSelected", OnProjectLoad);
        	mHelper.GetFileURLForOpen();
        }
  
        public function SaveProject() : void
        {
        	if (mGameModel.GameModelUrl == "Nuevo")
        	{
        		SaveAsProject();
        	}
        	else
        	{
				mHelper.SaveStringToFile(mGameModel.GetXML().toXMLString(), mGameModel.GameModelUrl);
				SaveLibrary();
        	}
        }
        
        public function SaveAsProject() : void
        {
        	mHelper.addEventListener("FileUrlSaved", OnProjectSave);
        	mHelper.SaveStringToFile(mGameModel.GetXML().toXMLString(), null);
        }
       
		private function OnProjectLoad(event:GenericEvent) : void
		{
			mHelper.removeEventListener("FileUrlForOpenSelected", OnProjectLoad);
			
			if (event.Data != null)
			{
				LoadProjectUrl(event.Data as String);
			}
		}
        
        private function OnProjectSave(event:GenericEvent):void
        {
        	mHelper.removeEventListener("FileUrlSaved", OnProjectSave);
        	
        	if (event.Data != null)
        	{
        		mGameModel.GameModelUrl = event.Data as String;
        	}
        	
        	SaveLibrary();
        }
        
        public function OpenLibrary() : void
        {
        	mHelper.addEventListener("FileUrlForOpenSelected", OnLibraryLoad);
        	mHelper.GetFileURLForOpen(); 
        }
        
        private function OnLibraryLoad(event:GenericEvent):void 
		{
			mHelper.removeEventListener("FileUrlForOpenSelected", OnLibraryLoad);
			
			if (event.Data != null)
			{
				mGameModel.TheAssetLibrary.addEventListener("LoadError", OnLibraryLoadError, false, 0, true);
				mGameModel.TheAssetLibrary.Load(event.Data as String);
			}
        }
        
        public function SaveLibrary() : void
        {
        	if (mGameModel.TheAssetLibrary.LibraryUrl == "Nuevo")
        	{
        		SaveAsLibrary();
        	}
        	else
        	{
				mHelper.SaveStringToFile(mGameModel.TheAssetLibrary.GetXML().toXMLString(), 
										 mGameModel.TheAssetLibrary.LibraryUrl);
        	}
        }
        
        public function SaveAsLibrary() : void
        {
        	mHelper.addEventListener("FileUrlSaved", OnLibrarySave);
        	mHelper.SaveStringToFile(mGameModel.TheAssetLibrary.GetXML().toXMLString(), null);
        }
        
        
        private function OnLibrarySave(event:GenericEvent):void
        {
        	mHelper.removeEventListener("FileUrlSaved", OnLibrarySave);
        	
        	if (event.Data != null)
        	{
        		mGameModel.TheAssetLibrary.LibraryUrl = event.Data as String;
        	}
        }
        
           
        public function New() : void
        {
        	CreateNewGameModel();
        	dispatchEvent(new Event("GameModelNew"));
        }
        
        public function SelectBackgroundSWF() : void
        {
        	mHelper.addEventListener("FileUrlForOpenSelected", OnBackgroundSWFToLoadSelected);
        	mHelper.GetFileURLForOpen();
        }
        
        public function OnBackgroundSWFToLoadSelected(event:GenericEvent) : void
        {
        	mHelper.removeEventListener("FileUrlForOpenSelected", OnBackgroundSWFToLoadSelected);
        	
        	if (event.Data != null)
        	{
        		mGameModel.TheIsoCamera.TheIsoBackground.SelectSWF(event.Data as String);
        	}
        }
        
        public function AddSWFToLibrary() : void
        {
        	mHelper.addEventListener("FileUrlForOpenSelected", OnSWFToLoadSelected);
        	mHelper.GetFileURLForOpen(); 
        }
        
        private function OnSWFToLoadSelected(event:GenericEvent):void
        {
        	mHelper.removeEventListener("FileUrlForOpenSelected", OnSWFToLoadSelected);
        	
        	if (event.Data != null)
        	{
        		mGameModel.TheAssetLibrary.AddSWFLibrary(event.Data as String);
        	}
        }

		
		private function OnGameModelEvent(event:Event):void
		{
			// Re-dispatchamos todo lo que nos diga el GameModel
			dispatchEvent(event);
		}
		
		private function OnLibraryLoadError(event:Event):void
		{
			// Tb redispachamos todo lo que nos diga la librería
			dispatchEvent(event);
		}
        
        
        private var mHelper : ILoadSaveHelper;
        private var mGameModel : GameModel;
	}
}