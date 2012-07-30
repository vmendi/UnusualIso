package Quiz
{
	import r1.deval.D;
		
	public class DEvalHelper
	{
		public static function IsValidCode(code : String) : Boolean
		{
			var bRet : Boolean = true;
			
			try {
				D.parseProgram(code);
			}
			catch (e : Error) {
				bRet = false;
			}
			
			return bRet;
		}

	}
}