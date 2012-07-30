package GameComponents.Insignia
{
	import GameComponents.GameComponent;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.URLVariables;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	import mx.core.Application;

	import utils.Delegate;
	import utils.GenericEvent;
	import utils.MovieClipLabels;
	import utils.Server;

	/**
	 * Interface
	 */
	public final class OIInterface extends GameComponent
	{
		override public function OnStart() : void
		{
			mTutorialMain = TheGameModel.FindGameComponentByShortName("OITutorialMain") as OITutorialMain;
			mGameMain = TheGameModel.FindGameComponentByShortName("OIGameMain") as OIGameMain;

			mPopup = TheGameModel.TheAssetLibrary.CreateMovieClip("mcPopup");

			MovieClipLabels.AddFrameScripts(FRAME_SCRIPTS, TheVisualObject);

			if (TheGameModel.TheIsoEngine.GameDef.hasOwnProperty("Code"))
				GotoPerfil(null);
			else
				GotoMain(null);
		}


		override public function OnStop() : void
		{
			MovieClipLabels.RemoveFrameScripts(FRAME_SCRIPTS, TheVisualObject);
			mTutorialMain = null;
			mGameMain = null;
			TheVisualObject.visible = true;
			TheVisualObject.gotoAndStop("Stop");
		}

		//
		// PANTALLA: MAIN
		//
		public function GotoMain(event:MouseEvent) : void
		{
			TheVisualObject.visible = true;
			TheVisualObject.gotoAndPlay("Main");
		}

		private function OnMainEndFrame() : void
		{
			TheVisualObject.stop();

			ConfigureTabs(MAIN_FIELDS, OnEnterKeyMain);

			TheVisualObject.btSend.tabEnabled = false;
			TheVisualObject.btJoin.tabEnabled = false;
			TheVisualObject.btRecordar.tabEnabled = false;

			TheVisualObject.btSend.addEventListener(MouseEvent.CLICK, OnLoginClickHandler, false, 0, true);
			TheVisualObject.btJoin.addEventListener(MouseEvent.CLICK, GotoRegistro, false, 0, true);

			TheVisualObject.btRecordar.addEventListener(MouseEvent.CLICK, OnRecordarContrasenaClick, false, 0, true);
		}

		private function OnRecordarContrasenaClick(event:Event):void
		{
			if (TheVisualObject.ctUser.text != "")
			{
				var vars : URLVariables = new URLVariables();
				vars.usr = TheVisualObject.ctUser.text;

				mServer = CreateServer();
				mServer.addEventListener("RequestComplete", OnPasswordRequestComplete, false, 0, true);
				mServer.Request(vars, "/public/services/lostpassword.php");
			}
			else
				ShowMessagePopup("Debes introducir tu eMail para que podamos enviarte la contraseña", null, true);
		}

		private function OnPasswordRequestComplete(event:GenericEvent):void
		{
			mServer = null;

			var responseXML : XML = XML(event.Data);
			var result : String = responseXML.pwd_change_status;

			if (result == "FAIL")
			{
				ShowMessagePopup("El eMail que has introducido no corresponde a ningún usuario registrado.", null, false);
			}
			else
			{
				ShowMessagePopup("eMail recordatorio de contraseña enviado con éxito.", null, true);
			}
		}

		private const MAIN_FIELDS : Array = [ "ctUser", "ctPasswd", "btSend" ];

		private function OnEnterKeyMain(ctrlName:String):void
		{
			if (ctrlName == "ctPasswd")
				OnLoginClickHandler(null);
		}

		private function OnLoginClickHandler(event:MouseEvent):void
		{
			var vars : URLVariables = new URLVariables();
			vars.usr = TheVisualObject.ctUser.text;
			vars.pass = TheVisualObject.ctPasswd.text;

			/*
			vars.usr = "vmendi@gmail.com";
			vars.pass = "lalala";
			*/

			// Las almacenamos para que estén ahí durante toda la sesión
			TheGameModel.TheIsoEngine.GameDef.eMail = vars.usr;
			TheGameModel.TheIsoEngine.GameDef.Password = vars.pass;

			if (vars.usr == "UnusualWonder")
				TheGameModel.TheIsoEngine.GameDef.UnusualMode = true;
			else
				TheGameModel.TheIsoEngine.GameDef.UnusualMode = false

			if (TheGameModel.TheIsoEngine.GameDef.UnusualMode)
			{
				GotoInstrucciones(null);
			}
			else
			{
				mServer = CreateServer();
				mServer.addEventListener("RequestComplete", OnLoginRequestComplete, false, 0, true);
				mServer.Request(vars, "/public/services/login.php");
			}
		}

		private function OnLoginRequestComplete(event:GenericEvent):void
		{
			mServer = null;

			var responseXML : XML = XML(event.Data);
			var result : String = responseXML.user_status;

			if (result == "FOUND")
			{
				TheGameModel.TheIsoEngine.GameDef.Nick = responseXML.user_name;
				TheGameModel.TheIsoEngine.GameDef.Code = responseXML.user_code;

				GotoPerfil(null);
			}
			else
			if (result == "NOT_FOUND")
			{
				ShowMessagePopup("Nombre o Contraseña incorrecta", null);
			}
			else
			{
				ShowMessagePopup("Error en el servidor", null);
			}
		}

		//
		// PANTALLA: FIN DEL TUTORIAL
		//
		public function GotoEntrenamientoEnd() : void
		{
			TheVisualObject.visible = true;
			TheVisualObject.gotoAndPlay("FinEntrenamiento");
		}
		private function OnFinEntrenamientoEndFrame() : void
		{
			TheVisualObject.stop();
			TheVisualObject.btEntrenar.addEventListener(MouseEvent.CLICK, GotoPerfil, false, 0, true);
		}

		//
		// PANTALLA: PERFIL
		//
		private function OnPerfilEndFrame():void
		{
			TheVisualObject.stop();

			TheVisualObject.ctNombre.text = TheGameModel.TheIsoEngine.GameDef.Nick;
			TheVisualObject.btJugar.addEventListener(MouseEvent.CLICK, GotoIntro, false, 0, true);
			TheVisualObject.btDatos.addEventListener(MouseEvent.CLICK, GotoUpdatePerfil, false, 0, true);
			TheVisualObject.btQuiz.addEventListener(MouseEvent.CLICK, GotoJugarQuiz, false, 0, true);
			TheVisualObject.btRanking.addEventListener(MouseEvent.CLICK, GotoRanking, false, 0, true);
			TheVisualObject.btTutorial.addEventListener(MouseEvent.CLICK, OnTutorialClickHandler, false, 0, true);
			TheVisualObject.btQueEsDesafio.addEventListener(MouseEvent.CLICK, GotoQueEsDesafio, false, 0, true);

			var varsTenis : URLVariables = new URLVariables();
			varsTenis.id_juego = 1;

			mServer = CreateServer();
			mServer.addEventListener("RequestComplete", OnPositionRequestComplete, false, 0, true);
			mServer.Request(varsTenis, "/private/services/getposition.php");
		}

		private function OnTutorialClickHandler(e:MouseEvent) : void
		{
			TheVisualObject.visible = false;
			mTutorialMain.StartTutorial();
		}

		private function OnPositionRequestComplete(event:GenericEvent):void
		{
			// Si clicka muy rapido, la comunicación con el servidor puede llegar despues de haber cambiado de pantalla
			if (TheVisualObject.currentLabel != "PerfilEnd")
				return;

			var responseXML : XML = XML(event.Data);
			var position_total : String = responseXML.position_total;

			// Es posible que todavía no haya grabada ninguna puntuacion
			if (position_total == "FAIL")
			{
				TheVisualObject.ctRanking.text = "-";
				TheVisualObject.ctPuntosTotal.text = "-";
				TheVisualObject.ctPuntos.text = "-";
				TheVisualObject.ctPuntosQuiz.text = "-";
			}
			else
			{
				TheVisualObject.ctRanking.text = position_total;
				TheVisualObject.ctPuntosTotal.text = responseXML.puntos_total;
				TheVisualObject.ctPuntos.text = responseXML.juego.(id == "1").puntos + " INSIGNIAS";
				TheVisualObject.ctPuntosQuiz.text = responseXML.juego.(id == "2").puntos + " INSIGNIAS";
			}
		}

		public function GotoPerfil(event:MouseEvent):void
		{
			TheVisualObject.visible = true;
			TheVisualObject.gotoAndPlay("Perfil");
		}

		public function GotoJugarQuiz(event:MouseEvent):void
		{
			TheGameModel.TheIsoEngine.Load("Maps/OpelInsignia/QuizOI.xml");
		}

		//
		// PANTALLA: UPDATE PERFIL
		//
		private function OnDatosEndFrame() : void
		{
			TheVisualObject.stop();

			ConfigureTabs(REGISTRO_FIELDS, null);

			TheVisualObject.btAceptar.tabEnabled = false;
			TheVisualObject.btAceptar.addEventListener(MouseEvent.CLICK, OnUpdatePerfilClick, false, 0, true);
			TheVisualObject.btSalir.addEventListener(MouseEvent.CLICK, GotoPerfil, false, 0, true);

			var vars : URLVariables = new URLVariables();

			mServer = CreateServer();
			mServer.addEventListener("RequestComplete", OnGetDatosPerfilComplete, false, 0, true);
			mServer.Request(vars, "/private/services/getaccount.php");
		}

		public function GotoUpdatePerfil(event:MouseEvent):void
		{
			TheVisualObject.gotoAndPlay("Datos");
		}

		private function OnUpdatePerfilClick(event:MouseEvent):void
		{
			var error : String = VerifyRegistry(true);

			if (error == "")
			{
				var vars : URLVariables = GetURLVars(true);

				mServer = CreateServer();
				mServer.addEventListener("RequestComplete", OnUpdatePerfilComplete, false, 0, true);
				mServer.Request(vars, "/private/services/updateaccount.php");
			}
			else
			{
				ShowMessagePopup(error, null);
			}
		}

		private function OnUpdatePerfilComplete(event:GenericEvent):void
		{
			var responseXML : XML = XML(event.Data);

			if (responseXML.upd_account_status == "REGISTERED")
				ShowMessagePopup("Se actualizo su perfil con éxito", GotoPerfil, true);
			else
			if (responseXML.upd_account_status == "FAIL_EMAIL")
				ShowMessagePopup("E-mail ya existente en nuestra base de datos", null);
			else
				ShowMessagePopup("El servidor falló al realizar la actualización", GotoPerfil);
		}

		private function OnGetDatosPerfilComplete(event:GenericEvent):void
		{
			if (TheVisualObject.currentLabel == "Datos")
				return;

			var responseXML : XML = XML(event.Data);

			// El email no se edita, aunque viene como dato
			// TheVisualObject.ctMail.text = responseXML.email;
			TheVisualObject.ctPasswd.text = responseXML.password;
			TheVisualObject.ctConfPasswd.text = responseXML.password;

			TheVisualObject.ctNombre.text = responseXML.name;
			TheVisualObject.ctApellido1.text = responseXML.surname1;
			TheVisualObject.ctApellido2.text = responseXML.surname2;

			TheVisualObject.ctDay.text = responseXML.day_birth;
			TheVisualObject.ctMonth.text = responseXML.month_birth;
			TheVisualObject.ctYear.text = responseXML.year_birth;

			TheVisualObject.ctMobile.text = responseXML.cell_phone;
			TheVisualObject.ctAdress.text = responseXML.address;
			TheVisualObject.ctZip.text = responseXML.postcode;
			TheVisualObject.ctCity.text = responseXML.city;

			TheVisualObject.cbProvincia.setStyle("embedFonts", true);
			TheVisualObject.cbProvincia.textField.setStyle("embedFonts", true);

			var textFormat : TextFormat = new TextFormat("standard 07_57", 8, 0x000000);
			TheVisualObject.cbProvincia.textField.setStyle("textFormat", textFormat);

			ComboBoxHelper.AddProvinciasToComboBox(TheVisualObject.cbProvincia);
			ComboBoxHelper.SetComboBoxSelection(TheVisualObject.cbProvincia, responseXML.state);

			TheVisualObject.cbMail.selected = responseXML.alert == "1";
		}

		//
		// PANTALLA: INTRO
		//
		private function OnIntroEndFrame():void
		{
			TheVisualObject.stop();

			TheVisualObject.btComenzar.addEventListener(MouseEvent.CLICK, OnJugarClickHandler, false, 0, true);
			TheVisualObject.btInstrucciones.addEventListener(MouseEvent.CLICK, GotoInstrucciones, false, 0, true);
		}

		public function GotoIntro(event:MouseEvent):void
		{
			TheVisualObject.gotoAndPlay("Intro");
		}

		private function OnJugarClickHandler(event:MouseEvent):void
		{
			TheVisualObject.visible = false;
			mGameMain.StartGame();
		}

		//
		// PANTALLA: INSTRUCCIONES
		//
		private function OnInstruccionesEndFrame():void
		{
			TheVisualObject.stop();

			TheVisualObject.btComenzar.addEventListener(MouseEvent.CLICK, OnJugarClickHandler, false, 0, true);
			TheVisualObject.btVolver.addEventListener(MouseEvent.CLICK, GotoIntro, false, 0, true);
		}

		public function GotoInstrucciones(event:MouseEvent):void
		{
			TheVisualObject.gotoAndPlay("Instrucciones");
		}

		//
		// PANTALLA: RANKING
		//
		private function OnRankingEndFrame():void
		{
			TheVisualObject.stop();
			TheVisualObject.btPerfil.addEventListener(MouseEvent.CLICK, GotoPerfil, false, 0, true);

			var vars : URLVariables = new URLVariables();
			vars.id_juego = 1;

			mServer = CreateServer();
			mServer.addEventListener("RequestComplete", RankingRequestComplete, false, 0, true);
			mServer.Request(vars, "/private/services/pointslist.php");
		}

		private function RankingRequestComplete(event:GenericEvent):void
		{
			mServer = null;

			if (TheVisualObject.currentLabel != "RankingEnd")
				return;

			var responseXML : XML = XML(event.Data);

			var counter : int = 1;
			for each(var usuario : XML in responseXML.usuario)
			{
				if (counter > 10)
					break;

				var counterString : String = NumberToString(counter);

				TheVisualObject["ctPlayer"+counterString].text = usuario.nick.toUpperCase();
				TheVisualObject["ctScore"+counterString].text = usuario.juego.(id=="1").puntos;
				TheVisualObject["ctScoreQuiz"+counterString].text = usuario.juego.(id=="2").puntos;
				TheVisualObject["ctScoreTotal"+counterString].text = usuario.puntos;

				counter++;
			}
		}

		private function NumberToString(num : int):String
		{
			if (num < 10)
				return "0"+num.toString();
			else
				return num.toString();
		}

		public function GotoRanking(event:MouseEvent):void
		{
			TheVisualObject.gotoAndPlay("Ranking");
		}

		//
		// PANTALLA: QUE ES DESAFIO
		//
		private function OnQueEsDesafioEndFrame():void
		{
			TheVisualObject.stop();
			TheVisualObject.btSalir.addEventListener(MouseEvent.CLICK, GotoPerfil, false, 0, true);
		}

		private function GotoQueEsDesafio(event:Event):void
		{
			TheVisualObject.gotoAndPlay("QueEsDesafio");
		}

		//
		// PANTALLA: REGISTRO
		//
		private function OnRegistroEndFrame():void
		{
			TheVisualObject.stop();

			ConfigureTabs(REGISTRO_FIELDS, null);

			TheVisualObject.cbProvincia.setStyle("embedFonts", true);
			TheVisualObject.cbProvincia.textField.setStyle("embedFonts", true);

			var textFormat : TextFormat = new TextFormat("standard 07_57", 8, 0x000000);
			TheVisualObject.cbProvincia.textField.setStyle("textFormat", textFormat);

			ComboBoxHelper.AddProvinciasToComboBox(TheVisualObject.cbProvincia);

			TheVisualObject.btAceptar.tabEnabled = false;
			TheVisualObject.btCondiciones.tabEnabled = false;
			TheVisualObject.btSalir.tabEnabled = false;

			TheVisualObject.btAceptar.addEventListener(MouseEvent.CLICK, OnRegistrarClick, false, 0, true);
			TheVisualObject.btSalir.addEventListener(MouseEvent.CLICK, GotoMain, false, 0, true);
			TheVisualObject.btCondiciones.addEventListener(MouseEvent.CLICK, ShowCondiciones, false, 0, true);
		}

		private function ShowCondiciones(event:Event):void
		{
			ShowMessagePopup("", null, false, true);
		}


		private const REGISTRO_FIELDS : Array = [ "ctNombre", "ctApellido1", "ctApellido2", "ctUser", "ctPasswd", "ctConfPasswd",
									    		  "ctDay", "ctMonth", "ctYear", "ctMail", "ctMobile", "ctAdress",
												  "ctZip", "ctCity", "cbProvincia" ];

		private function OnRegistrarClick(event:MouseEvent):void
		{
			var error : String = VerifyRegistry(false);

			if (error == "")
			{
				var vars : URLVariables = GetURLVars(false);

				mServer = CreateServer();
				mServer.addEventListener("RequestComplete", OnRegistroRequestComplete, false, 0, true);
				mServer.Request(vars, "/public/services/registeraccount.php");
			}
			else
			{
				ShowMessagePopup(error, null);
			}
		}

		private function OnRegistroRequestComplete(event:GenericEvent):void
		{
			mServer = null;

			var responseXML : XML = XML(event.Data);
			var result : String = responseXML.account_status;

			if (result == "REGISTERED")
			{
				TheGameModel.TheIsoEngine.GameDef.eMail = TheVisualObject.ctUser.text;
				TheGameModel.TheIsoEngine.GameDef.Password = TheVisualObject.ctPasswd.text;

				TheGameModel.TheIsoEngine.GameDef.Nick = responseXML.user_name;
				TheGameModel.TheIsoEngine.GameDef.Code = responseXML.user_code;

				GotoPerfil(null);
			}
			else
			if (result == "FAIL_EMAIL")
			{
				ShowMessagePopup("Email ya registrado o incorrecto", null);
			}
			else
			if (result == "FAIL_NICK")
			{
				ShowMessagePopup("Nombre de usuario ya registrado", null);
			}
			else
			{
				ShowMessagePopup("Campos de registro incorrectos", null);
			}
		}

		private function GetURLVars(updating:Boolean) : URLVariables
		{
			var vars : URLVariables = new URLVariables();

			vars.name = TheVisualObject.ctNombre.text;
			vars.surname1 = TheVisualObject.ctApellido1.text;
			vars.surname2 = TheVisualObject.ctApellido2.text;

			if (!updating)
				vars.nick = TheVisualObject.ctUser.text;
			vars.password = TheVisualObject.ctPasswd.text;

			if (!updating)
				vars.email = TheVisualObject.ctMail.text;
			else
				vars.email = TheGameModel.TheIsoEngine.GameDef.eMail;

			vars.day_birth = TheVisualObject.ctDay.text;
			vars.month_birth = TheVisualObject.ctMonth.text;
			vars.year_birth = TheVisualObject.ctYear.text;

			vars.cell_phone = TheVisualObject.ctMobile.text;
			vars.phone = TheVisualObject.ctMobile.text;			// Lo dejamos así, nadie parece echarlo de menos

			vars.address = TheVisualObject.ctAdress.text;
			vars.postcode = TheVisualObject.ctZip.text;
			vars.city = TheVisualObject.ctCity.text;
			vars.state = TheVisualObject.cbProvincia.selectedItem.label;

			vars.alert = TheVisualObject.cbMail.selected? "1" : "0";

			return vars;
		}

		private function VerifyRegistry(updating:Boolean) : String
		{
			var ret : String = "";

			if (!updating && TheVisualObject.cbCondiciones.selected != true)
				ret += "Debes aceptar los terminos y condiciones legales.\n";

			if (TheVisualObject.ctConfPasswd.text != TheVisualObject.ctPasswd.text)
				ret += "Las passwords no coinciden.\n";

			if (TheVisualObject.ctNombre.text == "" || TheVisualObject.ctApellido1.text == "" ||
				TheVisualObject.ctApellido2.text == "")
				ret += "El nombre y apellidos son obligatorios.\n";

			if (!updating && TheVisualObject.ctUser.text == "")
				ret += "El campo de nick no pueden dejarse en blanco.\n";

			if (TheVisualObject.ctPasswd.text == "")
				ret += "El campo de password no puede dejarse en blanco.\n";

			if (!updating && TheVisualObject.ctMail.text.length==0)
				ret += "El campo de email es obligatorio.\n";

			if (TheVisualObject.ctMobile.text == "")
				ret += "El campo de teléfono móvil es obligatorio.\n";

			if (TheVisualObject.ctAdress.text == "")
				ret += "La dirección es obligatoria\n";

			 if (TheVisualObject.ctZip.text == "")
			 	ret += "El código postal es obligatorio.\n";

			 if (TheVisualObject.ctCity.text == "")
				ret += "La población es obligatoria.\n";

			return ret;
		}

		private function GotoRegistro(event:MouseEvent):void
		{
			TheVisualObject.gotoAndPlay("Registro");
		}

		//
		// PANTALLA: ENTREFASES
		//
		private function OnEntrefasesEndFrame():void
		{
			TheVisualObject.stop();

			TheVisualObject.mcTit.gotoAndStop("Fase"+(mGameMain.DiffLevel+1).toString());
			TheVisualObject.mcMensaje.gotoAndStop("Fase"+(mGameMain.DiffLevel+1).toString());

			TheVisualObject.btContinuar.addEventListener(MouseEvent.CLICK, OnJugarClickHandler, false, 0, true);

			TheVisualObject.ctPuntos.text = mGameMain.TotalScore;
		}

		public function GotoEntreFases(event:Event):void
		{
			TheVisualObject.visible = true;
			TheVisualObject.gotoAndPlay("Entrefases");
		}

		//
		// PANTALLA: FIN FRACASO
		//
		private function OnFinFracasoEndFrame():void
		{
			TheVisualObject.stop();

			TheVisualObject.btSalir.addEventListener(MouseEvent.CLICK, GotoPerfil, false, 0, true);
			TheVisualObject.btJugar.addEventListener(MouseEvent.CLICK, GotoIntro, false, 0, true);

			TheVisualObject.ctPuntos.text = mGameMain.TotalScore;
			SendScoreToServer(mGameMain.TotalScore);

			mGameMain.ResetGame();
		}

		public function GotoFinFracaso(event:Event):void
		{
			TheVisualObject.visible=true;
			TheVisualObject.gotoAndPlay("FinFracaso");
		}

		//
		// PANTALLA: FIN EXITO
		//
		private function OnFinExitoEndFrame():void
		{
			TheVisualObject.stop();

			TheVisualObject.btSalir.addEventListener(MouseEvent.CLICK, GotoPerfil, false, 0, true);
			TheVisualObject.btJugar.addEventListener(MouseEvent.CLICK, GotoIntro, false, 0, true);

			TheVisualObject.ctPuntos.text = mGameMain.TotalScore;
			SendScoreToServer(mGameMain.TotalScore);

			mGameMain.ResetGame();
		}

		public function GotoFinExito(event:Event) : void
		{
			TheVisualObject.visible=true;
			TheVisualObject.gotoAndPlay("FinExito");
		}

		//
		// Envio de puntos al servidor. Lo hacemos de forma silenciosa.
		//
		private function SendScoreToServer(score:int):void
		{
			if (TheGameModel.TheIsoEngine.GameDef.UnusualMode)
				return;

			var vars : URLVariables = new URLVariables();

			vars.id_juego = 1;
			vars.puntos = score;

			mServer = CreateServer();
			mServer.addEventListener("RequestComplete", OnScoreSendComplete);
			mServer.Request(vars, "/private/services/newpoint.php");
		}

		private function OnScoreSendComplete(event:GenericEvent):void
		{
			//trace("ScoreSendComplete: " + event.Data);
		}

		//
		// POPUP
		//
		private function ShowMessagePopup(msg : String, retFunc:Function, bIsSuccess:Boolean=false, bIsCondiciones:Boolean=false):void
		{
			mPopupRetFunc = retFunc;
			TheGameModel.TheRender2DCamera.addChild(mPopup);

			if (!bIsCondiciones)
				mPopup.gotoAndStop(bIsSuccess? "acierto" : "error");
			else
				mPopup.gotoAndStop("Condiciones");

			if (mPopup.ctMessage)
				mPopup.ctMessage.text = msg;

			mPopup.btAceptar.addEventListener(MouseEvent.CLICK, OnAceptarClick);
		}
		private function OnAceptarClick(event:MouseEvent):void
		{
			mPopup.btAceptar.removeEventListener(MouseEvent.CLICK, OnAceptarClick);
			TheGameModel.TheRender2DCamera.removeChild(mPopup);

			if (mPopupRetFunc != null)
			{
				mPopupRetFunc(null);
				mPopupRetFunc = null;
			}
		}

		//
		// Tabulado
		//
		private function ConfigureTabs(names : Array, enterFunction : Function) : void
		{
			for (var c:int = 0; c < names.length; c++)
			{
				var name : String = names[c];

				if (TheVisualObject[name] != null && !TheVisualObject[name].hasEventListener(KeyboardEvent.KEY_DOWN))
					TheVisualObject[name].addEventListener(KeyboardEvent.KEY_DOWN, Delegate.create(OnKeyDown, names, enterFunction));
			}
		}

		private function OnKeyDown(event:KeyboardEvent, names:Array, enterFunction:Function):void
		{
			if (event.keyCode != Keyboard.TAB && event.keyCode != Keyboard.ENTER)
				return;

			var curr : TextField = event.target as TextField;

			for (var c:int = 0; c < names.length; c++)
			{
				if (TheVisualObject[names[c]] == curr)
					break;
			}

			if (c != names.length && event.keyCode == Keyboard.TAB)
			{
				if (event.shiftKey)
				{
					if (c != 0)
						TheVisualObject.stage.focus = TheVisualObject[names[c-1]];
					else
						TheVisualObject.stage.focus = TheVisualObject[names[names.length-1]];
				}
				else
				{
					if (c != names.length-1)
						TheVisualObject.stage.focus = TheVisualObject[names[c+1]];
					else
						TheVisualObject.stage.focus = TheVisualObject[names[0]];
				}
			}

			if (c != names.length && event.keyCode == Keyboard.ENTER)
				enterFunction(names[c]);
		}

		private function CreateServer() : Server
		{
			var concatMe : String = "";
			var daUrl : String = Application.application.url;
			if (daUrl.indexOf("www") != -1)
				concatMe = "www.";

			var server : Server = new Server("http://" + concatMe + "elfuturoesnuestrapista.com");
			server.addEventListener("RequestError", OnRequestError, false, 0, true);
			return server;
		}

		private function OnRequestError(event:Event):void
		{
			mServer = null;
			ShowMessagePopup("Error en la conexión con el servidor", null);
		}

		private var mServer : Server;
		private var mTutorialMain : OITutorialMain;
		private var mGameMain : OIGameMain;

		private var mPopup : MovieClip;
		private var mPopupRetFunc : Function;

		private const FRAME_SCRIPTS : Array = [ {label: "MainEnd", func: OnMainEndFrame},
												{label: "FinEntrenamientoEnd", func: OnFinEntrenamientoEndFrame},
												{label: "PerfilEnd", func: OnPerfilEndFrame},
												{label: "RankingEnd", func: OnRankingEndFrame},
												{label: "RegistroEnd", func: OnRegistroEndFrame},
												{label: "EntrefasesEnd", func: OnEntrefasesEndFrame},
												{label: "FinFracasoEnd", func: OnFinFracasoEndFrame},
												{label: "FinExitoEnd", func: OnFinExitoEndFrame},
												{label: "IntroEnd", func: OnIntroEndFrame},
												{label: "InstruccionesEnd", func: OnInstruccionesEndFrame},
												{label: "DatosEnd", func: OnDatosEndFrame},
												{label: "QueEsDesafioEnd", func: OnQueEsDesafioEndFrame},
											  ]
	}
}

internal class ComboBoxHelper
{
	static public function SetComboBoxSelection(cbProvincia : Object, provincia : String):void
	{
		for (var c:int=0; c < cbProvincia.length; c++)
		{
			if (cbProvincia.getItemAt(c).label == provincia)
			{
				cbProvincia.selectedIndex = c;
				break;
			}
		}
	}

	static public function AddProvinciasToComboBox(cb : Object):void
	{
		cb.addItem({label:"Álava", data:""});
		cb.addItem({label:"Albacete", data:""});
		cb.addItem({label:"Alicante", data:""});
		cb.addItem({label:"Almería", data:""});
		cb.addItem({label:"Asturias", data:""});
		cb.addItem({label:"Ávila", data:""});
		cb.addItem({label:"Badajoz", data:""});
		cb.addItem({label:"Barcelona", data:""});
		cb.addItem({label:"Burgos", data:""});
		cb.addItem({label:"Cáceres", data:""});
		cb.addItem({label:"Cádiz", data:""});
		cb.addItem({label:"Cantabria", data:""});
		cb.addItem({label:"Castellón", data:""});
		cb.addItem({label:"Ciudad Real", data:""});
		cb.addItem({label:"Córdoba", data:""});
		cb.addItem({label:"La Coruña", data:""});
		cb.addItem({label:"Cuenca", data:""});
		cb.addItem({label:"Gerona", data:""});
		cb.addItem({label:"Granada", data:""});
		cb.addItem({label:"Guadalajara", data:""});
		cb.addItem({label:"Guipúzcoa", data:""});
		cb.addItem({label:"Huelva", data:""});
		cb.addItem({label:"Huesca", data:""});
		cb.addItem({label:"Islas Baleares", data:""});
		cb.addItem({label:"Jaén", data:""});
		cb.addItem({label:"León", data:""});
		cb.addItem({label:"Lérida", data:""});
		cb.addItem({label:"Lugo", data:""});
		cb.addItem({label:"Madrid", data:""});
		cb.addItem({label:"Málaga", data:""});
		cb.addItem({label:"Murcia", data:""});
		cb.addItem({label:"Navarra", data:""});
		cb.addItem({label:"Orense", data:""});
		cb.addItem({label:"Palencia", data:""});
		cb.addItem({label:"Las Palmas", data:""});
		cb.addItem({label:"Pontevedra", data:""});
		cb.addItem({label:"La Rioja", data:""});
		cb.addItem({label:"Salamanca", data:""});
		cb.addItem({label:"Segovia", data:""});
		cb.addItem({label:"Sevilla", data:""});
		cb.addItem({label:"Soria", data:""});
		cb.addItem({label:"Tarragona", data:""});
		cb.addItem({label:"Santa Cruz de T.", data:""});
		cb.addItem({label:"Teruel", data:""});
		cb.addItem({label:"Toledo", data:""});
		cb.addItem({label:"Valencia", data:""});
		cb.addItem({label:"Valladolid", data:""});
		cb.addItem({label:"Vizcaya", data:""});
		cb.addItem({label:"Zamora", data:""});
		cb.addItem({label:"Zaragoza", data:""});
	}
}
