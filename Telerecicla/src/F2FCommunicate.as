package
{
	import com.flash2flash.ecoembes.Communicate;
	import com.flash2flash.ecoembes.CommunicateEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.Security;
	
	import mx.core.Application;
	
	import utils.GenericEvent;
	import utils.UIComponentWrapper;



	public class F2FCommunicate extends EventDispatcher
	{
		public function F2FCommunicate(app:Application, gameID : int)
		{
			mApp = app;
			mGameID = gameID;

			if (mApp.loaderInfo.loader != null)
			{
				Security.allowDomain("*");

				mComm = new Communicate();

				mApp.loaderInfo.loader.addEventListener("startGameAnswer", OnStartGameAnswer);
				mApp.loaderInfo.loader.addEventListener("endGameAnswer", OnEndGameAnswer);
				mApp.loaderInfo.loader.addEventListener("loadXMLAnswer", OnLoadXMLAnswer);

				var wrapper : UIComponentWrapper = new UIComponentWrapper(mComm);
				mApp.addChild(wrapper);
			}
		}
		
		public function SetUserID(userID:String):void
		{
			mStrUserID = userID;	
		}
		
		public function RequestStart() : void
		{
			if (mComm == null)
				return;
						
			mComm.requestStart(mGameID, mStrUserID);	
		}

		public function RequestProvinciasXML():void
		{
			if (mComm == null)
				return;

			mComm.requestXML();
		}

		private function OnLoadXMLAnswer(event:CommunicateEvent):void
		{
			if (event.nExito == 1)
			{
				dispatchEvent(new GenericEvent("XMLAnswer", event.strXMLProvincias));
			}
			else
			{
				// ... Manejo de error
			}
		}


		public function SaveScoreToServer(score : Number, success:Boolean, idProv:int=0) : void
		{
			if (mComm == null)
				return;

			mScore = score;
			mProvID = idProv;
			mScoreSuccess = success;

			mComm.requestEnd(mGameID, mStrHash, mScore, mScoreSuccess, mProvID, mStrUserID);
		}

		private function OnStartGameAnswer(event:CommunicateEvent):void
		{
			if (event.nExito == 1)
			{
				mStrHash = event.strHash;
				dispatchEvent(new Event("ServerConnected"));	
			}
			else
			{
				dispatchEvent(new Event("ServerError"));
				
				// ... TODO: Manejo de error hacia el interface del juego
				// mApp["myTA"].text += "error en F2FCommunicate:OnStartGameAnswer " + event.nExito;
			}
		}

		private function OnEndGameAnswer(event:CommunicateEvent):void
		{
			if (event.nExito != 1)
			{
				// ... TODO: Manejo de error hacia el interface del juego
				//mApp["myTA"].text += "error en F2FCommunicate:OnEndGameAnswer " + event.nExito;
			}
			else
			{
				// Exito al grabar
				//mApp["myTA"].text += "AlabamAlabamAlabimbombam";
			}
		}

		private var mGameID : int = -1;
		private var mStrUserID : String = "";
		private var mStrHash : String = "";
		private var mProvID : int = 0;
		private var mScore : Number;
		private var mScoreSuccess : Boolean;
		
		private	var mComm : Communicate;
		private var mApp : Application;
	}
}