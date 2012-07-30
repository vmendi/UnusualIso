package Editor.QuizEditor
{
	import Editor.ILoadSaveHelper;
	
	import Quiz.QuizModel;
	import Quiz.QuizNode;
	
	import utils.GenericEvent;
	
	public class QuizEditorController
	{
		[Bindable]
		public var TheQuizModel : QuizModel;
				
        public function get SelectedNode() : QuizNode { return mSelectedNode; }
        public function set SelectedNode(sel : QuizNode):void { mSelectedNode = sel; }
		
		
		public function QuizEditorController(loadSaveHelper : ILoadSaveHelper)
		{
			mLoadSaveHelper = loadSaveHelper;
			
			New();
		}
		
		public function New() : void
		{
			TheQuizModel = new QuizModel();
		}
		
		public function Open() : void
        {
        	mLoadSaveHelper.addEventListener("FileUrlForOpenSelected", OnProjectLoaded);
        	mLoadSaveHelper.GetFileURLForOpen();
        }
        
        private function OnProjectLoaded(event:GenericEvent) : void
		{
			mLoadSaveHelper.removeEventListener("FileUrlForOpenSelected", OnProjectLoaded);
			
			if (event.Data != null)
			{
				New();
				TheQuizModel.Load(event.Data as String);
			}
		}
		
		public function Save() : void
        {
        	if (TheQuizModel.Url == "Nuevo")
        		SaveAs();
        	else
				mLoadSaveHelper.SaveStringToFile(TheQuizModel.GetXML().toXMLString(), TheQuizModel.Url);
        }
		
		public function SaveAs() : void
		{
			mLoadSaveHelper.addEventListener("FileUrlSaved", OnProjectSaved);
        	mLoadSaveHelper.SaveStringToFile(TheQuizModel.GetXML().toXMLString(), null);
		}
		
		private function OnProjectSaved(event:GenericEvent):void
        {
        	mLoadSaveHelper.removeEventListener("FileUrlSaved", OnProjectSaved);
        	
        	if (event.Data != null)
        		TheQuizModel.Url = event.Data as String;
        }
        
		private var mSelectedNode : QuizNode;			
		private var mLoadSaveHelper : ILoadSaveHelper;
	}
}