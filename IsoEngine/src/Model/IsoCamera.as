package Model
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import mx.core.UIComponent;
	
	import utils.KeyboardHandler;
	import utils.Point3;
	
	/**
	 * Cámara a partir de la que se renderiza el mundo.
	 */
	public class IsoCamera extends UIComponent
	{	
		/** Posición del target de la cámara en el mundo. Es el punto del mundo al que está mirando la cámara */	
		public function get TargetPos() : Point { return mCamTarget; }
		public function set TargetPos(p : Point) : void
		{
			// Los objetos no cambian sus coordenadas 2D (respecto a su padre, nosotros) a medida que se mueve la camara. 
			// Sólo cambia nuestra posición 2D, somos el viewport principal, lo único que se mueve.
			var pos : Point = IsoWorldToCamera(new Point3(0, 0, 0), p);
						 
			if (mCheckLimits)
			{
				var theRect : Rectangle = mIsoBackground.GetContentBounds();
				
				if (pos.x > Math.abs(theRect.left))
				{
					if (theRect.width > parent.width)
						pos.x = Math.abs(theRect.left);
					else
						pos.x = x;
				}
				else
				if (pos.x < (2*mScreenCenter.x) - Math.abs(theRect.right))
				{
					if (theRect.width > parent.width)
						pos.x = (2*mScreenCenter.x) - Math.abs(theRect.right);
					else
						pos.x = x;
				}

				if (pos.y > Math.abs(theRect.top))
				{
					if (theRect.height > parent.height)
						pos.y = Math.abs(theRect.top);
					else
						pos.y = y;
				}
				else
				if (pos.y < (2*mScreenCenter.y) - Math.abs(theRect.bottom))
				{
					if (theRect.height > parent.height)
						pos.y = (2*mScreenCenter.y) - Math.abs(theRect.bottom);
					else
						pos.y = y;
				}
				
				var newCamTarget : Point3 = IsoCameraToWorld(pos, Point3.ZERO_POINT2);
				mCamTarget.x = -newCamTarget.x;
				mCamTarget.y = -newCamTarget.z;
			}
			else
			{
				mCamTarget = p;
			}
			
			x = Math.floor(pos.x);
			y = Math.floor(pos.y);
				
			// Recentramos el background
			mIsoBackground.SetCameraCenter(mCamTarget);
		}
		
		/** Factor de Zoom, medido en pixels de pantalla por metro de mundo */
		static public function get PixelsPerMeter() : Number { return 50; }
		
		/** El IsoBackground asociado a la camara */
		public function get TheIsoBackground() : IsoBackground { return mIsoBackground; }
				
		public function IsoCamera()
		{
			mIsoBackground = new IsoBackground();
			addChild(mIsoBackground);
			
			addEventListener(Event.ADDED_TO_STAGE, OnAddedToStage, false, 0, true);
		}
		
		private function OnAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, OnAddedToStage, false);
			addEventListener(Event.REMOVED_FROM_STAGE, OnRemovedOfStage, false, 0, true);
			
			// Para pillar el resize, tenemos que subscribirnos a nuestro padre
			parent.addEventListener(Event.RESIZE, OnParentResize, false, 0, true);
			
			SetViewportOnCenterOf(parent);
		}
		
		private function OnParentResize(event:Event):void
		{
			// Cada vez que el padre se redimensione, queremos que la camara permanezca apuntando al mismo sitio
			SetViewportOnCenterOf(parent);
		}
		
		private function OnRemovedOfStage(event:Event):void
		{
			parent.removeEventListener(Event.RESIZE, OnParentResize, false);
		}
		
		private function SetViewportOnCenterOf(disObj : DisplayObject) : void
		{
			// Nos aseguramos de que al centrarnos en pantalla no chequeamos los limites
			var supressCheckLimits : Boolean = CheckLimits;
			CheckLimits = false;
			
			mScreenCenter.x = disObj.width*0.5;
			mScreenCenter.y = disObj.height*0.5;
						
			// Cambiar el centro de proyección es equivalente a un movimiento del target.
			// Forzamos el update.
			TargetPos = mCamTarget;
			
			// Recuperamos el valor anterior
			CheckLimits = supressCheckLimits;	
		}
		
		
		public function MoveWithKeyboard(elapsedTime : Number, bCtrlModifier : Boolean) : void
		{	
			if (mCamVel.x != 0 || mCamVel.y != 0)
			{
				var newTarget : Point = mCamTarget.clone();
				
				newTarget.x += mCamVel.x * (elapsedTime*0.001);
				newTarget.y += mCamVel.y * (elapsedTime*0.001);
				
				TargetPos = newTarget;
			}
			
			var bModifiersPressed : Boolean = KeyboardHandler.Keyb.IsKeyPressed(Keyboard.CONTROL);
			
			if (!bCtrlModifier)
				bModifiersPressed = !bModifiersPressed; 
			
			var dirMov : Point = new Point(0, 0);
			if (KeyboardHandler.Keyb.IsKeyPressed(Keyboard.UP) && bModifiersPressed)
			{
				dirMov = dirMov.add(new Point(1, 1));
			}
			else 
			if (KeyboardHandler.Keyb.IsKeyPressed(Keyboard.DOWN) && bModifiersPressed)
			{
				dirMov = dirMov.add(new Point(-1, -1));
			}
			
			if (KeyboardHandler.Keyb.IsKeyPressed(Keyboard.RIGHT) && bModifiersPressed)
			{
				dirMov = dirMov.add(new Point(1, -1));
			}
			else 
			if (KeyboardHandler.Keyb.IsKeyPressed(Keyboard.LEFT) && bModifiersPressed)
			{
				dirMov = dirMov.add(new Point(-1, 1));
			}
			
			var factor : Number = (MOVEMENT_SPEED - mCamVel.length) * 0.55;
			mCamVel = dirMov;
			mCamVel.normalize(factor);
			
			// Amortiguación de parada
			mCamVel.x = mCamVel.x * 0.8;
			mCamVel.y = mCamVel.y * 0.8;
			
			if (Math.abs(mCamVel.x) < 0.1) mCamVel.x = 0;
			if (Math.abs(mCamVel.y) < 0.1) mCamVel.y = 0;
		}
		
		/**
		 * Transformación a coordenadas de pantalla. Entrada en metros, salida en pixels
		 */
		public function IsoWorldToScreen(p : Point3) : Point
		{
			var xCart : Number = ((p.x - mCamTarget.x) - (p.z - mCamTarget.y))*Math.cos(ATAN_GAME_ISOMETRIC);
			var yCart : Number  = p.y + ((p.x - mCamTarget.x) + (p.z - mCamTarget.y))*Math.sin(ATAN_GAME_ISOMETRIC);
			
			return new Point( (xCart * PixelsPerMeter) + mScreenCenter.x, 
							  (-yCart* PixelsPerMeter) + mScreenCenter.y);
		}
		
		private function IsoWorldToCamera(p:Point3, camTarget : Point) : Point
		{
			var xCart : Number = ((p.x - camTarget.x) - (p.z - camTarget.y))*Math.cos(ATAN_GAME_ISOMETRIC);
			var yCart : Number  = p.y + ((p.x - camTarget.x) + (p.z - camTarget.y))*Math.sin(ATAN_GAME_ISOMETRIC);
			
			return new Point( (xCart * PixelsPerMeter) + mScreenCenter.x, 
							  (-yCart* PixelsPerMeter) + mScreenCenter.y);
		}
		
		public function IsoScreenToWorld(p : Point) : Point3
		{			
			var ret : Point3 = new Point3(0, 0, 0);
			
			var cosDen : Number = 2*PixelsPerMeter*Math.cos(ATAN_GAME_ISOMETRIC);
			var sinDen : Number = 2*PixelsPerMeter*Math.sin(ATAN_GAME_ISOMETRIC);
			ret.x = ((p.x - mScreenCenter.x)/cosDen) + ((mScreenCenter.y - p.y)/sinDen) + mCamTarget.x;
			ret.z = ((mScreenCenter.x - p.x)/cosDen) + ((mScreenCenter.y - p.y)/sinDen) + mCamTarget.y;
			
			return ret;
		}
		
		private function IsoCameraToWorld(p : Point, camTarget : Point) : Point3
		{
			var ret : Point3 = new Point3(0, 0, 0);
			
			var cosDen : Number = 2*PixelsPerMeter*Math.cos(ATAN_GAME_ISOMETRIC);
			var sinDen : Number = 2*PixelsPerMeter*Math.sin(ATAN_GAME_ISOMETRIC);
			ret.x = ((p.x - mScreenCenter.x)/cosDen) + ((mScreenCenter.y - p.y)/sinDen) + camTarget.x;
			ret.z = ((mScreenCenter.x - p.x)/cosDen) + ((mScreenCenter.y - p.y)/sinDen) + camTarget.y;
			
			return ret;
		}
		
		static public function IsoProject(p : Point3) : Point
		{
			var xCart : Number = (p.x - p.z)*Math.cos(ATAN_GAME_ISOMETRIC);
			var yCart : Number = p.y + ((p.x + p.z)*Math.sin(ATAN_GAME_ISOMETRIC));
			
			return new Point(xCart*PixelsPerMeter, -yCart*PixelsPerMeter);
		}

	
		public function set CheckLimits(v : Boolean) : void { mCheckLimits = v; }
		public function get CheckLimits() : Boolean { return mCheckLimits; }
		
		// En metros por segundo
		static private const MOVEMENT_SPEED : Number = 7.0;
		static private const ATAN_GAME_ISOMETRIC : Number = Math.atan(0.5);
				
		private var mScreenCenter : Point = new Point(0, 0);

		private var mCamTarget : Point = new Point(0, 0);
		private var mCamVel : Point = new Point(0, 0);		// Velocidad en pixels / segundo
		
		private var mIsoBackground : IsoBackground;
		
		private var mCheckLimits : Boolean = false;
	}
}