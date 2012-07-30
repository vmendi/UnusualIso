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
        import flash.utils.getQualifiedClassName;
        

        // todo: profile e4x queries versus storing lists of the results
        // todo: query interfaces, methods, properties, with e4x expressions (...maybe)
        // todo: implement additional features beyond what is required by the di framework
       
        /**
         * ClassInfo encapsulates the reflection information of a Class, and provides a clean
         * API for requesting information about the methods, properties, getters and setters.
         *
         * @example <listing version="3.0">
         * var classInfo:ClassInfo = new ClassInfo( Box );
         * </listing>
         */
        public class ClassInfo
        {
                private var _qualifiedName:String;
                private var _type:Class;
                private var _description:XML;
               
                // results caching
                private var _interfaces:Array;
                private var _superClasses:Array;
                private var _methods:Array;
                private var _properties:Array;
                private var _propertiesAndMethods:Array;

                /**
                 * The ClassInfo constructor accepts either a Class itself or an instance of a Class
                 */
                public function ClassInfo( object:Object )
                {
                        _qualifiedName = getQualifiedClassName( object );

                        _type = (object is Class)
                                ? (object as Class)
                                : getDefinitionByName( _qualifiedName ) as Class;
                       
                        // fixme: does getDefinitionByName check just the current ApplicationDomain?
                        // fixme: do we need to add the facility check other ApplicationDomains?
                       
                        if( !_type ) throw new ArgumentError( 'Not class or definition not found, received:'+ object );
                       
                        _description = describeType( _type );
                }
               
                /**
                 * The class that was reflected
                 */
                public function get type():Class
                {
                        return _type;
                }
               
                /**
                 * The output of describeType
                 */
                public function get description():XML
                {
                        return _description;
                }

                // inheritance          
               
                /**
                 * The fully qualified class name
                 */
                public function get qualifiedName():String
                {
                        return description.@name;
                }
               
                /**
                 * The class name without namespaces
                 */
                public function get shortName():String
                {
                        return qualifiedName.split('::').pop();
                }

                /**
                 * The package the Class is in
                 */
                public function get packageName():String
                {      
                        // fixme: this may need some refining for internal classes where the namespace is a.b.class.as$lineNumber::ClassName
                        return qualifiedName.split('::').shift();
                }
               
                /**
                 * Interfaces the Class implements
                 */
                public function get interfaces():Array // of Class
                {
                        if( !_interfaces )
                        {
                                var interfaceQualifiedNames:XMLList = description.factory.implementsInterface.@type;
                                _interfaces = [];
                                for each( var interfaceName:XML in interfaceQualifiedNames )
                                {
                                        _interfaces.push( getDefinitionByName( interfaceName ) );
                                }
                        }
                        return _interfaces;
                }
               
                /**
                 * Classes the class extends
                 */
                public function get superClasses():Array // of Class
                {
                        if( !_superClasses )
                        {
                                var superclassQualifiedNames:XMLList = description.factory.implementsInterface.@type;
                                _superClasses = [];
                                for each( var className:XML in superclassQualifiedNames )
                                {
                                        _superClasses.push( getDefinitionByName( className ) );
                                }
                        }
                        return _superClasses;
                }
               
                // methods, properties, variables
               
                /**
                 * Constructor description
                 */
                public function get constructor():MethodInfo
                {
                        return ( isConcrete ) ? new MethodInfo( this, description.factory.constructor[0] ) : null;
                }
               
                /**
                 * Instance method descriptions
                 */
                public function get methods():Array // of MethodInfo
                {
                        if( !_methods )
                        {
                                _methods = [];
                                for each( var method:XML in description.factory.method )
                                {
                                        _methods.push( new MethodInfo( this, method ) );
                                }
                        }
                        return _methods;                        
                }
                               
                /**
                 * Instance Properties and Variables
                 */
                public function get properties():Array // of MethodInfo
                {
                        if( !_properties )
                        {
                                _properties = [];
                                for each( var prop:XML in description.factory.accessor )
                                {
                                        _properties.push( new MethodInfo( this, prop ) );
                                }
                                for each( var variable:XML in description.factory.variable )
                                {
                                        _properties.push( new MethodInfo( this, variable ) );
                                }
                        }
                        return _properties;
                }
               
                /**
                 * All MethoddInfo instances for the properties, variables and methods of an instance of the reflected class
                 */
                public function get propertiesAndMethods():Array
                {
                        if( !_propertiesAndMethods )
                        {
                                _propertiesAndMethods = properties.concat.apply( properties, methods );
                        }
                        return _propertiesAndMethods;
                }
               
                /**
                 * Search for a method with the specified name and return its MethodInfo
                 *
                 * @param name The method name to search for
                 * @return The MethodInfo for the method if it exists
                 */
                public function method( name:String ):MethodInfo
                {
                        return ArrayPeer.findFirst( methods, {name: name });
                }
               
                /**
                 * Search for a property or variable with the specified name and return its MethodInfo
                 *
                 * @param name The property or variable name to search for
                 * @return The MethodInfo for the property if it exists
                 */
                public function property( name:String ):MethodInfo
                {
                        return ArrayPeer.findFirst( properties, { name: name });
                }
               
                /**
                 * Search for a getter (property, variable or method) with the specified name and return its MethodInfo
                 *
                 * @param name The getter name to search for
                 * @return The MethodInfo for the getter if it exists
                 */
                public function getter( name:String ):MethodInfo
                {
                        // search methods, properties, and variables for /(get)?name/i
                        var getter:MethodInfo = ArrayPeer.findFirst( propertiesAndMethods, { name: new RegExp('^((?:get)?'+ name +')$', 'i') }) as MethodInfo;
                       
                        if( getter && (getter.returnType || getter.readable) ) return getter;
                       
                        // or if dynamic return a MethodInfo instance with null(ish) values;
                        // and set the return type to *
                        // note: due to the way describeType works if provided with a Class we cannot determine this accurately
                        if( isDynamic )
                        {
                                // todo: implement (kind of tricky given that describeType lies to us about the dynamicism of classes)
                                // todo: return a MethodInfo object with a fake description that would be gettable
                                return null;
                        }
                       
                        return null;
                }
               
                /**
                 * Search for a setter (property, variable or method) with the specified name and return its MethodInfo
                 *
                 * @param name The setter name to search for
                 * @return The MethodInfo for the setter if it exists
                 */
                public function setter( name:String ):MethodInfo
                {
                        // search methods, properties, and variables for /(set)?name/i
                        var setter:MethodInfo = ArrayPeer.findFirst( propertiesAndMethods, {name: new RegExp('^((?:set)?'+ name +')$', 'i')} ) as MethodInfo;
                       
                        if( setter && ((setter.callable && setter.parameters.length > 0) || setter.writable) ) return setter;
                       
                        // or if dynamic return a MethodInfo instance with null(ish) values;
                        // and set the return type to *
                        // note: due to the way describeType works if provided with a Class we cannot determine this accurately                        
                        if( isDynamic )
                        {
                                // todo: implement (kind of tricky given that describeType lies to us about the dynamicism of classes)
                                // todo: return a MethodInfo object with a fake description that would be gettable
                                return null;
                        }
                       
                        return null;                    
                }
               
                /**
                 *
                 */
                /*public function get classMethods():Array // of MethodInfo
                {
                        return null;
                }*/
               
                /**
                 *
                 */
                /*public function get classProperties():Array // of MethodInfo
                {
                        return null;
                }*/
               
                // questions
               
                /**
                 * Is this class marked as final
                 */
                public function get isFinal():Boolean
                {
                        return description.@isFinal == 'true' ? true : false;
                }
               
                /**
                 * Indicates if the Class is dynamic
                 * <p>note: flash.utils.describeType lies to us and only returns the correct answer if you use describeType on an instance of a class, not the class itself. Until a workaround is found this function will always returns false.</p>
                 */
                public function get isDynamic():Boolean
                {
                        //return description.@isDynamic == 'true' ? true : false;      
                        return false;
                }
               
                /**
                 * Is this a Class or an interface?
                 */
                public function get isConcrete():Boolean
                {
                        // todo: perhaps also check for <constructor /> node ?
                        return ( description.factory[0].extendsClass.length() > 0 ) ? true : false;
                }
               
                /**
                 * Is this Class an interface?
                 */
                public function get isInterface():Boolean
                {
                        return ( description.factory[0].extendsClass.length() == 0 ) ? true : false;
                }
               
                // type inheritance
                /*public function isSuperClassOf( type:Class ):Boolean
                {
                        // todo: implement isSuperClassOf
                        return false;
                }*/
               
                /**
                 * Indicates if the reflected class is a subclass of the supplied class
                 */
                public function isSubClassOf( type:Class ):Boolean
                {      
                        return superClasses.indexOf( type ) > -1 ? true : false;
                }
               
                /**
                 * Indicates if the reflected class implements the supplied type
                 */
                public function isImplementorOf( type:Class ):Boolean
                {
                        if( this.type === type ) return true;
                        return ( isSubClassOf( type ) );
                }
               
                public function toString():String
                {
                        return '[ClassInfo '+ qualifiedName +']';
                }
        }
}

