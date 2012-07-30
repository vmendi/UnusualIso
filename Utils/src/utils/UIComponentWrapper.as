package utils
{
	import flash.display.DisplayObject;
	import mx.core.UIComponent;
	
	
	public final class UIComponentWrapper extends UIComponent
	{
		public function UIComponentWrapper(wrapMe : DisplayObject)
		{
			addChild(wrapMe);
			width = wrapMe.width;
			height = wrapMe.height;
		}

	}
}