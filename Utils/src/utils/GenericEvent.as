package utils
{
	import flash.events.Event;

	public class GenericEvent extends Event
	{
		public var Data : Object;
		
		public function GenericEvent(type:String, obj:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			Data=obj;
			super(type, bubbles, cancelable);
		}
		
	}
}