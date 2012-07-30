package GameComponents.TeleRecicla
{
	import GameComponents.GameComponent;

	import com.facebook.Facebook;
	import com.facebook.commands.users.GetInfo;
	import com.facebook.data.users.FacebookUser;
	import com.facebook.data.users.GetInfoData;
	import com.facebook.data.users.GetInfoFieldValues;
	import com.facebook.events.FacebookEvent;
	import com.facebook.net.FacebookCall;
	import com.facebook.utils.FacebookSessionUtil;

	import flash.events.Event;
	import flash.events.MouseEvent;


	public class AmarilloMain extends GameComponent
	{
		override public function OnStart() : void
		{
			if (TheGameModel.TheIsoEngine.GameDef.GameID != null && TheGameModel.TheIsoEngine.GameDef.GameID == 5)
			{
				mSession = new FacebookSessionUtil(API_KEY, null, TheVisualObject.stage.loaderInfo);
				mSession.addEventListener(FacebookEvent.CONNECT, OnFacebookConnect);
				mSession.addEventListener(FacebookEvent.WAITING_FOR_LOGIN, OnWaitingForLogin);
				mSession.addEventListener(FacebookEvent.VERIFYING_SESSION, OnVerifyingSession);

				mFacebook = mSession.facebook;

				mSession.verifySession();
			}
			else
			{
				(TheGameModel.FindGameComponentByShortName("AmarilloGame") as AmarilloGame).StartGame();
			}
		}


		private function OnVerifyingSession(event:Event):void
		{
		}

		private function OnWaitingForLogin(event:Event):void
		{
		}

		private function OnFacebookConnect(event:FacebookEvent):void
		{
			if (mFacebook.is_connected)
			{
				var getInfo : GetInfo = new GetInfo([mFacebook.uid], [GetInfoFieldValues.ALL_VALUES]);
				var call : FacebookCall = mFacebook.post(getInfo);
				call.addEventListener(FacebookEvent.COMPLETE, OnGetInfoCallComplete);
			}
		}

		private function OnGetInfoCallComplete(event:FacebookEvent):void
		{
			var getInfoData : GetInfoData = event.data as GetInfoData;
			var user : FacebookUser = getInfoData.userCollection.getItemAt(0) as FacebookUser;

			TheGameModel.TheIsoEngine.GameDef.F2FCommunicate.SetUserID(user.uid);

			(TheGameModel.FindGameComponentByShortName("AmarilloGame") as AmarilloGame).StartGame();
		}

		private const API_KEY : String = "73d69a0333d99da2f28bb4d154458ddc";
		private const APP_ID : String = "73773770908";

		private var mFacebook : Facebook;
		private var mSession : FacebookSessionUtil;

		private var mAmarilloGame : AmarilloGame;
	}
}