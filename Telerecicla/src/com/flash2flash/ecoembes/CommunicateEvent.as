package com.flash2flash.ecoembes 
{
	import flash.events.Event;
	

	public class CommunicateEvent extends Event 
	{
		
		public var strHash:String;
		public var nExito:Number;
		public var nIdJuego:Number;
		public var strIdUsuario:String;
		public var nPuntuacion:Number;
		public var nIdProvincia:Number;
		public var bCorrecto:Boolean;
		public var strXMLProvincias:String;
		
		public function CommunicateEvent(type:String) 
		{ 
			
			super(type, true, false);
		} 
		
		public override function clone():Event 
		{ 
			return new CommunicateEvent(type);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("CommunicateEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}