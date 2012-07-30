package PathFinding
{
	/**
	 * Interface que debe implementar todo espacio de busqueda
	 */
	public interface IAStarSearchable
	{
		function IsWalkable(x:int, y:int):Boolean;
		function GetWidth():int;
		function GetHeight():int;
	}
}