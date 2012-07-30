package Model
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import gs.TweenLite;
	
	import utils.MathUtils;
		
	
	/**
	 * Objeto principal de pantalla: Se hace transparente, hace HitTest, etc...
	 *  
	 * Se crea a partir de un AssetObject de la librería, que es el que le da comportamiento y propiedades. 
	 */
	public class SceneObject
	{
		/** AssetObject con el que se creó este SceneObject */
		public function get TheAssetObject() : AssetObject { return mAssetObj; }
		
		/** MovieClip que representa visualmente a este SceneObject */
		public function get TheVisualObject() : MovieClip { return mVisualObject; }
		
		/** El GameModel al que pertenece este SceneObject */
		public function get TheGameModel() : GameModel { return mGameModel; }
		
		/** Coordenada X en pantalla del SceneObject, es la misma que la de su TheVisualObject */
		public function get ScreenX() : Number { return mVisualObject.x; }
		
		/** Coordenada Y en pantalla del SceneObject, es la misma que la de su TheVisualObject */
		public function get ScreenY() : Number { return mVisualObject.y; }
		
		
		/** Constructor. El AssetObject tiene que venir ya clonado, para que sea este SceneObject su único propietario */
		public function SceneObject(gameModel : GameModel, assetObj : AssetObject)
		{
			mGameModel = gameModel;
			mAssetObj = assetObj;
			mVisualObject = mGameModel.TheAssetLibrary.CreateMovieClip(mAssetObj.TheDefaultGameComponent.MovieClipName);
		}

		
		/** 
		 * Activa/desactiva el render de la bounding box (en espacio de pantalla) 
		 */
		public function set ShowBounds(show : Boolean) : void
		{
			if (show == mShowBounds)
				return;
				
			mShowBounds = show;
			
			InvalidateBoundingRectangle();
		} 
		
		/** 
		 * Chequea si el punto está dentro de este TheVisualObject. Lo hace pixel-perfect
		 */
		public function RealHitTest(point:Point) : Boolean
		{
			var bRet : Boolean = false;
			
            if (mVisualObject.hitTestPoint(point.x, point.y, false))
            {
                var bmapData:BitmapData = new BitmapData(mVisualObject.width, mVisualObject.height, true, 0x00000000);
                
                // El (0,0) del VisualObject es arbitrario, el BitmapData lo tiene arriba a la izquierda. Es decir, hay que copiar
                // el rectángulo de contenido del VisualObject al rectangulo del BitmapData
                var rect : Rectangle = mVisualObject.getBounds(mVisualObject);
                bmapData.draw(mVisualObject, new Matrix(1, 0, 0, 1, -rect.left, -rect.top));
                
                var onVisual : Point = mVisualObject.globalToLocal(point);
                onVisual.x += -rect.left;
                onVisual.y += -rect.top;
                
                bRet = bmapData.hitTest(new Point(0, 0), 0x00, onVisual);
                                
                bmapData.dispose();
            }
            
            return bRet;
        }
		
		/** Devuelve el XML que representa este SceneObject */
		public function GetXML() : XML
		{
			var sceneObjXML : XML = <SceneObj>
								    </SceneObj>
			
			sceneObjXML.appendChild(mAssetObj.GetXML());
			
			return sceneObjXML;
		}
		
		/** Inicializa el SceneObj a partir de los valores de un trozo de XML */
		public function LoadFromXML(xml : XML) : void
		{
		}		

		public function InvalidateBoundingRectangle() : void
		{
			mVisualObject.graphics.clear();
			
			if (mShowBounds)
			{
				var rect : Rectangle = mVisualObject.getBounds(mVisualObject);
				mVisualObject.graphics.lineStyle(1, 0xFF0000);
				mVisualObject.graphics.moveTo(rect.left-1, rect.bottom);
				mVisualObject.graphics.lineTo(rect.left+rect.width, rect.bottom);
				mVisualObject.graphics.lineTo(rect.left+rect.width, rect.bottom-rect.height-1);
				mVisualObject.graphics.lineTo(rect.left-1, rect.bottom-rect.height-1);
				mVisualObject.graphics.lineTo(rect.left-1, rect.bottom);
			}
		}

		/** Hace transparente (o no) el objeto */
		public function MakeTransparent(transparent : Boolean) : void
		{
			if (transparent)
			{
				if ((mAlphaTweener == null && MathUtils.ThresholdNotEqual(mVisualObject.alpha, mTransparencyLevel, 0.01)) || 
				    (mAlphaTweener != null && MathUtils.ThresholdNotEqual(mAlphaTweener.vars.alpha, mTransparencyLevel, 0.01)) )
				    {				    
						mAlphaTweener = TweenLite.to(mVisualObject, 1, {alpha:mTransparencyLevel, onComplete:OnAlphaTweenComplete })
				    }
			}			
			else
			{
				if ((mAlphaTweener == null && MathUtils.ThresholdNotEqual(mVisualObject.alpha, 1.0, 0.01))	||
				    (mAlphaTweener != null && MathUtils.ThresholdNotEqual(mAlphaTweener.vars.alpha, 1.0, 0.01)) )
				{
					mAlphaTweener = TweenLite.to(mVisualObject, 1, {alpha:1.0, onComplete:OnAlphaTweenComplete })
				}
			}
		}
		
		/** Nivel de transparencia entre 0 y 1 que tendrá el SceneObject al llamar a MakeTransparent */
		public function get TransparencyLevel() : Number 	  	   { return mTransparencyLevel; }
		public function set TransparencyLevel(level : Number):void { mTransparencyLevel = level; }
		
		private function OnAlphaTweenComplete():void
		{
			mAlphaTweener = null;
		}
		
		
		private var mGameModel : GameModel;
		private var mShowBounds : Boolean = false;
		
		private var mVisualObject : MovieClip;
		private var mAlphaTweener : TweenLite;
				
		private var mTransparencyLevel : Number = 0.3;
		
		private var mAssetObj : AssetObject;	
	}
}