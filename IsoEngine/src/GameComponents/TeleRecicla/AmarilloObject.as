package GameComponents.TeleRecicla
{
	import GameComponents.GameComponent;
	
	import Model.UpdateEvent;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import gs.TweenLite;
	
	import utils.KeyboardHandler;
	import utils.RandUtils;

	public class AmarilloObject extends GameComponent
	{
		public var DownSpeed : Number = 0.1;
		public var DownSpeedFast : Number = 0.2;

		override public function OnStart():void
		{
			TheVisualObject.visible = false;

			// Hay del 1 al 29 fotogramas
			mSequence = RandUtils.GenerateShuffledArray(TheVisualObject.framesLoaded);	
			mNumSuccess = 0;
			mRunning = false;
			
			mSequence = mSequence.slice(0, NumStarting);
			
			mResult = TheGameModel.TheAssetLibrary.CreateMovieClip("mcResultado");
			TheGameModel.TheRender2DCamera.addChild(mResult);
		}

		override public function OnStop():void
		{
			TheGameModel.TheRender2DCamera.removeChild(mResult);
			mResult = null;
		}

		public function SetPlayCoords(initialX:Number, initialY:Number, coordsX : Object, finalCoordY:Number):void
		{
			mInitialCoords.x = initialX; mInitialCoords.y = initialY;
			mFinalCoordY = finalCoordY;

			for (var c:int=0; c < mColors.length; c++)
				mColors[c].CoordX = coordsX[mColors[c].Name];
		}

		public function NextObject():void
		{
			if (mSequence.length == 0)
				throw "Sequence complete";

			TheVisualObject.visible = true;
			TheAssetObject.TheRender2DComponent.ScreenPos = mInitialCoords;

			mRunning = true;
			mCurrLineIdx = 1;

			var nextInSeq : int = mSequence.shift();
			TheVisualObject.gotoAndStop(nextInSeq+1);
		}

		override public function OnUpdate(event:UpdateEvent):void
		{
			if (!mRunning)
				return;

			var currPos : Point = TheAssetObject.TheRender2DComponent.ScreenPos;

			currPos.y += event.ElapsedTime * DownSpeed;

			if (currPos.y > mFinalCoordY)
			{
				mRunning = false;
				TheVisualObject.visible = false;

				TweenLite.killTweensOf(TheVisualObject);
				TheVisualObject.x = mColors[mCurrLineIdx].CoordX;
				
				mResult.x = TheVisualObject.x;
				mResult.y = TheVisualObject.y;
				
				var containerEvent : Event = null;
				
				if (mCurrLineIdx == GetCurrObjectColorIdx())
				{
					mNumSuccess++;
					dispatchEvent(new Event("ScoreUpdated"));
				
					mResult.gotoAndPlay("Acierto");
					containerEvent = new Event("ContainerOK");
				}
				else
				{
					mResult.gotoAndPlay("Error");
					containerEvent = new Event("ContainerKO");					
				}
				
				// En la última esperamos para dispachar a que se acabe la animación
				if (Remaining == 0)
					TweenLite.delayedCall(1.5, OnResultEnd, [containerEvent]);
				else
					dispatchEvent(containerEvent);
			}
			else
			{
				if (KeyboardHandler.Keyb.IsKeyPressed(Keyboard.DOWN))
				{
					currPos.y += event.ElapsedTime * DownSpeedFast;
				}

				if (KeyboardHandler.Keyb.IsKeyPressedOnce(Keyboard.LEFT))
				{
					if (mCurrLineIdx > 0)
					{
						mCurrLineIdx--;
						TweenLite.to(TheVisualObject, 0.3, {x:mColors[mCurrLineIdx].CoordX});
					}
				}
				else
				if (KeyboardHandler.Keyb.IsKeyPressedOnce(Keyboard.RIGHT))
				{
					if (mCurrLineIdx < mColors.length-1)
					{
						mCurrLineIdx++;
						TweenLite.to(TheVisualObject, 0.3, {x:mColors[mCurrLineIdx].CoordX});
					}
				}

				TheVisualObject.y = currPos.y;
			}
		}
		
		private function OnResultEnd(containerEvent:Event):void
		{
			dispatchEvent(containerEvent);
		}

		private function GetCurrObjectColorIdx():int
		{
			var ret : int = -1;

			for (var c:int=0; c < mColors.length; c++)
			{
				if (TheVisualObject.currentFrame >= mColors[c].LabelStartIdx &&
					TheVisualObject.currentFrame <= mColors[c].LabelEndIdx)
				{
					ret = c;
					break;
				}
			}

			return ret;
		}

		public function get NumSuccess() : int 	{ return mNumSuccess; }
		public function get Remaining() : int 	{ return mSequence.length; }
		public function get NumStarting() : int	{ return 10; }

		public function get Score() : int
		{
			return Math.round(10*NumSuccess / NumStarting)*10;
		}

		private var mColors : Array = [	{ Name:"Gris", LabelStartIdx:30, LabelEndIdx:39, CoordX: -1 },
										{ Name:"Amarillo", LabelStartIdx:1, LabelEndIdx:18, CoordX: -1 },
										{ Name:"Azul", LabelStartIdx:19, LabelEndIdx:29, CoordX: -1 }
									  ]

		private var mCurrLineIdx : int = 0;
		private var mNumSuccess : int = 0;
		private var mSequence : Array;
		private var mRunning : Boolean = false;

		private var mFinalCoordY : Number;
		private var mInitialCoords : Point = new Point();
		
		private var mResult : MovieClip;
	}
}