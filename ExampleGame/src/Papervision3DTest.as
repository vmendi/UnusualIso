package
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.ascollada.utils.Logger;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.view.BasicView;
	
		

	public class Papervision3DTest extends BasicView
	{
		public function Papervision3DTest()
		{
			/**
			 * Width and Height are set to 1, since scaleToStage is set to true, these will be overriden.
			 * We will not use interactivity and keep the default cameraType.
			 */
			super(1, 1, true, true);
					
			//Color the background of this basicview / helloworld instance black.
			opaqueBackground = 0;
			
			//Create the materials and primitives.
			initScene();
			
			//Call the native startRendering function, to render every frame.
			startRendering();
		}
		
		/**
		 * initScene will create the needed primitives, and materials.
		 */
		protected function initScene():void
		{
			/*
			//Create a new bitmapdata to be used as a texture for our world.
			worldBitmapData = new BitmapData(512,256,false,0);
			//Use perlin noise to colorize the texture....for examples sake.
			worldBitmapData.perlinNoise(256,127,8,1234,true, true,7,true);
			
			//Create a material to be used by the sphere primitive.
			//The Material will utilize the bitmapData we just created as a texture.
			worldMaterial = new BitmapMaterial(worldBitmapData);
		
			//Create the world primitive, using the native Sphere primitive.
			world = new Sphere(worldMaterial,300, 10, 10);
			
			//Add the world to the scene, which is already instanciated by the super BasicView.
			//scene.addChild(world);
			*/
			
			//mTest3DS = new Max3DS("Link");
			//mTest3DS.replaceTextureExtension("tga", "png");
			//mTest3DS.load("Assets/Zelda/Telma/Telma-Processed.3ds", null, "./Assets/Zelda/Telma/png/");
			
			/*
			var material : BitmapFileMaterial = new BitmapFileMaterial("Assets/Zelda/CH01_11.jpg", true);
						
			var materialsList:MaterialsList = new MaterialsList();
			materialsList.addMaterial( material, "Veamos");
			*/
			
			org.ascollada.utils.Logger.VERBOSE = true;
			mTest3DS = new DAE();
			mTest3DS.load("Assets/Zelda/Skinned/Skinned.dae");
			//mTest3DS.load("Assets/Zelda/Prueba.dae");

			/*
			mTest3DS = new Max3DS("Link");
			mTest3DS.replaceTextureExtension("tga", "png");
			mTest3DS.load("Assets/Zelda/Henna/Henna.3ds", null, "./Assets/Zelda/Henna/");
			*/
			
			mTest3DS.addEventListener(FileLoadEvent.LOAD_COMPLETE, OnLoadComplete);
			scene.addChild(mTest3DS);			

			SetCameraPosition();
			
			addEventListener(Event.ADDED_TO_STAGE, OnAddedToStage);
		}
		
		private function OnAddedToStage(event:Event):void
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
		}
		
		private function OnMouseDown(event:MouseEvent):void
	    {
		      mDoRotation = true;
		      mLastMouseX = event.stageX;
		      mLastMouseY = event.stageY;
	    }

		private function OnMouseUp(event:MouseEvent):void
		{
      		mDoRotation = false;
    	}

		private function OnLoadComplete(event:Event):void
		{
			/*
			for each(var theChild : DisplayObject3D in mTest3DS.children)
			{
				var test : TriangleMesh3D = theChild as TriangleMesh3D;
				if (test != null)
					test.meshSort = DisplayObject3D.MESH_SORT_FAR;
			}
			*/
			
			var theFoot : DisplayObject3D = mTest3DS.getChildByName("CMan0024-RightFoot", true);
			
			//theFoot.visible = false;
			
			for each(var mat : BitmapFileMaterial in mTest3DS.materials.materialsByName)
			{
				//mat.addEventListener(FileLoadEvent.LOAD_COMPLETE, Test01);
				mat.precise = false;
				mat.smooth = false;
			}
		}
		
		/*
		private function Test01(event:Event):void
		{
			var mat : MaterialObject3D = event.target as MaterialObject3D;			
		}
		*/
		
		override protected function onRenderTick(event:Event=null):void
		{
			UpdateCamera();

			super.onRenderTick(event);
		}
		
		private function UpdateCamera():void
		{
      		if (mDoRotation)
      		{
		        var dPitch:Number = (mouseY - mLastMouseY) / 2;
		        var dYaw:Number = (mouseX - mLastMouseX) / 2;
		       
		        mCamPitch -= dPitch;
		        mCamYaw -= dYaw;
		       
		        if (mCamPitch <= 0) {
		          mCamPitch = 0.1;
		        } else if (mCamPitch >= 180) {
		          mCamPitch = 179.9;
		        }
		        
		        mLastMouseX = mouseX;
		        mLastMouseY = mouseY;
      		} 
      		
      		SetCameraPosition();
    	}
    	
    	private function SetCameraPosition():void
    	{
    		this.camera.position = new Number3D(0, 0, 1.5);
    		this.camera.target.position = new Number3D(0, 1, 0);
    		this.camera.orbit(mCamPitch, mCamYaw, true);
    	}
    	
    	private var mCamPitch : Number = -90;
		private var mCamYaw : Number = 90;
		private var mDoRotation : Boolean;
		private var mLastMouseX : Number = 0;
		private var mLastMouseY : Number = 0;
		
		/*
		protected var world:Sphere;
		protected var worldBitmapData:BitmapData;
		protected var worldMaterial:BitmapMaterial;
		*/
		//protected var mTest3DS : Max3DS;
		protected var mTest3DS : DAE;
	}
}