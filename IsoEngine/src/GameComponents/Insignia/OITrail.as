package GameComponents.Insignia
{
	import GameComponents.GameComponent;
	
	import Model.UpdateEvent;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import gs.TweenMax;
	
	import mx.core.UIComponent;
	
	
	public class OITrail extends GameComponent
	{		
		override public function OnStart():void
		{
			// Añadimos el UIComponent al root (a la stage no funciona).
			mOnStageSprite = new UIComponent();
			(TheVisualObject.root as DisplayObjectContainer).addChild(mOnStageSprite);
			mNumSegments = 0;
		}
		
		override public function OnStop() : void
		{
			StopTweening();
			TheVisualObject.stage.removeEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			TheVisualObject.stage.removeEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
			TheVisualObject.stage.removeEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
			(TheVisualObject.root as DisplayObjectContainer).removeChild(mOnStageSprite);
			mOnStageSprite = null;
		}
		
		override public function OnUpdate(event:UpdateEvent):void
		{
			var gr : Graphics = mOnStageSprite.graphics; 
			gr.clear();
			
			if ((mNumSegments == 0) || (mTrailPoints == null) )
				return;
					
			for (var c:int = 0; c < mTrailPoints.length;c++)
			{
				var curr : Object = mTrailPoints[c];
				
				gr.beginFill(0xFFFFFF, mTrailPoints[c].Alpha);		
				gr.drawCircle(curr.Center.x, curr.Center.y, 10);								
				gr.endFill();
			}
		}
		
		override public function OnPause() : void
		{
			TweenMax.pauseAll();
			mPaused = true;
		}
		
		override public function OnResume():void
		{
			mPaused = false;
			TweenMax.resumeAll();
		}
		
		private function OnMouseDown(event:MouseEvent):void
		{
			StartTrail();
		}
		
		private function OnMouseUp(event:MouseEvent):void
		{
			EndTrail();
		}
		
		private function StartTrail() : void
		{
			StopTweening();
			
			mCapturing = true;
			mTrailPoints = new Array();
			
			mOnStageSprite.graphics.clear();
		}
		
		private function StopTweening() : void
		{
			if (!mTrailPoints)
				return;
				
			for (var c:int = 0; c < mTrailPoints.length; c++)
				TweenMax.killTweensOf(mTrailPoints[c]);
		}
		
		private function EndTrail() : void
		{
			if (!mCapturing)
				return;
						
			mCapturing = false;
		}
		
		public function SetRenderingEnabled(enabled : Boolean):void
		{
			if (enabled)
			{
				TheVisualObject.stage.addEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown, false, 0, true);
				TheVisualObject.stage.addEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove, false, 0, true);
				TheVisualObject.stage.addEventListener(MouseEvent.MOUSE_UP, OnMouseUp, false, 0, true);
			}
			else
			{
				TheVisualObject.stage.removeEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
				TheVisualObject.stage.removeEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
				TheVisualObject.stage.removeEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
			}				
		}
				
		private function OnMouseMove(event:MouseEvent) : void
		{
			if (!event.buttonDown)
				mCapturing = false;
							
			if (!mCapturing || mPaused)
				return;
			
			var currCenter : Point = new Point(event.stageX, event.stageY);

			if (mTrailPoints.length != 0)
			{
				var prevCenter : Point = mTrailPoints[mTrailPoints.length-1].Center;
				var centersDistance : Number = currCenter.subtract(prevCenter).length;
			
				if (centersDistance > 4)
				{
					var step : Number = 3/centersDistance;
					var prevX : Number = Number.NEGATIVE_INFINITY;
					var prevY : Number = Number.NEGATIVE_INFINITY;
					
					var dir : Point = currCenter.subtract(prevCenter);

					for (var t:Number = 0; t <= 1.0; t += step)
					{
						var interpX : Number = prevCenter.x + dir.x*t;
						var interpY : Number = prevCenter.y + dir.y*t;

						var roundedX : Number = Math.floor(interpX);
						var roundedY : Number = Math.floor(interpY);
						
						if ((roundedX != prevX) || (roundedY != prevY))
						{
							var interpCenter : Point = new Point(roundedX, roundedY);
							var currSegment : Object = {Center:interpCenter, Alpha:0.2};

							mTrailPoints.push(currSegment);
					
							mNumSegments++;
							TweenMax.to(currSegment, 0.2, { Alpha:0, onComplete:SegmentAlphaComplete });
							
							prevX = roundedX;
							prevY = roundedY;
						}
					}
				}
			}
			else
			{
				// Primer punto
				mTrailPoints.push({Center:currCenter, Alpha:0.2});
				
				mNumSegments++;
				TweenMax.to(mTrailPoints[0], 0.2, { Alpha:0, onComplete:SegmentAlphaComplete });
			}
		}

		private function SegmentAlphaComplete() : void
		{
			mNumSegments--;
			mTrailPoints.shift();
		}
						
		private function GenerateLeftRightForSegment(prevCenter:Point, currSegment:Object, invertDir:Boolean=false, t:Number=1.0) : void
		{
			const TRAIL_WIDTH : Number = 7;
			
			var dir : Point = currSegment.Center.subtract(prevCenter);
			if (invertDir)
			{
				dir.x *= -1; dir.y *= -1;
			}
			var norm : Point = new Point(-dir.y, dir.x);
			norm.normalize(TRAIL_WIDTH*t);
	
			currSegment.Right = currSegment.Center.add(norm);
			currSegment.Left = currSegment.Center.add(new Point(-norm.x, -norm.y));
		}  
		
		private var mPaused : Boolean = false;
		private var mCapturing : Boolean = false;
		private var mNumSegments : int = 0;
		private var mOnStageSprite : UIComponent;
		private var mTrailPoints : Array;		
	}
}