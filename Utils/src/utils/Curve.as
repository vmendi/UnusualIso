package utils
{
	import flash.utils.Dictionary;
	
	public class Curve
	{
		public function Curve()
		{
			mModifying = false;
			mValues = new Array();
		}
		
		public function LoadFromXML(xml:XML):void
		{
			mValues = new Array;
			
			StartModification();
			
			for each(var keyframe : XML in xml.child("KeyFrame"))
			{
				var time : Number = parseFloat(keyframe.attribute("Time").toString());
				var val : Number = parseFloat(keyframe.attribute("Value").toString());
				
				AddKeyFrame(val, time);
			}
			
			EndModification();
		}
	
		public function StartModification():void
		{
			mModifying = true;	
		}
	
		public function AddKeyFrame(val:Object, t:Number):void
		{
			if (!mModifying)
				throw new ("You must call StartModification");

			mValues.push( {Value:val, Time:t} ); 
		}
		
		public function EndModification():void
		{
			mModifying = false;
			
			mValues.sortOn("Time", Array.NUMERIC);
		}
				
		public function Evaluate(atTime:Number):Object
		{
			if (mValues.length == 0 || mModifying)
				throw new ("Incorrect setup");
				
			var ret : Object = null;
			var idxToSup : int = -1;
 
			for (var c:int=0; c < mValues.length; c++)
			{
				if (mValues[c].Time > atTime)
				{
					idxToSup = c;
					break;
				}
			}

			// Si nos salimos por arriba o por abajo, cogemos el último o primer valor, es decir,
			// la curva permanece constante fuera de sus limites según el primer (último) valor
			// que tendrá (tuvo)
			if (idxToSup == -1)
				ret = mValues[mValues.length-1].Value;
			else if (idxToSup == 0)
				ret = mValues[0].Value;
			else
			{
				var prevTime : Number = mValues[idxToSup-1].Time;
				var nextTime : Number = mValues[idxToSup].Time;
				
				if (prevTime != nextTime)
				{
					var interpParam : Number = (atTime - prevTime) / (nextTime-prevTime);
					ret = (mValues[idxToSup-1].Value*(1.0-interpParam)) + (mValues[idxToSup].Value*interpParam);
				}
				else
				{
					ret = mValues[idxToSup].Value;
				}
			}
			
			return ret;
		}
		
		private var mModifying : Boolean;
		private var mValues : Array;
	}
}