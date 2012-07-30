package utils
{
	import flash.geom.Point;
	
	public final class Point3
	{
		public var x : Number = 0;
		public var y : Number = 0;
		public var z : Number = 0;
		
		static public const ZERO_POINT3 : Point3 = new Point3(0,0,0);
		static public const ZERO_POINT2 : Point = new Point(0,0);
		
		static public function Point3FromString(str : String):Point3
		{
			var ret : Point3 = null;
			
			var xIdx : int = str.indexOf("=");
			var yIdx : int = str.indexOf("=", xIdx+1);
			var zIdx : int = str.indexOf("=", yIdx+1);
			
			if (xIdx != -1 && yIdx != -1 && zIdx != -1)
			{	
				ret = new Point3();
				
				ret.x = parseFloat(str.substr(xIdx+1, yIdx-xIdx));
				ret.y = parseFloat(str.substr(yIdx+1, zIdx-yIdx));
				ret.z = parseFloat(str.substr(zIdx+1, str.length-zIdx));
			}
			
			return ret;
		}
		
		static public function PointFromString(str: String):Point
		{
			var ret : Point = null;
			
			var xIdx : int = str.indexOf("=");
			var yIdx : int = str.indexOf("=", xIdx+1);
						
			if (xIdx != -1 && yIdx != -1)
			{	
				ret = new Point();
				
				ret.x = parseFloat(str.substr(xIdx+1, yIdx-xIdx));
				ret.y = parseFloat(str.substr(yIdx+1, str.length-yIdx));
			}
			
			return ret;
		}
		
		
		public function Point3(xCoord : Number = 0, yCoord : Number = 0, zCoord : Number = 0)
		{
			x = xCoord; y = yCoord; z = zCoord;
		}
		
		
		public function toString() : String { return "(x=" + x + ", y=" + y + ", z=" + z + ")"; }
		
		public function Clone() : Point3
		{
			return new Point3(x, y, z);
		}
		
		public function IsEqual(other : Point3) : Boolean
		{
			return x == other.x && y == other.y && z == other.z;
		}
		
		public function Normalize() : void
		{
			var invLength : Number = 1/Math.sqrt(x*x + y*y + z*z);
			
			x *= invLength;
			y *= invLength;
			z *= invLength;
		}
		
		public function Distance(other : Point3) : Number
		{
			return Math.sqrt( (other.x - x)*(other.x - x) + (other.y - y)*(other.y - y) + (other.z - z)*(other.z - z) );  
		}
		
		public function AddToThis(other : Point3) : Point3
		{
			x += other.x;
			y += other.y;
			z += other.z;
			return this;
		}
		
		public function Add(other : Point3) : Point3
		{
			return new Point3(x + other.x, y + other.y, z + other.z);
		}

		public function Substract(other : Point3) : Point3
		{
			return new Point3(x - other.x, y - other.y, z - other.z);
		}
		
		public function GetScaledDirection(secondPoint : Point3, scale : Number) : Point3
		{
			var temp : Point3 = new Point3(secondPoint.x - x, secondPoint.y - y, secondPoint.z - z);
			temp.Normalize();
			temp.x *= scale;
			temp.y *= scale;
			temp.z *= scale;
			return temp;
		}
	}
}