package EditorUtils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
		
	public class XMLLoadSave
	{
		public static function Load(path:String):XML
		{
			var ret : XML = null;
			var file:File = new File(path);
			
			if (file.exists)
			{
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.READ);
				var str:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
				fileStream.close();				
				ret = XML(str);
			}
			else
			{
				throw "FILE "+path+" DOES NOT EXISTS!";
			}
			
			return ret;
		}
		
		public static function Save(path:String, saveMe:String) : void
		{
			var file:File = new File(path);
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeUTFBytes(saveMe);
			fileStream.close();	
		}

	}
}