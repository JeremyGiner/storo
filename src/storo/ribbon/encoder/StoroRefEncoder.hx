package storo.ribbon.encoder;
import haxe.io.Bytes;
import sweet.ribbon.IMappingInfoProvider;
import sweet.ribbon.MappingInfo;
import sweet.ribbon.encoder.ISubEncoder;
import storo.core.Database;
import sweet.ribbon.encoder.InstanceEncoder;
import sweet.ribbon.encoder.IntEncoder;
import sweet.ribbon.encoder.StringEncoder;
import sweet.ribbon.tool.BytesTool;
import sweet.ribbon.RibbonMacro;

/**
 * ...
 * @author GINER Jeremy
 */
class StoroRefEncoder implements ISubEncoder<Dynamic> {

	var _oDatabase :Database;
	var _oMappingInfo :MappingInfo;
	
	public function new( oDatabase :Database ) {
		_oDatabase = oDatabase;
		_oMappingInfo = new MappingInfo('storo.StoroReference', ['_iEntityId','_sStorageId']);
	}
	
	public function encode( o :Dynamic, iClassDescIndex :Null<Int> = null ) {
		return (new IntEncoder()).encode( iClassDescIndex ); //TODO use singleton
	}
	
	public function getChildAr( o :Dynamic ) {
		
		var oRef = _oDatabase.createRef( o );
		var a = new List<Dynamic>();
		for ( sField in getMappingInfo( oRef ).getFieldNameAr() )
			a.push( Reflect.field( o, sField ) );
		return a;
	}
	
	public function getMappingInfo( o :Dynamic ) {
		return _oMappingInfo;
	}
}