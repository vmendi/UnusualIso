package Model
{
	import GameComponents.GameComponent;
	
	import flash.events.EventDispatcher;
	
	/**
	 * TODO: La idea es que este es el sitio central desde donde se mandan los eventos a los GameComponents, de tal manera que
	 *       no hay overrides de OnStart, OnUpdate... y tampoco hace falta hacer addEventListeners por ejemplo para recibir los
	 *       eventos del personaje.
	 *       Este cacharrito lo que haría sera reflexionar todos los componentes para ver qué funciones tiene dentro de las que
	 *       reconoce. Opciones de "reconocimiento": Lista estática definida aquí (al menos para las básicas OnStart...), lista 
	 *       dinámica que los componentes que dispachan van creando en su OnStart. Coger todas las On*.
	 *       Desde fuera, se haría un DispatchToGameComponents.
	 */
	public class GameEventDispatcher extends EventDispatcher
	{
		public function GameEventDispatcher()
		{
		}
		
		public function OnStart(isoObjs : Array) : void
		{
			for each(var isoObj : SceneObject in isoObjs)
			{
				for each(var comp : GameComponent in isoObj.TheAssetObject.TheGameComponents)
				{
					// ... TODO
				}
			}
		}
	}
}