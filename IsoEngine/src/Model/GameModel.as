package Model
{
	import GameComponents.GameComponent;
	import GameComponents.IsoComponent;
	import GameComponents.Render2DComponent;

	import flash.display.DisplayObjectContainer;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;

	import utils.ArrayUtils;
	import utils.Point3;


	[Bindable]
	/**
	 * Objeto principal del juego. Lleva funciones centrales como la gestión de mundo y la librería de assets.
	 */
	public class GameModel extends EventDispatcher
	{
		/** IsoEngine que contiene a este GameModel. */
		public function get TheIsoEngine() : IsoEngine { return mIsoEngine; }

		/** Canvas en el que se renderiza todo el motor. */
		public function get TheRenderCanvas() : DisplayObjectContainer { return mRenderCanvas; }

		/** Url desde la que se cargó este GameModel. */
		public function get GameModelUrl() : String { return mGameModelUrl; }
		public function set GameModelUrl(url : String) : void { mGameModelUrl = url; }

		/** Cámara principal isometrica sobre la que se renderiza el juego. */
		public function get TheIsoCamera() : IsoCamera { return mIsoCamera; }

		/** Cámara 2D principal. */
		public function get TheRender2DCamera() : IsoCamera { return mRender2DCamera; }

		/** Librería principal y única de gestión de AssetObjects. */
		public function get TheAssetLibrary() : AssetLibrary { return mAssetLibrary; }

		/** Espacio de busqueda. No será creado hasta que se llame a StartGame(), y será destruido al llamar a StopGame(). */
		public function get TheAStartSpace() : AStartMapSpace { return mAStartMapSpace;	}

		/** Tamaño de la celda en metros. Este es el único punto en el que se define. */
		static public function get CellSizeMeters() : Number { return 0.5; }


		public function GameModel(isoEngine : IsoEngine)
		{
			mIsoEngine = isoEngine;
			mGameModelUrl = "Nuevo";

			mAssetLibrary = new AssetLibrary(isoEngine);

			mIsoCamera = new IsoCamera();
			mRender2DCamera = new IsoCamera();

			// Como a la librería la pueden modificar desde fuera, tenemos que estar atentos para sincronizar SceneObjects
			mAssetLibrary.addEventListener("LibraryLoaded", OnLibrarySynchronize, false, 0, true);
			mAssetLibrary.addEventListener("SWFLibraryRemoved", OnLibrarySynchronize, false, 0, true);

			mSceneObjs = new Array();
		}


		/**
		 * Obligado llamarla para que se comience a renderizar.
		 */
		public function AttachToRenderCanvas(theRenderCanvas : DisplayObjectContainer) : void
		{
			mRenderCanvas = theRenderCanvas;
			mRenderCanvas.addChild(mIsoCamera);
			mRenderCanvas.addChild(mRender2DCamera);

			mLastTime = flash.utils.getTimer();

			mRenderCanvas.addEventListener(Event.ENTER_FRAME, OnEnterFrame, false, 0, true);
			mRenderCanvas.addEventListener(Event.REMOVED_FROM_STAGE, OnRemovedFromStage, false, 0, true);
		}

		/**
		 * Elimina del canvas todo lo que estamos renderizando sobre él.
		 *
		 * Es útil cuando se quiere parar de renderizar este GameModel sobre un RenderCanvas
		 * que va a seguir siendo utilizado.
		 *
		 * Si el RenderCanvas suministrado en AttachToRenderCanvas es removido de la Stage, automáticamente
		 * nosotros también llamaremos a RemoveFromRenderCanvas y no hace falta que el cliente lo haga.
		 */
		public function RemoveFromRenderCanvas() : void
		{
			mLastTime = -1;
			mRenderCanvas.removeEventListener(Event.ENTER_FRAME, OnEnterFrame, false);
			mRenderCanvas.removeEventListener(Event.REMOVED_FROM_STAGE, OnRemovedFromStage, false);
			mRenderCanvas.removeChild(mRender2DCamera);
			mRenderCanvas.removeChild(mIsoCamera);
			mRenderCanvas = null;
		}

		private function OnRemovedFromStage(event:Event):void
		{
			// Nos quitamos automaticamente nosotros solos
			RemoveFromRenderCanvas();
		}

		/**
		 * Busca un SceneObject según el "Name" asignado dentro del "TheAssetObject.TheDefaultGameComponent.Name".
		 * Si hay varios con el mismo nombre, devuelve el primero que encuentre sin ningún orden en particular.
		 */
		public function FindSceneObjectByName(name : String) : SceneObject
		{
			var ret : SceneObject = null;

			for each(var sceneObj : SceneObject in mSceneObjs)
			{
				if (sceneObj.TheAssetObject.TheDefaultGameComponent.Name == name)
				{
					ret = sceneObj;
					break;
				}
			}

			return ret;
		}

		/**
		 * Igual que FindSceneObjectByName pero devolviendo <b>todos</b> los SceneObjects con el mismo nombre
		 */
		public function FindAllSceneObjectsByName(name : String): Array
		{
			var ret : Array = new Array();

			for each(var sceneObj : SceneObject in mSceneObjs)
			{
				if (sceneObj.TheAssetObject.TheDefaultGameComponent.Name == name)
					ret.push(sceneObj);
			}

			return ret;
		}

		/**
		 * Busca en todos los SceneObjects el componente de nombre corto dado, devolviendo el primero que encuentre.
		 */
		public function FindGameComponentByShortName(name : String) : GameComponent
		{
			var ret : GameComponent = null;

			for each(var sceneObj : SceneObject in mSceneObjs)
			{
				ret = sceneObj.TheAssetObject.FindGameComponentByShortName(name);

				if (ret != null)
					break;
			}

			return ret;
		}

		/**
		 * Busca en todos los SceneObjects todos los componentes de nombre corto dado.
		 *
		 * <p>Nota: Cada SceneObject sólo puede tener un componente con el mismo nombre.</p>
		 */
		public function FindAllGameComponentsByShortName(name : String) : Array
		{
			var ret : Array = new Array;

			for each(var sceneObj : SceneObject in mSceneObjs)
			{
				var gameComp : GameComponent = sceneObj.TheAssetObject.FindGameComponentByShortName(name);

				if (gameComp != null)
					ret.push(gameComp);
			}

			return ret;
		}


		/**
		 * Comienza a ejecutar el juego. Hay que llamar aquí para que todo se ponga en marcha. Se generan eventos de
		 * OnStart para los componentes, se empieza a llamar a OnUpdate()...
		 */
		public function StartGame() : void
		{
			mAStartMapSpace = new AStartMapSpace(GatherIsoComponents(), mIsoCamera.TheIsoBackground, CellSizeMeters);

			// Llamamos al OnStart de todos los componentes y los subscribimos a nuestros eventos
			for each(var sceneObj : SceneObject in mSceneObjs)
			{
				StartSceneObject(sceneObj);
			}

			mGameStarted = true;
		}

		private function StartSceneObject(sceneObj:SceneObject):void
		{
			for each(var comp : GameComponent in sceneObj.TheAssetObject.TheGameComponents)
			{
				comp.OnStart();
				addEventListener("OnUpdate", comp.OnUpdate, false, 0, true);
			}
		}

		/**
		 * Pausa y Resume del juego. Para toda la entrada de usuario, navegación, etc.
		 */
		public function PauseGame(pause : Boolean) : void
		{
			if (mPaused == pause)
				return;

			mPaused = pause;

			for each(var sceneObj : SceneObject in mSceneObjs)
			{
				for each(var comp : GameComponent in sceneObj.TheAssetObject.TheGameComponents)
				{
					if (pause)
					{
						comp.OnPause();
						removeEventListener("OnUpdate", comp.OnUpdate);
					}
					else
					{
						comp.OnResume();
						addEventListener("OnUpdate", comp.OnUpdate, false, 0, true);
					}
				}
			}
		}

		/**
		 * Conmuta la pausa. Función de comodidad igual que "PauseGame".
		 *
		 * @return Indica el estado actual de la pausa, on/off
		 */
		public function TogglePause() : Boolean
		{
			PauseGame(!mPaused);

			return mPaused;
		}

		/**
		 *  Para el juego. Llama a todos los OnStop, deja de llamar a OnUpdate, resetea el AStartMapSpace...
		 */
		public function StopGame() : void
		{
			for each(var sceneObj : SceneObject in mSceneObjs)
			{
				StopSceneObj(sceneObj);
			}

			mAStartMapSpace = null;
			mGameStarted = false;
		}

		private function StopSceneObj(sceneObj:SceneObject):void
		{
			for each(var comp : GameComponent in sceneObj.TheAssetObject.TheGameComponents)
			{
				removeEventListener("OnUpdate", comp.OnUpdate);
				comp.OnStop();
			}
		}

		/**
		 * Carga un mapa .xml de juego. No se puede llamar dos veces sobre el mismo objeto, para cargar un nuevo
		 * mapa hay que hacerlo sobre un "new GameModel()"
		 *
		 * <p>Lanza Evento: GameModelLoaded</p>
		 * <p>Lanza Evento: LoadError</p>
		 */
		public function Load(url : String) : void
		{
			if (mGameModelUrl != "Nuevo")
				throw "No soportado: Ya estamos cargados";

			mXMLLoader = new URLLoader();

			mXMLLoader.addEventListener("complete", xmlLoaded);
			mXMLLoader.addEventListener("ioError", xmlError);
			mXMLLoader.addEventListener("securityError", xmlError);
			mXMLLoader.load(new URLRequest(IsoEngine.BaseUrl+url));

			function xmlError(event:Event):void
			{
				mXMLLoader = null;

				dispatchEvent(new ErrorEvent("LoadError", false, false, event.toString() + "\n\n" + "GameModel: Error cargando " + url));
			}

			function xmlLoaded(event:Event):void
			{
				mGameModelUrl = url;

				var myXML:XML = XML(mXMLLoader.data);
				mXMLLoader = null;

				// Background
				mIsoCamera.TheIsoBackground.LoadFromXML(myXML.child("IsoBackground")[0]);

				// Libreria
				var libraryUrl : XMLList = myXML.child("LibraryUrl");

				mAssetLibrary.addEventListener("LibraryLoaded", internalOnLibraryLoaded);
				mAssetLibrary.Load(libraryUrl.toString());

				function internalOnLibraryLoaded(event:Event):void
				{
					mAssetLibrary.removeEventListener("LibraryLoaded", internalOnLibraryLoaded);

					for each(var sceneObjXML : XML in myXML.SceneObjs.child("SceneObj"))
					{
						var assetObj : AssetObject = new AssetObject(false);
						assetObj.LoadFromXML(sceneObjXML.child("AssetObject")[0]);

						// Ya no existe el MovieClip desde el que se creó porque lo han borrado de la librería?
						if (mAssetLibrary.FindAssetObjectByMovieClipName(assetObj.TheDefaultGameComponent.MovieClipName) != null)
						{
							var sceneObj : SceneObject = CreateSceneObjectNoClone(assetObj);

							sceneObj.LoadFromXML(sceneObjXML);
						}
					}

					dispatchEvent(new Event("GameModelLoaded"));
				}
			}
		}

		private function OnLibrarySynchronize(event:Event):void
		{
			// Tenemos que borrar todos los SceneObjects que ya no tengan su AssetObj
			for (var c : int = 0; c < mSceneObjs.length; c++)
			{
				var assetObj : Object = mAssetLibrary.FindAssetObjectByMovieClipName(mSceneObjs[c].TheAssetObject.TheDefaultGameComponent.MovieClipName);

				if (assetObj == null)
				{
					DeleteSceneObject(mSceneObjs[c]);
					c--;
				}
			}
		}


		/**
		 * Busca y devuelve todos los SceneObjs que están en las coordenadas del ratón "globalMouse". Estas coordenadas
		 * son globales, es decir, respecto a la stage.
		 * Está garantizado que se devuelven siempre en el mismo orden.
		 */
		public function FindUnderCursor(globalMouse : Point) : Array
		{
			var ret : Array = new Array();

			for (var c : int = 0; c < mSceneObjs.length; c++)
			{
				if (mSceneObjs[c].RealHitTest(globalMouse))
					ret.push(mSceneObjs[c]);
			}

			ret.sortOn(["ScreenY", "ScreenX"], Array.NUMERIC | Array.DESCENDING);

			return ret;
		}

		/**
		 * Chequea que el AssetObj asociado a mcName tenga los componentes adecuados para ser instanciado en la escena
		 */
		public function CanBeAddedToScene(mcName : String) : Boolean
		{
			var assetObj : AssetObject = mAssetLibrary.FindAssetObjectByMovieClipName(mcName);

			return assetObj.CanBeAddedToScene();
		}

		/**
		 * Creación de un nuevo SceneObject usando al AssetObj como template.
		 */
		public function CreateSceneObject(assetObj : AssetObject) : SceneObject
		{
			return CreateSceneObjectNoClone(assetObj.GetDeepClone());
		}

		private function CreateSceneObjectNoClone(assetObj : AssetObject) : SceneObject
		{
			var newObj : SceneObject = new SceneObject(this, assetObj);
			mSceneObjs.push(newObj);

			assetObj.AddToScene(newObj);

			if (mGameStarted)
				StartSceneObject(newObj);

			return newObj;
		}

		/**
		 * Dado el nombre del movieclip que define al AssetObject, crea un SceneObject y devuelve su componente
		 * de nombre "retComponentShortName". Si el componente no existe, devolverá null, pero el SceneObject
		 * habrá sido creado.
		 */
		public function CreateSceneObjectFromMovieClip(movieClipName:String, retComponentShortName:String):Object
		{
			var assetObj : AssetObject = TheAssetLibrary.FindAssetObjectByMovieClipName(movieClipName);
			var sceneObj : SceneObject = CreateSceneObject(assetObj);

			return sceneObj.TheAssetObject.FindGameComponentByShortName(retComponentShortName);
		}


		/**
		 * Borra del mapa de juego el SceneObject
		 */
		public function DeleteSceneObject(sceneObj : SceneObject) : void
		{
			if (mGameStarted)
				StopSceneObj(sceneObj);

			sceneObj.TheAssetObject.RemoveFromScene();

			ArrayUtils.removeValueFromArray(mSceneObjs, sceneObj);
		}

		/**
		 * Hace transparentes todos los objetos con IsoComponent que ocluyan al parámetro "characterIsoComp".
		 * Los objetos tienen que estar marcados como "TheIsoComponent.Transparent = true".
		 */
		public function MakeTransparentOthers(characterIsoComp : IsoComponent) : void
		{
			var idxStart : int = mSortedIsoComps.indexOf(characterIsoComp);

			for (var c:int = 0; c < mSortedIsoComps.length; c++)
			{
				var isoComp : IsoComponent = mSortedIsoComps[c];

				if (isoComp == characterIsoComp)
					continue;

				// Todos los que están por detras del personaje no son transparentes.
				if (c <= idxStart)
				{
					isoComp.TheSceneObject.MakeTransparent(false);
				}
				else
				{
					if (!isoComp.Transparent)
						continue;

					var myBounds : IsoBounds = characterIsoComp.Bounds;
					var otherBounds : IsoBounds = isoComp.Bounds;
					var margin : Number = 2 * CellSizeMeters;

					if (myBounds.Right <= otherBounds.Left)
						isoComp.TheSceneObject.MakeTransparent(false);
					else
					if (myBounds.Front <= otherBounds.Back)
						isoComp.TheSceneObject.MakeTransparent(false);
					else
					{
						if ((myBounds.Left - otherBounds.Right >= margin) ||
						    (myBounds.Back - otherBounds.Front >= margin))
						    isoComp.TheSceneObject.MakeTransparent(false);
						else
							isoComp.TheSceneObject.MakeTransparent(true);
					}
				}
			}
		}

		/**
		 * Serialización del modelo.
		 * @return Serialización de todo el juego listo para ser grabado a disco
		 */
		public function GetXML() : XML
		{
			var mapXML : XML = <Map></Map>

			var libraryUrlXML : XML = <LibraryUrl>{mAssetLibrary.LibraryUrl}</LibraryUrl>
			mapXML.appendChild(libraryUrlXML);

			var sceneObjsXML : XML = <SceneObjs></SceneObjs>
			mapXML.appendChild(sceneObjsXML);

			var backgroundXML : XML = mIsoCamera.TheIsoBackground.GetXML();
			mapXML.appendChild(backgroundXML);

			for (var c : int = 0; c < mSceneObjs.length; c++)
			{
				var sceneObjXML : XML = mSceneObjs[c].GetXML();
				sceneObjsXML.appendChild(sceneObjXML);
			}

			return mapXML;
		}

		/**
		 * Snap de coordenadas de mundo
		 * @return La misma posición worldPos pero ajustada al grid de celdas
		 */
		static public function GetSnappedWorldPos(worldPos : Point3) : Point3
		{
			return new Point3(Math.floor(worldPos.x/CellSizeMeters) * CellSizeMeters,
							  Math.floor(worldPos.y/CellSizeMeters) * CellSizeMeters,
							  Math.floor(worldPos.z/CellSizeMeters) * CellSizeMeters);
		}

		/**
		 * Snap de coordenadas de mundo, pero redondeando a la más cercana
		 * @return La misma posición worldPos pero ajustada al grid de celdas
		 */
		static public function GetRoundedWorldPos(worldPos : Point3) : Point3
		{
			return new Point3(Math.round(worldPos.x/CellSizeMeters) * CellSizeMeters,
							  Math.round(worldPos.y/CellSizeMeters) * CellSizeMeters,
							  Math.round(worldPos.z/CellSizeMeters) * CellSizeMeters);
		}

		/**
		 * Escribe el AssetObj parámetro sobre todos los que hay en el mapa que sean el mismo movieclip.
		 */
		public function CopyAssetObjectToAllSceneObjects(assetObj : AssetObject) : void
		{
			var assetObjName : String = assetObj.TheDefaultGameComponent.MovieClipName;

			for each(var sceneObj : SceneObject in mSceneObjs)
			{
				if (sceneObj.TheAssetObject.TheDefaultGameComponent.MovieClipName == assetObjName)
					sceneObj.TheAssetObject.Overwrite(assetObj);
			}
		}

		/**
		 * Activa/Desactiva el render de todos los SceneObjs.
		 */
		public function SetSceneObjectRendering(enabled : Boolean) : void
		{
			if (mSceneObjectRenderingEnabled == enabled)
				return;

			mSceneObjectRenderingEnabled = enabled;

			for each(var sceneObj : SceneObject in mSceneObjs)
				sceneObj.TheAssetObject.SetRenderingEnabled(mSceneObjectRenderingEnabled);
		}


		private function OnEnterFrame(event:Event) : void
		{
			var currentTime : int = flash.utils.getTimer();
			var elapsedTime : int = currentTime - mLastTime;

			Sort();

			dispatchEvent(new UpdateEvent("OnUpdate", 1000/mRenderCanvas.stage.frameRate));
			//dispatchEvent(new UpdateEvent("OnUpdate", elapsedTime));

			mLastTime = currentTime;
		}

		private function Sort() : void
		{
			if (!mSceneObjectRenderingEnabled)
				return;

			var sorter : IsoSorter = new IsoSorter();
			mSortedIsoComps = sorter.Sort(GatherIsoComponents());

			// Primero los IsoComps
			var numIsoComps : int = mSortedIsoComps.length;

			for (var c:int=0; c < numIsoComps; c++)
			{
				mIsoCamera.setChildIndex(mSortedIsoComps[c].TheVisualObject, c);
			}

			mIsoCamera.setChildIndex(mIsoCamera.TheIsoBackground, 0);

			// Orden en profundidad de los Render2D
			var render2DComps : Array = GatherRender2DComponents();

			render2DComps.sortOn("ZOrder", Array.NUMERIC);

			for (c=0; c < render2DComps.length; c++)
			{
				mRender2DCamera.setChildIndex(render2DComps[c].TheVisualObject, c);
			}
		}


		private function GatherIsoComponents() : Array
		{
			var ret : Array = new Array();

			for each(var sceneObj : SceneObject in mSceneObjs)
			{
				var isoComp : IsoComponent = sceneObj.TheAssetObject.TheIsoComponent;

				if (isoComp != null)
					ret.push(isoComp);
			}

			return ret;
		}

		private function GatherRender2DComponents() : Array
		{
			var ret : Array = new Array();

			for each(var sceneObj : SceneObject in mSceneObjs)
			{
				var comp : Render2DComponent = sceneObj.TheAssetObject.TheRender2DComponent;

				if (comp != null)
					ret.push(comp);
			}

			return ret;
		}


		private var mIsoEngine : IsoEngine;
		private var mRenderCanvas : DisplayObjectContainer;

		private var mGameModelUrl : String = "Nuevo";
		private var mXMLLoader : URLLoader;

		private var mSceneObjs : Array;
		private var mAssetLibrary : AssetLibrary;
		private var mIsoCamera : IsoCamera;
		private var mRender2DCamera : IsoCamera;

		private var mSceneObjectRenderingEnabled : Boolean = true;

		private var mAStartMapSpace : AStartMapSpace = null;
		private var mSortedIsoComps : Array = null;

		private var mGameStarted : Boolean = false;
		private var mPaused : Boolean = false;
		private var mLastTime : Number = 0;
	}
}