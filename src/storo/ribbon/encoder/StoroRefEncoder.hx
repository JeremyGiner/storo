package storo.ribbon.encoder;
import haxe.io.Bytes;
import sweet.ribbon.encoder.ISubEncoderBaseType;
import storo.core.Database;
import sweet.ribbon.encoder.IntEncoder;
import sweet.ribbon.encoder.StringEncoder;
import sweet.ribbon.tool.BytesTool;

/**
 * ...
 * @author GINER Jeremy
 */
class StoroRefEncoder implements ISubEncoderBaseType<Dynamic> {

	var _oDatabase :Database;
	
	public function new( oDatabase :Database ) {
		_oDatabase = oDatabase;
	}
	
	public function encode( o :Dynamic ) {
		
		// get storage
		var oStorage = _oDatabase.getStorageByObject( o );
		
		var lBytes = new List<Bytes>();
		
		// write storage id
		lBytes.add( new StringEncoder().encode( oStorage.getId() ) ); // TODO : make and use static function
		
		// write entity id
		lBytes.add( new IntEncoder().encode( 
			oStorage.getPrimaryIndexKeyProvider().get(o) 
		) );
		
		
		return BytesTool.joinList( lBytes );
	}
}