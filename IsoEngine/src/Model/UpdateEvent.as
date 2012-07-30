package Model
{
	import flash.events.Event;
	
	/**
	 * Evento que lanza el GameModel para indicar que ha transcurrido un fotograma. 
	 * 
	 * Se usa para actualizar el juego, según el tiempo transcurrido desde el último fotograma "elapsedTime".
	 */
	public final class UpdateEvent extends Event
	{
		public var ElapsedTime : Number = 0;
		
		public function UpdateEvent(type:String, elapsedTime:Number, bubbles:Boolean=false, cancelable:Boolean=false) : void
		{
			ElapsedTime = elapsedTime;
			super(type, bubbles, cancelable);
		}

	}
}