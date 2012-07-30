package GameComponents.TeleRecicla
{
	import GameComponents.GameComponent;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	import gs.TweenLite;

	import utils.GenericEvent;
	import utils.KeyboardHandler;
	import utils.MovieClipLabels;

	public class AmarilloGame extends GameComponent
	{
		override public function OnStop() : void
		{
			StopGame();
		}

		public function StartGame() : void
		{
			if (TheGameModel.TheIsoEngine.GameDef.F2FCommunicate)
				TheGameModel.TheIsoEngine.GameDef.F2FCommunicate.addEventListener("XMLAnswer", OnXMLAnswerReceived, false, 0, true);
			
			MovieClipLabels.AddFrameScripts(FRAME_SCRIPTS, TheVisualObject);
			GotoSeleccion(null);
		}

		public function StopGame() : void
		{
			if (TheGameModel.TheIsoEngine.GameDef.F2FCommunicate)
				TheGameModel.TheIsoEngine.GameDef.F2FCommunicate.removeEventListener("XMLAnswer", OnXMLAnswerReceived);

			DestroyAmarilloObject();
			MovieClipLabels.RemoveFrameScripts(FRAME_SCRIPTS, TheVisualObject);
		}

		private function OnGameInitFrame():void
		{
			if (TheGameModel.TheIsoEngine.GameDef.GameID && TheGameModel.TheIsoEngine.GameDef.GameID==5)
				TweenLite.to(TheVisualObject.mcLogoHome, 0.5, {alpha:1.0});
		}

		//
		// PANTALLA: SELECCION
		//
		private function OnSeleccionEndFrame() : void
		{
			TheVisualObject.stop();
			TheVisualObject.mcSeleccion.visible = false;
			TheVisualObject.mcSeleccion.mcMapa.stop();

			if (TheGameModel.TheIsoEngine.GameDef.GameID && TheGameModel.TheIsoEngine.GameDef.GameID==5)
				TweenLite.to(TheVisualObject.mcLogoHome, 0.5, {alpha:1.0});

			for (var c:int=0; c < TheVisualObject.mcMapa.numChildren; c++)
			{
				var prov : SimpleButton = TheVisualObject.mcMapa.getChildAt(c) as SimpleButton;

				if (prov != null)
					prov.addEventListener(MouseEvent.CLICK, OnProvinciaClick);
			}

			if (TheGameModel.TheIsoEngine.GameDef.F2FCommunicate)
				TheGameModel.TheIsoEngine.GameDef.F2FCommunicate.RequestProvinciasXML();
			else
				SetAllYellow();

			if (mProvName != "")
				ProvinciaReady();
		}
		
		private function SetAllYellow():void
		{
			var mapa : MovieClip = TheVisualObject.mcMapa;

			if (mapa == null)
				mapa = TheVisualObject.mcMapaFinal;

			if (mapa != null)
			{
				for (var c:int=0; c < mapa.numChildren; c++)
				{
					var prov : SimpleButton = mapa.getChildAt(c) as SimpleButton;

					if (prov != null)
						prov.alpha = 1.0;
				}
			}
		}

		private function OnXMLAnswerReceived(event:GenericEvent):void
		{
			var xml : XML = new XML(event.Data as String);

			var mapa : MovieClip = TheVisualObject.mcMapa;

			if (mapa == null)
				mapa = TheVisualObject.mcMapaFinal;

			if (mapa != null)
			{
				for (var c:int=0; c < mapa.numChildren; c++)
				{
					var prov : SimpleButton = mapa.getChildAt(c) as SimpleButton;

					if (prov != null)
					{
						var provID : int = ProvinciasHelper.PROVINCIAS.indexOf(ProvinciasHelper.TranslateButton(prov.name)) + 1;
						prov.alpha = parseFloat(xml.provincia.(id==provID).porcentaje.toString()) / 100;
					}
				}

				SyncProvinciaMapaAndSeleccion(mapa);

				// May God forgive me...
				if (TheVisualObject.mcMapaFinal)
				{
					Blinko(5, TheVisualObject.mcMapaFinal[mButtonName].alpha);
				}
			}
		}

		private function SyncProvinciaMapaAndSeleccion(mapa:MovieClip):void
		{
			if (mapa == null || TheVisualObject.mcSeleccion == null)
				return;

			if (mButtonName == null || mButtonName == "")
				return;

			TheVisualObject.mcSeleccion.mcMapa.alpha = mapa[mButtonName].alpha;
		}

		private function OnProvinciaClick(event:MouseEvent):void
		{
			if ((event.target as SimpleButton).name != mButtonName)
			{
				mButtonName = (event.target as SimpleButton).name;
				mProvName = ProvinciasHelper.TranslateButton(mButtonName);

				ProvinciaReady();
			}
		}

		private function ProvinciaReady():void
		{
			TheVisualObject.mcSeleccion.visible = true;
			TheVisualObject.mcSeleccion.ctNombre.text = mProvName;
			TheVisualObject.mcSeleccion.mcMapa.gotoAndStop(mButtonName);
			TheVisualObject.mcSeleccion.mcMapaFondo.gotoAndStop(mButtonName);

			SyncProvinciaMapaAndSeleccion(TheVisualObject.mcMapa);

			TheVisualObject.btComenzar.addEventListener(MouseEvent.CLICK, GotoGame);
			TweenLite.to(TheVisualObject.btComenzar, 1.0, {alpha:1.0});

			TheVisualObject.mcSeleccion.alpha = 0.0;
			TweenLite.to(TheVisualObject.mcSeleccion, 1.0, {alpha:1.0});
		}

		private function GotoSeleccion(event:Event):void
		{
			TheVisualObject.gotoAndPlay("Seleccion");
		}


		//
		// JUEGO
		//

		private function OnGameEndFrame():void
		{
			TheVisualObject.stop();

			TheVisualObject.mcTermometro.gotoAndStop(1);
			TheVisualObject.mcLugar.ctNombre.text = mProvName;
			TheVisualObject.mcLugar.mcMapa.gotoAndStop(mButtonName);
			TheVisualObject.mcLugar.mcMapaFondo.gotoAndStop(mButtonName);

			mAmarilloObject = TheGameModel.CreateSceneObjectFromMovieClip("mcObjeto", "AmarilloObject") as AmarilloObject;
			mAmarilloObject.addEventListener("ContainerOK", OnContainerOK);
			mAmarilloObject.addEventListener("ContainerKO", OnContainerKO);
			mAmarilloObject.addEventListener("ScoreUpdated", OnScoreUpdated);

			var coordsX : Object = new Object();
			coordsX["Gris"] = TheVisualObject.mcContenedorGris.x;
			coordsX["Amarillo"] = TheVisualObject.mcContenedorAmarillo.x;
			coordsX["Azul"] = TheVisualObject.mcContenedorAzul.x;

			mAmarilloObject.SetPlayCoords(TheVisualObject.mcObjectSpawn.x, TheVisualObject.mcObjectSpawn.y,
										  coordsX, TheVisualObject.mcContenedorGris.y);

			TheVisualObject.mcLugar.mcMapa.alpha = 0.0;

			KeyboardHandler.Keyb.ResetKeybsOnce();

			if (TheGameModel.TheIsoEngine.GameDef.F2FCommunicate != null)
				TheGameModel.TheIsoEngine.GameDef.F2FCommunicate.RequestStart();

			NextObject();
		}

		private function GotoGame(event:Event):void
		{
			TheVisualObject.gotoAndPlay("Game");
		}

		private function OnContainerOK(event:Event):void
		{
			if (mAmarilloObject.Remaining == 0)
				GotoFin(null);
			else
				NextObject();
		}

		private function OnContainerKO(event:Event):void
		{
			if (mAmarilloObject.Remaining == 0)
				GotoFin(null);
			else
				NextObject();
		}

		private function OnScoreUpdated(event:Event):void
		{
			if (mAmarilloObject.Score != 0)
			{
				TheVisualObject.mcTermometro.addFrameScript(mAmarilloObject.Score-1, OnTermometroScoreReached);
				TheVisualObject.mcTermometro.play();

				TheVisualObject.mcLugar.mcMapa.alpha = mAmarilloObject.Score/100;
			}
			else
				TheVisualObject.mcTermometro.gotoAndStop(1);
		}

		private function NextObject():void
		{
			mAmarilloObject.NextObject();
		}

		private function OnTermometroScoreReached():void
		{
			TheVisualObject.mcTermometro.addFrameScript(TheVisualObject.mcTermometro.currentFrame-1, null);
			TheVisualObject.mcTermometro.stop();
		}


		//
		// PANTALLA: FIN
		//

		private function OnFindEndFrame():void
		{
			TheVisualObject.stop();

			if (TheGameModel.TheIsoEngine.GameDef.GameID && TheGameModel.TheIsoEngine.GameDef.GameID==5)
			{
				TweenLite.to(TheVisualObject.btBanner, 0.5, {alpha:1.0});
				TheVisualObject.btBanner.addEventListener(MouseEvent.CLICK, OnBannerClick, false, 0, true);
			}

			TheVisualObject.btComienzo.addEventListener(MouseEvent.CLICK, GotoSeleccion);
			TheVisualObject.btPlayAgain.addEventListener(MouseEvent.CLICK, GotoGame);

			TheVisualObject.ctPuntos.text = mAmarilloObject.Score.toString() + " %";

			if (TheGameModel.TheIsoEngine.GameDef.F2FCommunicate)
			{
				var idProv : int = ProvinciasHelper.PROVINCIAS.indexOf(mProvName) + 1;
				TheGameModel.TheIsoEngine.GameDef.F2FCommunicate.SaveScoreToServer(mAmarilloObject.Score, true, idProv);

				TheGameModel.TheIsoEngine.GameDef.F2FCommunicate.RequestProvinciasXML();
			}
			else
				SetAllYellow();

			DestroyAmarilloObject();
		}

		private function OnBannerClick(event:Event):void
		{
			var url:String = "http://www.telerecicla.com";
            var request:URLRequest = new URLRequest(url);

            try {
                navigateToURL(request);
            }
            catch (e:Error) {
            }
		}

		private function Blinko(numTimes:int, finalAlpha:Number):void
		{
			if (TheVisualObject.mcMapaFinal == null)
				return;

			var provToBlink : DisplayObject = TheVisualObject.mcMapaFinal[mButtonName];
			if (numTimes != 0)
			{
				provToBlink.alpha = 0;
				TweenLite.to(provToBlink, 0.5, {alpha:1.0, onComplete:Blinko, onCompleteParams:[numTimes-1, finalAlpha]})
			}
			else
			{
				provToBlink.alpha = finalAlpha;
			}
		}

		private function DestroyAmarilloObject():void
		{
			if (mAmarilloObject != null)
			{
				mAmarilloObject.removeEventListener("ScoreUpdated", OnScoreUpdated);
				mAmarilloObject.removeEventListener("ContainerOK", OnContainerOK);
				mAmarilloObject.removeEventListener("ContainerKO", OnContainerKO);
				TheGameModel.DeleteSceneObject(mAmarilloObject.TheSceneObject);
				mAmarilloObject = null;
			}
		}

		private function GotoFin(event:Event):void
		{
			TheVisualObject.gotoAndPlay("FinCompleto");
		}


		private var mButtonName : String = "";
		private var mProvName : String = "";
		private var mAmarilloObject : AmarilloObject;

		private const FRAME_SCRIPTS : Array = [ {label: "SeleccionEnd", func: OnSeleccionEndFrame},
												{label: "GameEnd", func: OnGameEndFrame},
												{label: "FinCompletoEnd", func: OnFindEndFrame},
												{label: "GameInit", func: OnGameInitFrame}
											  ]
	}
}


import flash.utils.Dictionary;

internal class ProvinciasHelper
{
	public static const PROVINCIAS : Array = [	 "La Coruña", "Álava", "Albacete", "Alicante", "Almería", "Asturias",
												 "Avila", "Badajoz", "Baleares", "Barcelona", "Burgos", "Cáceres",
												 "Cádiz", "Cantabria", "Castellón", "Ceuta", "Ciudad Real", "Córdoba",
	          									 "Cuenca", "Girona", "Granada", "Guadalajara", "Guipúzcoa", "Huelva",
	          									 "Huesca", "Jaén", "La Rioja", "Las Palmas", "León", "Lleida",
	          									 "Lugo", "Madrid", "Málaga", "Melilla", "Murcia", "Navarra",
	          									 "Orense", "Palencia", "Pontevedra", "Salamanca", "Santa Cruz de Tenerife",
	          									 "Segovia", "Sevilla", "Soria", "Tarragona", "Teruel", "Toledo", "Valencia",
	          									 "Valladolid", "Vizcaya", "Zamora", "Zaragoza"
          									 ]

	public static function TranslateButton(butName:String):String
	{
		var ret : String = "";

		if (PROVINCIAS.indexOf(butName) != -1)
			ret = butName;
		else
		{
			var trans : Dictionary = new Dictionary();
			trans["ACoruña"] = "La Coruña";
			trans["CiudadReal"] = "Ciudad Real";
			trans["LaRioja"] = "La Rioja";
			trans["LasPalmas"] = "Las Palmas";
			trans["Tenerife"] = "Santa Cruz de Tenerife";

			ret = trans[butName];
		}

		if (ret == null)
			ret = butName;

		return ret;
	}
}