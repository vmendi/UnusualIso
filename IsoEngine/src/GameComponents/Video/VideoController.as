package GameComponents.Video
{
	import GameComponents.GameComponent;
	import Model.UpdateEvent;
	
	import flash.events.MouseEvent;

	/**
	 * Componente para controlar un vídeo dentro de un movieclip de la librería
	 */	
	public final class VideoController extends GameComponent
	{
		
		override public function OnStart() : void
		{
			// Referencia al GameComponent que contiene el vídeo
			mVideo = TheGameModel.FindGameComponentByShortName("VideoContent") as VideoContent;
			
			// Eventos
			if (mVideo != null)
			{
				TheVisualObject.btPlay.addEventListener(MouseEvent.CLICK, onClickPlay);
				TheVisualObject.btStop.addEventListener(MouseEvent.CLICK, onClickStop);
				TheVisualObject.btPause.addEventListener(MouseEvent.CLICK, onClickPause);
			}

			
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
			//TheVisualObject.Video.
		}
		
		// Handlers
		
		private function onClickPlay(e:MouseEvent):void
		{
			mVideo.TheVisualObject.Video.play();
		}
		
		private function onClickPause(e:MouseEvent):void
		{
			mVideo.TheVisualObject.Video.pause();
		}
		
		private function onClickStop(e:MouseEvent):void
		{
			mVideo.TheVisualObject.Video.stop();
			mVideo.TheVisualObject.Video.seek(0);
		}
		
		// Variables

		private var mVideo : VideoContent;
		
	}
	
}