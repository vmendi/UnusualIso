package PathFinding
{
	import de.polygonal.ds.PriorityQueue;
	

	/**
	 * El buscacaminos. Se sirve de un IAStartSearchable para definir dónde tiene que buscar.
	 */
	public class AStar
	{
		private var mWidth:int;
		private var mHeight:int;

		private var mStart:AStarNode;
		private var mGoal:AStarNode;
			
		private var mMap : IAStarSearchable;
			
		// Nodos a considerar
		private var mOpen:Array;
		private var mOpenPrioritized:PriorityQueue;
		
		// Nodos ya visitados
		private var mClosed:Array;	
			
		// Costes diagonal y ortogonal
		private static const COST_ORTHOGONAL:Number = 100;
		private static const COST_DIAGONAL:Number = 141;
		
		// Multiplicador para la distancia (H) al goal, su valor dependerá de los costes G
		private static const DISTANCE_FACTOR:Number = 2;
				
		private const DIRS:Array = [ new Dir(0,-1,COST_ORTHOGONAL,false), new Dir(1,0,COST_ORTHOGONAL,false), 
						       	     new Dir(0,1,COST_ORTHOGONAL,false), new Dir(-1,0,COST_ORTHOGONAL,false), 
						             new Dir(1,-1,COST_DIAGONAL,true,1,0,0,-1), 
						             new Dir(1,1,COST_DIAGONAL,true,1,0,0,1),
						             new Dir(-1,1,COST_DIAGONAL,true,-1,0,0,1), 
						             new Dir(-1,-1,COST_DIAGONAL,true,-1,0,0,-1)];
		
		
		public function AStar(map:IAStarSearchable)
		{
			mWidth = map.GetWidth();
			mHeight = map.GetHeight();
			
			mMap = map;
		}
		
		/**
		 * 	Array de AStartNode describiendo el camino resultante
		 */ 
		public function Solve(start:IntPoint, goal:IntPoint):Array
		{						
			if ( goal.x < 0 || goal.x > mWidth-1 || goal.y < 0 || goal.y > mHeight-1 || (!mMap.IsWalkable(goal.x, goal.y)) )
				return null;
				
			this.mStart = new AStarNode(start.x, start.y);
			this.mGoal = new AStarNode(goal.x, goal.y);

			mOpen = new Array(mWidth*mHeight);
			mClosed = new Array(mWidth*mHeight);
			mOpenPrioritized = new PriorityQueue(1000);

			var currentNode : AStarNode = mStart;
			currentNode.h = DistDiagonalShortcut(currentNode, mGoal);
			mOpen[(currentNode.y*mWidth)+currentNode.x] = currentNode;
			mOpenPrioritized.enqueue(currentNode);

			var solved:Boolean = false;
			var evalued : int = 0;
			

			while (!solved) 
			{
				if (mOpenPrioritized.size <= 0)
					break;

				// Cogemos el siguiente nodo con menor coste, lo sacamos de los abiertos, lo metemos en los cerrados
				currentNode = mOpenPrioritized.dequeue() as AStarNode;
				mOpen[(currentNode.y*mWidth)+currentNode.x] = null;
				mClosed[(currentNode.y*mWidth)+currentNode.x] = currentNode;
				
				// Estamos ahí?
				if (currentNode.x == mGoal.x && currentNode.y == mGoal.y)
				{
					solved = true;
					break;
				}
				
				evalued++;
				
				for (var c:int=0; c < 8; c++)
				{
					var neighborX : int = currentNode.x + DIRS[c].x;	
					var neighborY : int = currentNode.y + DIRS[c].y;
					
					if (!mMap.IsWalkable(neighborX, neighborY))
						continue;
			
					if (DIRS[c].isDiagonal)
					{
						if ( (!mMap.IsWalkable(currentNode.x+DIRS[c].OneX, currentNode.y+DIRS[c].OneY)) || 
						     (!mMap.IsWalkable(currentNode.x+DIRS[c].TwoX, currentNode.y+DIRS[c].TwoY)) )
							continue;
					}
																																
					var neighborG : Number = currentNode.g + DIRS[c].cost;					
					var element:AStarNode = mClosed[(neighborY*mWidth)+neighborX];

					if (element != null)
						continue;
					
					element = mOpen[(neighborY*mWidth)+neighborX];

					if (element != null)
					{
						if (neighborG < element.g)
						{
							var oldPriority : int = element.priority;
							element.parent = currentNode;
							element.g = neighborG;
							mOpenPrioritized.reprioritize(element, oldPriority);
						}
					}
					else
					{
						var newNode : AStarNode = new AStarNode(neighborX, neighborY);
						newNode.parent = currentNode;
						newNode.g = neighborG;
						newNode.h = DistDiagonalShortcut(newNode, mGoal);
						mOpen[(neighborY*mWidth)+neighborX] = newNode;
						mOpenPrioritized.enqueue(newNode);
					}
				}
			}
			
			trace("Evalued :  " + evalued);

			var ret : Array = null;

			if (solved)
			{
				ret = new Array();
				
				// Añadimos el nodo final
				ret.push(currentNode);

				// Todos los intermedios
				while (currentNode.parent && currentNode.parent != mStart)
				{
					currentNode = currentNode.parent;
					ret.push(currentNode);
				}
								
				// Y le damos la vuelta para que el nodo inicial sea el 0
				ret = ret.reverse();
			} 
			
			return ret;
		}
				
		
		private function DistManhattan(n1:AStarNode, n2:AStarNode):Number
		{
			return Math.abs(n1.x-n2.x)+Math.abs(n1.y-n2.y)*DISTANCE_FACTOR;
		}
		
		
		private function DistEuclidian(n1:AStarNode, n2:AStarNode):Number
		{
			var x2 : Number = n1.x-n2.x;
			var y2 : Number = n1.y-n2.y;
			
			return Math.sqrt((x2*x2) + (y2*y2))*DISTANCE_FACTOR;
		}
		
		private function DistDiagonalShortcut(n1:AStarNode, n2:AStarNode):Number
		{
			var xDistance : Number = Math.abs(n1.x-n2.x);
			var yDistance : Number = Math.abs(n1.y-n2.y);
			
			if (xDistance > yDistance)
				return DISTANCE_FACTOR*((COST_DIAGONAL*yDistance) + (COST_ORTHOGONAL*(xDistance-yDistance)));
			else
				return DISTANCE_FACTOR*((COST_DIAGONAL*xDistance) + (COST_ORTHOGONAL*(yDistance-xDistance)));
		}
	}	
}

class Dir
{
	public var x : int;
	public var y : int;
	public var cost : Number;
	public var isDiagonal : Boolean;
	
	// Las dos celdas de alrededor q hay que mirar q son las que tienen que ser transitables al ir en esta dirección
	public var OneX : int;
	public var OneY : int;
	
	public var TwoX : int;
	public var TwoY : int;
	
	// Como AS3 no soporta sobrecarga, tenemos q emularla mediante parámetros por defecto
	public function Dir(_x:int, _y:int, _cost:Number, _isD:Boolean, 
						oneX:int=0, oneY:int=0, twoX:int=0, twoY:int=0)
	{
		x = _x;
		y = _y;
		cost = _cost;
		isDiagonal = _isD;
		
		OneX = oneX;
		OneY = oneY;
		
		TwoX = twoX;
		TwoY = twoY;
	}
}
