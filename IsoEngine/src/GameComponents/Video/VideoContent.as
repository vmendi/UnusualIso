package GameComponents.Video
{
	import GameComponents.GameComponent;
	import Model.UpdateEvent;

	/**
	 * Componente para controlar un vídeo dentro de un movieclip de la librería
	 */	
	public final class VideoContent extends GameComponent
	{

		public var TargetWidth : Number = 800;
				
		override public function OnStart() : void
		{
			mOriginalWidth = TheVisualObject.Video.width;
			mOriginalHeight = TheVisualObject.Video.height;
			var OriginalRatio : Number = mOriginalHeight/mOriginalWidth;
			TheVisualObject.Video.scaleMode = "maintainAspectRatio";
			var NewWidth : Number = TargetWidth;
			var NewHeight : Number = Math.abs(OriginalRatio * NewWidth);
			TheVisualObject.Video.setSize(NewWidth,NewHeight);
			TheVisualObject.x = -TheVisualObject.Video.width/2;
			TheVisualObject.y = -TheVisualObject.Video.height/2;
		}
		
		override public function OnPause():void
		{
			//TheVisualObject.Video.pause();
		}
		
		override public function OnResume():void
		{
			//TheVisualObject.Video.play();
		}
		
		override public function OnStop():void
		{
			//TheVisualObject.Video.stop();
			//TheVisualObject.Video.seek(0);
		}
		
		override public function OnUpdate(event:UpdateEvent):void
		{

		}
		
		// Handlers
		
		// Variables

		private var mOriginalWidth : Number;
		private var mOriginalHeight : Number;
		
	}
	
}