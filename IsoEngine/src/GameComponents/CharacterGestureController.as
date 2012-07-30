package GameComponents
{
	import Model.UpdateEvent;
	
	import flash.events.Event;
	
	import mouseGestures.*;

	/**
	 * Componente para enviar mensajes a un GameComponent Character ante determinados gestos del mouse
	 */
	
	public final class CharacterGestureController extends GameComponent
	{

		public var Gesture : String = "";
		
		override public function OnStart() : void
		{
			mMg = new MouseGesture(TheVisualObject.stage);
			//mMg.addGesture("A","71");
			mMg.addGesture("BACKSPACE","4");
			
			mMg.addEventListener(GestureEvent.GESTURE_MATCH,matchHandler);
			mMg.addEventListener(GestureEvent.NO_MATCH,noMatchHandler);
			mMg.addEventListener(GestureEvent.START_CAPTURE,startHandler);
			mMg.addEventListener(GestureEvent.STOP_CAPTURE,stopHandler);
		}
		
		override public function OnPause():void
		{
			
		}
		
		override public function OnResume():void
		{

		}
		
		override public function OnStop():void
		{

		}
		
		override public function OnUpdate(event:UpdateEvent):void
		{

		}
		
		// Handlers
		
		private function matchHandler(e:GestureEvent):void
		{
			TheVisualObject.ctOutput.text = "Match: " + e.datas;
		}			

		private function noMatchHandler(e:GestureEvent):void
		{
			TheVisualObject.ctOutput.text = "No Match";
		}
		
		private function startHandler(e:GestureEvent):void
		{
			TheVisualObject.visible = false;
		}		

		private function stopHandler(e:GestureEvent):void
		{
			TheVisualObject.visible = true;
		}

		// Variables

		private var mMg : MouseGesture;
		
	}
	
}