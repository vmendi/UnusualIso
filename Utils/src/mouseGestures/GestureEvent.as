/**
*
*
*	GestureEvent
*	
*	@notice		Gesture Event
*	@author		Didier Brun
*	@version	1.0
* 	@link		http://www.bytearray.org/?p=91
*
*/

package mouseGestures {
	
	import flash.events.Event;

	public class GestureEvent extends Event {
		
		// ------------------------------------------------
		//
		// ---o static
		//
		// ------------------------------------------------
		
		public static const START_CAPTURE:String="startCapture";
		public static const STOP_CAPTURE:String="stopCapture";
		public static const CAPTURING:String="capturing";
		public static const GESTURE_MATCH:String="gestureMatch";
		public static const NO_MATCH:String="noMatch";
		
		// ------------------------------------------------
		//
		// ---o properties
		//
		// ------------------------------------------------
		
		public var datas:*;
		public var fiability:uint;
		
		// ------------------------------------------------
		//
		// ---o constructor
		//
		// ------------------------------------------------
		
		public function GestureEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super (type,bubbles,cancelable);
		}
		
		// ------------------------------------------------
		//
		// ---o methods
		//
		// ------------------------------------------------
		
		public override function clone():Event{
			return new GestureEvent(type, bubbles, cancelable) as Event;
		}
		
	}
}
		
    