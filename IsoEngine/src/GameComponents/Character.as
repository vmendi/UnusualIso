package GameComponents
{
	import Model.AStartMapSpace;
	import Model.UpdateEvent;
	
	import PathFinding.*;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import utils.MovieClipLabels;
	import utils.Point3;
	
	/**
	 * Componente para hacer que un objeto se comporte como personaje.
	 */
	public final class Character extends GameComponent
	{
		public var WalkSpeed : Number = 1;
		public var StartOrientation : String = "SE";
		public var CamFollow : Boolean = true;
		
		override public function OnStart() : void
		{
			mSearchSpace = TheGameModel.TheAStartSpace;
			
			mAStart = new AStar(mSearchSpace);

			// Controlamos el click
			TheVisualObject.stage.addEventListener(MouseEvent.CLICK, OnClick);

			var frameOfStop : int = MovieClipLabels.GetFrameOfLabel("stop", TheVisualObject);
			TheVisualObject.addFrameScript(frameOfStop-1, OnVisualFrameStop);
			
			// Posición inicial
			TheVisualObject.gotoAndStop("idle"+StartOrientation);
			
			// Posición inicial
			if (TheGameModel.TheIsoEngine.GameDef.NextStartWorldPos != null)
				TheIsoComponent.WorldPos = TheGameModel.TheIsoEngine.GameDef.NextStartWorldPos;
			
			// Orientación inicial
			if (TheGameModel.TheIsoEngine.GameDef.NextOrientation != null)
				TheVisualObject.gotoAndStop("idle"+TheGameModel.TheIsoEngine.GameDef.NextOrientation);
			else
				TheVisualObject.gotoAndStop("idle"+StartOrientation);
			
			/*
			// Test de rendimiento del pathfinding
			var prevTime : int = getTimer();
			
			for (var c : int = 0; c < 100; c++)
			{
				this.NavigateTo(new Point3(-6.27217067688691, 0, -10.842921626362186));
			}
			
			var totalTime : int = getTimer() - prevTime;
			trace("Tiempo: " + totalTime);
			*/
			
			if (CamFollow)
			{
				TheGameModel.TheIsoCamera.CheckLimits = true;
				TheGameModel.TheIsoCamera.TargetPos = new Point(TheIsoComponent.WorldPos.x, TheIsoComponent.WorldPos.z);
			}				
		}
		
		override public function OnPause():void
		{
			TheVisualObject.stage.removeEventListener(MouseEvent.CLICK, OnClick);
			TheVisualObject.gotoAndStop("stop");
			mPath = null;
		}
		
		override public function OnResume():void
		{
			TheVisualObject.stage.addEventListener(MouseEvent.CLICK, OnClick);
		}
		
		override public function OnStop():void
		{
			TheVisualObject.stage.removeEventListener(MouseEvent.CLICK, OnClick);
			TheVisualObject.gotoAndStop("stop");
			mPath = null;
			mAStart = null;
			mSearchSpace = null;
		}
		
		
		private function OnClick(event:MouseEvent) : void
		{
			var mousePos : Point = TheGameModel.TheRenderCanvas.globalToLocal(new Point(event.stageX, event.stageY));
			var worldClickPos : Point3 = TheGameModel.TheIsoCamera.IsoScreenToWorld(mousePos);
			
			NavigateTo(worldClickPos);
		}


		public function NavigateTo(globalPos : Point3) : void
		{
			var srcPoint : IntPoint = mSearchSpace.WorldToSearchSpace(TheIsoComponent.WorldPos);
			var dstPoint : IntPoint = mSearchSpace.WorldToSearchSpace(globalPos);
			
			var path : Array = mAStart.Solve(srcPoint, dstPoint);

			if (path != null)
			{
				mPath = path;
				mFirstStartingPoint = TheIsoComponent.WorldPos;
				mCurrentPathPoint = -1;
				mCurrentDist = 0;
				mLastHeading = "";

				dispatchEvent(new Event("NavigationStart"));
			}
			else
			{
				trace("Path no encontrado");
			}
		}
		
		public function OrientTo(toPoint : Point3) : void
		{
			var currHeading : String = GetHeadingString(TheIsoComponent.WorldPos, toPoint);
			
			if (currHeading != mLastHeading)
			{
				TheVisualObject.gotoAndStop("idle"+currHeading);
				mLastHeading = currHeading;
			}
		}
			

		override public function OnUpdate(event:UpdateEvent):void
		{
			// Movimiento
			InterpolateMovement(event.ElapsedTime);
			
			// Centramos la camara en nosotros
			if (CamFollow)
				TheGameModel.TheIsoCamera.TargetPos = new Point(TheIsoComponent.WorldPos.x, TheIsoComponent.WorldPos.z);
			
			// Hacemos transparente el escenario
			TheGameModel.MakeTransparentOthers(TheIsoComponent);			
		}
		
		
		private function InterpolateMovement(elapsedTime : Number) : void
		{
			if (mPath != null)
			{
				var firstPoint : Point3 = null;
				var secondPoint : Point3 = null;
				
				if (mCurrentPathPoint != -1)
					firstPoint = mSearchSpace.SearchToWorldSpace(mPath[mCurrentPathPoint]);
				else
					firstPoint = mFirstStartingPoint.Clone();
								
				secondPoint = mSearchSpace.SearchToWorldSpace(mPath[mCurrentPathPoint+1]);

				var distTotal : Number = secondPoint.Distance(firstPoint);
				var distStep : Number = elapsedTime*WalkSpeed*0.001;
				
				// Paso al siguiente punto?
				if (mCurrentDist + distStep > distTotal)
				{
					mCurrentPathPoint++;
					mCurrentDist = 0;
					distStep = 0;
	
					if (mCurrentPathPoint == mPath.length-1)
					{
						mPath = null;
						TheIsoComponent.SetWorldPosRounded(secondPoint);
						TheVisualObject.gotoAndStop("stop");
						dispatchEvent(new Event("NavigationEnd"));
					}
					else
					{
						firstPoint = mSearchSpace.SearchToWorldSpace(mPath[mCurrentPathPoint]);
						secondPoint = mSearchSpace.SearchToWorldSpace(mPath[mCurrentPathPoint+1]);
					}
				}
								
				if (mPath != null)
				{
					var currHeading : String = GetHeadingString(firstPoint, secondPoint);
					if (currHeading != mLastHeading)
					{
						TheVisualObject.gotoAndStop("walk"+currHeading);
						mLastHeading = currHeading;
					}
					mCurrentDist += distStep;
					TheIsoComponent.WorldPos = firstPoint.AddToThis(firstPoint.GetScaledDirection(secondPoint, mCurrentDist));
				}
			}	
		}
	 
		
		private function OnVisualFrameStop() : void
		{
			TheVisualObject.gotoAndStop("idle"+mLastHeading);
		}
		
		private function GetHeadingString(firstPoint : Point3, secondPoint : Point3) : String
		{
			var headingVect : Point3 = secondPoint.Substract(firstPoint);
			var ret : String = "";
						
			if (headingVect.z > 0.1)
			{
				if (headingVect.x > 0.1)
					ret = "N";
				else
				if 	(headingVect.x < -0.1)
					ret = "W";
				else
					ret = "NW";
			}
			else
			if (headingVect.z < -0.1)
			{
				if (headingVect.x > 0.1)
					ret = "E";
				else
				if (headingVect.x < -0.1)
					ret = "S";
				else
					ret = "SE";
			}
			else
			{
				if (headingVect.x > 0.1)
					ret = "NE";
				else
				if (headingVect.x < -0.1)
					ret = "SW";
				else
					ret = "";	// Estamos parados
			}
			
			return ret;
		} 
		
		public function SetNavigationEnabled(enabled : Boolean) : void
		{
			TheVisualObject.stage.removeEventListener(MouseEvent.CLICK, OnClick);
			
			if (enabled)
				TheVisualObject.stage.addEventListener(MouseEvent.CLICK, OnClick);
		}
	
		private var mPath : Array;
		private var mCurrentPathPoint : int = 0;
		private var mCurrentDist : Number = 0;
		private var mFirstStartingPoint : Point3;
		private var mLastHeading : String = "";
		private var mSearchSpace : AStartMapSpace;
		private var mAStart : AStar;
	}
}