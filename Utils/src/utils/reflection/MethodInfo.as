/*
        Copyright (c) 2007, ANYwebcam.com Pty Ltd. All rights reserved.

        The software in this package is published under the terms of the BSD style 
        license, a copy of which has been included with this distribution in the 
        license.txt file.
        
        http://code.google.com/p/di-as3/
*/
package utils.reflection
{
        import flash.utils.getDefinitionByName;

        /**
         * Describes a property, variable or method, its parameters and return value
         */
        public class MethodInfo
        {
                private var _classInfo:ClassInfo;
                private var _description:XML;
                // caching
                private var _name:String;
                private var _parameters:Array;
                private var _requiredParameters:Array;
                private var _returnType:Class;
                private var _callable:Boolean = false;
                private var _readable:Boolean = false;
                private var _writable:Boolean = false;

                public function MethodInfo( classInfo:ClassInfo, methodDescription:XML )
                {
                        _classInfo = classInfo;
                        _description = methodDescription;
                        _name = _description.@name;

                        if( _name == 'getPropertyName' )
                        {
                                trace( this, _classInfo.description, _description );
                        }
                        
                        var localName:String = description.localName();
                        
                        _callable = (localName == 'method') ? true : false;
                        
                        switch( localName )
                        {
                                case 'accessor' : 
                                        _readable = (description.@access == 'readwrite' || description.@access == 'readonly');
                                        _writable = (description.@access == 'readwrite' || description.@access == 'writeonly');
                                        break;
                                case 'variable' : 
                                        _readable = true;
                                        _writable = true;
                                        break;
                                case 'method'   : 
                                default                 : 
                                        _readable = false;
                                        _writable = false;
                        }
                }
                
                /**
                 * XML describing the property, variable or method
                 */
                public function get description():XML
                {
                        return _description;
                }
                
                /**
                 * Name of the property, variable or method
                 */
                public function get name():String
                {
                        return _name;
                }
                
                /**
                 * Method parameters as an ordered Array of Class
                 */
                public function get parameters():Array // of Class, in expected order
                {
                        if( !_parameters )
                        {
                                _parameters = [];
                                
                                // if method or property
                                for each( var param:XML in description.parameter )
                                {
                                        //trace( this, 'parameters', param.@type );
                                        _parameters.push( getDefinitionByName( param.@type ) );
                                }
                                
                                // if accessor
                                if(( description.localName() == 'accessor' 
                                ||   description.localName() == 'variable' )
                                && description.@type )
                                {
                                        _parameters.push( getDefinitionByName( description.@type ) );
                                }
                        }                                       
                        return _parameters;
                }
                
                /**
                 * Method required parameters as an ordered Array of Class
                 */
                public function get requiredParameters():Array // of Class, in expected order
                {
                        if( !_requiredParameters )
                        {
                                _requiredParameters = [];
                                for each( var param:XML in description.parameter.(@optional == 'false') )
                                {
                                        _requiredParameters.push( getDefinitionByName( param.@type ) );
                                }
                        }
                        return _requiredParameters;
                }
                
                /**
                 * Returns the Class of the this method's return type, or null if function returns void.
                 */
                public function get returnType():Class
                {
                        //trace( this, 'returnType', name, description.@returnType || description.@type );

                        if( !_returnType ) 
                        {
                                var typeName:String = description.@returnType || description.@type;
                                _returnType = (typeName && typeName != 'void') 
                                                        ? getDefinitionByName( typeName ) as Class 
                                                        : null;                 
                        }
                        return _returnType;
                }

                // method specifc
                /**
                 * Indicates if the MethodInfo describes a method, not a property or variable
                 */
                public function get callable():Boolean
                {
                        return _callable;
                }

                // property specific
                /**
                 * Indicates if the MethodInfo describes a property or variable and is it readable
                 */
                public function get readable():Boolean
                {
                        return _readable;
                }
                
                /**
                 * Indicates if the MethodInfo describes a property or variable and is it writable
                 */
                public function get writable():Boolean
                {
                        return _writable;
                }
                
                /**
                 * Calls this method on an instance, as appropriate for a method or property
                 */
                public function invoke( instance:Object, ...args ):*
                {
                        //no point checking as the runtime will throw the same error for us anyway
                        //if( args.length < requiredParameters.length ) throw new ArgumentError();
                        if( callable )
                        {
                                instance[ name ].apply( instance, args );
                        }
                        else
                        {
                                // fixme: perhaps check the length of args before setting
                                instance[ name ] = args[0];
                        }
                }
                
                /*
                public function get isStatic():Boolean
                {
                        return false;
                }
                */
                
                public function toString():String
                {
                        return '[MethodInfo '+ _classInfo.qualifiedName +'#'+ name +']';
                }
        }
}
