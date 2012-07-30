package utils
{
	//
	// Para poder pasar parámetros a funciones puntero:
	//
	// mc.addFrameScript(mc.totalFrames-1,Delegate.create(myFunction,i));
	//
	public final class Delegate
	{
		public static function create(handler:Function,...args):Function
		{
			return function(...innerArgs):void
			{
				handler.apply(this,innerArgs.concat(args));
			}
		}
	}

}