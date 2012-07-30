/**
* getDefinitionNames by Denis Kolyako. August 13, 2008
* Visit http://etcs.ru for documentation, updates and more free code.
*
* You may distribute this class freely, provided it is not modified in any way (including
* removing this header or changing the package path).
* 
*
* Please contact etc[at]mail.ru prior to distributing modified versions of this class.
*/
package utils
{
	import flash.display.LoaderInfo;
	
	/**
	 * getDefinitionNames function
	 * 
	 * @author					etc
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	/**
	 * Return an array of class names in LoaderInfo object.
	 * 
	 * @param loaderInfo	Associated LoaderInfo object.
	 */
	public function getDefinitionNames(loaderInfo:LoaderInfo):Array	{
		var position:uint = loaderInfo.bytes.position;
		var finder:Finder = new Finder(loaderInfo.bytes);
		loaderInfo.bytes.position = position;
		return finder.getDefinitionNames();
	}
}

import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.geom.Rectangle;

internal class Finder {
		
	public function Finder(bytes:ByteArray) {
		super();
		this._data = new SWFByteArray(bytes);
	}

	/**
	 * @private
	 */
	private var _data:SWFByteArray;
	
	/**
	 * @private
	 */
	private var _stringTable:Array;
	
	/**
	 * @private
	 */
	private var _namespaceTable:Array;

	/**
	 * @private
	 */
	private var _multinameTable:Array;
			
	public function getDefinitionNames():Array {
		var definitions:Array = new Array();
		var length:uint = this.findTag();
		var pos:uint;

		while (length) {
			pos = this._data.position;
			definitions.push.apply(definitions, this.getDefinitionNamesInTag());
			this._data.position = pos+length;
			length = this.findTag();
		}

		return definitions;
	}
	
	/**
	 * @private
	 */
	private function findTag():uint {
		var tag:uint;
		var id:uint;
		var length:uint;
		var minorVersion:uint;
		var majorVersion:uint;
		
		while (this._data.bytesAvailable) {
			tag = this._data.readUnsignedShort();
			id = tag >> 6;
			length = tag & 0x3F;
			length = (length == 0x3F) ? this._data.readUnsignedInt() : length;
			
			switch (id) {
				case 72:
				case 82:
				
					if (id == 82) {
						this._data.position += 4;
						this._data.readString(); // identifier
					}
					
					minorVersion = this._data.readUnsignedShort();
					majorVersion = this._data.readUnsignedShort();
					
					if (minorVersion == 0x0010 && majorVersion == 0x002E) {
						return length;
					} else {
						this._data.position += length;
					}
				break;
				default:
					this._data.position += length;
			}
		}
		
		return 0;
	}
	
	/**
	 * @private
	 */
	private function getDefinitionNamesInTag():Array {
		var count:int;
		var kind:uint;
		var id:uint;
		var flags:uint;
		var counter:uint;
		var ns:uint;
		var names:Array = new Array();
		this._stringTable = new Array();
		this._namespaceTable = new Array();
		this._multinameTable = new Array();
		
		// int table
		count = this._data.readASInt()-1;
		
		while (count > 0 && count--) {
			this._data.readASInt();
		}
		
		// uint table
		count = this._data.readASInt()-1;
		
		while (count > 0 && count--) {
			this._data.readASInt();
		}

		// Double table
		count = this._data.readASInt()-1;
		
		while (count > 0 && count--) {
			this._data.readDouble();
		}
		
		// String table
		count = this._data.readASInt()-1;
		id = 1;
		
		while (count > 0 && count--) {
			this._stringTable[id] = this._data.readUTFBytes(this._data.readASInt());
			id++;
		}
		
		// Namespace table
		count = this._data.readASInt()-1;
		id = 1;
		
		while (count > 0 && count--) {
			this._data.readUnsignedByte();
			this._namespaceTable[id] = this._data.readASInt();
			id++;
		}
		
		// NsSet table
		count = this._data.readASInt()-1;
		
		while (count > 0 && count--) {
			 counter = this._data.readUnsignedByte();
			 while (counter--) this._data.readASInt();
		}
		
		// Multiname table
		count = this._data.readASInt()-1;
		id = 1;
		
		while (count > 0 && count--) {
            kind = this._data.readASInt();
            
            switch (kind) {
                case 0x07:
                case 0x0D:
                	ns =  this._data.readASInt();
                    this._multinameTable[id] = [ns, this._data.readASInt()];
                break;    
                case 0x0F:
                case 0x10:
                    this._multinameTable[id] = [0, this._stringTable[this._data.readASInt()]];
                break;    
                case 0x11:
                case 0x12:
                break;    
                case 0x09:
                case 0x0E:
                    this._multinameTable[id] = [0, this._stringTable[this._data.readASInt()]];
                    this._data.readASInt();
                break;    
                case 0x1B:
                case 0x1C:
                    this._data.readASInt();
                break;    
            }
            
            id++;
		}
		
		// Method table
		count = this._data.readASInt();

		while (count > 0 && count--) {
			var paramsCount:int = this._data.readASInt();
			counter = paramsCount;
			this._data.readASInt();
			while (counter--) this._data.readASInt();
			this._data.readASInt();
			flags = this._data.readUnsignedByte();
			
			if (flags & 0x08) {
				counter = this._data.readASInt();
				
				while (counter--) {
					this._data.readASInt();
					this._data.readASInt();
				}
			}
			
			if (flags & 0x80) {
				counter = paramsCount;
				while (counter--) this._data.readASInt();
			}
		}

		// Metadata table
		count = this._data.readASInt();

		while (count > 0 && count--) {
			this._data.readASInt();
			counter = this._data.readASInt();
			
			while (counter--) {
				this._data.readASInt();
				this._data.readASInt();
			}
		}

		// Instance table
		count = this._data.readASInt();
		var nss:uint;

		while (count > 0 && count--) {
			id = this._data.readASInt();
			this._data.readASInt();
            flags = this._data.readUnsignedByte();
            if (flags & 0x08) nss = this._data.readASInt();
            counter = this._data.readASInt();
            while (counter--) this._data.readASInt();
            this._data.readASInt();
	        var traitCount:uint = this._data.readASInt();
	
	        while (traitCount--) {
	            this._data.readASInt();
	            kind = this._data.readUnsignedByte();
	            var upperBits:uint = kind >> 4;
	            var lowerBits:uint = kind & 0xF;
	
	            switch (lowerBits) {
	                case 0x00:
	                case 0x06:
	                    this._data.readASInt();
	                    this._data.readASInt();
	                    if (this._data.readASInt()) this._data.readUnsignedByte();        
	                break;
	                default:
	                    this._data.readASInt();
	                    this._data.readASInt();
	            }
	
	            if (upperBits & 0x04) {
	                counter = this._data.readASInt();
	                while (counter--) this._data.readASInt();
	            }
	        }
	        
        	ns = this._multinameTable[id][0];
        	var nameSpace:String = this._stringTable[this._namespaceTable[ns]] || '';
        	
        	if (nameSpace.indexOf('.as$') < 0) { // skip internal classes
        		names.push((nameSpace ? nameSpace+'::' : '') + this._stringTable[this._multinameTable[id][1]]);
        	} 
		}

		return names;
	}

}
	
internal class SWFByteArray extends ByteArray {
	
	/**
	 * @private
	 */
	private static const TAG_SWF:String = 'FWS';
	
	/**
	 * @private
	 */
	private static const TAG_SWF_COMPRESSED:String = 'CWS';
	
	public function SWFByteArray(data:ByteArray=null):void {
		super();
		super.endian = Endian.LITTLE_ENDIAN;
		var endian:String;
		var tag:String;
		
		if (data) {
			endian = data.endian;
			data.endian = Endian.LITTLE_ENDIAN;
			
			if (data.bytesAvailable > 26) {
				tag = data.readUTFBytes(3);
				
				if (tag == SWFByteArray.TAG_SWF || tag == SWFByteArray.TAG_SWF_COMPRESSED) {
					this._version = data.readUnsignedByte();
					data.readUnsignedInt();
					data.readBytes(this);
					if (tag == SWFByteArray.TAG_SWF_COMPRESSED) super.uncompress();
				} else throw new ArgumentError('Error #2124: Loaded file is an unknown type.');
				
				this.readHeader();
			}
			
			data.endian = endian;
		}
	}
		
	/**
	 * @private
	 */
	private var _bitIndex:uint;
	
	/**
	 * @private
	 */
	private var _version:uint;
	
	public function get version():uint {
		return this._version;
	}
	
	/**
	 * @private
	 */
	private var _frameRate:Number;
	
	public function get frameRate():Number {
		return this._frameRate;	
	}
	
	/**
	 * @private
	 */
	private var _rect:Rectangle;
	
	public function get rect():Rectangle {
		return this._rect;
	}

	public function writeBytesFromString(bytesHexString:String):void {
		var length:uint = bytesHexString.length;
		
		for (var i:uint = 0;i<length;i += 2) {
			var hexByte:String = bytesHexString.substr(i, 2);
			var byte:uint = parseInt(hexByte, 16);
			writeByte(byte);
		}
	}
	
	public function readRect():Rectangle {
		var pos:uint = super.position;
		var byte:uint = this[pos];
		var bits:uint = byte >> 3;
		var xMin:Number = this.readBits(bits, 5) / 20;
		var xMax:Number = this.readBits(bits) / 20;
		var yMin:Number = this.readBits(bits) / 20;
		var yMax:Number = this.readBits(bits) / 20;
		super.position = pos + Math.ceil(((bits * 4) - 3) / 8) + 1;
		return new Rectangle(xMin, yMin, xMax - xMin, yMax - yMin);
	}
	
	public function readBits(length:uint, start:int = -1):Number {
		if (start < 0) start = this._bitIndex;
		this._bitIndex = start;
		var byte:uint = this[super.position];
		var out:Number = 0;
		var shift:Number = 0;
		var currentByteBitsLeft:uint = 8 - start;
		var bitsLeft:Number = length - currentByteBitsLeft;
		
		if (bitsLeft > 0) {
			super.position++;
			out = this.readBits(bitsLeft, 0) | ((byte & ((1 << currentByteBitsLeft) - 1)) << (bitsLeft));
		} else {
			out = (byte >> (8 - length - start)) & ((1 << length) - 1);
			this._bitIndex = (start + length) % 8;
			if (start + length > 7) super.position++;
		}
		
		return out;
	}
	
    public function readASInt():int {
		var result:uint = 0;
		var i:uint = 0, byte:uint;
		do {
			byte = super.readUnsignedByte();
			result |= ( byte & 0x7F ) << ( i*7 );
			i+=1;
		} while ( byte & 1<<7 );
		return result;	        
    }

	public function readString():String {
		var i:uint = super.position;
		while (this[i] && (i+=1));
		var str:String = super.readUTFBytes(i - super.position);
		super.position = i+1; 
		return str;
    }

	public function traceArray(array:ByteArray):String { // for debug
		var out:String = '';
		var pos:uint = array.position;
		var i:uint = 0;
		array.position = 0;

		while (array.bytesAvailable) {
			var str:String = array.readUnsignedByte().toString(16).toUpperCase();
			str = str.length < 2 ? '0'+str : str;
			out += str+' ';
		}
		
		array.position = pos;
		return out;
	}

	/**
	 * @private
	 */
	private function readFrameRate():void {
		if (this._version < 8) {
			this._frameRate = super.readUnsignedShort();
		} else {
			var fixed:Number = super.readUnsignedByte() / 0xFF;
			this._frameRate = super.readUnsignedByte() + fixed;
		}
	}
	
	/**
	 * @private
	 */
	private function readHeader():void {
		this._rect = this.readRect();
		this.readFrameRate();		
		super.readShort(); // num of frames
	}
}