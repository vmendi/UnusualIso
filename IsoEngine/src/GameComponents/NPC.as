package GameComponents
{
	import Model.AStartMapSpace;
	import Model.GameModel;
	import Model.UpdateEvent;
	
	import PathFinding.*;
	
	import flash.events.Event;
	
	import utils.MovieClipLabels;
	import utils.Point3;
	
	/**
	 * Componente para hacer que un objeto se comporte como un NPC.
	 */
	public final class NPC extends GameComponent
	{
		public var WalkSpeed : Number = 1;
		public var StartOrientation : String = "SE";
		
		override public function OnStart() : void
		{
			mSearchSpace = TheGameModel.TheAStartSpace;
			
			mAStart = new AStar(mSearchSpace);
			
			var frameOfStop : int = MovieClipLabels.GetFrameOfLabel("stop", TheVisualObject);
			TheVisualObject.addFrameScript(frameOfStop-1, OnVisualFrameStop);
			
			// Posición inicial
			TheVisualObject.gotoAndStop("idle"+StartOrientation);
		}
		
		override public function OnPause():void
		{
			TheVisualObject.gotoAndStop("stop");
			mPath = null;
		}
		
		override public function OnResume():void
		{
			//TheIsoObject.TheGameModel.stage.addEventListener(MouseEvent.CLICK, OnClick);
		}
		
		override public function OnStop():void
		{
			//TheIsoObject.TheGameModel.stage.removeEventListener(MouseEvent.CLICK, OnClick);
			TheVisualObject.gotoAndStop("stop");
			mPath = null;
			mAStart = null;
			mSearchSpace = null;
		}
		
		
		public function GoPoint(worldClickPos:Point3) : void
		{
			//2.8062653117622363, 0, 5.775839587037192
			/*
			var mousePos : Point = new Point(event.stageX, event.stageY);
			var worldClickPos : Point3 = TheIsoObject.TheGameModel.TheMainCamera.IsoScreenToWorld(mousePos, TheIsoObject.TheGameModel.GetParentCoord());
			*/
			NavigateTo(worldClickPos);
		}


		public function NavigateTo(globalPos : Point3) : void
		{
			var snappedSrcPos : Point3 = GameModel.GetSnappedWorldPos(TheIsoComponent.WorldPos);
			var snappedDstPos : Point3 = GameModel.GetSnappedWorldPos(globalPos);
			
			var srcPoint : IntPoint = mSearchSpace.WorldToSearchSpace(snappedSrcPos);
			var dstPoint : IntPoint = mSearchSpace.WorldToSearchSpace(snappedDstPos);
			
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
			//TheIsoObject.TheGameModel.TheMainCamera.TargetPos = new Point(TheIsoObject.WorldPos.x, TheIsoObject.WorldPos.z);
			
			// Hacemos transparente el escenario
			//TheIsoObject.TheGameModel.MakeTransparentOthers(TheIsoObject);			
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
						TheIsoComponent.SetWorldPosSnapped(secondPoint);
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
			/*
			TheIsoObject.TheGameModel.stage.removeEventListener(MouseEvent.CLICK, OnClick);
			
			if (enabled)
				TheIsoObject.TheGameModel.stage.addEventListener(MouseEvent.CLICK, OnClick);
			*/
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