package
{
	import Model.IsoCamera;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import utils.Point3;
	
	public class IsoRenderer
	{
		public function IsoRenderer(canvas : Sprite, camera : IsoCamera)
		{
			mCanvas = canvas;
			mCamera = camera;
		}
			
		public function DrawCenterTarget() : void
		{
			mCanvas.graphics.lineStyle(0.0, 0x000000);
			mCanvas.graphics.moveTo((mCanvas.width*0.5)-20.0, (mCanvas.height*0.5));
			mCanvas.graphics.lineTo((mCanvas.width*0.5)+20.0, (mCanvas.height*0.5));
			
			mCanvas.graphics.moveTo(mCanvas.width*0.5, (mCanvas.height*0.5)-20.0);
			mCanvas.graphics.lineTo(mCanvas.width*0.5, (mCanvas.height*0.5)+20.0);
		}
		

		public function DrawAxis(pos : Point3) : void
		{
			DrawLine(0xFF0000, pos, new Point3(pos.x + 1, pos.y, pos.z));
			DrawLine(0x00FF00, pos, new Point3(pos.x, pos.y + 1, pos.z));
			DrawLine(0x0000FF, pos, new Point3(pos.x, pos.y, pos.z + 1));
		}
		
		public function DrawLine(color : uint, first : Point3, second : Point3) : void
		{
			mCanvas.graphics.lineStyle(0, color);
			DrawLineNoColor(first, second);
		}
		
	
		public function DrawGrid(cellSizeMeters : Number) : void
		{
			const cellSizePixels : Number = (IsoCamera.PixelsPerMeter * cellSizeMeters);
			
			var pos : Point = mCamera.TargetPos;
			
			var diagonal : Number = Math.sqrt(mCanvas.width*mCanvas.width + mCanvas.height*mCanvas.height);
			var halfDiagonal : Number = 2.0 + (diagonal / IsoCamera.PixelsPerMeter * 0.5);
			
			// Numero de celdas que caben en pantalla. Hacerlo igual para X e Y es incorrecto y sólo
			// valdrá cuando el ratio de pantalla es aprox 1
			// TODO: Calcular correctamente cuántas celdas caben en cada eje
			var numCellsOnScreen : Number = (diagonal/cellSizePixels) + 4;	
			var intNumCellsOnScreen : int = numCellsOnScreen;

			// Calculo de la coordenada de la primera celda que empezamos a pintar
			var startCellX : Number = pos.x / cellSizeMeters;
			startCellX -= numCellsOnScreen * 0.5;

			var currCoordX : Number = Math.floor(startCellX) * cellSizeMeters;
			
			mCanvas.graphics.lineStyle(0, 0xAAAAAA);
			
			for (var c:int = 0; c < intNumCellsOnScreen+2; c++)
			{
				DrawLineNoColor(new Point3(currCoordX, 0, -halfDiagonal+pos.y), new Point3(currCoordX, 0, halfDiagonal+pos.y));
				currCoordX += cellSizeMeters;
			}
			
			// Ahora en Y
			var startCellY : Number = pos.y / cellSizeMeters;
			startCellY -= numCellsOnScreen*0.5;
					
			var currCoordY : Number = Math.floor(startCellY) * cellSizeMeters;
			
			for (c = 0; c < intNumCellsOnScreen+2; c++)
			{
				DrawLineNoColor(new Point3(-halfDiagonal+pos.x, 0, currCoordY), new Point3(halfDiagonal+pos.x, 0, currCoordY));
				currCoordY += cellSizeMeters;
			}
		}
				
		private function DrawLineNoColor(first : Point3, second : Point3) : void
		{
			var prj00 : Point = mCamera.IsoWorldToScreen(first);
			var prj01 : Point = mCamera.IsoWorldToScreen(second);
			mCanvas.graphics.moveTo(prj00.x, prj00.y);
			mCanvas.graphics.lineTo(prj01.x, prj01.y);
		}
		
		
		private var mCamera : IsoCamera;
		private var mCanvas : Sprite;
	}
}