package Model
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.getQualifiedClassName;

	import mx.collections.ArrayCollection;

	import utils.Delegate;
	import utils.GenericEvent;
	import utils.Type;
	import utils.getDefinitionNames;


	/**
	 * Librería de AssetObjs. Gestiona los SWFs disponibles, manteniendo un AssetObj por cada MovieClip en estos
	 * SWFs.
	 *
	 * Cada vez que se añade un SWF a la librería, ésta se ocupa de enumerar los MovieClip <b>exportados</b>,
	 * sólo los exportados. Crea un nuevo AssetObject por cada MovieClip que antes no existiera.
	 *
	 * Cuando se carga una librería desde disco y por lo tanto se cargan todos los SWFs a los que referencia,
	 * también se borran todos los AssetObjects que se hayan quedado sin su correspondiente MovieClip porque
	 * se hayan borrado del SWF.
	 */
	public class AssetLibrary extends EventDispatcher
	{
		public function get LibraryUrl() : String { return mLibraryUrl; }
		public function set LibraryUrl(url : String) : void { mLibraryUrl = url; }


		[Bindable(event="SWFLibrariesChanged")]
		public function get SWFLibraries() : ArrayCollection { return mSWFLibraries; }


		public function AssetLibrary(isoEngine : IsoEngine) : void
		{
			mIsoEngine = isoEngine;
		}

		/**
		 * Crea y devuelve un MovieClip, que tiene que estar exportando en cualquiera de los SWFs cargados con
		 * el nombre pasado como parámetro "mcName".
		 */
		public function CreateMovieClip(mcName : String) : MovieClip
		{
			var mcClass : Class = null;

			try
			{
				mcClass = mLoadedAppDomain.getDefinition(mcName) as Class;
			}
			catch(e:Error)
			{
			}

			var ret : MovieClip = null;

			if (mcClass != null)
			{
				ret = new mcClass as MovieClip;
				ret.cacheAsBitmap = true;
			}

			return ret;
		}

		/**
		 * Devuelve el AssetObject cuyo MovieClip asociado es "mcName"
		 */
		public function FindAssetObjectByMovieClipName(mcName : String) : AssetObject
		{
			var ret : AssetObject = null;
			for each(var obj : AssetObject in mAssetObjects)
			{
				if (obj.TheDefaultGameComponent.MovieClipName == mcName)
				{
					ret = obj;
					break;
				}
			}

			return ret;
		}

		public function GetXML() : XML
		{
			var libraryXML : XML = <Library></Library>
			var assetObjectsXML : XML = <AssetObjects></AssetObjects>
			libraryXML.appendChild(assetObjectsXML);

			var swfLibraryUrlsXML : XML = <SWFLibraryUrls></SWFLibraryUrls>
			libraryXML.appendChild(swfLibraryUrlsXML);

			var totalBytesInSWFs : XML = <TotalBytesInSWFs>{mTotalBytesInSWFs}</TotalBytesInSWFs>
			libraryXML.appendChild(totalBytesInSWFs);

			for (var c : int = 0; c < mSWFLibraries.length; c++)
			{
				var swfPathXML : XML = <SWFLibraryUrl>{mSWFLibraries[c].Url}</SWFLibraryUrl>
				swfLibraryUrlsXML.appendChild(swfPathXML);
			}

			for (c = 0; c < mAssetObjects.length; c++)
			{
				assetObjectsXML.appendChild(mAssetObjects[c].GetXML());
			}

			return libraryXML;
		}


		/**
		 * Carga una librería desde un XML
		 */
		public function Load(url : String) : void
		{
			if (url.length == 0)
				throw "URL Vacia";

			if (url == "Nuevo")
			{
				OnLoadEnd();
				return;
			}

			mXMLLoader = new URLLoader();

			mXMLLoader.addEventListener("complete", xmlLoaded);
			mXMLLoader.addEventListener("ioError", dispatchLoadError);
			mXMLLoader.addEventListener("securityError", dispatchLoadError);
			mXMLLoader.load(new URLRequest(IsoEngine.BaseUrl+url));

			function xmlLoaded(event:Event):void
			{
				mLibraryUrl = url;
				mLoadedAppDomain = null;
				mSWFLibraries = new ArrayCollection();
				mAssetObjects = new ArrayCollection();

				var myXML:XML = XML(mXMLLoader.data);
				mXMLLoader = null;

				mTotalBytesInSWFs = parseInt(myXML.TotalBytesInSWFs.toString());

				for each(var swfLibraryUrlXML : XML in myXML.SWFLibraryUrls.child("SWFLibraryUrl"))
				{
					mSWFLibraries.addItem({ Url:swfLibraryUrlXML.toString(), MovieClipNames:new ArrayCollection() } );
				}

				for each(var nodeXML : XML in myXML.AssetObjects.child("AssetObject"))
				{
					var assetObj : AssetObject = new AssetObject();
					assetObj.LoadFromXML(nodeXML);

					mAssetObjects.addItem(assetObj);
				}

				// Cargamos ahora los assets gráficos de los SWF
				LoadSWFLibrary();
			}

			function dispatchLoadError(event:Event) : void
			{
				mXMLLoader = null;

				dispatchEvent(new ErrorEvent("LoadError", false, false, event.toString() + "\n\nAssetLibrary: Error cargando " + url));
			}
		}

		private function LoadSWFLibrary() : void
		{
			mLoadedAppDomain = new ApplicationDomain();

			var centralLoader : CentralLoader = mIsoEngine.TheCentralLoader;
			centralLoader.addEventListener("LoadComplete", OnSWFsLoadComplete);
			centralLoader.addEventListener("LoadError", OnSWFsLoadError);

			for (var c : int = 0; c < mSWFLibraries.length; c++)
			{
				centralLoader.AddToQueue(mSWFLibraries[c].Url, true, mLoadedAppDomain);
			}

			// Configuramos el contador de bytes totales para mostrar correctamente el progreso
			if (mTotalBytesInSWFs != -1)
				centralLoader.TotalBytes += mTotalBytesInSWFs;

			// Tsk Tsk
			centralLoader.LoadQueue();
		}

		private function OnSWFsLoadComplete(event:Event) : void
		{
			var centralLoader : CentralLoader = (event.target as CentralLoader);

			// Nos tenemos que desuscribir puesto que el CentralLoader sirve para multiples cargas
			centralLoader.removeEventListener("LoadComplete", OnSWFsLoadComplete);
			centralLoader.removeEventListener("LoadError", OnSWFsLoadError);

			for (var c : int = 0; c < mSWFLibraries.length; c++)
			{
				var loader : Loader = centralLoader.GetLoadedContentFor(mSWFLibraries[c].Url) as Loader;
				GatherMovieClipNames(loader.contentLoaderInfo, c);
			}

			// Re-inicializamos el contador de bytes con el valor verdadero de esta vez
			mTotalBytesInSWFs = centralLoader.LoadedBytes;

			OnLoadEnd();
		}

		private function OnSWFsLoadError(event:ErrorEvent) : void
		{
			(event.target as CentralLoader).removeEventListener("LoadComplete", OnSWFsLoadComplete);
			(event.target as CentralLoader).removeEventListener("LoadError", OnSWFsLoadError);

			dispatchEvent(event);
		}

		private function OnLoadEnd() : void
		{
			// El gather ya tiene que estar hecho, podemos sincronizar los AssetObjs con los SWFs
			SyncAssetObjects();

			dispatchEvent(new Event("SWFLibrariesChanged"));
			dispatchEvent(new Event("LibraryLoaded"));
		}

		//
		// Está el nombre del MovieClip exportado en alguno de los SWFs?
		//
		private function IsMovieClipNameInSWFLibraries(mcName : String) : Boolean
		{
			var bRet : Boolean = false;

			for (var c : int = 0; c < mSWFLibraries.length; c++)
			{
				if (mSWFLibraries[c].MovieClipNames.contains(mcName))
				{
					bRet = true;
					break;
				}
			}

			return bRet;
		}

		//
		// Se encarga de borrar los AssetObjs que ya no están entre los movieclips y de crear los nuevos
		//
		private function SyncAssetObjects():void
		{
			// Borramos los AssetObjects obsoletos (ha desaparecido su MovieClip dentro de todos los SWFs!)
			for (var c : int = 0; c < mAssetObjects.length; c++)
			{
				if (!IsMovieClipNameInSWFLibraries(mAssetObjects[c].TheDefaultGameComponent.MovieClipName))
				{
					mAssetObjects.removeItemAt(c);
					c--;
				}
			}

			// Sincronizamos los AssetObjs de todas las librerías
			for (c = 0; c < mSWFLibraries.length; c++)
			{
				SyncAssetObjectsInSWFLibray(c);
			}
		}

		private function SyncAssetObjectsInSWFLibray(swfLibraryIndex : int):void
		{
			mSWFLibraries[swfLibraryIndex].AssetObjects = new ArrayCollection();

			for (var c : int = 0; c < mSWFLibraries[swfLibraryIndex].MovieClipNames.length; c++)
			{
				var mcName : String = mSWFLibraries[swfLibraryIndex].MovieClipNames[c];
				var assetObj : Object = FindAssetObjectByMovieClipName(mcName);

				// Si no existe, viene de nuevas en este SWF y hay que crearle su AssetObject correspondiente
				if (assetObj == null)
				{
					assetObj = new AssetObject();
					assetObj.TheDefaultGameComponent.MovieClipName = mcName;

					// Hay que añadirlo tb a la lista global
					mAssetObjects.addItem(assetObj);
				}

				mSWFLibraries[swfLibraryIndex].AssetObjects.addItem(assetObj);
			}
		}

		private function GatherMovieClipNames(loaderInfo:LoaderInfo, swfLibraryIndex : int):void
		{
			if (loaderInfo == null)
				return;

			// Generamos la lista de nombres de los movieclips disponibles usando la libreria enumeradora
			var defNames : Array = utils.getDefinitionNames(loaderInfo);

			for (var c:int=0; c < defNames.length; c++)
			{
				// Quitamos los no exportados (asumimos que llevan un ::)
				if (defNames[c].indexOf("::") == -1)
				{
					// ¿ Está duplicado ?
					if (!IsMovieClipNameInSWFLibraries(defNames[c]))
					{
						// Quitamos también todo lo que no sea movieclip, por ejemplo sonidos
						var theClass : Class = mLoadedAppDomain.getDefinition(defNames[c]) as Class;

						if (utils.Type.IsSubclassOf(theClass, getQualifiedClassName(MovieClip)))
							mSWFLibraries[swfLibraryIndex].MovieClipNames.addItem(defNames[c]);
					}
					else
					{
						// En caso de duplicado damos un mensaje de aviso y no lo añadimos
						dispatchEvent(new ErrorEvent("LoadError", false, false, "Nombre de movieclip duplicado.\nLibrería: " +
													  mSWFLibraries[swfLibraryIndex].Url + " MovieClip: " + defNames[c]));
					}
				}
			}
		}

		/**
		 * Añade un SWF a la librería
		 */
		public function AddSWFLibrary(url : String) : void
		{
			if (mLoadedAppDomain == null)
				mLoadedAppDomain = new ApplicationDomain();

			var urlRequest : URLRequest = new URLRequest(url);
			mSWFLoader = new Loader();

			mSWFLoader.contentLoaderInfo.addEventListener("complete", Delegate.create(swfLoaded, url));
			mSWFLoader.contentLoaderInfo.addEventListener("ioError", ioError);
			mSWFLoader.contentLoaderInfo.addEventListener("securityError", ioError);

			var context : LoaderContext = new LoaderContext(false, mLoadedAppDomain);
			mSWFLoader.load(urlRequest, context);

			function swfLoaded(event:Event, url : String):void
			{
				mSWFLoader = null;

				mSWFLibraries.addItem({ Url:url, MovieClipNames:new ArrayCollection});

				var idxToLast : int = mSWFLibraries.length-1;

				GatherMovieClipNames(event.target as LoaderInfo, idxToLast);
				SyncAssetObjectsInSWFLibray(idxToLast);

				dispatchEvent(new Event("SWFLibrariesChanged"));
				dispatchEvent(new GenericEvent("SWFLibraryAdded", mSWFLibraries[idxToLast]));
			}

			function ioError(event:Event):void
			{
				mSWFLoader = null;
				dispatchEvent(new ErrorEvent("LoadError", false, false, "Error cargando SWF " + url));
			}
		}

		public function RemoveSWFLibrary(swfLibrary : Object) : void
		{
			var idxToRemove : int = mSWFLibraries.getItemIndex(swfLibrary);

			if (idxToRemove == -1) throw "Unexpected Bug";

			// Quitamos los AssetObjects de nuestra lista global
			for each(var assetObj : AssetObject in swfLibrary.AssetObjects)
			{
				mAssetObjects.removeItemAt(mAssetObjects.getItemIndex(assetObj));
			}

			mSWFLibraries.removeItemAt(idxToRemove);

			dispatchEvent(new Event("SWFLibrariesChanged"));
			dispatchEvent(new GenericEvent("SWFLibraryRemoved", swfLibrary));
		}

		private var mSWFLoader : Loader = null;	// Lo necesitamos para evitar la descarga por el recolector
		private var mXMLLoader : URLLoader = null;

		private var mLoadedAppDomain : ApplicationDomain;

		private var mSWFLibraries : ArrayCollection = new ArrayCollection();	//	{ Url: , MovieClipNames: , AssetObjects: , LoaderInfo: }
		private var mLibraryUrl : String = "Nuevo";

		// Global con todos los AssetObjets, para no tener que acceder a través de la mSWFLibrary
		private var mAssetObjects : ArrayCollection = new ArrayCollection();

		// Para objeter el CentralLoader, necesitamos el IsoEngine
		private var mIsoEngine : IsoEngine = null;

		// Num total de bytes que hemos cargado la última vez que cargamos todos los SWFs
		private var mTotalBytesInSWFs : int = -1;
	}
}