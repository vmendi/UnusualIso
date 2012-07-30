/*
        Copyright (c) 2007, ANYwebcam.com Pty Ltd. All rights reserved.

        The software in this package is published under the terms of the BSD style
        license, a copy of which has been included with this distribution in the
        license.txt file.
        
        http://code.google.com/p/di-as3/
*/
package utils.reflection
{
        import flash.utils.describeType;
        import flash.utils.getDefinitionByName;
        import flash.utils.getQualifiedClassName;

        // todo: check if the type has already been corrected
        // todo: cache the results and return cached copy on subsequent calls
        /**
         * Extends the behaviour of flash.utils.describeType to work-around the constructor description bug
         *
         * @see flash.utils.describeType
         */
        public function describeType( type:* ):XML
        {
                var description:XML = flash.utils.describeType( type );        
               
                //trace( 'describeType', type,
                //      description.factory.constructor.parameter.length(),
                //      description.factory.constructor.parameter.(@optional == 'false').length(),
                //      description.factory.constructor.parameter.toXMLString() );
               
                // do all parameters
                //var requiredParameterCount:Number = description.factory.constructor.parameter.(@optional == 'false').length();
                //if( requiredParameterCount == 0 ) return description;
                var parameterCount:Number = description.factory.constructor.parameter.length();
                if( parameterCount == 0 ) return description;
               
                var impl:Class = ( type is Class )
                        ? type as Class
                        : getDefinitionByName( getQualifiedClassName( type ) ) as Class;
               
                try
                {
                        var instance:Object;
                       
                        switch( parameterCount )
                        {
                                case 0: instance = new impl();
                    break;  
                case 1: instance = new impl( null );
                    break;
                case 2: instance = new impl( null, null );
                    break;
                case 3: instance = new impl( null, null, null );
                    break;
                case 4: instance = new impl( null, null, null, null );
                    break;
                case 5: instance = new impl( null, null, null, null, null );
                    break;
                case 6: instance = new impl( null, null, null, null, null, null );
                    break;
                case 7: instance = new impl( null, null, null, null, null, null, null );
                    break;
                case 8: instance = new impl( null, null, null, null, null, null, null, null);
                    break;
                case 9: instance = new impl( null, null, null, null, null, null, null, null, null );
                    break;
                case 10: instance = new impl( null, null, null, null, null, null, null, null, null, null );
                    break;
                default:
                    // too many params? add some more cases here or consider refactoring your class
                    break;
                        }
                       
                        instance = null;
                }
                catch( e:Error )
                {
                        // ignored!
                }
               
                return flash.utils.describeType( type );  
        }
}