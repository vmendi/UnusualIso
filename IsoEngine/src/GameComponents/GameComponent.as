package GameComponents
{
	import Model.AssetObject;
	import Model.GameModel;
	import Model.SceneObject;
	import Model.UpdateEvent;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	import utils.KeyValueWrapper;
	import utils.Point3;
	import utils.reflection.ClassInfo;
	import utils.reflection.MethodInfo;
	
	[Bindable]
	/**
	 * Clase base para todos los componentes del juego.
	 */
	public dynamic class GameComponent extends EventDispatcher
	{
		virtual public function OnStart():void {}					/** El sistema llama al comenzar el juego. */
		virtual public function OnUpdate(event:UpdateEvent):void {} /** Actualización en cada fotograma. */ 
		virtual public function OnPause():void {}					/** El sistema llama para que el componente implemente la pause. */
		virtual public function OnResume():void {}				  	/** Y aquí para volver a jugar. */
		virtual public function OnStop():void {}					/** Se llama al parar el juego. */
		
		/** El componente Interaction informa a todos sus hermanos de que se ha producido una interacción con el personaje. */
		virtual public function OnCharacterInteraction():void {}
		
		/** El componente Interaction informa a todos sus hermanos de que se ha producido una interacción de ratón (click). */	
		virtual public function OnClickInteraction():void {}
		
		
		/** Nos llaman para indicar que nos han añadido a un AssetObj */
		virtual public function OnAddedToAssetObject(assetObj : AssetObject) : void 
		{
			mAssetObject = assetObj;
			
			if (mAssetObject.TheSceneObject != null)
				OnAddedToScene(); 
		}
		
		/** Nos llaman para indicar que nos van a eliminar del AssetObject, por ejemplo, durante el editor */
		virtual public function OnRemovedFromAssetObject() : void
		{
			if (mAssetObject.TheSceneObject != null)
				OnRemovedFromScene();
			
			mAssetObject = null;
		}
		
		/** Nos llaman para indicar que el SceneObject es valido y que nos han añadido al mapa */
		virtual public function OnAddedToScene() : void {}
		
		/** Nos llaman para indicar que este componente ya no está en el mapa */
		virtual public function OnRemovedFromScene() : void {}
		
		
		/** SceneObject al que pertenece este componente */
		public function get TheSceneObject() : SceneObject
		{
			// Debido al sistema de serialización AMF (por ejemplo en AssetObj.GetDeepClone), durante la
			// deserialización de algún componente (IsoComponent) se ejecuta código que requiere del SceneObject,
			// pero todavia no está ni siquiera asignado el AssetObject
			if (mAssetObject != null)
				return mAssetObject.TheSceneObject;
			else
				return null;
		}
		
		/** AssetObject al que pertenece este componente */
		public function get TheAssetObject() : AssetObject { return mAssetObject; }
		
		/** GameModel al que pertenece el componente */
		public function get TheGameModel() : GameModel
		{
			// Es posible que no tengamos todavía SceneObject, no estamos añadidos a la escena
			if (mAssetObject != null && mAssetObject.TheSceneObject != null)
				return mAssetObject.TheSceneObject.TheGameModel;
			else
				return null;
		}
		/** VisualObject asociado a nuestro SceneObject */
		public function get TheVisualObject() : MovieClip
		{ 
			if (mAssetObject != null && mAssetObject.TheSceneObject != null)
				return mAssetObject.TheSceneObject.TheVisualObject;
			else
				return null; 
		}
		
		/** IsoComponent: Acceso directo a uno de mis siblings importantes. */
		public function get TheIsoComponent() : IsoComponent { return mAssetObject.TheIsoComponent; }


		/** Nombre de la clase del componente, por ejemplo: GameComponents::Character */
		public function get FullName()  : String { return getQualifiedClassName(this); }
		/** Nombre corto de la clase del componente, quitando todos los namespaces */
		public function get ShortName() : String
		{
			var fullName : String = getQualifiedClassName(this);
			var start : int = fullName.lastIndexOf("::");
						
			return fullName.substr(start+2, fullName.length-start-2); 
		}
		
		
		/**
		 * Devuelve un ArrayCollection con todas las variables dinámicas del GameComponent.
		 * 
		 * Necesitamos esto porque las rows del DataGrid tienen que estar en una colección, y
		 * queremos que ésta colección sea las variables del objeto en formato (llave, valor)
		 */
		public function ReflectGameComponent() : ArrayCollection
		{
			var ret : ArrayCollection = new ArrayCollection();
			var clInfo : ClassInfo = new ClassInfo(this);
			
			for each(var property : MethodInfo in clInfo.properties)
			{
				// Nos deshacemos de las variables que no nos interesan (IsXXXXXXSerializable)
				var serializeIt : Boolean = true;
				var funcName : String = "Is"+property.name+"Serializable";
				var isSerializableFunc : MethodInfo = clInfo.method(funcName); 
				
				if (isSerializableFunc != null)
					serializeIt = this[funcName]() as Boolean;

				if (property.writable && serializeIt)
				{
					// Envolvemos para que el set al Value nos escriba en nosotros
					ret.addItem(new KeyValueWrapper(this, property.name));					
				}
			}
			
			var theSort : Sort = new Sort();    
     		theSort.fields = [new SortField("ValueType",true), new SortField("Key",true, true) ]
       		ret.sort = theSort;
       		theSort.reverse();
       		ret.refresh();
			
			return ret;
		}
		
		/**
		 * Deserializa el componente a partir de un XML. Es aquí donde se decide nuestros tipos soportados.
		 */
		public function LoadFromXML(compXML:XML) : void
		{
			var clInfo : ClassInfo = new ClassInfo(this);
				
			for each(var attribXML : XML in compXML.child("Attrib"))
			{
				var attribName : String = attribXML.Name.toString();
				
				// Quizá el atributo haya desaparecido en esta nueva versión de la clase
				if (clInfo.property(attribName) != null)
				{
					// Convertimos aquí nuestros tipos y todo lo que no sea inicializable directamente desde String
					if (this[attribName] is Boolean)
						this[attribName] = (attribXML.Value.toString() == "true")? true : false;
					else
					if (this[attribName] is utils.Point3)
						this[attribName] = Point3.Point3FromString(attribXML.Value.toString());
					else
					if (this[attribName] is Point)
						this[attribName] = Point3.PointFromString(attribXML.Value.toString());
					else
						this[attribName] = attribXML.Value.toString();
				}
			}
		}
		
		public function GetXML() : XML
		{
			var className : String = getQualifiedClassName(this);
			var compXML : XML = <GameComponent><ClassName>{className}</ClassName></GameComponent>
				
			var props : ArrayCollection = ReflectGameComponent();
			
			for each(var prop : KeyValueWrapper in props)
			{
				if (prop.Value == null)
					throw "El valor de una propiedad no puede ser null al ir a grabar";

				// Grabamos el Value como una String
				var attribXML : XML = <Attrib>
									  	<Name>{prop.Key}</Name>
									  	<Value>{prop.Value.toString()}</Value>
									  </Attrib>
				compXML.appendChild(attribXML);
			}
			
			return compXML;
		}

		private var mAssetObject : AssetObject;
	}
}