package Model
{
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import utils.Point3;
	
	/**
	 * Objeto auxiliar para renderizar una rejilla. 
	 *
	 * Hay que llamar a SetCameraCenter para que se mueva junto a la camara al moverse ésta.
	 * 
	 */
	public final class IsoGrid extends UIComponent
	{							
		public function IsoGrid() : void
		{
		}
		
		public function Generate(widthCells : int, heightCells : int, cellSizeMeters : Number) : void
		{
			mWidthCells = widthCells;
			mHeightCells = heightCells;
			mCellSizeMeters = cellSizeMeters;

			var totalHeight : Number = mHeightCells * mCellSizeMeters;
			var totalWidth : Number  = mWidthCells * mCellSizeMeters;
			
			var currCoordX : Number = 0;
			
			graphics.clear();
			graphics.lineStyle(0, 0xAAAAAA);
			
			for (var c : int = 0; c < mWidthCells+1; c++)
			{
				var prj00 : Point = IsoCamera.IsoProject(new Point3(currCoordX, 0, 0));
				var prj01 : Point = IsoCamera.IsoProject(new Point3(currCoordX, 0, totalHeight));
									
				graphics.moveTo(prj00.x, prj00.y);
				graphics.lineTo(prj01.x, prj01.y);

				currCoordX += mCellSizeMeters;
			}
			
			var currCoordZ : Number = 0;
				
			for (c = 0; c < mHeightCells+1; c++)
			{
				prj00 = IsoCamera.IsoProject(new Point3(0, 0, currCoordZ));
				prj01 = IsoCamera.IsoProject(new Point3(totalHeight, 0, currCoordZ));
				
				graphics.moveTo(prj00.x, prj00.y);
				graphics.lineTo(prj01.x, prj01.y);
				
				currCoordZ += mCellSizeMeters;
			}

			this.cacheAsBitmap = true;
			
			// Pintamos el Eje. El centro no está en el 0, sino en la mitad de la rejilla
			var center : Point3 = new Point3(mWidthCells*mCellSizeMeters*0.5, 0, mHeightCells*mCellSizeMeters*0.5);
			var snappedCenter : Point3 = GameModel.GetSnappedWorldPos(center);
			
			/*
			var renderer : IsoRenderer = new IsoRenderer(this, new IsoCamera());
			renderer.DrawAxis(snappedCenter);
			*/
						
			// Nos posicionamos respecto al padre, que esperamos sea el mundo
			var centerOnParent : Point = IsoCamera.IsoProject(snappedCenter);

			x = -centerOnParent.x;
			y = -centerOnParent.y;
		}
		
		public function SetCameraCenter(camCenter : Point) : void
		{
			var center : Point3 = new Point3(mWidthCells*mCellSizeMeters*0.5, 0, mHeightCells*mCellSizeMeters*0.5);
			var snappedCenter : Point3 = GameModel.GetSnappedWorldPos(center);
			
			var local : Point3 =  GameModel.GetSnappedWorldPos(new Point3(camCenter.x, 0, camCenter.y));
			snappedCenter.x -= local.x;
			snappedCenter.y -= local.y;
			snappedCenter.z -= local.z;
			
			var centerOnParent : Point = IsoCamera.IsoProject(snappedCenter);

			x = -centerOnParent.x;
			y = -centerOnParent.y;
		}

		private var mGameModel : GameModel;
		private var mCellSizeMeters : Number = 0;
		private var mWidthCells  : int = 0;
		private var mHeightCells  : int = 0;
	}
}