package
{
	import Editor.IWindowHelper;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.system.Capabilities;
	
	import mx.core.Window;
	import mx.events.AIREvent;
	
	import utils.Delegate;

	
	public class WindowHelperAIR implements IWindowHelper
	{
		public function OpenWindow(title:String, width:Number, height:Number, content:DisplayObject):void
		{
			var window : Window = new Window();
			window.addEventListener(AIREvent.WINDOW_COMPLETE, CenterOnCreationComplete, false, 0, true);
			window.title=title;
			window.width=width;
			window.height=height;
			window.addChild(content);
			window.open(true);
		}
		
		public function OpenWindowDocked(title:String, width:Number, height:Number, 
									     content:DisplayObject, dockTo:Object, where:String="DockToBottom",
									     offsetX:Number = 0, offsetY:Number = 0):void
		{
			var dockToWindow : Window = dockTo as Window;

			if (dockToWindow == null)
				throw "DockTo must be an AIR Window";
			
			if (where != "DockToBottom" && where != "DockToRight")
				throw "Unsupported";

			var window : Window = new Window();
			if (where == "DockToBottom")
			{
				window.addEventListener(AIREvent.WINDOW_COMPLETE, Delegate.create(DockToBottomOnCreationComplete, 
									    dockToWindow, offsetX, offsetY));
				window.title=title;
				window.width=dockToWindow.width;
				window.height=height;
			}
			else
			if (where == "DockToRight")
			{
				window.addEventListener(AIREvent.WINDOW_COMPLETE, Delegate.create(DockToRightOnCreationComplete, 
										dockToWindow, offsetX, offsetY));
				window.title=title;
				window.width=width;
				window.height=dockToWindow.height;
			}
			
			dockToWindow.addEventListener(Event.CLOSING, Delegate.create(OnDockToWindowClosing, window));
			
			window.addChild(content);
			window.open(true);
		}
		
		private function OnDockToWindowClosing(event:Event, childWindow : Window):void
		{
			var dockToWindow : Window = (event.target as Window)
			dockToWindow.removeEventListener(Event.CLOSING, OnDockToWindowClosing);
			
			// Cerramos la ventana "hija", la que se dockeo
			childWindow.nativeWindow.close();
		}
		
		private function DockToRightOnCreationComplete(event: Event, dockToWindow:Window, 
											           offsetX:Number, offsetY:Number): void
		{
			var window : Window = event.target as Window;
			window.removeEventListener(AIREvent.WINDOW_COMPLETE, DockToRightOnCreationComplete);
			
			window.nativeWindow.x = dockToWindow.nativeWindow.x+dockToWindow.nativeWindow.width+offsetX;
			window.nativeWindow.y = dockToWindow.nativeWindow.y+offsetY;
						
			window.orderInBackOf(dockToWindow);
		}
		
		private function DockToBottomOnCreationComplete(event: Event, dockToWindow:Window, 
														offsetX:Number, offsetY:Number): void
		{
			var window : Window = event.target as Window;
			window.removeEventListener(AIREvent.WINDOW_COMPLETE, DockToBottomOnCreationComplete);
			
			window.nativeWindow.x = dockToWindow.nativeWindow.x + offsetX;
			window.nativeWindow.y = dockToWindow.nativeWindow.y+dockToWindow.nativeWindow.height+offsetY;
			
			window.orderInBackOf(dockToWindow);
		}
		
		private function CenterOnCreationComplete(event: Event): void
        {
        	var window : Window = event.target as Window;        	
        	window.removeEventListener(AIREvent.WINDOW_COMPLETE, CenterOnCreationComplete);
        	
            window.nativeWindow.x = (Capabilities.screenResolutionX - window.width) / 2;
            window.nativeWindow.y = (Capabilities.screenResolutionY - window.height) / 2;
        }
	}
}