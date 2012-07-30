package utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	public final class Server extends EventDispatcher
	{
		private var mBase : String = "http://www.unusualwonder.com/";
		
		public function Server(baseUrl:String)
		{
			mBase = baseUrl;
		}
		
		public function Request(variables:URLVariables, func : String) : void
		{	
			var antiCache : int = Math.random()*9999999;
			var url:String = mBase+func+"?"+antiCache;
			var req:URLRequest = new URLRequest(url);
			req.method = URLRequestMethod.POST;
			req.data = variables;
			
			mURLLoader = new URLLoader();
			
			mURLLoader.addEventListener(Event.COMPLETE, OnRequestComplete);
			mURLLoader.addEventListener(IOErrorEvent.IO_ERROR, OnRequestError);
			
			try	{
				mURLLoader.load(req);
			} 
			catch (error:Error)
			{
				dispatchEvent(new Event("RequestError"));
			}
		}		
		
		private function OnRequestComplete(e:Event) : void
		{
			var loader:URLLoader = e.target as URLLoader;
		
			dispatchEvent(new GenericEvent("RequestComplete", loader.data));	
		}
		
		private function OnRequestError(e:IOErrorEvent):void
		{
			trace("Server: Request Error");
			dispatchEvent(new Event("RequestError"));
		}
		
		private var mURLLoader : URLLoader;
	}
}