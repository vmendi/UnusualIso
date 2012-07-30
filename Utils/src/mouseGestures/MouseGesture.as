/**
*
*
*	MouseGesture
*	
*	@notice		Mouse Gesture Recognizer
*	@author		Didier Brun
*	@version	1.0
* 	@date		2007-05-17
* 	@link		http://www.bytearray.org/?p=91
* 
* 
*	Original author :
*	-----------------
*	Didier Brun aka Foxy
*	webmaster@foxaweb.com
*	http://www.foxaweb.com
*
* 	AUTHOR ******************************************************************************
* 
*	authorName : 	Didier Brun - www.foxaweb.com
* 	contribution : 	the original class
* 	date :			2007-01-18
* 
* 	VISIT www.byteArray.org
* 
*
*	LICENSE ******************************************************************************
* 
* 	This class is under RECIPROCAL PUBLIC LICENSE.
* 	http://www.opensource.org/licenses/rpl.php
* 
* 	Please, keep this header and the list of all authors
* 
*
*/

package mouseGestures {
	
	import flash.display.InteractiveObject;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;

	public class MouseGesture extends EventDispatcher {
		
		// ------------------------------------------------
		//
		// ---o static
		//
		// ------------------------------------------------

		public static const DEFAULT_NB_SECTORS:uint=8;		// Number of sectors
		public static const DEFAULT_TIME_STEP:uint=20;		// Capture interval in ms
		public static const DEFAULT_PRECISION:uint=8;		// Precision of catpure in pixels
		public static const DEFAULT_FIABILITY:uint=30;		// Default fiability level
		
		// ------------------------------------------------
		//
		// ---o properties
		//
		// ------------------------------------------------
		
		private var moves:Array;						// Mouse gestures
		private var lastPoint:Point;					// Last mouse point
		private var mouseZone:InteractiveObject;		// Mouse zone
		private var captureDepth:uint;					// Current capture depth 
		private var gestures:Array;						// Gestures to match
		private var rect:Object;						// Rectangle zone
		private var points:Array;						// Mouse points 
		private var captureStarted:Boolean;		// para controlar que ha comenzado la captura
	
		protected var timer:Timer;						// Timer
		protected var sectorRad:Number;					// Angle of one sector		
		protected var anglesMap:Array;					// Angles map 
		
		// ------------------------------------------------
		//
		// ---o constructor
		//
		// ------------------------------------------------

		function MouseGesture(pZone:InteractiveObject){
			
			// parametters
			mouseZone=pZone;
	
			// initialization
			init();
		}
		
		// ------------------------------------------------
		//
		// ---o public methods
		//
		// ------------------------------------------------
		
		/**
		*	Add a gesture
		*/
		public function addGesture(o:*,gesture:String,matchHandler:Function=null):void{
			var g:Array=[];
			for (var i:uint=0;i<gesture.length;i++){
				g.push(gesture.charAt(i)=="." ? -1 : parseInt(gesture.charAt(i),16));				
			}
			gestures.push({datas:o,moves:g,match:matchHandler});	
		}
								   
		
		// ------------------------------------------------
		//
		// ---o private methods
		//
		// ------------------------------------------------
		
		/**
		*	Initialisation
		*/
		protected function init():void{
			
			// Build the angles map
			buildAnglesMap();
			
			// Timer
			timer=new Timer(DEFAULT_TIME_STEP);
			timer.addEventListener(TimerEvent.TIMER,captureHandler,false,0,true);
				
			// Gesture Spots
			gestures=[];
			
			// Tenemos que controlar que ha comenzado la captura, porque or alguna razón en el editor se llama antes a stopCapture que a startCapture
			captureStarted = false;
								
			// Mouse Events
			mouseZone.addEventListener(MouseEvent.MOUSE_DOWN,startCapture,false,0,true);
			mouseZone.addEventListener(MouseEvent.MOUSE_UP,stopCapture,false,0,true);			
		}
		
		public function ForceStopCapture() : void
		{
			DoStopCapture();
		}
		
		/**
		*	Build the angles map
		*/
		protected function buildAnglesMap():void{
			
			// Angle of one sector
			sectorRad=Math.PI*2/DEFAULT_NB_SECTORS;
			
			// map containing sectors no from 0 to PI*2
			anglesMap=[];
			
			// the precision is Math.PI*2/100
			var step:Number=Math.PI*2/100;
						
			// memorize sectors
			var sector:Number;
			for (var i:Number=-sectorRad/2;i<=Math.PI*2-sectorRad/2;i+=step){
				sector=Math.floor((i+sectorRad/2)/sectorRad);
				anglesMap.push(sector);
			}
		}
		
		/**
		*	Time Handler
		*/
		protected function captureHandler(e:TimerEvent):void{
			
			// calcul dif 
			var msx:int=mouseZone.mouseX;
			var msy:int=mouseZone.mouseY;
			
			var difx:int=msx-lastPoint.x;
			var dify:int=msy-lastPoint.y;
			var sqDist:Number=difx*difx+dify*dify;
			var sqPrec:Number=DEFAULT_PRECISION*DEFAULT_PRECISION;
					
			if (sqDist>sqPrec){
				points.push(new Point(msx,msy));
				addMove(difx,dify);
				lastPoint.x=msx;
				lastPoint.y=msy;
				
				if (msx<rect.minx)rect.minx=msx;
				if (msx>rect.maxx)rect.maxx=msx;
				if (msy<rect.miny)rect.miny=msy;
				if (msy>rect.maxy)rect.maxy=msy;
			}
			
			// event
			dispatchEvent (new GestureEvent(GestureEvent.CAPTURING));
			
		}
		
		/**
		*	Add a move 
		*/
		protected function addMove(dx:int,dy:int):void{
			var angle:Number=Math.atan2(dy,dx)+sectorRad/2;
			if (angle<0)angle+=Math.PI*2;
			var no:int=Math.floor(angle/(Math.PI*2)*100);
			moves.push(anglesMap[no]);
		}
		
		/**
		*	Start the capture phase
		*/
		protected function startCapture(e:MouseEvent):void{
			
			// moves
			moves=[];
			points=[];
			rect={	minx:Number.POSITIVE_INFINITY,
					maxx:Number.NEGATIVE_INFINITY,
					miny:Number.POSITIVE_INFINITY,
					maxy:Number.NEGATIVE_INFINITY};
			
			// Control
			captureStarted = true;
	
			// event
			dispatchEvent(new GestureEvent(GestureEvent.START_CAPTURE))
			
			// last point
			lastPoint=new Point(mouseZone.mouseX,mouseZone.mouseY);
			
			// start the timer
			timer.start();
		}
		
		/**
		*	Stop the capture phase
		*/
		protected function stopCapture(e:MouseEvent) : void
		{
			DoStopCapture();
		}
		
		protected function DoStopCapture() : void
		{
			if (captureStarted)
			{
				// match 
				matchGesture();
				// event
				dispatchEvent(new GestureEvent(GestureEvent.STOP_CAPTURE))
				// stop the timer
				timer.stop();
			}
			captureStarted = false;
		}
		
		/**
		*	Match the gesture
		*/
		protected function matchGesture():void
		{
			var bestCost:uint=1000000;
			var nbGestures:uint=gestures.length;
			var cost:uint;
			var gest:Array;
			var bestGesture:Object=null;
			var infos:Object={	points:points,
								moves:moves,
								lastPoint:lastPoint,
								rect:new Rectangle(	rect.minx,
													rect.miny,
													rect.maxx-rect.minx,
													rect.maxy-rect.miny) };
			
			for (var i:uint=0;i<nbGestures;i++)
			{
				gest=gestures[i].moves;
				infos.datas=gestures[i].datas;
				cost=costLeven(gest,moves);
				
				if (cost<=DEFAULT_FIABILITY){
					if (gestures[i].match!=null){
						infos.cost=cost;
						cost=gestures[i].match(infos);
					}
					if (cost<bestCost){
						bestCost=cost;
						bestGesture=gestures[i];
					}
				}
				
			}
			
			if (bestGesture!=null){
				var evt:GestureEvent=new GestureEvent(GestureEvent.GESTURE_MATCH);
				evt.datas=bestGesture.datas;
				evt.fiability=bestCost;
				dispatchEvent(evt);
			}else{
				dispatchEvent(new GestureEvent(GestureEvent.NO_MATCH));
			}
			
		}
				
		/**
		*	dif angle
		*/
		protected function difAngle(a:uint,b:uint):uint{
			var dif:uint=Math.abs(a-b);
			if (dif>DEFAULT_NB_SECTORS/2)dif=DEFAULT_NB_SECTORS-dif;
			return dif;
		}
		
		/**
		*	return a filled 2D table
		*/
		protected function fill2DTable(w:uint,h:uint,f:*):Array{
			var o:Array=new Array(w);
			for (var x:uint=0;x<w;x++){
				o[x]=new Array(h);
				for (var y:uint=0;y<h;y++)o[x][y]=f;
			}
			return o;
		}
		
		/**
		*	cost Levenshtein
		*/
		protected function costLeven(a:Array,b:Array) : uint
		{
			
			// point
			if (a[0]==-1){
				return b.length==0 ? 0 : 100000;
			}
			
			// precalc difangles
			var d : Array = fill2DTable(a.length+1,b.length+1,0);
			var w : Array = d.slice();
			
			for (var x:uint=1;x<=a.length;x++){
				for (var y:uint=1;y<b.length;y++){
					d[x][y]=difAngle(a[x-1],b[y-1]);
				}
			}
			
			// max cost
			for (y=1;y<=b.length;y++)w[0][y]=100000;
			for (x=1;x<=a.length;x++)w[x][0]=100000;
			w[0][0]=0;
			
			// levensthein application
			var cost:uint=0;
			var pa:uint;
			var pb:uint;
			var pc:uint;
			
			for (x=1;x<=a.length;x++){
				for (y=1;y<b.length;y++){
					cost=d[x][y];
					pa=w[x-1][y]+cost;
					pb=w[x][y-1]+cost;
					pc=w[x-1][y-1]+cost;
					w[x][y]=Math.min(Math.min(pa,pb),pc)
				}
			}
			
			return w[x-1][y-1];
		}
				
	}
}