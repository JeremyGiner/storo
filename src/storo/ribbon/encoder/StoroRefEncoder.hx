package storo.ribbon.encoder;
import haxe.io.Bytes;
import sweet.ribbon.IMappingInfoProvider;
import sweet.ribbon.encoder.ISubEncoder;
import storo.core.Database;
import sweet.ribbon.encoder.InstanceEncoder;
import sweet.ribbon.encoder.IntEncoder;
import sweet.ribbon.encoder.StringEncoder;
import sweet.ribbon.tool.BytesTool;

/**
 * ...
 * @author GINER Jeremy
 */
class StoroRefEncoder extends InstanceEncoder {

	var _oDatabase :Database;
	
	public function new( oDatabase :Database, oMappingInfoProvider :IMappingInfoProvider ) {
		_oDatabase = oDatabase;
		super(oMappingInfoProvider);
	}
	
	override public function getChildAr( o :Dynamic ) {
		
		var oRef = _oDatabase.createRef( o );
		return super.getChildAr( oRef );
	}
	
	override public function getMappingInfo( o :Dynamic ) {
		return _oMappingInfoProvider.getByClass( StoroReference );
	}
}