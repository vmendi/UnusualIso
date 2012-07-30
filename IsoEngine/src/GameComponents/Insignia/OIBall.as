package GameComponents.Insignia
{
	import GameComponents.GameComponent;
	
	import Model.UpdateEvent;
	
	import flash.geom.Point;
	
	import gs.TweenMax;

	public class OIBall extends GameComponent
	{
		public var StartScale : Number = 0.1;
		public var EndScale : Number = 1;
		
		override public function OnStart():void
		{
			mPaused = false;
			TheVisualObject.visible = false;
		}
		
		override public function OnStop():void
		{
			mInterpolating = false;
			TheVisualObject.visible = true;
			SymetricalScale = 1.0;
			TweenMax.killTweensOf(this);
		}
		
		public function IsSymetricalScaleSerializable() : Boolean { return false; }
		
		public function set SymetricalScale(scl:Number) : void
		{
			if (TheVisualObject != null)
			{
				TheVisualObject.scaleX = scl;
				TheVisualObject.scaleY = scl;
			}
		}		
		public function get SymetricalScale() : Number
		{
			// Si están clonando a nuestro AssetObj, todavía no hay VisualObject
			if (TheVisualObject != null) 
				return TheVisualObject.scaleX;
			else
				return 0;
		}
				
				
		override public function OnPause():void
		{
			mPaused = true;
			TweenMax.pauseAll();
		}
		
		override public function OnResume():void
		{
			mPaused = false;
			TweenMax.resumeAll();
		}
			
		override public function OnUpdate(event:UpdateEvent):void
		{
			if (!mInterpolating)
				return;

			if (mCurrentTime > mTotalTime)
			{
				StopTween();
			}
			else
			{		
				ScreenX += mSpeed.x * event.ElapsedTime / 1000.0;
				ScreenY += mSpeed.y * event.ElapsedTime / 1000.0;
			
				mSpeed.y += GRAVITY * event.ElapsedTime / 1000.0;

				mCurrentTime += event.ElapsedTime;
			}
		}
		
		public function CancelMovement() : void
		{
			if (mPaused)
				throw "Pausate - Pausate - Pausate - Pausate";

			StopTween();
		}
		

		public function StartMovement(traj:OIBallTrajectory, isIncoming : Boolean) : void
		{	
			if (mPaused)
				throw "Pausate - Pausate - Pausate - Pausate - Que te pauses";

			TheVisualObject.visible = true;

			SetupTrajectory(traj, !isIncoming);
			SetupScale(isIncoming);
			
			mTrajectory = traj;
		}
				
		private function StopTween() : void
		{
			mTrajectory = null;
			mInterpolating = false;
			TheVisualObject.visible = false;
			TweenMax.killTweensOf(this);
		}
		
		private function SetupScale(isIncoming : Boolean) : void
		{
			if (isIncoming)
			{
				SymetricalScale = StartScale;
				TweenMax.to(this, mTotalTime/1000, { SymetricalScale:EndScale });
			}
			else
			{
				TweenMax.to(this, mTotalTime/1000, { SymetricalScale:StartScale });
			}	
		}
						
		private function SetupTrajectory(traj : OIBallTrajectory, useCurrentStartPos:Boolean) : void
		{
			var startPos : Point = new Point(traj.StartPos.x, traj.StartPos.y);
			
			if (useCurrentStartPos)
			{
				startPos = new Point(ScreenX, ScreenY);
			}
			else
			{
				ScreenX = startPos.x;
				ScreenY = startPos.y;
			}
			
			// Velocidad inicial
			var flyTimeInSeconds : Number = traj.FlyTime / 1000;		
			var diffY : Number = traj.EndPos.y - startPos.y;
			var vertSpeed : Number = (diffY - (0.5 * GRAVITY * flyTimeInSeconds*flyTimeInSeconds)) / flyTimeInSeconds;
			var horiSpeed : Number = (traj.EndPos.x - startPos.x) / flyTimeInSeconds;
									
			mSpeed = new Point(horiSpeed, vertSpeed);

			mCurrentTime = 0;
			mTotalTime = traj.FlyTime + traj.EndDelayTime;
			
			mInterpolating = true;
		}

		// Tenemos que hacer la coordenadas X e Y accesibles individualmente
		public function IsScreenXSerializable() : Boolean { return false; }
		public function get ScreenX():Number { return TheAssetObject.TheRender2DComponent.ScreenPos.x; }
		public function set ScreenX(val : Number):void
		{ 
			if (TheAssetObject != null)
				TheAssetObject.TheRender2DComponent.ScreenPos = new Point(val, TheAssetObject.TheRender2DComponent.ScreenPos.y);  
		}
		
		public function IsScreenYSerializable() : Boolean { return false; }
		public function get ScreenY():Number { return TheAssetObject.TheRender2DComponent.ScreenPos.y; }
		public function set ScreenY(val : Number):void
		{ 
			if (TheAssetObject != null)
				TheAssetObject.TheRender2DComponent.ScreenPos = new Point(TheAssetObject.TheRender2DComponent.ScreenPos.x, val);
		}
		
		private const GRAVITY : Number = 1200;
		
		private var mInterpolating : Boolean = false;
		private var mCurrentTime : Number = 0;
		private var mTotalTime : Number = 0;
		
		private var mPaused : Boolean = false;
		
		private var mSpeed : Point;
		
		private var mTrajectory : OIBallTrajectory = null;
	}
}