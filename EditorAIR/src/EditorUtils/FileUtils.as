package EditorUtils
{
	import flash.filesystem.*;
	
	public class FileUtils
	{
		// Nos pasan un file en formato absoluto (file://) y lo transformamos en una cadena relativa al workspace (aplicacion)
		public static function GetPathRelativeToWorkSpace(daFile : File) : String
        {				
			// Tenemos que transformar el formato del File a file: en vez de como viene (app:), porque si no, el getRelativePath
			// no funciona
		    var appDir : File = File.applicationDirectory;
		    var workspaceDir : File = new File(appDir.nativePath);
			    			    
		    return workspaceDir.getRelativePath(daFile, true);
        }
        
        // Nos pasan un path relativo al directorio de la aplicacion (workspace de momento, hasta que tengamos varios),
        // y devolvemos un File que apunta a él de forma absoluta
        public static function GetAbsolutePath(relativePathFromWorkspace : String) : File
        {
        	var appDir : File = File.applicationDirectory;
		    var workspaceDir : File = new File(appDir.nativePath);
		    
		    return workspaceDir.resolvePath(relativePathFromWorkspace);
        }
        
        public static function GetApplicationDirAbsolute() : File
        {
        	var appDir : File = File.applicationDirectory;
		    return new File(appDir.nativePath);
        }
	}
}