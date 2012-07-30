package com.flash2flash.ecoembes 
{
	import flash.display.DisplayObject;
	import com.flash2flash.ecoembes.CommunicateEvent;
	import com.flash2flash.ecoembes.CommunicateEventType;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.Event;
		
	public class Communicate extends MovieClip
	{
		
		private var edTarget:EventDispatcher;
		
		/**
		 * Constructor. Crea un objeto Communicate.
		 */
		public function Communicate() 
		{
			super();
		}
		
		/**
		 * Pide un nuevo código identificador de jugada.
		 * Se generará un evento de respuesta CommunicateEventType.STARTGAME_ANSWER
		 * con los atributos:
		 * 		nExito: 
		 * 			0: error o sesión expirada. No puede jugar. 
		 * 			1: código identificador correcto.
		 * 		strHash: código identificador de jugada;
		 * @param	nIdJuego: Identificador de Juego (1 – Ecotrivial; 2 – Hidden Object; 3 – Time management; 4 – Tiñe España de Amarillo en Telerecicla; 5 – Tiñe España de Amarillo en Facebook.
		 * @param	strIdUsuario: Identificador de usuario (obligatorio para facebook);

		 */
		public function requestStart(nIdJuego:Number, strIdUsuario:String="") {
			var evt:CommunicateEvent=new CommunicateEvent(CommunicateEventType.STARTGAME_REQUEST)
			evt.nIdJuego = nIdJuego;
			evt.strIdUsuario = strIdUsuario;
			dispatchEvent(evt);
		}
		
		/**
		 * API F2F.
		 */

		public function answerStart(nExito:Number, strHash:String) {
			var evt:CommunicateEvent = new CommunicateEvent(CommunicateEventType.STARTGAME_ANSWER);
			evt.nExito = nExito;
			evt.strHash = strHash;
			destino.dispatchEvent(evt);
			
		}
		
		/**
		 * Pide el XML de provincias y porcentajes para el juego Tiñe España de Amarillo.
		 * Se generará un evento de respuesta CommunicateEventType.LOADXML_REQUEST
		 * con los atributos:
		 * 		nExito: 
		 * 			0: error. 
		 * 			1: éxito al recoger XML.
		 * 		strXMLProvincias: XML de provincias y porcentajes;
		 */
		
		public function requestXML() {
			dispatchEvent(new CommunicateEvent(CommunicateEventType.LOADXML_REQUEST));
		}
		
		/**
		 * API F2F.
		 */
		
		public function answerXML(nExito:Number, strXMLProvincias:String) {
			var evt:CommunicateEvent = new CommunicateEvent(CommunicateEventType.LOADXML_ANSWER);
			evt.nExito = nExito;
			evt.strXMLProvincias = strXMLProvincias;
			destino.dispatchEvent(evt);
		}
	
		/**
		 * Inicia la petición para guardar la jugada..
		 * Se generará un evento de respuesta CommunicateEventType.ENDGAME_ANSWER
		 * con los atributos:
		 * 		nExito: 
		 * 			0: Error genérico ó sesión expirada/no iniciada
		 * 			1: Éxito
		 * 			2: Error. Código identificador de jugada, puntuación o identificador de juego vacíos.
		 * 			3: Error. El identificador de juego corresponde a los juegos de Tiñe España de Amarillo y no se envía provincia
		 * 			4: Error. Código identificador de jugada no existente.
		 * 			5: Error. Código identificador de jugada ya usado.
		 * 		
		 * @param	nIdJuego: Identificador de Juego (1 – Ecotrivial; 2 – Hidden Object; 3 – Time management; 4 – Tiñe España de Amarillo en Telerecicla; 5 – Tiñe España de Amarillo en Facebook.
		 * @param	strHash: Identificador de jugada recibido al llamar al método requestStart();
		 * @param	nPuntuacion: Puntuación obtenida en juego;
		 * @param	bCorrecto: Booleano indicando si la jugada ha sido correcta y el usuario obtiene participación si corresponde;
		 * @param	nIdProvincia: Opcional, identificador de provincia si es uno de los juegos Tiñe España de Amarillo;
		 * @param	strIdUsuario: Identificador de usuario (obligatorio para facebook);
		 */
		
		public function requestEnd(nIdJuego:Number, strHash:String, nPuntuacion:Number, bCorrecto:Boolean, nIdProvincia:Number=0, strIdUsuario:String="" ) {
			var evt:CommunicateEvent = new CommunicateEvent(CommunicateEventType.ENDGAME_REQUEST);
			evt.nIdJuego = nIdJuego;
			evt.strHash = strHash;
			evt.nPuntuacion = nPuntuacion;
			evt.bCorrecto = bCorrecto;
			evt.nIdProvincia = nIdProvincia;
			evt.strIdUsuario = strIdUsuario;
			dispatchEvent(evt);
		}
		/**
		 * API F2F.
		 */
		public function answerEnd(nExito:Number) {
			var evt:CommunicateEvent = new CommunicateEvent(CommunicateEventType.ENDGAME_ANSWER);
			evt.nExito = nExito;
			
			destino.dispatchEvent(evt);
		}		
		
		/**
		 * Establece el elemento destino de la comunicación... debe extender a EventDispatcher.
		 */
		public function set destino(edT:EventDispatcher):void
		{
			this.edTarget = edT;
		}
		
		/**
		 * Devuelve el elemento destino de la comunicación.
		 */
		public function get destino():EventDispatcher
		{
			return(edTarget);
		}
	}
}