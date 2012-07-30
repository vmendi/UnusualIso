package Model
{
	import GameComponents.IsoComponent;
	
	import PathFinding.IAStarSearchable;
	import PathFinding.IntPoint;
	
	import utils.Point3;
	
	/**
	 * Espacio de busqueda para el A estrella, se calcula a partir de la caminabilidad del fondo y de los propios IsoObjs del mundo.
	 */
	public class AStartMapSpace implements IAStarSearchable
	{
		public function AStartMapSpace(paramIsoComps : Array, isoBackground : IsoBackground, cellSizeInMeters : Number) : void
		{
			mCellSizeInMeters = cellSizeInMeters;
			
			var isoComps : Array = paramIsoComps.slice();

			mBounds = ConvertBoundsToCells(GetBounds(isoComps));
			mBounds.Join(ConvertBoundsToCells(isoBackground.GetBounds()));

			// Cacheamos aquí, hemos comprobado con el AStar que le cuesta pedir el IsWalkable.
			// Este es el primer y único sitio donde se modifica mBounds, así que el cache siempre será valido
			mBoundsWidth = mBounds.Width;
			mBoundsHeight = mBounds.Height;

			mCells = new Array((mBoundsWidth as int)*(mBoundsHeight as int));
			
			for (var c : int = 0; c < mBoundsWidth*mBoundsHeight; c++)
				mCells[c] = true;
			
			for each(var isoObj : IsoComponent in isoComps)
			{
				if (isoObj.Walkable)
					continue;
				
				for (c = 0; c < isoObj.OrientedWidthInCells; c++)
				{
					var coordX : int = Math.round((isoObj.WorldPos.x/mCellSizeInMeters) + c - mBounds.Left);
					for (var d:int = 0; d < isoObj.OrientedHeightInCells; d++)
					{
						var coordZ : int = Math.round((isoObj.WorldPos.z/mCellSizeInMeters) + d - mBounds.Back);
						mCells[coordX + (coordZ*mBoundsWidth)] = false; 
					}
				}
			}
			
			var nonWalkable : Array = isoBackground.NonWalkable;
			
			for each(var cell : Object in nonWalkable)
			{
				var cellX : int = Math.round((cell.ThePoint.x/mCellSizeInMeters) - mBounds.Left);
				var cellY : int = Math.round((cell.ThePoint.y/mCellSizeInMeters) - mBounds.Back);
				
				mCells[cellX + (cellY*mBoundsWidth)] = false;
			}
		}
		
		private function GetBounds(isoComps : Array) : IsoBounds
		{
			var ret : IsoBounds = new IsoBounds;
			
			if (isoComps.length != 0)
			{
				ret.Left = int.MAX_VALUE;
				ret.Right = int.MIN_VALUE;
				ret.Back = int.MAX_VALUE;
				ret.Front = int.MIN_VALUE;
			}
			
			for each(var isoComp : IsoComponent in isoComps)
			{
				var posX : Number = isoComp.WorldPos.x;
				var posZ : Number = isoComp.WorldPos.z;
				
				var maxPosX : Number = posX + isoComp.OrientedWidthInCells*mCellSizeInMeters;
				var maxPosZ : Number = posZ + isoComp.OrientedHeightInCells*mCellSizeInMeters;
				
				if (posX < ret.Left)
					ret.Left = posX;
				if (maxPosX > ret.Right)
					ret.Right = maxPosX;
				if (posZ < ret.Back)
					ret.Back = posZ;
				if (maxPosZ > ret.Front)
					ret.Front = maxPosZ;
			}
			
			return ret;
		}
		
		public function WorldToSearchSpace(worldPos : Point3) : IntPoint
		{
			return new IntPoint((worldPos.x/mCellSizeInMeters) - mBounds.Left, 
							    (worldPos.z/mCellSizeInMeters) - mBounds.Back);
		}
		
		public function SearchToWorldSpace(pos : IntPoint) : Point3
		{
			return new Point3((pos.x + mBounds.Left)*mCellSizeInMeters, 0, 
							  (pos.y + mBounds.Back)*mCellSizeInMeters);
		}
		
		public function IsWalkable(x : int, y : int) : Boolean
		{
			if ((x >= 0) && (y >= 0) && (x < mBoundsWidth) && (y < mBoundsHeight))
				return mCells[x + (y*mBoundsWidth)];
			
			return false;
		}
		
		public function IsWorldPosWalkable(worldPos : Point3) : Boolean
		{
			var srcPoint : IntPoint = WorldToSearchSpace(worldPos);

			return IsWalkable(srcPoint.x, srcPoint.y);
		}
		
		public function ConvertBoundsToCells(worldBounds : IsoBounds) : IsoBounds
		{
			var ret : IsoBounds = new IsoBounds();
			
			ret.Left  = worldBounds.Left / mCellSizeInMeters;
			ret.Right = worldBounds.Right / mCellSizeInMeters;
			ret.Front = worldBounds.Front / mCellSizeInMeters;
			ret.Back  = worldBounds.Back / mCellSizeInMeters;
			
			return ret;	
		}
		
		public function SetWalkable(worldBounds : IsoBounds, walkable : Boolean) : void
		{
			var cellBounds : IsoBounds = ConvertBoundsToCells(worldBounds);
			var start : IntPoint = WorldToSearchSpace(worldBounds.LeftBackCorner);
			
			for (var c:int = start.y; c < start.y+cellBounds.Height; c++)
			{
				var currRow : int = c*mBoundsWidth;
				for (var d:int = start.x; d < start.x+cellBounds.Width; d++)
				{
					mCells[d+currRow] = walkable;
				}
			}
		}
		
		public function GetWidth() : int
		{
			return mBoundsWidth;	
		}
		
		public function GetHeight() : int
		{
			return mBoundsHeight;	
		}
		
		
		private var mCellSizeInMeters : Number;		
		private var mCells : Array;
		private var mBounds : IsoBounds;
		
		// Cacheamos aquí, hemos comprobado con el AStar que le cuesta pedir el IsWalkable
		private var mBoundsWidth : Number;
		private var mBoundsHeight : Number;
	}
}