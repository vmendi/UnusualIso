package utils
{
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	
	public final class MovieClipFinder
	{
		static public function GetDeepChildByName(name : String, mc : DisplayObjectContainer): DisplayObject
		{
			var ret : DisplayObject = mc.getChildByName(name);
			
			if (ret == null)
			{
				for (var c : int = 0; c < mc.numChildren; c++)
				{
					var curr : DisplayObjectContainer = mc.getChildAt(c) as DisplayObjectContainer;
					
					// Solo hay que buscar en los containers
					if (curr != null)
					{ 
						ret = GetDeepChildByName(name, curr);
						
						if (ret != null)
							break;
					}		
				}
			}
			
			return ret;
		}
	}
}