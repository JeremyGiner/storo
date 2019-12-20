package storo.ribbon.decoder;
import storo.core.Database;
import storo.core.Storage;
//import storo.tool.BytesReader;
import sweet.ribbon.tool.BytesReader;
import sweet.ribbon.decoder.ISubDecoderBaseType;

/**
 * ...
 * @author GINER Jeremy
 */
class StoroRefDecoder implements ISubDecoderBaseType<Dynamic> {

	var _oDatabase :Database;
	
	public function new( oDatabase :Database ) {
		_oDatabase = oDatabase;
	}
	
	public function decode( oReader :BytesReader ) {
		var sStorageId = oReader.readSizedString();
		var iEntityId = oReader.readInt32();
		return _oDatabase.get( sStorageId, iEntityId ); 
	}
}