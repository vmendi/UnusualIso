package GameComponents
{
	import Model.GameModel;
	import Model.IsoBounds;
	import Model.IsoCamera;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import utils.Point3;
	
	public final class IsoComponent extends GameComponent
	{
		public var WidthInCells : int = 0;
		public var HeightInCells : int = 0;
		public var Transparent : Boolean = true;
		public var Walkable : Boolean = false;
		
		/** Posición en el mundo */
		[Bindable(event="WorldPosChanged")]
		public function get WorldPos() : Point3  { return mWorldPos; }
		
		/** Cambia la posición en mundo */
		public function set WorldPos(p : Point3) : void
		{
			mWorldPos = p;
			UpdateVisualObjectPos();
			dispatchEvent(new Event("WorldPosChanged"));
		}
		
		public const SOUTH_EAST : int = 0;
		public const SOUTH_WEST : int = 1;
		public const NORTH_WEST : int = 2;
		public const NORTH_EAST : int = 3;

		public function NextOrientation() : void
		{
			Orientation = Orientation+1;
		}
		
		[Bindable(event="OrientationChanged")]
		public function get Orientation() : int 	{ return mOrientation; }
		public function set Orientation(or : int):void
		{
			mOrientation = or;
			
			if (mOrientation > NORTH_EAST)
				mOrientation = SOUTH_EAST;
			
			UpdateVisualObjectOrient();
			dispatchEvent(new Event("OrientationChanged"));
		}
		
		/** Ancho en celdas del objeto, depende de la orientación */
		public function get OrientedWidthInCells() : int 
		{ 
			if (mOrientation == NORTH_EAST || mOrientation == SOUTH_WEST)
				return HeightInCells;
				
			return WidthInCells;
		}
		
		/** Alto en celdas del objeto, depende de la orientación */
		public function get OrientedHeightInCells() : int 
		{ 
			if (mOrientation == NORTH_EAST || mOrientation == SOUTH_WEST)
				return WidthInCells;

			return HeightInCells;
		}
		
		/** Coordenada X en mundo de la esquina frontal derecha. Se usa para ordenar en profundidad */
		public function get FrontRigthX() : Number { return mWorldPos.x + (OrientedWidthInCells*GameModel.CellSizeMeters); }
		/** Coordenada Z en mundo de la esquina frontal derecha. Se usa para ordenar en profundidad */
		public function get FrontRigthZ() : Number { return mWorldPos.z + (OrientedHeightInCells*GameModel.CellSizeMeters); }
		
		/** Bounds en espacio de mundo */
		public function get Bounds() : IsoBounds
		{
			mBounds.Left = mWorldPos.x;
			mBounds.Back = mWorldPos.z;
			mBounds.Right = mWorldPos.x + (OrientedWidthInCells*GameModel.CellSizeMeters);
			mBounds.Front = mWorldPos.z + (OrientedHeightInCells*GameModel.CellSizeMeters);
			
			return mBounds;
		}

		/** Cambia la posición en mundo pero haciendo primero un snap a celda */
		public function SetWorldPosSnapped(p : Point3) : void
		{
			WorldPos = GameModel.GetSnappedWorldPos(p);
		}
		
		/** Cambia la posición en mundo pero haciendo primero un snap a celda redondeando a la más cercana */
		public function SetWorldPosRounded(p : Point3) : void
		{
			WorldPos = GameModel.GetRoundedWorldPos(p);
		}
		
		
		private function UpdateVisualObjectPos() : void
		{
			// Es posible que no estemos todavía insertados en la escena.
			if (TheSceneObject != null)
			{
				var pos : Point = IsoCamera.IsoProject(mWorldPos);
								
				TheVisualObject.x = Math.floor(pos.x);
				TheVisualObject.y = Math.floor(pos.y);
			}
		}
		
		private function UpdateVisualObjectOrient() : void
		{
			// Es posible que no estemos todavía insertados en la escena, pero si tenemos SceneObject
			// el IsoComponent exige que exista su VisualObject, no puede ser un SceneObject vacio.
			if (TheSceneObject != null)
			{
				var orientString : Array = [ "se", "sw", "nw", "ne" ];
				
				TheVisualObject.gotoAndStop(orientString[mOrientation]);
			
				TheSceneObject.InvalidateBoundingRectangle();
			}
		}
		
		override public function OnAddedToScene():void
		{
			TheGameModel.TheIsoCamera.addChild(TheVisualObject);
			
			// Refrescamos el estado de pantalla.
			UpdateVisualObjectPos();
			UpdateVisualObjectOrient();	
		}
		
		override public function OnRemovedFromScene():void
		{
			TheGameModel.TheIsoCamera.removeChild(TheVisualObject);
		}
		
		
		public function IsoComponent()
		{
			mBounds = new IsoBounds();
		}

		
		/** Auxiliar para ayudar al Sorter */
		public function set SortingProcessed(val : Boolean) : void { mSortingProcessed = val; }
		public function get SortingProcessed() : Boolean { return mSortingProcessed; }
		public function 	IsSortingProcessedSerializable() : Boolean { return	false; }		// No queremos que se serialize al disco
		
		private var mSortingProcessed : Boolean = false;
		private var mBounds : IsoBounds;
		private var mWorldPos : Point3 = new Point3(0, 0, 0);
		private var mOrientation : int = SOUTH_EAST;
	}
}