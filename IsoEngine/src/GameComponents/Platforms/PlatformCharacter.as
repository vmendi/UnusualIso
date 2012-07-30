package GameComponents.Platforms
{
	import Model.UpdateEvent;
	import GameComponents.GameComponent;
	
	import flash.ui.Keyboard;
	
	import utils.KeyboardHandler;
	import utils.MovieClipLabels;	
	
	public final class PlatformCharacter extends GameComponent
	{
		public var width : Number = 50;
		public var height : Number = 100;
		public var groundWalkIncrement : Number = 1.7;
		public var airWalkIncrement : Number = 1.7;
		public var floor : Number = 100;
		public var gravity : Number = 2;
		public var jumpSpeed : Number = 23;
		public var runXmov : Number = 3;
		public var windResistance : Number = 0.92;
		public var runDecay : Number = 0.85;
		public var minXmov : Number = 0.75;
		public var maxXmov : Number = 12;
		
		override public function OnStart():void
		{
			mInAir = false;
			
			mIsCrouching = false;
			mIsWalking = false;
			mIsRunning = false;
			mIsSliding = false;
			
			mJoystickH = 0;
			mXmov = 0;
			mYmov = 0;
		
			// Callback de final de las animaciones
			var frame : int = MovieClipLabels.GetFrameOfLabel("WalkEnd", TheVisualObject);
			TheVisualObject.addFrameScript(frame-1, OnWalkEnd);
			frame = MovieClipLabels.GetFrameOfLabel("TurnEnd", TheVisualObject);
			TheVisualObject.addFrameScript(frame-1, OnTurnEnd);
							
			// Buscamos todas las plataformas de la escena
			mPlatformList = TheGameModel.FindAllGameComponentsByShortName("Platform") as Array;
			
			// Posición y estado inicial
			mCurrentAnimation = "Idle";
		}
		
		override public function OnUpdate(event:UpdateEvent):void
		{
			listenForKeys();
			addFrictionAndGravity();
			createTempPosition();
			//baddyDetection();
			platformDetect();
			//collectableDetect();
			//detectFlag();
			checkFloor();
			DrawFinalPosition();
		}
		
		// Propias
		
		private function listenForKeys():void
		{
			mWalkIncrement = (mInAir) ? airWalkIncrement : groundWalkIncrement;
			// Eje horizontal
			if ( KeyboardHandler.Keyb.IsKeyPressed(80) && ( !mIsCrouching || mIsCrouching && mInAir ) )
			{
				mJoystickH = 1;
				mXmov += mWalkIncrement;
				Walk();
			}
			else if ( KeyboardHandler.Keyb.IsKeyPressed(79) && ( !mIsCrouching || mIsCrouching && mInAir ) )
			{
				mJoystickH = -1;
				mXmov -= mWalkIncrement;
				Walk();
			}
			else
			{
				mJoystickH = 0;
				StopWalking();
			}
			// Salto
			if ( KeyboardHandler.Keyb.IsKeyPressed(Keyboard.SPACE) && mOkToJump )
			{
				mOkToJump = false;
				if (!mIsJumping && !mInAir)
				{
					mInAir = true;
					mYmov = -jumpSpeed;
					Jump();
				}
			}
			else if ( !KeyboardHandler.Keyb.IsKeyPressed(Keyboard.SPACE) && !mOkToJump )
			{
				mOkToJump = true;
			}
			
			/*
			if (Key.isDown(Key.DOWN)) {
				hero.crouch();
			} else {
				hero.unCrouch();
			}			
			*/
		}
		
		private function addFrictionAndGravity():void
		{
			mYmov += gravity;

			if (mYmov > 0 && mInAir && !mIsFalling)
				Fall();
				
			if (!mInAir)
				mXmov *= runDecay;
			else
				mXmov *= windResistance;
			
			if (Math.abs(mXmov) < minXmov)
			{
				if (mJoystickH == 0)
				{
					mXmov = 0;
					if (!mInAir)
						Stop();
				}
			}
			
			if (Math.abs(mXmov) > maxXmov)
			{
				mXmov = (Math.abs(mXmov)/mXmov) * maxXmov;
			}
		}
		
		private function createTempPosition():void
		{
			mTempX = TheVisualObject.x + mXmov;
			mTempY = TheVisualObject.y + mYmov;
			var yMovABS : Number = Math.abs(mYmov);
			if (yMovABS > 10)
			{
				if (yMovABS > 22)
					mYmov = 22*(mYmov/yMovABS);
				mTotalIterations = 2;
			}
			else
			{
				mTotalIterations = 1;
			}
		}
		
		private function checkFloor():void
		{
			var onFloor : Boolean = mTempY > floor;
			if (onFloor)
			{
				mYmov = 0;
				mTempY = floor;
				if (mInAir)
					StopJumping();
				mInAir = false;
			}
		}
		
		private function platformDetect():void
		{
			var oldOnPlatform : Boolean = mOnPlatform;
			var onPlatform : Boolean = false;
			var platformTop : Number = 0;
			var newY : Number = 0;
			var newX : Number = 0;

			for (var i : Number = 0; i<mPlatformList.length; i++)
			{
				
				var py : Number = mPlatformList[i].y;
				var px : Number = mPlatformList[i].x;
				var pw : Number = mPlatformList[i].width;
				var ph : Number = mPlatformList[i].height;
				
				for (var iteration : Number = 1; iteration <= mTotalIterations; ++iteration)
				{
					mTempX = TheVisualObject.x + ((mXmov / mTotalIterations) * iteration);
					mTempY = TheVisualObject.y + ((mYmov / mTotalIterations) * iteration);
					// Comprobamos is hay colisión
					if ( (mTempX+width/2 > px) && (mTempX-width/2 < px+pw) && (mTempY - height < py+ph) && (mTempY > py) )
					{
						// Buscamos el lado del impacto
						if ( mTempY > py && TheVisualObject.y <= py+0.1 && mYmov > 0)
						{
							// Aterrizamos en la parte superior
							onPlatform = true;
							platformTop = py;
							LandOnPlatform(platformTop);
						}
						else if ( mTempY-height > py && mTempY-height < py+ph && mTempX+width/2 > px && mTempX < px+pw-width/2 && mYmov < 0)
						{
							// Colisión por debajo
							newY = py + ph + height;
							BounceOffOfBottom(newY);
						}
						else if ( mTempX+width/2 > px && mTempX+width/2<px+pw )
						{
							// Colisión por la izquierda
							newX = px-width/2;
							BounceOffOfPlatform(newX);
						}
						else if ( mTempX-width/2 > px && mTempX-width/2 < px+pw )
						{
							// Colisiona por la derecha
							newX = px+pw+width/2;
							BounceOffOfPlatform(newX);
						}
					}
				} 
			}
			
			mOnPlatform = onPlatform;
			if (!mOnPlatform && oldOnPlatform) 
			{
				// Acaba de dejar la plataforma
				mInAir = true;
			}
		}
		
		private function LandOnPlatform(platformTop:Number):void
		{
			mYmov = 0;
			mTempY = platformTop;
			if (mInAir)
				StopJumping();
			mInAir = false;			
		}
		
		private function BounceOffOfBottom(newY:Number):void
		{
			TheVisualObject.y = newY;
			mYmov = 0;
			mTempY = TheVisualObject.y + mYmov;
		}
		
		private function BounceOffOfPlatform(newX:Number):void
		{
			TheVisualObject.x = newX;
			mXmov = 0;
			mTempX = TheVisualObject.x + mXmov;
		}
		
		private function DrawFinalPosition():void
		{
			TheVisualObject.x = mTempX;
			TheVisualObject.y = mTempY;
		}
		
		// Acciones
		
		private function Walk():void
		{
			// Detecta si hay cambio de dirección para colocar el sprite en la orientación adecuada
			var Turn : Boolean = false;
			if (mJoystickH == 1)
			{
				if (mLastHeading == -1)
				{
					Turn = true;
				}
				mLastHeading = 1;
				TheVisualObject.scaleX = 1;
			}
			else if (mJoystickH == -1)
			{
				if (mLastHeading == 1)
				{
					Turn = true;
				}
				mLastHeading = -1;
				TheVisualObject.scaleX = -1;
			}

			if (!mInAir)
			{
				if (Math.abs(mXmov) > runXmov)
				{
					if (Turn)
					{
						PlayAnimation("Turn");
					}
					else
					{
						PlayAnimation("Run");
					}
				}
				else
				{
					PlayAnimation("Walk");
				}
			}
		}
		
		private function StopWalking():void
		{
			// Se lanza cuando se deja de pulsar una de las direcciones (izda o derecha)
			if (!mInAir)
			{
				if (Math.abs(mXmov) > minXmov)
				{
					PlayAnimation("Slide");
				}
				else
				{
					PlayAnimation("Idle");
				}
			}
		}
		
		private function Stop():void
		{
			PlayAnimation("Idle");
		}
		
		private function Jump():void
		{
			if (Math.abs(mXmov) > runXmov)
				PlayAnimation("RunJump");
			else
				PlayAnimation("StillJump");
		}
		
		private function Fall():void
		{
			if (Math.abs(mXmov) > runXmov)
				PlayAnimation("RunFalling");
			else
				PlayAnimation("StillFalling");
		}
		
		private function StopJumping():void
		{
			
			if (Math.abs(mXmov) > runXmov && mJoystickH != 0)
				PlayAnimation("Run");
			else if (mJoystickH != 0)
				PlayAnimation("Walk");
			else if (Math.abs(mXmov) > minXmov && mJoystickH == 0)
				PlayAnimation("Slide");
			else if (mJoystickH == 0)
				PlayAnimation("Idle");
		}
		
		// Animaciones
		
		private function PlayAnimation(animation:String):void
		{
			switch (mCurrentAnimation)
			{
				case "Idle":
					switch (animation)
					{
						case "Walk":
							mCurrentAnimation = "Walk";
							TheVisualObject.gotoAndPlay("Walk");
						break;
						case "StillJump":
							mCurrentAnimation = "StillJump";
							TheVisualObject.gotoAndPlay("StillJump");
						break;
					}
				break;
				case "Walk":
					switch (animation)
					{
						case "Idle":
							mCurrentAnimation = "Idle";
							TheVisualObject.gotoAndPlay("Idle");
						break;
						case "Run":
							//mNextAnimation = "WalkEnd";
						break;
						case "Turn":
							mCurrentAnimation = "Turn";
							TheVisualObject.gotoAndPlay("Turn");
						break;
						case "StillJump":
							mCurrentAnimation = "StillJump";
							TheVisualObject.gotoAndPlay("StillJump");
						break;
						case "RunJump":
							mCurrentAnimation = "RunJump";
							TheVisualObject.gotoAndPlay("RunJump");
						break;							
					}
				break;
				case "Run":
					switch (animation)
					{
						case "Idle":
							mCurrentAnimation = "Idle";
							TheVisualObject.gotoAndPlay("Idle");
						break;
						case "Slide":
							mCurrentAnimation = "Slide";
							TheVisualObject.gotoAndPlay("Slide");
						break;
						case "Turn":
							mCurrentAnimation = "Turn";
							TheVisualObject.gotoAndPlay("Turn");
						break;
						case "RunJump":
							mCurrentAnimation = "RunJump";
							TheVisualObject.gotoAndPlay("RunJump");
						break;
					}
				break;
				case "Turn":
					switch (animation)
					{				
						case "RunJump":
							mCurrentAnimation = "RunJump";
							TheVisualObject.gotoAndPlay("RunJump");
						break;
						case "StillJump":
							mCurrentAnimation = "StillJump";
							TheVisualObject.gotoAndPlay("StillJump");
						break;
					}
				break;
				case "Slide":
					switch (animation)
					{
						case "Idle":
							mCurrentAnimation = "Idle";
							TheVisualObject.gotoAndPlay("Idle");							
						break;
						case "Walk":
							mCurrentAnimation = "Walk";
							TheVisualObject.gotoAndPlay("Walk");
						break;
						case "Run":
							mCurrentAnimation = "Run";
							TheVisualObject.gotoAndPlay("Run");
						break;
						case "RunJump":
							mCurrentAnimation = "RunJump";
							TheVisualObject.gotoAndPlay("RunJump");
						break;
						case "StillJump":
							mCurrentAnimation = "StillJump";
							TheVisualObject.gotoAndPlay("StillJump");
						break;
					}					
				break;
				case "StillJump":
					switch (animation)
					{
						case "StillFalling":
							mCurrentAnimation = "StillFalling";
							TheVisualObject.gotoAndPlay("StillFalling");
						break;
						case "RunFalling":
							mCurrentAnimation = "StillFalling";
							TheVisualObject.gotoAndPlay("StillFalling");
						break;
					}
				break;
				case "StillFalling":
					switch (animation)
					{
						case "Idle":
							mCurrentAnimation = "Idle";
							TheVisualObject.gotoAndPlay("Idle");
						break;
						case "Walk":
							mCurrentAnimation = "Walk";
							TheVisualObject.gotoAndPlay("Walk");
						break;
						case "Run":
							mCurrentAnimation = "Run";
							TheVisualObject.gotoAndPlay("Run");
						break;
						case "Slide":
							mCurrentAnimation = "Slide";
							TheVisualObject.gotoAndPlay("Slide");
						break;
						case "Turn":
							mCurrentAnimation = "Turn";
							TheVisualObject.gotoAndPlay("Turn");
						break;												
					}
				break;
				case "RunJump":
					switch (animation)
					{
						case "RunFalling":
							mCurrentAnimation = "RunFalling";
							TheVisualObject.gotoAndPlay("RunFalling");
						break;
						case "StillFalling":
							mCurrentAnimation = "RunFalling";
							TheVisualObject.gotoAndPlay("RunFalling");
						break;					}
				break;
				case "RunFalling":
					switch (animation)
					{
						case "Idle":
							mCurrentAnimation = "Idle";
							TheVisualObject.gotoAndPlay("Idle");
						break;
						case "Walk":
							mCurrentAnimation = "Walk";
							TheVisualObject.gotoAndPlay("Walk");
						break;
						case "Run":
							mCurrentAnimation = "Run";
							TheVisualObject.gotoAndPlay("Run");
						break;
						case "Slide":
							mCurrentAnimation = "Slide";
							TheVisualObject.gotoAndPlay("Slide");
						break;
						case "Turn":
							mCurrentAnimation = "Turn";
							TheVisualObject.gotoAndPlay("Turn");
						break;						
					}
				break;
			}
		}
		
		// Callbacks de las animaciones
		
		private function OnWalkEnd():void
		{
			mCurrentAnimation = "Run";
			TheVisualObject.gotoAndPlay("Run");
		}
		
		private function OnTurnEnd():void
		{
			mCurrentAnimation = "Run";
			TheVisualObject.gotoAndPlay("Run");
		}
		
		// Variables privadas
		
		private var mInAir : Boolean;
		private var mOkToJump : Boolean = true;
		private var mWalkIncrement : Number = 0;
		private var mXmov : Number = 0;
		private var mYmov : Number = 0;
		private var mLastHeading : Number = 0;
		private var mTempX : Number = 0;
		private var mTempY : Number = 0;
		private var mTotalIterations : Number = 1;
		private var mJoystickH : Number = 0;
		private var mOnPlatform : Boolean = false;
		private var mPlatformList : Array;
		// Estados
		private var mIsCrouching : Boolean;
		private var mIsWalking : Boolean;
		private var mIsRunning : Boolean;
		private var mIsSliding : Boolean;
		private var mIsJumping :Boolean = false;
		private var mIsFalling : Boolean = false;
		// Estado de las animaciones
		private var mCurrentAnimation : String;
		private var mOldAnimation : String;
		private var mNextAnimation : String;
	}

}