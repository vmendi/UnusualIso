package
{
	import flash.events.ProgressEvent;
	
	import mx.preloaders.DownloadProgressBar;
	
	/**
	 * http://livedocs.adobe.com/flex/3/html/help.html?content=app_container_4.html
	 */
	public class ProgressPreloader extends DownloadProgressBar 
	{
		public function ProgressPreloader()
		{
			downloadingLabel = "Descargando...";
			initializingLabel = "Inicializando...";
		}

		 // Override to return true so progress bar appears during initialization.       
        override protected function showDisplayForInit(elapsedTime:int, count:int):Boolean
        {
			return false;
        }

        // Override to return true so progress bar appears during download.
        override protected function showDisplayForDownloading(elapsedTime:int, event:ProgressEvent):Boolean
        {
                return true;
        }

	}
}