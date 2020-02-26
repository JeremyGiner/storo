package storo.ribbon.mapper;
import storo.core.Database;
import storo.StoroReference;
import sweet.functor.validator.IValidator;
import sweet.ribbon.MappingInfo;
import sweet.ribbon.mapper.AMapper;

/**
 * ...
 * @author ...
 */
class StoroInstanceMapper extends AMapper<Dynamic> {
	
	var _oDatabase :Database;
	var _bPartialMode :Bool;
	
	public function new( 
		oDatabase :Database, 
		oMappingInfo :MappingInfo, 
		bPartialMode :Bool
	) {
		_oDatabase = oDatabase;
		_bPartialMode = bPartialMode;
		super( oMappingInfo );
	}
	
	override public function addChild( o:Dynamic ) {
		
		super.addChild( o );
		
		Reflect.setField( 
			getObject(), 
			_oClassDesc.getFieldNameAr()[ _aChild.length-1 ], 
			_aChild[_aChild.length-1] 
		);//TODO: safe mode?
		
		// Case: Reference complete -> load it
		if( isFilled() && !_bPartialMode )
			_oObject = _oDatabase.loadReference( _oObject );
		return this;
	}
	override public function createObject() :Dynamic {
		
		var o = Type.createEmptyInstance( 
			Type.resolveClass( _oClassDesc.getClassName() ) 
		);
		return o;
	}
}