package Editor
{
	import GameComponents.DefaultGameComponent;
	import GameComponents.GameComponent;
	import GameComponents.IGameComponentEnumerator;
	import GameComponents.Render2DComponent;
	
	import Model.*;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.managers.DragManager;
	
	import utils.KeyboardHandler;
	import utils.Point3;
	
	
	public class EditorController extends EventDispatcher
	{
		public function EditorController(gameCompEnum : IGameComponentEnumerator, loadSaveCont : EditorLoadSaveController)
		{
			mModel = loadSaveCont.TheGameModel;
			mLoadSaveController = loadSaveCont;
			mGameComponentEnumerator = gameCompEnum;

			// El modelo nos notifica de que ha transcurrido un frame para que nosotros decidamos qué hacer
			mModel.addEventListener("OnUpdate", OnUpdate, false, 0, true);

			// Tb nos notifica de un cambio en la libreria
			BindingUtils.bindSetter(OnSWFLibrariesChanged, mModel.TheAssetLibrary, "SWFLibraries");
		}
		
		public function PlayGame() : void
		{
			mDisabledMouseInteraction = true;
			SelectSceneObject(null, null);
			
			mModel.StartGame();		
		}
		
		public function StopGame() : void
		{
			mModel.StopGame();
			
			mDisabledMouseInteraction = false;
		}
		
		public function ToggleGridRendering() : Boolean
		{
			return mModel.TheIsoCamera.TheIsoBackground.ToggleGridRendering();
		}
		
		public function ToggleWalkableRendering() : Boolean
		{
			return mModel.TheIsoCamera.TheIsoBackground.ToggleWalkableRendering();
		}
		
		public function ToggleEditBackground() : Boolean
		{
			if (!mEditingBackground)
			{
				mEditingBackground = true;				
				mModel.SetSceneObjectRendering(false);
				mModel.TheIsoCamera.TheIsoBackground.EnableGridAndWalkableRendering();
			}
			else
			{
				mEditingBackground = false;
				mModel.SetSceneObjectRendering(true);
			}
			
			return mEditingBackground;
		}		

		public function DeleteBackground() : void
		{
			mModel.TheIsoCamera.TheIsoBackground.DeleteBackground();
		}
	
		public function AddComponentToSelectedAssetObject(compName : String) : void
		{			
			if (SelectedAnyAssetObject == null)
				return;
			
			SelectedAnyAssetObject.AddGameComponent(compName);
		}
		
		public function RemoveComponentToSelectedAssetObject(compName : String) : void
		{
			if (SelectedAnyAssetObject == null)
				return;
				
			SelectedAnyAssetObject.RemoveGameComponent(compName);
		}
		
		public function CopyAssetObjectSelectedToAll() : void
		{
			mModel.CopyAssetObjectToAllSceneObjects(SelectedAnyAssetObject);
		}
		
		private function OnSWFLibrariesChanged(swfLibraries : ArrayCollection):void
		{
			// Si cambian los AssetObjects, nosotros perdemos la seleccion
			mSelectedSceneObject = null;
			dispatchEvent(new Event("SelectedSceneObjectChanged"));
		}
		
		
		public function get TheGameModel() : GameModel { return mModel; }
		public function get TheEditorLoadSaveController() : EditorLoadSaveController { return mLoadSaveController; }


		public function GetAddComponentsForSelectedAssetObject() : ArrayCollection
		{
			var ret : ArrayCollection = new ArrayCollection;
			
			if (SelectedAnyAssetObject == null)
				return ret;
				
			var allComps : ArrayCollection = mGameComponentEnumerator.GetComponentsDescription();
						
			for each(var comp : Object in allComps)
			{
				if (!SelectedAnyAssetObject.HasComponent(comp.FullName))
					ret.addItem(comp);
			}
			
			return ret;
		}
		
		public function GetRemoveComponentsForSelectedAssetObject() : ArrayCollection
		{
			var ret : ArrayCollection = new ArrayCollection;
			
			if (SelectedAnyAssetObject == null)
				return ret;
		
			for each(var comp : GameComponent in SelectedAnyAssetObject.TheGameComponents)
			{
				// El Default no se quita... 
				if (comp is DefaultGameComponent)
					continue;
					
				var theClass : Class = getDefinitionByName(getQualifiedClassName(comp)) as Class;
				var obj : Object = mGameComponentEnumerator.GetDescription(theClass);
				ret.addItem(obj);
			} 
		
			return ret;
		}
		
		
		//
		// Devuelve el AssetObject seleccionado, el normal o el del SceneObject
		//
		[Bindable(event="SelectedAnyAssetObjectChanged")]
		public function get SelectedAnyAssetObject() : AssetObject
		{
			if (mSelectedAssetObject != null)
				return mSelectedAssetObject;
			else
			if (mSelectedSceneObject != null)
				return mSelectedSceneObject.TheAssetObject;
				
			return null;
		}		

		
		[Bindable(event="SelectedAssetObjectChanged")]
		public function get SelectedAssetObject() : AssetObject { return mSelectedAssetObject; }
		public function set SelectedAssetObject(obj : AssetObject) : void
		{ 
			mSelectedAssetObject = obj;
			
			// El AssetObject deselecciona el SceneObject y al contrario
			if (mSelectedSceneObject != null)
				mSelectedSceneObject.ShowBounds = false;
			mSelectedSceneObject = null;
			
			dispatchEvent(new Event("SelectedAssetObjectChanged"));
			dispatchEvent(new Event("SelectedSceneObjectChanged"));	
			dispatchEvent(new Event("SelectedAnyAssetObjectChanged"));
		}
		

		[Bindable(event="SelectedSceneObjectChanged")]
		public function get SelectedSceneObject() : SceneObject	{ return mSelectedSceneObject; }
				
		private function SelectSceneObject(sceneObj : SceneObject, stageMouse : Point):void
		{
			mMouseMovementStart = CalcMouseMovementStart(sceneObj, stageMouse);
			
			if (mSelectedSceneObject != sceneObj)
			{
				if (mSelectedSceneObject != null)
					mSelectedSceneObject.ShowBounds = false;
		
				mSelectedSceneObject = sceneObj;
				
				if (mSelectedSceneObject != null)
					mSelectedSceneObject.ShowBounds = true;
							
				// El AssetObject deselecciona el SceneObject y al contrario
				mSelectedAssetObject = null;
				
				dispatchEvent(new Event("SelectedAssetObjectChanged"));
				dispatchEvent(new Event("SelectedSceneObjectChanged"));			
				dispatchEvent(new Event("SelectedAnyAssetObjectChanged"));
			}
		}
		
		// Calcula el offset del raton respecto al origen del movieclip
		private function CalcMouseMovementStart(sceneObj:SceneObject, stageMouse:Point) : Point
		{
			var ret : Point = null;
			
			if (stageMouse != null && sceneObj != null)
			{
				var globalVisualObjectCoord : Point = sceneObj.TheVisualObject.localToGlobal(new Point(0,0));

				ret = globalVisualObjectCoord.subtract(stageMouse);
			}
						
			return ret;
		}
		
		public function OnMouseMove(localMouse : Point, stageMouse : Point, globalMouseDown : Boolean) : void
		{
			if (mEditingBackground && globalMouseDown)
			{
				var onRenderCanvasPos : Point = mModel.TheRenderCanvas.globalToLocal(stageMouse);
				var worldPos : Point3 = mModel.TheIsoCamera.IsoScreenToWorld(onRenderCanvasPos);
				var snappedWorldPos : Point3 = GameModel.GetSnappedWorldPos(worldPos);
				if (mLastMarkedCell == null || (!mLastMarkedCell.IsEqual(snappedWorldPos)))
				{
					mLastMarkedCell = snappedWorldPos;
					mModel.TheIsoCamera.TheIsoBackground.ToggleCell(mLastMarkedCell);
				}
			}
			else
			if (mSelectedSceneObject != null && (mMouseDown || (globalMouseDown && DragManager.isDragging)) )
			{
				// Si hay objeto seleccionado & el ratón está down dentro del objeto seleccionado ||
				// || el ratón está down en global y arrastrando
				mIsMoving = true;
								
				if (KeyboardHandler.Keyb.IsKeyPressed(Keyboard.SHIFT) && (!mIsCloning) && (!DragManager.isDragging))
				{
					mSelectedSceneObject.ShowBounds = false;
					SelectSceneObject(mModel.CreateSceneObject(mSelectedSceneObject.TheAssetObject), stageMouse);
					mSelectedSceneObject.ShowBounds = true;
										
					// Para sólo clonar 1 vez
					mIsCloning = true;
				}
				
				if (mMouseMovementStart != null)
					stageMouse = stageMouse.add(mMouseMovementStart);
				
				// Distinguimos el movimiento para IsoComps del de Render2DComps
				if (mSelectedSceneObject.TheAssetObject.TheIsoComponent != null)
				{
					onRenderCanvasPos = mModel.TheRenderCanvas.globalToLocal(stageMouse);	
					var ret : Point3 = mModel.TheIsoCamera.IsoScreenToWorld(onRenderCanvasPos);
					mSelectedSceneObject.TheAssetObject.TheIsoComponent.SetWorldPosSnapped(ret);
				}
				else
				{
					// Es precondicion que exista el alternativo Render2DComp
					var render2D : Render2DComponent = mSelectedSceneObject.TheAssetObject.FindGameComponentByShortName("Render2DComponent") as Render2DComponent;
					onRenderCanvasPos = mModel.TheRender2DCamera.globalToLocal(stageMouse);
					render2D.ScreenPos = onRenderCanvasPos;
				}
			}
		}
		
		public function OnMouseClick(localMouse : Point, stageMouse : Point) : void
		{
			if (mEditingBackground || mDisabledMouseInteraction)
				return;
		}
		
		public function OnMouseDown(localMouse : Point, stageMouse : Point) : void
		{
			mMouseDown = true;
			
			if (mDisabledMouseInteraction)
				return;
			
			if (!mEditingBackground)
			{
				// Vemos si hacemos selección en cadena de profundidad
				if (!mIsMoving && mSelectedSceneObject && (KeyboardHandler.Keyb.IsKeyPressed(90)))
				{
					var underCursor : Array = mModel.FindUnderCursor(stageMouse);
					var lastIdx : int = underCursor.indexOf(mSelectedSceneObject);
	
					// Si el que seleccionamos la vez anterior está entre los posibles de ahora, cogemos el siguiente de la lista.
					// Suponemos que la lista siempre viene en el mismo orden, de detrás a delante
					if (lastIdx != -1)
					{
						var nextIdx : int = lastIdx+1;
						if (nextIdx >= underCursor.length)
							nextIdx = 0;
						
						SelectSceneObject(underCursor[nextIdx], stageMouse);
					}
				}
				else
				{
					underCursor = mModel.FindUnderCursor(stageMouse);
					
					if (underCursor.length > 0)
						SelectSceneObject(underCursor[0], stageMouse);
					else
						SelectSceneObject(null, null);
				}
			}
			else
			{
				var onRenderCanvasPos : Point = mModel.TheRenderCanvas.globalToLocal(stageMouse);
				var worldPos : Point3 = mModel.TheIsoCamera.IsoScreenToWorld(onRenderCanvasPos);
				mLastMarkedCell = GameModel.GetSnappedWorldPos(worldPos);
				mModel.TheIsoCamera.TheIsoBackground.ToggleCell(mLastMarkedCell);
			}
		}
				
		public function OnMouseUp(localMouse : Point, stageMouse : Point) : void
		{
			mLastMarkedCell = null;
			
			mIsCloning = false;
			mIsMoving = false;
			
			mMouseDown = false;
		}
		
		public function OnUpdate(event : UpdateEvent) : void
		{
			mModel.TheIsoCamera.MoveWithKeyboard(event.ElapsedTime, false);
			mModel.TheRender2DCamera.MoveWithKeyboard(event.ElapsedTime, true);
		}
		
	
		public function RotateIsoObject() : void
		{
			if (mSelectedSceneObject != null && mSelectedSceneObject.TheAssetObject.TheIsoComponent != null)
			{
				mSelectedSceneObject.TheAssetObject.TheIsoComponent.NextOrientation(); 
			}
		}
		
		public function OnDeletePressed() : void
		{
			if (mSelectedSceneObject != null)
			{
				mModel.DeleteSceneObject(mSelectedSceneObject);
				SelectSceneObject(null, null);
			}
		}
		
		public function OnSpacePressed() : void
		{
			RotateIsoObject();
		}
		
		public function DropAssetObjectStart(mcName : String) : Boolean
		{
			if (mEditingBackground || mDisabledMouseInteraction)
				return false;
				
			if (!mModel.CanBeAddedToScene(mcName))
				return false;
				
			var assetObj : AssetObject = mModel.TheAssetLibrary.FindAssetObjectByMovieClipName(mcName);
			SelectSceneObject(mModel.CreateSceneObject(assetObj), null);
			
			return true;
		}
		
		public function DropAssetObjectEnd(success : Boolean) : void
		{
			if (mEditingBackground || mDisabledMouseInteraction)
				return;
				
			if (!success && mSelectedSceneObject)
			{
				// Tenemos que cancelar la operación
				mModel.DeleteSceneObject(mSelectedSceneObject);
			}
			
			SelectSceneObject(null, null);
		}
		
		public function RemoveSWFLibrary(swfLibrary : Object) : void
		{
			mModel.TheAssetLibrary.RemoveSWFLibrary(swfLibrary);
		}
		
				
		private var mDisabledMouseInteraction : Boolean = false;		
		private var mEditingBackground : Boolean = false;
		private var mLastMarkedCell : Point3 = null;
		
		private var mIsMoving  : Boolean = false;
		private var mIsCloning : Boolean = false;
		private var mMouseDown : Boolean = false;
		
		private var mMouseMovementStart : Point;
				
		private var mSelectedSceneObject : SceneObject;
		private var mSelectedAssetObject : AssetObject;
		
		private var mModel : GameModel;
		private var mLoadSaveController : EditorLoadSaveController;
		private var mGameComponentEnumerator : IGameComponentEnumerator;		
	}
}