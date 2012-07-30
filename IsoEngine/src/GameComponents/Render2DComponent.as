package GameComponents
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import utils.Point3;
	
	public final class Render2DComponent extends GameComponent
	{
		public var ZOrder : int = 0;
		
		
		override public function OnAddedToScene():void
		{
			// La primera vez que nos añaden, recuperamos la posición cargada desde disco
			if (mLoadedPos != null)
			{
				ScreenPos = mLoadedPos;
				mLoadedPos = null;
			}
			
			TheGameModel.TheRender2DCamera.addChild(TheVisualObject);
		}
		
		override public function OnRemovedFromScene():void
		{
			TheGameModel.TheRender2DCamera.removeChild(TheVisualObject);
		}
	
		
		[Bindable(event="ScreenPosChanged")]
		public function get ScreenPos() : Point
		{ 
			if (TheVisualObject != null)
				return new Point(TheVisualObject.x, TheVisualObject.y);
			
			return Point3.ZERO_POINT2;
		}
			
		public function set ScreenPos(pos : Point):void
		{
			// Cuando no estamos en pantalla, no tenemos VisualObject
			if (TheVisualObject != null)
			{ 
				TheVisualObject.x = pos.x; 
				TheVisualObject.y = pos.y;
			}
			else
			{
				// En el primer Set no estamos añadidos a la escena, almacenamos la posicion para luego
				mLoadedPos = pos;
			}
			
			dispatchEvent(new Event("ScreenPosChanged"));
		}
		
				
		private var mLoadedPos : Point;		
	}
}