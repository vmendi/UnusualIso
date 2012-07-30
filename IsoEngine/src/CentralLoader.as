package
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.system.ApplicationDomain;


	public class CentralLoader extends EventDispatcher
	{
		public function AddToQueue(url : String, isMovieClip:Boolean, appDomain : ApplicationDomain=null) : void
		{
			mQueue.push(new GenericLoadHelper(OnLoaded, OnProgress, url, isMovieClip, appDomain));
		}

		public function LoadQueue() : void
		{
			dispatchEvent(new Event("LoadStart"));

			mLoadedBytes = 0;
			mRemainingToLoad = mQueue.length;

			if (mQueue.length == 0)
				dispatchEvent(new Event("LoadComplete"));

			for each (var unique : GenericLoadHelper in mQueue)
			{
				unique.Load();
			}
		}

		public function GetLoadedContentFor(url : String) : Object
		{
			var ret : Object = null;

			for each (var unique : GenericLoadHelper in mQueue)
			{
				if (unique.URL == url)
				{
					ret = unique.TheLoader;
					break;
				}
			}

			return ret;
		}

		public function DiscardContents() : void
		{
			mLoadedBytes = 0;
			mTotalBytes = 0;
			mRemainingToLoad = 0;
			mQueue = new Array();
			mLoaders = new Array();
		}

		public function set TotalBytes(bytes : int) : void { mTotalBytes = bytes; }
		public function get TotalBytes() : int { return mTotalBytes; }

		public function get LoadedBytes() : int { return mLoadedBytes; }

		private function OnLoaded(loaded : GenericLoadHelper) : void
		{
			if (loaded.TheLoader == null)
			{
				dispatchEvent(new ErrorEvent("LoadError", false, false,  "Error de carga en CentralLoader: " + loaded.URL));
			}
			else
			{
				mRemainingToLoad--;

				if (mRemainingToLoad == 0)
					dispatchEvent(new Event("LoadComplete"));
			}
		}

		private function OnProgress(loading : GenericLoadHelper, loadedBytes : int, event:ProgressEvent) : void
		{
			// En el parametro nos pasan el diferencial respecto a la ultima vez
			mLoadedBytes += loadedBytes;

			var progressEvent : ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS, false, false, mLoadedBytes, mTotalBytes);
			dispatchEvent(progressEvent);
		}

		private var mLoadedBytes : int = 0;
		private var mTotalBytes : int = 0;
		private var mQueue : Array = new Array();
		private var mRemainingToLoad : int = 0;
		private var mLoaders : Array = new Array();
	}
}

import mx.controls.SWFLoader;
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.display.Loader;
import flash.system.LoaderContext;
import flash.events.ProgressEvent;


internal class GenericLoadHelper
{
	public function GenericLoadHelper(onLoaded : Function, onProgress : Function, url : String,
									  isMovieClip:Boolean, appDomain:ApplicationDomain)
	{
		mOnLoaded = onLoaded;
		mOnProgress = onProgress;
		mUrl = url;
		mIsMovieClip = isMovieClip;
		mLoader = null;
		mAppDomain = appDomain;
		mLastBytesLoaded = 0;
	}

	public function get IsMovieClip() : Boolean { return mIsMovieClip; }
	public function get TheLoader() : Object { return mLoader; }
	public function get URL() : String { return mUrl; }

	public function Load() : void
	{
		if (mLoader != null)
			throw "Ya cargados...";

		if (mUrl == null)
		{
			// Siempre que hay un fallo notificamos con TheLoader a null
			if (mOnLoaded != null)
				mOnLoaded(this);
		}
		else
		if (mIsMovieClip)
		{
			var swfLoader : Loader = new Loader();
			mLoader = swfLoader;

			swfLoader.contentLoaderInfo.addEventListener("complete", OnLoaded);
			swfLoader.contentLoaderInfo.addEventListener("ioError", OnError);
			swfLoader.contentLoaderInfo.addEventListener("securityError", OnError);
			swfLoader.contentLoaderInfo.addEventListener("progress", OnProgress);

			var context : LoaderContext = null;
			if (mAppDomain != null)
				context = new LoaderContext(false, mAppDomain);

			swfLoader.load(new URLRequest(IsoEngine.BaseUrl+mUrl), context);
		}
		else
		{
			var loader : URLLoader = new URLLoader();
			mLoader = loader;

			loader.addEventListener("complete", OnLoaded);
			loader.addEventListener("ioError", OnError);
			loader.addEventListener("securityError", OnError);
			loader.addEventListener("progress", OnProgress);

			loader.load(new URLRequest(mUrl));
		}
	}

	private function OnProgress(event:ProgressEvent):void
	{
		if (event.bytesLoaded == mLastBytesLoaded)
			return;

		if (mOnProgress != null)
			mOnProgress(this, event.bytesLoaded-mLastBytesLoaded, event);

		mLastBytesLoaded = event.bytesLoaded;
	}

	private function OnLoaded(event:Event):void
	{
		if (mOnLoaded != null)
			mOnLoaded(this);
	}

	private function OnError(event:Event):void
	{
		trace("MovieClipLoadHelper: Error cargando " + mUrl);

		mLoader = null;

		if (mOnLoaded != null)
			mOnLoaded(this);
	}

	private var mIsMovieClip : Boolean = false;
 	private var mUrl : String = "";
 	private var mLoader : Object;
 	private var mOnLoaded : Function = null;
 	private var mOnProgress : Function = null;
 	private var mAppDomain : ApplicationDomain = null;
 	private var mLastBytesLoaded : int = 0;
}