package GameComponents.Video
{
	import GameComponents.GameComponent;
	import Model.UpdateEvent;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;

	/**
	 * Componente para controlar un vídeo dentro de un movieclip de la librería
	 */
	public final class VideoGizmo extends GameComponent
	{

		public var Data : String = "";
		public var Edit : Boolean = true;
		
		override public function OnStart() : void
		{
			mData = new Array();
			mX = 0;
			mY = 0;
			
			// Referencia al GameComponent que contiene el vídeo
			mVideo = TheGameModel.FindGameComponentByShortName("VideoContent") as VideoContent;
			
			// Cargamos los primeros datos, si los hay
			if (Data.length > 0)
			{
				ReadData();
			}
			
			// Eventos
			TheVisualObject.stage.addEventListener(MouseEvent.CLICK, onClickHandler);
			//TheVisualObject.btRecord.addEventListener(MouseEvent.CLICK, onClickRecord);
			
		}
		
		override public function OnPause():void
		{

		}
		
		override public function OnResume():void
		{

		}
		
		override public function OnStop():void
		{
			SaveData();
		}
		
		override public function OnUpdate(event:UpdateEvent):void
		{
			UpdateVisualData();
		}
		
		// Cambio de datos
		
		private function ReadData():void
		{
			
		}
		
		private function SaveData():void
		{

		}
		
		// Actualización de los datos
		
		private function UpdateVisualData():void
		{
			var videoTime : Number = mVideo.TheVisualObject.Video.playheadTime;
			TheVisualObject.ctTime.text = videoTime;
			TheVisualObject.ctX.text = mX;
			TheVisualObject.ctY.text = mY;
		}
		
		private function UpdateData():void
		{
			var newData : Object = {x:mX, y:mY};
			var videoTime : Number = mVideo.TheVisualObject.Video.playheadTime;
			mData[Math.floor(videoTime*1000)] = newData;
		}
		
		// Handlers
		
		private function onClickHandler(e:MouseEvent):void
		{ 
			var p : Point = TheGameModel.TheRender2DCamera.globalToLocal(new Point(e.stageX, e.stageY));
			mX = p.x;
			mY = p.y;
			UpdateVisualData();
		}
		
		private function onClickRecord(e:MouseEvent):void
		{
			UpdateData();
		}
				
		// Variables

		private var mVideo : VideoContent;
		private var mData : Array;
		private var mX : Number;
		private var mY : Number;

	}
	
}