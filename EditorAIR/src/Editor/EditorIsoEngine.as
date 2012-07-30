package Editor
{
	import flash.display.DisplayObjectContainer;

	/**
	 * IsoEngine para ser usado por el editor, realmente hace de proxy para el LoadSaveController 
	 */
	public class EditorIsoEngine extends IsoEngine
	{
		public function EditorIsoEngine(loadSaveController : EditorLoadSaveController)
		{
			super(null);
			
			mLoadSaveController = loadSaveController;
		}
		
		override public function Load(pathToMap:String):void
		{
			// Podemos parar el juego con seguridad, aquí sólo llaman los componentes.
			mLoadSaveController.TheGameModel.StopGame();
			
			// Le pedimos al controlador q cargue nuevo mapa como si el usuario lo hubiera pedido
			// desde la opción de menú.
			mLoadSaveController.LoadProjectUrl(pathToMap);
		}
		
		private var mLoadSaveController : EditorLoadSaveController;		
	}
}