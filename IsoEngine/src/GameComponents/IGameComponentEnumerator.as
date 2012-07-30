package GameComponents
{
	import mx.collections.ArrayCollection;
	
	/**
	 * Interace que debe cumplir cualquier enumerador de los componentes de cualquier juego.
	 */
	public interface IGameComponentEnumerator
	{
		/** Devuelve sólo las Classes de todos los componentes */
		function GetComponentClasses() : ArrayCollection;
				
		/** Devuelve todos los componentes en un array de Objects { TheClass: , FullName: , ShortName: , MiddleNamespace: } */
		function GetComponentsDescription() : ArrayCollection;
		
		/** Dado la clase de un componente, devuelve el Object { TheClass:, FullName:, ShortName: } que lo describe */
		function GetDescription(cl : Class) : Object;
	}
}