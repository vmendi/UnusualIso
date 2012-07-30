package GameComponents.TeleRecicla
{
	
	import GameComponents.GameComponent;
	
	import Model.UpdateEvent;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import utils.MovieClipLabels;
	import utils.RandUtils;

	public class CaminosGame extends GameComponent
	{
		
		public var TiempoPartida : int = 60000;
		public var PuntosMaxTurno : int = 10000;
		
		override public function OnStart() : void
		{
			MovieClipLabels.AddFrameScripts(FRAME_SCRIPTS, TheVisualObject.mcResultado);
			StartGame();
		}

		override public function OnStop() : void
		{
			TheVisualObject.stage.removeEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			TheVisualObject.stage.removeEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
			TheVisualObject.stage.removeEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
		}
		
		override public function OnUpdate(event:UpdateEvent):void
		{
			if (!mPlaying)
				return;
			
			// Control del tiempo de la partida
			var tTotalTime : int = getTimer() - mInitTime;
			if (tTotalTime > TiempoPartida)
			{
				StopGame();
			}
			else
			{
				TheVisualObject.mcReloj.ctPuntos.text = ConvertTimeToString(TiempoPartida - tTotalTime);
			}
			
			// Animación
			
			if (!mDoAnim)
				return;
				
			var tTotalWidth : Number = (mLevel.n_cols - 1) * mSeparacionColumnas;
			var tStartX : Number = -tTotalWidth/2;
			var tStartY : Number = -mAltoColumnas/2;
			var tUltimoNodo : Boolean = false;
			var tActualPos : Point = new Point(TheVisualObject.mcObjeto.x, TheVisualObject.mcObjeto.y);
			// Cálculo del siguiente punto de destino
			var tDestino : Point = new Point();
			tDestino.x = tStartX + (mCamino[mCaminoStep].col * mSeparacionColumnas);
			tDestino.y = tStartY + mCamino[mCaminoStep].y;
			// Cálculo de la siguiente posición
			var tVel : Point = tDestino.subtract(tActualPos);
			tVel.normalize(mCaminoVel);
			var tNewPos : Point = tActualPos.add(tVel);
			// Vemos si ha llegado
			var tDistancia : Number = Point.distance(tNewPos, tDestino);
			if (tDistancia < mCaminoVel)
			{
				tNewPos.x = tDestino.x;
				tNewPos.y = tDestino.y;
				if (mCaminoStep == mCamino.length-1)
				{
					mDoAnim = false;
					TheVisualObject.mcObjeto.scaleX = TheVisualObject.mcObjeto.scaleY = 0.5;
				}
				else
				{
					mCaminoStep++;
				}
			}
			// Ponemos el objeto en posición
			TheVisualObject.mcObjeto.x = tNewPos.x;
			TheVisualObject.mcObjeto.y = tNewPos.y;
			
			if (!mDoAnim)
			{
				var tFrame : String = (mLastResult) ? "Acierto" : "Error";
				TheVisualObject.mcResultado.gotoAndPlay(tFrame);
				TheVisualObject.mcPuntos.ctPuntos.text = mPuntos;
			}
		}
		
		// Control del juego

		public function StartGame() : void
		{
			mLevelNumber = 0;
			mPuntos = 0;
			mInitTime = getTimer();
			mPlaying = true;
			
			PlayLevel();
		}

		public function StopGame() : void
		{
			mDoAnim = false;
			mPlaying = false;
			TheVisualObject.stage.removeEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			TheVisualObject.stage.removeEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
			TheVisualObject.stage.removeEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
			if (mLevelNumber >= GameRules.RULES.length-1)
				TheGameModel.FindGameComponentByShortName("CaminosInterface").GotoFinExito(null);
			else
				TheGameModel.FindGameComponentByShortName("CaminosInterface").GotoFin(null);
		}

		public function GetFinalScore() : Number
		{
			return mPuntos;
		}
		
		public function PlayLevel() : void
		{
			mLastTime = getTimer();
			SetRenderingEnabled(true);
			mLevel = GetLevel(GameRules.RULES[mLevelNumber]);
			DrawLevel(mLevel);
		}
		
		public function ResolveLevel() : void
		{
			var tTotalWidth : Number = (mLevel.n_cols - 1) * mSeparacionColumnas;
			var tStartX : Number = -tTotalWidth/2;
			var tStartY : Number = -mAltoColumnas/2;
			var tCol1X : Number;
			var tCol2X : Number;
						
			// Si el trazo se ha hecho de derecha a izquierda, cambiamos el orden de los puntos
			if (mEndPoint.x < mStartPoint.x)
			{
				var tPoint : Point = mStartPoint;
				mStartPoint = mEndPoint;
				mEndPoint = tPoint;
			}
			
			
			// Encuentra las dos columnas con las que primero se cruza
			var tCol1 : Number = -1;
			var tCol2 : Number = -1;
						
			// Primera Columna
			for ( var i : Number = 0; i < mLevel.n_cols; i++)
			{
				tCol1X = tStartX + (i * mSeparacionColumnas);
				if (mStartPoint.x-20 <= tCol1X)
				{
					tCol1 = i;
					break;
				}
					
			}
			// Segunda Columna
			if (tCol1+1 < mLevel.n_cols)
			{
				for ( i = tCol1+1; i < mLevel.n_cols; i++)
				{
					tCol2X = tStartX + (i * mSeparacionColumnas);
					if (mEndPoint.x+20 >= tCol2X)
					{
						tCol2 = i;
						break;
					}
				}
			}
			
			// Si hemos cortado legalmente dos columnas, creamos el nuevo enlace
			if (tCol1 != -1 && tCol2 != -1)
			{
				// Calculamos las coords Y en los puntos de corte
				var tM : Number = ( (mEndPoint.y-mStartPoint.y) / (mEndPoint.x-mStartPoint.x) );
				var x1 : Number = tCol1X;
				var x2 : Number = tCol2X;
				var y1 : Number = ( tM*(x1-mStartPoint.x) ) + mStartPoint.y;
				var y2 : Number = ( tM*(x2-mStartPoint.x) ) + mStartPoint.y;
				// Dibujamos la línea
				TheVisualObject.mcEnlaces.graphics.lineStyle(10, 0x595859, 100, true, "none", "round", "miter", 1);
				TheVisualObject.mcEnlaces.graphics.moveTo(x1,y1);
				TheVisualObject.mcEnlaces.graphics.lineTo(x2,y2);
				// Añadimos el nuevo enlace a la lista
				var tEnlace : Object = {c1: tCol1, c2: tCol2, y1: y1-tStartY, y2: y2-tStartY};
				mLevel.enlaces.push(tEnlace);
			}
			// Resuelve el nivel
			mCamino = TestLevel(mLevel);
			var tColFinal : Number = mCamino[mCamino.length-1].col;
			mLastResult = (tColFinal == mLevel.cf) ? true : false;
			mCaminoStep = 0;
			// Calculamos los puntos
			var tTurnoTime : int = getTimer() - mLastTime;
			var tPuntos : Number = (PuntosMaxTurno > tTurnoTime) ? PuntosMaxTurno-tTurnoTime+100 : 100;
			mPuntos += (mLastResult) ? tPuntos : 0;
			mLevelNumber++;
			if (mLevelNumber > GameRules.RULES.length-1)
				mLevelNumber = GameRules.RULES.length-1;
			mDoAnim = true;
		}
		
		public function EndLevel() : void
		{
			// Si éxito seguimos.
			// Si fracaso pero vidas seguimos
			// Si fracaso y no vidas, a GameOver.
		}
		
		// Dibujo
		
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
		
		private function OnMouseMove(event:MouseEvent):void
		{
			if (!event.buttonDown)
				mCapturing = false;
							
			if (!mCapturing)
				return;
				
			TheVisualObject.mcCanvas.graphics.lineTo(TheVisualObject.mouseX, TheVisualObject.mouseY);
		}	
		
		private function OnMouseDown(event:MouseEvent):void
		{
			StartTrail();
		}
		
		private function OnMouseUp(event:MouseEvent):void
		{
			EndTrail();
		}
		
		private function StartTrail():void
		{
			mCapturing = true;
			mStartPoint = new Point(TheVisualObject.mouseX, TheVisualObject.mouseY);
			
			TheVisualObject.mcCanvas.graphics.clear();
			TheVisualObject.mcCanvas.graphics.lineStyle(10, 0x595859, 100, true, "none", "round", "miter", 1);
			TheVisualObject.mcCanvas.graphics.moveTo(TheVisualObject.mouseX, TheVisualObject.mouseY);
		}
		
		private function EndTrail():void
		{
			if (!mCapturing)
				return;
			
			SetRenderingEnabled(false);
			mEndPoint = new Point(TheVisualObject.mouseX, TheVisualObject.mouseY);
			mCapturing = false;
			TheVisualObject.mcCanvas.graphics.clear();
			ResolveLevel();
		}
		
		// Control de los niveles
		
		private function GetLevel(rules:Object) : Object
		{
			// Creares 
			var nivel : Object = new Object();
			nivel.n_cols = rules.n_cols;
			nivel.ci = RandUtils.RandInt(nivel.n_cols-1); // Columna de salida
			nivel.enlaces = new Array();
			// Lista de enlaces entre columnas, según las reglas
			var tNumeroEnlaces : Number = RandUtils.RandIntBetween(rules.nMaxEnlaces, rules.nMinEnlaces);
			var tEspacioEnlaces : Number = (mAltoColumnas-20) * rules.distribucion / 100;
			var tSeparacionEnlaces : Number = tEspacioEnlaces/tNumeroEnlaces;
			var tEnlacesComienzoY : Number = mAltoColumnas - 10 - tEspacioEnlaces;
			var tEnlace : Object = new Object();
			var tSentidoEnlace : Number;
			
			// Calcula los enlaces al azar entre las columnas
			for (var i : Number = 0; i < tNumeroEnlaces; i++)
			{
				tEnlace = new Object();
				if (i==0){
					// El primer enlace incluye la columna de salida. En caso de qe sea la última columna, hacemos que comience en la anterior  
					if (nivel.ci == nivel.n_cols-1)
						tEnlace.c1 = nivel.ci-1;
					else
						tEnlace.c1 = nivel.ci;
				} else {
					tEnlace.c1 = RandUtils.RandInt(rules.n_cols-2);
				}
				tEnlace.c2 = tEnlace.c1 + 1;
				tEnlace.y1 = tEnlace.y2 = tEnlacesComienzoY + (i*tSeparacionEnlaces) + RandUtils.RandInt(tSeparacionEnlaces);
				nivel.enlaces.push(tEnlace);
			}
			
			// Recorremos el nivel para ver cual es la columna de salida
			var tResultado : Array = TestLevel(nivel);
			var tColFinal : Number = tResultado[tResultado.length-1].col;
			nivel.cf = tColFinal;
			// Quitamos uno de los enlaces: será el que el usuario tiene que completar
			nivel.enlaces.splice(RandUtils.RandInt(nivel.enlaces.length-1),1); 
			tResultado = TestLevel(nivel);
			return nivel;
		}
		
		// Juega la partida de un nivel y determina cual es la columna de llegada
		private function TestLevel(level:Object) : Array
		{
			var tCamino : Array = new Array();
			var tCol : Number = level.ci;
			var tY : Number = 0;
			tCamino.push({col: tCol, y: tY});
			var tFin : Boolean = false;
			var tDistancia : Number;
			var tEnlaceEncontrado : Boolean;
			var tNodoA : Object;
			var tNodoB : Object;
			var tNewCol : Number;
			var tNewY : Number;
			
			do
			{			
				tDistancia = mAltoColumnas*2;
				tEnlaceEncontrado = false;
				for (var i : Number = 0; i < level.enlaces.length; i++)
				{
					if (level.enlaces[i].c1 == tCol && level.enlaces[i].y1 > tY && level.enlaces[i].y1 - tY < tDistancia)
					{
						tDistancia = level.enlaces[i].y1 - tY;
						tEnlaceEncontrado = true;
						tNewCol = level.enlaces[i].c2;
						tNewY = level.enlaces[i].y2;
						tNodoA = {col: tCol, y: level.enlaces[i].y1};
						tNodoB = {col: tNewCol, y: tNewY};
					}
					else if (level.enlaces[i].c2 == tCol && level.enlaces[i].y2 > tY && level.enlaces[i].y2 - tY < tDistancia)
					{
						tDistancia = level.enlaces[i].y2 - tY;
						tEnlaceEncontrado = true;
						tNewCol = level.enlaces[i].c1;
						tNewY = level.enlaces[i].y1;
						tNodoA = {col: tCol, y: level.enlaces[i].y2};
						tNodoB = {col: tNewCol, y: tNewY};
					}
				}
				
				if (tEnlaceEncontrado)
				{
					tCol = tNewCol;
					tY = tNewY;
					tCamino.push(tNodoA);
					tCamino.push(tNodoB);
				}
				else
				{
					var tNodoFinal : Object = {col: tCamino[tCamino.length-1].col, y: mAltoColumnas+50};
					tCamino.push(tNodoFinal)
					tFin = true;
				}
				
			} while (!tFin)	
			
			return tCamino;
		}
		
		private function DrawLevel(level:Object) : void
		{
			TheVisualObject.mcEnlaces.graphics.clear();
			TheVisualObject.mcEnlaces.graphics.lineStyle(10, 0x595859, 100, true, "none", "round", "miter", 1);
			
			// Si hay cintas, las borramos
			if (mListaColumnas.length > 0)
			{
				for (var i:int = 0; i < mListaColumnas.length; i++)
				{
					TheVisualObject.mcCintas.removeChild(mListaColumnas[i]);
					mListaColumnas[i] = null;
				}
			}
			
			// Selección del color de la fase
			var tColores : Array = ["Amarillo", "Azul", "Gris"];
			var tQueColor : Number = RandUtils.RandInt(tColores.length-1);
			var tColor : String = tColores[tQueColor];
			//trace("Color elegido: " + tColor);
			//trace("Colores: " + tColores.toString());
			tColores.splice(tQueColor,1);
			//trace("Colores: " + tColores.toString());
			
			// Columnas verticales
			mListaColumnas = new Array();
			var tTotalWidth : Number = (level.n_cols - 1) * mSeparacionColumnas;
			var tStartX : Number = -tTotalWidth/2;
			var tStartY : Number = -mAltoColumnas/2;
			
			for (i = 0; i < level.n_cols; i++)
			{
				mListaColumnas[i] = TheGameModel.TheAssetLibrary.CreateMovieClip("mcCinta");
				TheVisualObject.mcCintas.addChild(mListaColumnas[i]);
				mListaColumnas[i].x = tStartX + (i * mSeparacionColumnas) ;
				mListaColumnas[i].y = tStartY;
				// Colocación del contenedor adecuado
				if (i == level.cf)
				{
					mListaColumnas[i].mcContenedor.gotoAndStop(tColor);
				}
				else
				{
					mListaColumnas[i].mcContenedor.gotoAndStop(tColores[RandUtils.RandInt(tColores.length-1)]);
				}	
			}

			for (i = 0; i < level.enlaces.length; i++)
			{
				TheVisualObject.mcEnlaces.graphics.moveTo(tStartX + (mSeparacionColumnas * level.enlaces[i].c1) , tStartY + level.enlaces[i].y1);
				TheVisualObject.mcEnlaces.graphics.lineTo(tStartX + (mSeparacionColumnas * level.enlaces[i].c2) , tStartY + level.enlaces[i].y2);
			}
			
			// Colocamos los objetos
			TheVisualObject.mcObjeto.scaleX = TheVisualObject.mcObjeto.scaleY = 1;
			TheVisualObject.mcObjeto.x = tStartX + ( level.ci * mSeparacionColumnas);
			TheVisualObject.mcObjeto.y = tStartY;
			TheVisualObject.mcObjeto.gotoAndStop(tColor);
			/*
			TheVisualObject.mcContenedor.x = tStartX + ( level.cf * mSeparacionColumnas);
			TheVisualObject.mcContenedor.y = tStartY + mAltoColumnas + 30;
			*/
		}
		
		private function OnAciertoEndFrame() : void
		{
			TheVisualObject.mcResultado.gotoAndStop("Stop");
			PlayLevel();
		}
		
		private function OnErrorEndFrame() : void
		{
			TheVisualObject.mcResultado.gotoAndStop("Stop");
			PlayLevel();
		}
		
		private function ConvertTimeToString(milisecs:Number):String
		{
			var totalSeconds : Number = milisecs/1000;
			var minutes : Number = Math.floor(totalSeconds / 60);
			var seconds : Number = Math.floor(totalSeconds % 60);

			var secondsStr : String = seconds < 10? "0"+seconds.toString() : seconds.toString();

			return minutes.toString() + ":" + secondsStr;
		}
								
		// Variables
	
		private var mCapturing : Boolean;
		private var mAltoColumnas : Number = 318;
		private var mSeparacionColumnas : Number = 85;
		private var mLevel : Object; // Nivel que estamos jugando
		private var mLevelNumber : Number; // Contador de niveles 
		private var mPuntos : Number; // Puntos conseguidos en una partida
		private var mDoAnim : Boolean = false; // Flag que indica si hacemos la animación
		private var mListaColumnas : Array = new Array(); // Guardará las columnas gráficas
		private var mCamino: Array; // Array de puntos que tendrá que recorrer el objeto para llegar al final
		private var mCaminoStep : Number; // Punto del camino en el que se encuentra el objeto
		private var mCaminoVel : Number = 10; // Velocidad con la que recorre el camino
		private var mLastResult : Boolean;
		private var mStartPoint : Point;
		private var mEndPoint : Point;
		private var mColList : Array;
		private var mLastTime : int = 0;
		private var mInitTime : int = 0;
		private var mPlaying : Boolean;
		
		private const FRAME_SCRIPTS : Array = [ {label: "AciertoEnd", func: OnAciertoEndFrame},
												{label: "ErrorEnd", func: OnErrorEndFrame}
											  ]	
	}

}

// REGLAS DE LAS FASES
internal class GameRules
{
	
	// n_cols: 3 -> Número de columnas
	// nMinEnlaces: 2 -> Número mínimo de enlaces
	// nMaxEnlaces: 3 -> Número máximo de enlaces
	// distribucion: 50 -> Distribución de los enlaces en el espacio de la columna, en porcentaje, comenzando por arriba.
	
	// Fácil
	public static const RULES : Array = [  {n_cols: 3, nMinEnlaces: 2, nMaxEnlaces: 2, distribucion: 50},
											{n_cols: 3, nMinEnlaces: 2, nMaxEnlaces: 2, distribucion: 50},
											{n_cols: 3, nMinEnlaces: 2, nMaxEnlaces: 2, distribucion: 50},
	
											{n_cols: 3, nMinEnlaces: 3, nMaxEnlaces: 3, distribucion: 60},
											{n_cols: 3, nMinEnlaces: 3, nMaxEnlaces: 3, distribucion: 60},
											
											{n_cols: 4, nMinEnlaces: 4, nMaxEnlaces: 4, distribucion: 60},
											
											{n_cols: 4, nMinEnlaces: 4, nMaxEnlaces: 4, distribucion: 70},
											{n_cols: 4, nMinEnlaces: 4, nMaxEnlaces: 4, distribucion: 70},
											{n_cols: 4, nMinEnlaces: 4, nMaxEnlaces: 5, distribucion: 70},
  								 		 	{n_cols: 4, nMinEnlaces: 4, nMaxEnlaces: 5, distribucion: 70},
  											{n_cols: 4, nMinEnlaces: 5, nMaxEnlaces: 6, distribucion: 70},
  											
  											{n_cols: 5, nMinEnlaces: 5, nMaxEnlaces: 6, distribucion: 80},
  											{n_cols: 5, nMinEnlaces: 5, nMaxEnlaces: 6, distribucion: 80},

											{n_cols: 5, nMinEnlaces: 6, nMaxEnlaces: 7, distribucion: 80},
											{n_cols: 5, nMinEnlaces: 6, nMaxEnlaces: 7, distribucion: 80},
											
											{n_cols: 5, nMinEnlaces: 6, nMaxEnlaces: 7, distribucion: 100},
											{n_cols: 5, nMinEnlaces: 7, nMaxEnlaces: 8, distribucion: 100},
											
											{n_cols: 6, nMinEnlaces: 8, nMaxEnlaces: 9, distribucion: 100},
											{n_cols: 6, nMinEnlaces: 10, nMaxEnlaces: 11, distribucion: 100}
      								 		 ];
          								 		 
}


