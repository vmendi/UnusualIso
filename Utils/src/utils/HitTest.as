/*
 * Adventures In Actionscript AS3 Toolkit
 * Copyright (C) 2008 www.adventuresinactionscript.com
 * 
 * If you use this code in your own projects, please give credit to
 * the authors and feel free to let them know about your projects that
 * make use of this. You are not authorized to distribute modified
 * copies of this code, without first contacting all the authors and
 * obtaining their permission. You may however modified and use this 
 * code in your own compiled projects without permission. Do not remove
 * or modify this header in anyway.
 *
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 */
 
package utils {

	/**
	* A replacement collision detection class
	* @author The Actionscript Man (theactionscriptman [at] gmail.com)
	* @version 1.0.0
	*/
	public class HitTest
	{
		import flash.display.DisplayObject;
		import flash.display.BitmapData;
		import flash.geom.ColorTransform;
		import flash.geom.Matrix;
		import flash.geom.Rectangle;
		
		/**
		 * hitTestObject checks to see if two display objects have collided from 
		 * http://www.adventuresinactionscript.com/blog/15-03-2008/actionscript-3-hittestobject-and-pixel-perfect-collision-detection
		 * Based on Grant Skinner & Troy Gilberts collision detection functions
		 *
		 * @param  object1      the first object to be tested
		 * @param  object2      the second object to be tested
		 * @param  pixelPerfect check bounding rectangle only if set to false
		 * @param  tolerance    alpha tolerance value
		 * @return intersecting rectangle if the objects have collided, or null if no collision
		 * @see         HitTestObject
		 */	
		static public function HitTestObject(object1:DisplayObject, object2:DisplayObject, pixelPerfect:Boolean=true, tolerance:int = 255):Rectangle
		{
			// quickly rule out anything that isn't in our hitregion
			if (object1.hitTestObject(object2))
			{			
				// get bounds:
				var bounds1:Rectangle = object1.getBounds(object1.parent);
				var bounds2:Rectangle = object2.getBounds(object2.parent);
							
				// determine test area boundaries:
				var bounds:Rectangle = bounds1.intersection(bounds2);
				bounds.x = Math.floor(bounds.x);
				bounds.y = Math.floor(bounds.y);
				bounds.width = Math.ceil(bounds.width);
				bounds.height = Math.ceil(bounds.height);
						
				//ignore collisions smaller than 1 pixel
				if ((bounds.width < 1) || (bounds.height < 1))
					return null;
					
				if (!pixelPerfect)
					return bounds;
			
				// set up the image to use:
				var img:BitmapData = new BitmapData(bounds.width, bounds.height, false);
				
				// draw in the first image:
				var mat:Matrix = object1.transform.concatenatedMatrix;
				mat.translate( -bounds.left, -bounds.top);
				img.draw(object1,mat, new ColorTransform(1,1,1,1,255,-255,-255,tolerance));
								
				// overlay the second image:
				mat = object2.transform.concatenatedMatrix;
				mat.translate( -bounds.left, -bounds.top);
				img.draw(object2,mat, new ColorTransform(1,1,1,1,255,255,255,tolerance),"difference");
				
				// find the intersection:
				var intersection:Rectangle = img.getColorBoundsRect(0xFFFFFFFF,0xFF00FFFF);
				
				// if there is no intersection, return null:
				if (intersection.width == 0) { return null; }
				
				// adjust the intersection to account for the bounds:
				intersection.offset(bounds.left, bounds.top);
				
				return intersection; 
			}
			else
				return null;
		}		
		
	}
}
