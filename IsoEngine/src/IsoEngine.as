package
{
	import Model.GameModel;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class IsoEngine extends EventDispatcher
	{
		/** Para poder pasar estado entre carga y carga de mapa */
		public var GameDef : Object;

		/**
		 *  Al cargar dentro de facebook nos encontramos con que la ruta tiene que ser absoluta, así
		 *  que todos lo assets que el motor cargue se compondran con este path
		 */
		public static var BaseUrl : String = "";

		/**
		 * Sistema de carga centralizado: el motor carga todos sus assets a traves de él, y el cliente
		 * o los componentes pueden cooperar.
		 */
		public function get TheCentralLoader() : CentralLoader { return mCentralLoader; }
		
		public function get TheGameModel() : GameModel { return mGameModel; }

		/**
		 * Parent es dónde el motor hará su render. Un Canvas con el clipping activado por ejemplo.
		 */
		public function IsoEngine(parent : DisplayObjectContainer)
		{
			mParent = parent;
			mCentralLoader = new CentralLoader();

			GameDef = new Object();
		}

		/**
		 * Función de carga para que los componentes puedan cargar otro mapa.
		 * En Standalone llamaremos aquí directamente al iniciar el engine.
		 */
		virtual public function Load(pathToMap:String):void
		{
			// Limpiamos el anterior
			if (mGameModel != null)
			{
				mGameModel.StopGame();
				mGameModel.RemoveFromRenderCanvas();
				mGameModel = null;
				mController = null;

				mCentralLoader.DiscardContents();
			}

			// Carga
			mGameModel = new GameModel(this);
			mGameModel.addEventListener("GameModelLoaded", OnGameModelLoaded, false, 0, true);
			mGameModel.Load(pathToMap);
		}

		protected function OnGameModelLoaded(event:Event):void
		{
			mController = new StandaloneController(mGameModel);
			mGameModel.AttachToRenderCanvas(mParent);
			mController.StartGame();
		}
		

		private var mParent : DisplayObjectContainer = null;
		private var mController : StandaloneController = null;
		private var mCentralLoader : CentralLoader = null;
		private var mGameModel :  GameModel = null;
	}
}