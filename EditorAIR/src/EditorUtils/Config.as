package EditorUtils
{
	import flash.events.*;
	import flash.filesystem.File;
	
	import mx.utils.ObjectUtil;
	
	public class Config
	{
		public function Config()
		{
			if( !creatingSingleton ) throw new Error( "Singleton and can only be accessed through Singleton.getInstance()" );	
		}
	
		public static function GetInstance():Config
		{
			if( !instance )
			{
				creatingSingleton = true;
				instance = new Config();
				creatingSingleton = false;
			}
			
			return instance;
        }
        
        public function Create() : void
        {
			ReadConfigFile();
        }
        
		public function ReadValue(key : String) : String
		{
			return mConfig[key];
		}
		
		public function HasKey(key : String) : Boolean
		{
			return mConfig.hasOwnProperty(key);
		}
		
		public function WriteValue(key : String, value : String) : void
		{
			if (!(mConfig.hasOwnProperty(key) && (mConfig[key] == value)))
			{
				mConfig[key] = value;
				SaveConfigFile();
			}
		}
		
		private function ReadConfigFile() : void
		{	
			var pathStr : String = File.applicationDirectory.nativePath+"/Config.xml";
			var myXML:XML = XMLLoadSave.Load(pathStr);

			if (myXML != null)
			{
			    for each(var ch : XML in myXML.children())
			    {
			    	mConfig[ch.name()] = ch.toString();
			    }
			}		    
		}
		
		private function SaveConfigFile() : void
		{
			var pathStr : String = File.applicationDirectory.nativePath+"/Config.xml";
			var daXML : XML = <Config></Config>
			
			var props : Array = ObjectUtil.getClassInfo(mConfig).properties;
			for each(var prop : String in props)
			{
				var optXML : XML = <{prop}>{mConfig[prop]}</{prop}>
				daXML.appendChild(optXML);
			}
			
			XMLLoadSave.Save(pathStr, daXML.toXMLString());
		}
				
		private var mConfig : Object = new Object();
		
		private static var instance:Config;
		private static var creatingSingleton:Boolean = false;		
	}
}