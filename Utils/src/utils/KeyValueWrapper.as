package utils
{
	[Bindable]
	public class KeyValueWrapper
	{
		public function KeyValueWrapper(obj : Object, key : String)
		{
			mObject = obj;
			mKey = key;
		}
		
		public function get Key() : String { return mKey; }
				
		public function get Value() : Object { return mObject[mKey]; }
		public function set Value(val : Object) : void { mObject[mKey] = val; }
		
		public function get ValueType() : String { return typeof(mObject[mKey]); } 
		
		private var mObject : Object;
		private var mKey : String;
	}
}