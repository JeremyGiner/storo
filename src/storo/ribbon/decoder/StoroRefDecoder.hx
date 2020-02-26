package storo.ribbon.decoder;
import storo.StoroReference;
import storo.core.Database;
import storo.ribbon.mapper.StoroInstanceMapper;
//import storo.tool.BytesReader;
import sweet.ribbon.tool.BytesReader;
import sweet.ribbon.decoder.ISubDecoder;
import sweet.ribbon.MappingInfo;

/**
 * ...
 * @author GINER Jeremy
 */
class StoroRefDecoder implements ISubDecoder {

	var _oDatabase :Database;
	var _bPartialMode :Bool;
	
	public function new( oDatabase :Database ) {
		_oDatabase = oDatabase;
		_bPartialMode = false;
	}
	
	public function setPartialMode( b :Bool ) {
		_bPartialMode = b;
	}
	
	public function decode( 
		oReader :BytesReader, 
		aMapping :Array<MappingInfo> 
	) {
		var iClassIndex = oReader.readInt32();
		
		if ( iClassIndex < 0 || iClassIndex >= aMapping.length )
			throw 'Invalid class index : [' + iClassIndex + ']';
		
		var oClassDesc = aMapping[ iClassIndex ];
		return new StoroInstanceMapper( _oDatabase, oClassDesc, _bPartialMode );
	}
}