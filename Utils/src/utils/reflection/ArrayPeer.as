/*
        Copyright (c) 2007, ANYwebcam.com Pty Ltd. All rights reserved.

        The software in this package is published under the terms of the BSD style
        license, a copy of which has been included with this distribution in the
        license.txt file.
        
        http://code.google.com/p/di-as3/
       
*/
package utils.reflection
{
	 	/**
         * Helper for shortcutting searching in arrays
         */
         
        // todo: include examples
        // todo: add support for negative assertions in the conditions
        // todo: create version that extends Array
        // todo: allow either static use, or instantiated use
        // todo: add support for searching arrays when using property chain conditions
        // todo: implement negative conditions,and AND, OR type condition combinations       
        public class ArrayPeer
        {
                public static const FIRST       :String = 'first';
                public static const LAST        :String = 'last';
                public static const ALL         :String = 'all';

                /**
                 * Searches an array using simple or complex conditions.
                 * <p>The conditons are evaluated and compared strictly equal and the item must match all conditions to be in the returned array.</p>
                 * <p>Conditions with Class, Function or RegExp as the expected values are subject to some additional rules regarding matches. </p>
                 * <dl>
                 *      <dt>Class</dt><dd>If the actual value is a Class then they are compared with ===, else the actual value will be checked to see if it <code>is</code> of the Class type.</dd>
                 *      <dt>Function</dt><dd>If the actual value is a Function then they are compared with ===, else the expected function is called with the item and the actual value as parameters. This function needs to return a Boolean. eg <code>var condtions:Object = { someProperty: function(item:*, actual:*):Boolean { return actual != null; } }</code></dd>
                 *      <dt>RegExp</dt><dd>If the actual value is a RegExp then they are compared with ===, else the actual value is tested with the RegExp.</dd>
                 * </dl>
                 * <p>All other expected value are compared with ===</p>
                 *
                 * @example Some example uses
                 * <listing version="3.0">
                 * var movies:Array = []; // retrieve from some datasource
                 * // find with simple property value condition
                 * var moviesByMichaelBay:Array = ArrayPeer.find( movies, { director: 'Michael Bay' } );
                 * // find with property chain condition (assuming the 'released' property returns a Date instance)
                 * var moviesByMichaelByReleasedIn2007:Array = ArrayPeer.find( moviesByMichaelBay, { 'released.fullYear': 2007 }
                 * // find with Class condition
                 * // todo: add example
                 * // find with Function condition
                 * var moviesWithAverageRatings:Array = ArrayPeer.find( movies, { rating: function(item:Movie, actual:Number):Boolean { return actual > 2.4 && actual < 3.7; } })
                 * // find wtih RegExp
                 * var moviesTheBeginWithTr:Array = ArrayPeer.find( movies, { name: new RegExp('^Tr.*') });
                 * // find with sub-array query (assuming the 'cast' property returns an Array of Actors with the property 'name')
                 * var moviesWithMeganFox:Array = ArrayPeer.find( movies, { 'cast.name': 'Megan Fox' })
                 * </listing>
                 */
                public static function find( array:Array, conditions:Object, options:Object = null ):*
                {
                        if( conditions is Function )
                        {
                                return array.filter( conditions as Function );
                        }
                       
                        // todo: allow settings of default options
                        if( !options ) options = { find:FIRST };
                       
                        var i:int, n:int, item:*;
                       
                        if( options.find == FIRST )
                        {
                                i = 0;
                                n = array.length;
                               
                                while( i < n )
                                {
                                        if( matches( item = array[ i++ ], conditions ) ) return item;
                                }
                                return null;
                        }
                       
                        if( options.find == LAST )
                        {
                                i = array.length - 1;
                                n = 0;
                               
                                while( i >= n )
                                {
                                        if( matches( item = array[ i-- ], conditions ) ) return item;
                                }
                                return null;
                        }
                       
                        // otherwise, find all
                        return array.filter( function( item:Object, index:int, array:Array ):Boolean
                        {
                                return matches( array[ index ], conditions );
                        });
                }
               
                /**
                 * Shortcut for retrieving the first matching item
                 */
                public static function findFirst( array:Array, conditions:Object, options:Object = null ):*
                {
                        return find( array, conditions, {find:FIRST} );                
                }
               
                /**
                 * Shortcut for retrieving the last matching item
                 */
                public static function findLast( array:Array, conditions:Object, options:Object = null ):*
                {
                        return find( array, conditions, {find:LAST} );                  
                }

                /**
                 * Shortcut for searching by a single property
                 */
                public static function findAll( array:Array, conditions:Object, options:Object = null ):Array
                {
                        return find( array, conditions, {find:ALL} ) as Array;
                }
               
                /**
                 * Shortcut for searching by a single property
                 */
                public static function findBy( array:Array, property:String, value:*, options:Object = null ):*
                {
                        var conditions:Object = {};
                        conditions[ property ] = value;
                        return find( array, conditions, options );
                }
                       
                /**
                 * Checks it the item matches the conditions
                 *
                 * @private
                 */    
                public static function matches( item:Object, conditions:Object ):Boolean
                {
                        for( var property:String in conditions )
                        {
                                var expectedValue       :Object = conditions[ property ];
                                var actualValue         :Object;
                               
                                //trace( this, 'matches', item, property, expectedValue );
                               
                                // match property chain
                                // eg: how.low.can.you.go
                                // note: not much effort was put into catching dodgy property chains
                                // todo: put some effort into catching dodgy property chains
                                if( property.indexOf('.') > -1 )
                                {
                                        actualValue = item;
                                       
                                        var propertyChain       :Array   = property.split('.');
                                        var chainLength         :int     = propertyChain.length;
                                        var linkIndex           :int     = 0;
                                        var propertyLink        :String  = '';
                                        // todo: revert this to the nicer array.every style
                                        // var validChain               :Boolean = propertyChain.every(
                                        // function( propertyLink:String, index:int, array:Array ):Boolean
                                        var validChain          :Boolean = false;
                                       
                                        while( linkIndex < chainLength )
                                        {
                                                propertyLink = propertyChain[ linkIndex ];
                                               
                                                //trace( 'matches.propertyChain:', item, linkIndex, '/', chainLength,
                                                //      actualValue, propertyLink,
                                                //      actualValue.hasOwnProperty( propertyLink ) ? actualValue[ propertyLink ] : 'null' );
                                               
                                                if( !actualValue.hasOwnProperty( propertyLink ) ) break;
                                               
                                                actualValue = actualValue[ propertyLink ];
                                               
                                                // valid if we made it to the last link
                                                if( linkIndex == (chainLength - 1) )
                                                {
                                                        validChain = true;
                                                        break;
                                                }
                                               
                                                linkIndex++;
                                        }
                                       
                                        // dont match if the chain isnt valid
                                        if( !validChain )
                                        {
                                                // if links remain in the property chain, check if actualValue is an Array,
                                                // then see if there are items in that array that match
                                                if( actualValue is Array )
                                                {
                                                        // true if there are any items that match the remaining pieces
                                                        // its safe to bail out on the first found item
                                                        var conditions:Object = {};
                                                        conditions[ propertyChain.slice( linkIndex ).join('.') ] = expectedValue;
                                                        var found:Object = ArrayPeer.findFirst( actualValue as Array, conditions );
                                                        return found ? true : false;
                                                }
                                                return false;
                                        }
                                }
                                else
                                {
                                        // check property exists
                                        if( !item.hasOwnProperty( property ) ) return false;            
                                        actualValue = item[ property ];
                                }
                               
                                // check property value
                                if( !matchesValue( item, expectedValue, actualValue ) ) return false;                          
                        }
                       
                        // yay, conditions match!
                        return true;
                }
               
                /**
                 * Checks if a value matches the expected value
                 *
                 * @private
                 */
                public static function matchesValue( item:*, expected:*, actual:* ):Boolean
                {
                        // class matcher
                        if( (actual is Class) && (expected is Class) )
                        {
                                return ( (actual as Class) === (expected as Class) );
                        }
                        if( (expected is Class) )
                        {
                                // todo: test this works as expected
                                return (actual is expected);
                        }
                       
                        // function matcher
                        if( (actual is Function) && (expected is Function) )
                        {
                                return ( (actual as Function) === (expected as Function) );
                        }
                        if( expected is Function )
                        {
                                return (expected as Function)(item, actual);
                        }
                       
                        // regexp matcher
                        if( (actual is RegExp) && (expected is RegExp) )
                        {
                                return ( (actual as RegExp) === (expected as RegExp) )
                        }
                        if( (actual is String) && (expected is RegExp) )
                        {
                                return (expected as RegExp).test( actual as String );
                        }
                       
                        // literal matcher
                        return ( actual === expected );
                }
        }
}