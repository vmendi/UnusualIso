package GameComponents
{
	import Model.UpdateEvent;
	
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import utils.KeyboardHandler;
	import utils.Point3;	
	
	/**
	 * Componente para hacer que un objeto se comporte como vehículo.
	 */
	public final class Vehicle extends GameComponent
	{
		
		public var MaxBackSpeed : Number =  -5;
		public var MaxSpeed : Number = 15
		public var Acceleration : Number = 0.6;
		public var Deceleration : Number = 1;
		public var SpeedDecay : Number = 1.05;
		public var InitAngle : Number = 0;
		
		override public function OnStart() : void
		{

			TheGameModel.TheIsoCamera.CheckLimits = true;
			mAngle = InitAngle;
			
		}
		
		override public function OnPause():void
		{

		}
		
		override public function OnResume():void
		{
			
		}
		
		override public function OnStop():void
		{

		}

		override public function OnUpdate(event:UpdateEvent):void
		{
			// Teclas
			ListenForKeys();
			
			// Movimiento
			InterpolateMovement(event.ElapsedTime);
						
			// Centramos la camara en nosotros
			TheGameModel.TheIsoCamera.TargetPos = new Point(TheIsoComponent.WorldPos.x, TheIsoComponent.WorldPos.z);
			
			// Hacemos transparente el escenario
			TheGameModel.MakeTransparentOthers(TheIsoComponent);			
		}
		
		private function ListenForKeys():void
		{
			
			mSmoke = false;
			
			if ( KeyboardHandler.Keyb.IsKeyPressed(Keyboard.UP) && !mInAir)
			{
				mSpeed += Acceleration;
				if (mSpeed < 3)
					mSmoke = true;
			}
			else if ( KeyboardHandler.Keyb.IsKeyPressed(Keyboard.DOWN) && mSpeed > MaxBackSpeed && !mInAir)
			{
				mSpeed -= Deceleration;
			}
			else if (!mInAir)
			{
				mSpeed /= SpeedDecay;		
			}
			
			if (KeyboardHandler.Keyb.IsKeyPressed(Keyboard.LEFT))
			{
				mTurnDir = 40;
				mNewSteer = 100;
				mTiltDir = 1;
				if (mNewSlide < 15)
					mNewSlide += 0.2;
			}
			else if (KeyboardHandler.Keyb.IsKeyPressed(Keyboard.RIGHT))
			{
				mTurnDir = -40;
				mNewSteer = -100;
				mTiltDir = -1;
				if (mNewSlide < 15)
					mNewSlide += 0.2;
			}
			else
			{
				mTurnDir = 0;
				mNewSteer = 0;
				mTiltDir = 0;
				mNewSlide = 0;
				mSteer = 0;
			}
	
		}
		
		private function InterpolateMovement(elapsedTime : Number):void
		{
			var NewVx : Number;
			var NewVz : Number;
			var NewX : Number;
			var NewY : Number;
			var NewZ : Number;
			
			if (mSpeed > MaxSpeed)
				mSpeed = MaxSpeed;
			
			mTilt = mTilt + (((mTiltDir * (((mSpeed + 4) / 1.6) / 5)) - mTilt) / 3);
			mSlide = mSlide + ((mNewSlide - mSlide) / 10);
			mSteer = mSteer + ((mNewSteer - mSteer) / 10);
			mRotate = mSteer / 1000;
			
			// Ángulo
			mAngAdd = mRotate * mSpeed;
			if (mAngAdd > 0.5)
			{
				mAngAdd = 0.5;
				mT++;
			}
			else if (mAngAdd < -0.5)
			{
				mAngAdd = -0.5;
				mT++;
			}
			else
			{
				mT = 0;
			}
			
			mAngle = mAngle + mAngAdd;
			
			if (Math.round(mAngle) > 40)
			{
				mAngle = 1;
			}
			else if (Math.round(mAngle) < 1)
			{
				mAngle = 40;
			}
			
			if ( !mInAir && !mAuto )
			{
				NewVx = mSpeed * Math.sin(((Math.round(mAngle) * 9) + 135) * Math.PI/180);
				NewVz = -mSpeed * Math.cos(((Math.round(mAngle) * 9) + 135) * Math.PI/180);
				mVx = mVx + ((NewVx - mVx) / (mSlide + 1));
				mVz = mVz + ((NewVz - mVz) / (mSlide + 1));
			}
			mAuto = false;
			
			// TestColision();
			
			NewX = TheIsoComponent.WorldPos.x + (mVx/60);
			NewY = TheIsoComponent.WorldPos.y;
			NewZ = TheIsoComponent.WorldPos.z + (mVz/60);
			
			//calculaCuadro();

			Pinta(NewX, NewY, NewZ);			
			TheIsoComponent.WorldPos = new Point3(NewX,NewY,NewZ);
			TheVisualObject.car.body.gotoAndStop( ( Math.round(mAngle) + mIncline ) + mBank);
			TheVisualObject.car.wheels.gotoAndStop( ( Math.round(mAngle) + mIncline ) + mWheelsTurn);
			TheVisualObject.shadow.gotoAndStop( Math.round( mAngle + mShadowInc ) );
								
			/*
			calculaCuadro();
			_root["pinta" + cuadTipo[nCuad]]();
		
			// Transformación desde las coordenadas x,z del plano a la perspectiva y a coords de pantalla.
			Xpos = (z * sinY) + (x * cosY);
			Ypos = (y * cosX) - (((z * cosY) - (x * sinY)) / 2);
		
			// Representación de los elementos
			bg.bg._x = (-Xpos) * 0.95;
			bg.bg._y = (-Ypos) * 0.95;
			cocheClip.car._x = Xpos * 0.05;
			cocheClip.car._y = Ypos * 0.05;
			cocheClip.shadow._x = cocheClip.car._x;
			cocheClip.shadow._y = cocheClip.car._y + groundDis;
		
			cocheClip.car.BODY.gotoAndStop((int (angle) + incline) + Bank);
			cocheClip.car.WHEELS.gotoAndStop((int (angle) + incline) + WheelsTurn);
			cocheClip.shadow.gotoAndStop(int (angle + shadowInc));
		
			// Control del humo
			smkdelay++;
			if (smkdelay > 2) {
				smkdelay = 0;
				smk++;
				if (smk > 10) {
					smk = 1;
				}
			}
			
			// Derrape
			if ((t > 20) && (slide > 1) || (smoke == true)) {
				if (skid != false) {
					sound.gotoAndPlay(60);
					skid = false;
				}
				if (cuadHumo[nCuad]!=0){
					duplicateMovieClip (bg.bg.bg["sm_" + cuadHumo[nCuad]], "sm" + smk, smk);
					bg.bg.bg["sm" + smk]._x = (cocheClip.car._x - bg.bg._x - bg.bg.bg._x) + (30 * Math.sin((int (angle) * 9) * Math.PI/180));
					bg.bg.bg["sm" + smk]._y = (cocheClip.car._y - bg.bg._y - bg.bg.bg._y) + ((30 * Math.cos((int (angle) * 9) * Math.PI/180)) / 2);
					//bg.bg.bg["sm" + smk].sm.sm._rotation = int (random (360));
				}
			} else {
				skid = true;
			}
		
		    // Control de la máscara
			if (cuadEnmasc[nCuad] == true) {
				mask._x = bg.bg._x + bg._x;
				mask._y = bg.bg._y + bg._y;
				mask._visible = true;
			} else {
				mask._visible = false;
			}
		
			// Control de los waypoints y del navegador
			var coordx = Math.floor(id/18);
			var coordy = id%18;
			
			var DIFX = (WayPointsList[NumWayPoints]%18) - (nCuadroX);
			var DIFX = (Math.abs(DIFX)<2) ? 0 : (DIFX/Math.abs(DIFX));
			var DIFY = Math.floor(WayPointsList[NumWayPoints]/18) - (nCuadroZ);
			var DIFY = (Math.abs(DIFY)<2) ? 0 : (DIFY/Math.abs(DIFY));
		    	
			if ((DIFX==0) && (DIFY==0)){
				navegador.gotoAndStop("pto0");
			} else {
				navegador.gotoAndStop("pto"+DIFX+DIFY);
			}
			    
			if (WayPoints[nCuad] == NumWayPoints) {
				WayPointsClips[nCuad]._visible = false
				NumWayPoints++;
				if (NumWayPoints>=WayPointsList.length){
					finJuego();
				} else {
					WayPointsClips[WayPointsList[NumWayPoints]]._visible = true;
					setScoreBoard(NumWayPoints);
					waypointsound.start();
				}
			}
		
			// Control del tiempo
			if (ready == true) {
				time--;
				// Si se ha acabado el tiempo termina la partida.
				if (time==0)
					finJuego();
				// Línea de tiempo
				var donde = Math.floor(time*399/tiempoEtapa)+1;
				scoreboard.timer.gotoAndStop(donde);
			}
			*/
			
		}
		
		private function Pinta(x:Number, y:Number, z:Number):void
		{
			
			//floor = altoCuadrado * cuadNivel[nCuad];
			var floor : Number = 0;
			mShadowInc = 0;
			if (y >= floor) {
				mBank = Math.round(mTilt) * 40;
				mWheelsTurn = mTurnDir;
				y = floor;
				mVy = (-mVy) / 2;
				mGroundDis = 0;
				//TheVisualObject.car.gotoAndPlay(6);
				mIncline = 80;
				mInAir = false;
				/*
				if ((cuadCoordZ > 110) && (cuadTipo[nCuad+18] == 1) && (cuadNivel[nCuad] < cuadNivel[nCuad+18])) {
					z = z - 8;
					Vz = Vz - 5;
				}
				if ((cuadCoordX > 110) && (cuadTipo[nCuad+1] == 1) && (cuadNivel[nCuad] < cuadNivel[nCuad+1])) {
					x = x + 8;
					Vx = Vx + 5;
				}
				*/
			} else {
				mInAir = true;;
				mGroundDis = floor - y;
			}
			
		}
	
		private var mSmoke : Boolean = false;
		private var mInAir : Boolean = false;
		private var mSpeed : Number = 0;
		
		private var mTurnDir : Number = 0;
		private var mNewSteer : Number = 0;
		private var mTiltDir : Number = 1;
		private var mNewSlide : Number = 15;
		
		private var mSteer : Number = 0;
		private var mTilt : Number = 0;
		private var mSlide : Number = 0;
		private var mRotate : Number = 0;
		private var mAngAdd : Number = 0;
		private var mAngle : Number = 0;
		private var mT : Number = 0;
		private var mAuto : Boolean; // COMPROBAR
		private var mVx : Number = 0;
		private var mVz : Number = 0;
		private var mVy : Number = 0;
		
		private var mShadowInc : Number = 0;
		private var mBank : Number = 0;
		private var mWheelsTurn : Number = 0;
		private var mIncline : Number = 0;
		private var mGroundDis : Number = 0;
	}
}