package Editor
{
	import flash.display.DisplayObject;
	
	/**
	 * Inteface para ayudar a que una aplicación en Flash pueda abrir ventanas, sin depender de AIR.
	 * Cuando no haya AIR podremos por ejemplo hacer Switch de la actual a la nueva.
	 */
	public interface IWindowHelper
	{
		function OpenWindow(title:String, width:Number, height:Number, content:DisplayObject) : void;
		
		/** DockToBottom DockToRight */
		function OpenWindowDocked(title:String, width:Number, height:Number, 
								  content:DisplayObject, dockTo:Object, where:String="DockToBottom", 
								  offsetX:Number = 0, offsetY:Number = 0):void;
	}
}