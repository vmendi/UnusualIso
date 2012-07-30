package GameComponents.TeleRecicla
{
	import GameComponents.GameComponent;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import gs.TweenLite;
	
	import utils.RandUtils;

	public class HiddenGame extends GameComponent
	{
		public var ReturnSpeed : Number = 1500;


		override public function OnStart():void
		{
			GatherContainers();
			GatherRemains();
			PickTargets();
			DisableMouseForNonTargets();
			SubscribeListeners();
			FillTargetList();

			mClock = TheGameModel.CreateSceneObjectFromMovieClip("mcClock", "HiddenClock") as HiddenClock;
			mClock.addEventListener("TimeEnd", OnTimeEnd, false, 0, true);
			mClock.StartTimer();
			
			mResult = TheGameModel.TheAssetLibrary.CreateMovieClip("mcResultado");
			TheVisualObject.mcCocina.addChild(mResult);
		}

		override public function OnStop():void
		{
			TheVisualObject.mcCocina.removeChild(mResult);
			TheGameModel.DeleteSceneObject(mClock.TheSceneObject);
		}

		private function DisableMouseForNonTargets():void
		{
			var cocina : MovieClip = TheVisualObject.mcCocina;
			var numChildren : int = cocina.numChildren;

			for (var i:int = 0; i < numChildren; i++)
			{
				var child : InteractiveObject = cocina.getChildAt(i) as InteractiveObject;

				if (child != null && mTargets.indexOf(child) == -1)
					child.mouseEnabled = false;
			}

			(TheVisualObject.mcCocina.getChildByName("mcContenedorAzul") as MovieClip).mouseEnabled = false;
			(TheVisualObject.mcCocina.getChildByName("mcContenedorGris") as MovieClip).mouseEnabled = false;
			(TheVisualObject.mcCocina.getChildByName("mcContenedorAmarillo") as MovieClip).mouseEnabled = false;
		}

		private function OnTimeEnd(event:Event):void
		{
			if (mDragging)
				TweenDraggingToInitialPos();

			RemoveListeners();

			for (var i:int=0; i < mTargets.length; ++i)
				TweenLite.to(TheVisualObject["mcItem"+(i+1).toString()], 1.8, {alpha:0.0});

			TweenLite.delayedCall(2, GotoEndGame);
		}

		private function GotoEndGame():void
		{
			if (mClock.IsRunning)
				TheGameModel.FindGameComponentByShortName("HiddenInterface").GotoFinExito(null);
			else
				TheGameModel.FindGameComponentByShortName("HiddenInterface").GotoFin(null);
		}

		public function GetFinalScore() : Number
		{
			return mClock.RemainingMiliseconds;
		}

		private function FillTargetList():void
		{
			for (var i:int=0; i < mTargets.length; ++i)
			{
				TheVisualObject["mcItem"+(i+1).toString()].ctItem.text = ExtractRemainName(mTargets[i].name);
			}
		}

		private function ExtractRemainName(str : String):String
		{
			var ret : String = str.slice(0);

			ret = ret.replace("mcAmarillo", "");
			ret = ret.replace("mcAzul", "");
			ret = ret.replace("mcGris", "");

			while (ret.indexOf("_") != -1)
				ret = ret.replace("_", " ");

			return ret;
		}

		private function GatherContainers():void
		{
			mContainers.push(TheVisualObject.mcCocina.getChildByName("mcContenedorAzul"));
			mContainers.push(TheVisualObject.mcCocina.getChildByName("mcContenedorGris"));
			mContainers.push(TheVisualObject.mcCocina.getChildByName("mcContenedorAmarillo"));

			mContainerColors["mcContenedorAzul"] = "Azul";
			mContainerColors["mcContenedorGris"] = "Gris";
			mContainerColors["mcContenedorAmarillo"] = "Amarillo";
		}

		private function SubscribeListeners():void
		{
			TheVisualObject.stage.addEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			TheVisualObject.stage.addEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
		}

		private function RemoveListeners():void
		{
			TheVisualObject.stage.removeEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			TheVisualObject.stage.removeEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
		}

		private function OnMouseDown(event:Event):void
		{
			// Todavía estamos volando?
			if (mDragging != null)
				return;

			if (mAllRemains.indexOf(event.target) != -1 && mTargets.indexOf(event.target) != -1)
			{
				var dragging : MovieClip = event.target as MovieClip;
				var draggingIndex : int = dragging.parent.getChildIndex(dragging);

				dragging.parent.setChildIndex(dragging, dragging.parent.numChildren-1);
				dragging.startDrag();

				mDragging = { MovieClip:dragging, Index:draggingIndex, StartX:dragging.x, StartY:dragging.y };
			}
		}

		private function OnMouseUp(event:MouseEvent):void
		{
			if (mDragging == null || mTweening)
				return;

			var onStageMouseCoord : Point = new Point(event.stageX, event.stageY);
			var container : MovieClip = GetContainerForCoord(onStageMouseCoord);

			if (container != null)
			{
				var containerColor : String = mContainerColors[container.name];
				if (mDragging.MovieClip.name.indexOf(containerColor) != -1)
				{
					var targetIdx : int = mTargets.indexOf(mDragging.MovieClip);
					
					TheVisualObject["mcItem"+(targetIdx+1).toString()].gotoAndStop("Found");

					mDragging.MovieClip.stopDrag();
					TheVisualObject.mcCocina.removeChild(mDragging.MovieClip);
					mDragging = null;
					mTargets[targetIdx] = null;
					
					ShowResult(container.x, container.y, true);

					if (ArrayContainsOnlyNulls(mTargets))
						GotoEndGame();
				}
				else
				{
					ShowResult(container.x, container.y, false);
					TweenDraggingToInitialPos();
				}
			}
			else TweenDraggingToInitialPos();
		}
		
		private function ShowResult(x:Number, y:Number, result:Boolean):void
		{
			mResult.x = x;
			mResult.y = y;
			
			if (result)		
				mResult.gotoAndPlay("Acierto");
			else
				mResult.gotoAndPlay("Error");
		}

		private function ArrayContainsOnlyNulls(arr:Array):Boolean
		{
			var bRet : Boolean = true;
			for (var i:int = 0; i < arr.length; ++i)
			{
				if (arr[i] != null)
				{
					bRet = false;
					break;
				}
			}
			return bRet;
		}

		private function OnDraggingTweenComplete():void
		{
			mDragging.MovieClip.x = mDragging.StartX;
			mDragging.MovieClip.y = mDragging.StartY;
			mDragging.MovieClip.parent.setChildIndex(mDragging.MovieClip, mDragging.Index);
			mDragging = null;
			mTweening = false;
		}

		private function TweenDraggingToInitialPos():void
		{
			var startPoint : Point = new Point(mDragging.StartX, mDragging.StartY);
			var endPoint : Point = new Point(mDragging.MovieClip.x, mDragging.MovieClip.y);
			var distToTravel : Number = (startPoint.subtract(endPoint)).length;
			var timeToTravel : Number = distToTravel / ReturnSpeed;

			TweenLite.to(mDragging.MovieClip, timeToTravel, { x:mDragging.StartX, y:mDragging.StartY, onComplete:OnDraggingTweenComplete });

			// Es posible que ya se haya llamado a OnDragginTweenComplete si las coords son las mismas
			if (mDragging != null)
			{
				mDragging.MovieClip.stopDrag();
				mTweening = true;
			}
		}

		private function GatherRemains() : void
		{
			var cocina : MovieClip = TheVisualObject.mcCocina;
			var numChildren : int = cocina.numChildren;

			for (var i:int = 0; i < numChildren; i++)
			{
				var child : DisplayObject = cocina.getChildAt(i);
				var index : int = -1;
				
				if (child.name.indexOf("Contenedor") != -1)
					continue;

				if ((index = child.name.indexOf("Amarillo")) != -1)
					mYellowRemains[child.name] = child;
				else
				if ((index = child.name.indexOf("Azul")) != -1)
					mBlueRemains[child.name] = child;
				else
				if ((index = child.name.indexOf("Gris")) != -1)
					mGreyRemains[child.name] = child;

				if (index != -1)
					mAllRemains.push(child);
			}
		}

		private function PickTargets() : void
		{
			var shuffled : Array = RandUtils.Shuffle(ConvertToArray(mYellowRemains));
			mTargets = mTargets.concat(shuffled.slice(0, 4));

			shuffled = RandUtils.Shuffle(ConvertToArray(mBlueRemains));
			mTargets = mTargets.concat(shuffled.slice(0, 2));

			shuffled = RandUtils.Shuffle(ConvertToArray(mGreyRemains));
			mTargets = mTargets.concat(shuffled.slice(0, 2));

			mTargets = RandUtils.Shuffle(mTargets);
		}

		private function ConvertToArray(obj : Object) : Array
		{
			var ret : Array = new Array();

			for each(var prop:MovieClip in obj)
				ret.push(prop);

			return ret;
		}

		private function GetContainerForCoord(coord : Point) : MovieClip
		{
			var ret:MovieClip = null;

			for each(var container : MovieClip in mContainers)
			{
				if (container.getBounds(TheVisualObject.stage).containsPoint(coord))
				{
					ret = container;
					break;
				}
			}

			return ret;
		}

		private var mTargets : Array = new Array;
		private var mDragging : Object = null;
		private var mTweening : Boolean = false;

		private var mAllRemains : Array = new Array;
		private var mYellowRemains : Object = new Object;
		private var mBlueRemains : Object = new Object;
		private var mGreyRemains : Object = new Object;

		private var mContainers : Array = new Array;
		private var mContainerColors : Object = new Object;

		private var mClock : HiddenClock;
		
		private var mResult : MovieClip;
	}
}