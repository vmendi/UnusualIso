package Model
{
	import GameComponents.DefaultGameComponent;
	import GameComponents.GameComponent;
	import GameComponents.IsoComponent;
	import GameComponents.Render2DComponent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;
	
	import utils.Point3;
	
	
	[Bindable]
	/**
	 * Objeto principal de librería.
	 * 
	 * Sirve como template para crear IsoObjs. Lleva todos los GameComponents que dan propiedades y comportamiento al IsoObj.
	 */
	public class AssetObject extends EventDispatcher
	{
		[Bindable(event="GameComponentsChanged")]
		public function get TheGameComponents() : ArrayCollection { return mComponents; }
		
		// Acceso directo al componente por defecto. Todos los AssetObj lo tienen
		public function get TheDefaultGameComponent() : DefaultGameComponent { return mDefaultGameComponent; }
		
		// SceneObject al que este AssetObj puede pertenecer. Si es un AssetObj que no está en el escenario, no tendrá SceneObj.
		public function get TheSceneObject() : SceneObject { return mSceneObject; }
				
		/** Acceso directo al IsoComponent. TODO: Definir política, cachear */
		public function get TheIsoComponent() : IsoComponent { return FindGameComponentByShortName("IsoComponent") as IsoComponent; }
		
		/** TODO: Definir política, cachear */
		public function get TheRender2DComponent() : Render2DComponent { return FindGameComponentByShortName("Render2DComponent") as Render2DComponent; }
		
		
		public function AddToScene(sceneObject : SceneObject) : void
		{
			mSceneObject = sceneObject;
			
			for each(var comp : GameComponent in mComponents)
			{
				comp.OnAddedToScene();
			}
		}
		
		public function RemoveFromScene() : void
		{
			for each(var comp : GameComponent in mComponents)
			{
				comp.OnRemovedFromScene();
			}
			
			mSceneObject = null;
		}
		
		public function SetRenderingEnabled(enable : Boolean):void
		{
			for each(var comp : GameComponent in mComponents)
			{
				if (enable)
					comp.OnAddedToScene();
				else
					comp.OnRemovedFromScene();
			}
		}
		
		/** Busca un componente */
		public function FindGameComponentByShortName(shortName : String) : GameComponent
		{
			var ret : GameComponent;
			
			for each(var comp : GameComponent in mComponents)
			{
				if (comp.ShortName == shortName)
				{
					ret = comp;
					break;
				}
			}
			
			return ret;
		}		
		
		//
		// Clone profundo, copia bit a bit todo el AssetObject
		//
		public function GetDeepClone() : AssetObject
		{
			var myClone : AssetObject = new AssetObject(false);
			
			for each (var comp : GameComponent in mComponents)
			{
				// TODO: Usar nuestra propia serialización, en vez de AMF... Evitaríamos llamar a propiedades que no son
				//       serializables (IsXXXXXXSerializable). OnTime #146
				var compClone : GameComponent = ObjectUtil.copy(comp) as GameComponent;
				
				if (compClone is DefaultGameComponent)
					myClone.mDefaultGameComponent = compClone as DefaultGameComponent;
				
				// Ya podemos añadirselo
				myClone.mComponents.addItem(compClone);
				
				// Le notificamos
				compClone.OnAddedToAssetObject(myClone);				 
			}

			return myClone;
		}
		
		public function Overwrite(other : AssetObject) : void
		{
			if (other == this)
				return;
				
			mComponents.removeAll();
			
			for each (var comp : GameComponent in other.mComponents)
			{
				var compClone : GameComponent = ObjectUtil.copy(comp) as GameComponent;

				if (compClone is DefaultGameComponent)
					mDefaultGameComponent = compClone as DefaultGameComponent;
					
				mComponents.addItem(compClone);
				
				// Le notificamos
				compClone.OnAddedToAssetObject(this); 
			}
		}
		
		public function AssetObject(bCreateDefault : Boolean = true) : void
		{
			mComponents = new ArrayCollection;
			
			if (bCreateDefault)
			{
				mDefaultGameComponent = new DefaultGameComponent()
				mComponents.addItem(mDefaultGameComponent);
				
				mDefaultGameComponent.OnAddedToAssetObject(this);
			}
		}
		
		public function AddGameComponent(fullCompName : String) : void
		{
			if (HasComponent(fullCompName))
				throw "Componente ya añadido";
			
			var curr2DCoords : Point = null;	
			if (mSceneObject != null)
				curr2DCoords = mSceneObject.TheVisualObject.localToGlobal(Point3.ZERO_POINT2);
				
			if (fullCompName == "GameComponents::IsoComponent")
				RemoveGameComponentNoChecks("GameComponents::Render2DComponent");
			else
			if (fullCompName == "GameComponents::Render2DComponent")
				RemoveGameComponentNoChecks("GameComponents::IsoComponent");
			
			AddGameComponentNoChecks(fullCompName);
			
			if (fullCompName == "GameComponents::IsoComponent" && curr2DCoords != null)
			{
				curr2DCoords = mSceneObject.TheGameModel.TheRenderCanvas.globalToLocal(curr2DCoords);
				var worldPos : Point3 = mSceneObject.TheGameModel.TheIsoCamera.IsoScreenToWorld(curr2DCoords);
				TheIsoComponent.SetWorldPosSnapped(worldPos);
			}
			
			dispatchEvent(new Event("GameComponentsChanged"));
		}
		
		private function AddGameComponentNoChecks(fullCompName : String) : void
		{
			var newComponent : GameComponent = new (getDefinitionByName(fullCompName) as Class);
			mComponents.addItem(newComponent);

			newComponent.OnAddedToAssetObject(this);
		}
		
		public function RemoveGameComponent(fullCompName : String) : void
		{
			if (!HasComponent(fullCompName))
				throw "Componente ya existente";
				
			var curr2DCoords : Point = null;
			if (mSceneObject != null)
				curr2DCoords = mSceneObject.TheVisualObject.localToGlobal(Point3.ZERO_POINT2);

			RemoveGameComponentNoChecks(fullCompName);
			
			if (fullCompName == "GameComponents::IsoComponent")
				AddGameComponentNoChecks("GameComponents::Render2DComponent");
			else
			if (fullCompName == "GameComponents::Render2DComponent")
				AddGameComponentNoChecks("GameComponents::IsoComponent");
				
			if (fullCompName == "GameComponents::Render2DComponent" && curr2DCoords != null)
			{
				curr2DCoords = mSceneObject.TheGameModel.TheRenderCanvas.globalToLocal(curr2DCoords);
				var worldPos : Point3 = mSceneObject.TheGameModel.TheIsoCamera.IsoScreenToWorld(curr2DCoords);
				TheIsoComponent.SetWorldPosSnapped(worldPos);
			}
				
			dispatchEvent(new Event("GameComponentsChanged"));
		}
		
		private function RemoveGameComponentNoChecks(fullCompName : String) : void
		{
			for (var c:int = 0; c < mComponents.length; c++)
			{
				if (mComponents[c].FullName == fullCompName)
				{
					var toRemove : Object = mComponents[c]; 
					mComponents.removeItemAt(c);
					toRemove.OnRemovedFromAssetObject();
					break;
				}
			}
		}
		
		public function CanBeAddedToScene() : Boolean
		{
			var comp : Object = FindGameComponentByShortName("IsoComponent");
			if (comp != null)
				return true;
				
			comp = FindGameComponentByShortName("Render2DComponent");			
			if (comp != null)
				return true;
				
			return false;
		}
		
		public function HasComponent(fullName : String):Boolean
		{
			for each(var comp : GameComponent in mComponents)
				if (fullName == comp.FullName)
					return true;
			return false;
		}
		
		public function LoadFromXML(xml : XML) : void
		{	
			mComponents = new ArrayCollection();

			for each(var compXML : XML in xml.child("GameComponent"))
			{
				var className : String = compXML.ClassName.toString();
				var compClass : Class = getDefinitionByName(className) as Class;
				var component : GameComponent = new compClass;
				
				if (component is DefaultGameComponent)
					mDefaultGameComponent = component as DefaultGameComponent;
				
				this.mComponents.addItem(component);

				component.OnAddedToAssetObject(this);	
				component.LoadFromXML(compXML);
			}
		}
		
		public function GetXML() : XML
		{
			var assetObjXML : XML = <AssetObject></AssetObject>
			
			for each(var component : GameComponent in mComponents)
			{
				var compXML : XML = component.GetXML();
				assetObjXML.appendChild(compXML);
			}					    
												    
			return assetObjXML;
		}
		
		private var mComponents : ArrayCollection;
		private var mSceneObject : SceneObject;
		private var mDefaultGameComponent : DefaultGameComponent;
	}
}