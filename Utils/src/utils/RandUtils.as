package utils
{
	public final class RandUtils
	{
		static public function Shuffle(a:Array) : Array
		{
			var mixed : Array = a.slice(0, a.length);
			for (var i:uint = 0; i < a.length; i++)
			{
				var randomNum:Number = Math.round(Math.random() * (a.length-1));
				var tmp:Object = mixed[i];
				mixed[i] = mixed[randomNum];
				mixed[randomNum] = tmp;
			}

			return mixed;
		}

		static public function GenerateShuffledArray(maxIdx : int) : Array
		{
			var ret : Array = new Array();
			for (var c : int = 0; c < maxIdx; c++)
				ret.push(c);
			return Shuffle(ret);
		}

		/**
		 * Retorna un número aleatorio entre (-1, 1)
		 */
		static public function RandMinusPlus():Number
		{
			return ((Math.random()-0.5)*2.0);
		}

		/**
		 * Retorna un número entero aleatorio entre [0, n]
		 */
		static public function RandInt(n:Number) : int
		{
			return (Math.round(Math.random()*n));
		}

		/**
		 * Retorna un número entero aleatorio entre [a, b]
		 */
		static public function RandIntBetween(a:Number, b:Number) : int
		{
			return a + RandInt(b-a);
		}

	}
}