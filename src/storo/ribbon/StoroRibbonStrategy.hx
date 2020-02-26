package storo.ribbon;
import haxe.ds.StringMap;
import storo.core.Database;
import storo.core.Storage;
import storo.ribbon.decoder.StoroRefDecoder;
import storo.ribbon.encoder.StoroRefEncoder;
import storo.validator.IsStoroClass;
import sweet.functor.validator.And;
import sweet.functor.validator.Const;
import sweet.functor.validator.IsObject;
import sweet.functor.validator.Not;
import sweet.ribbon.IMappingInfoProvider;
import sweet.ribbon.MappingInfoProvider;
import sweet.ribbon.RibbonStrategy;
import sweet.ribbon.decoder.InstanceDecoder;
import sweet.ribbon.encoder.InstanceEncoder;
import storo.core.NotStorableException;
import sweet.ribbon.RibbonEncoder.ParentReference;
import sweet.ribbon.Reference;

/**
 * ...
 * @author GINER Jeremy
 */
class StoroRibbonStrategy extends RibbonStrategy {

	var _oDatabase :Database;
	
	var _oMappingInfoProvider :IMappingInfoProvider;
	var _oObjectValidator :IsObject;
	
	var _oRefDecoder :StoroRefDecoder;
	
	public function new( 
		oMappingInfoProvider :IMappingInfoProvider = null,
		oDatabase :Database
	) {
		_oMappingInfoProvider = oMappingInfoProvider;
		_oObjectValidator = new IsObject();
		
		_oDatabase = oDatabase;
		_oRefDecoder = new StoroRefDecoder( _oDatabase );
		
		var aCodexAr = RibbonStrategy.getDefaultCodexAr( oMappingInfoProvider );
		aCodexAr.push( {
			index: 20,
			encoderValidator: new Const(false),// validation implemented deirectly in getCodexIndex
			encoder: new StoroRefEncoder( _oDatabase, oMappingInfoProvider ),
			decoder: _oRefDecoder,
		} );
		
		super( oMappingInfoProvider, null, aCodexAr );
	}
	
	override public function getCodexIndex( o :Dynamic, aParent :List<ParentReference> ) :Null<Int> {
		
		// Case : object is storable and child object 
		// -> add relation and return codex index of StoroReference
		var oStorage :Storage<Dynamic,Dynamic>;
		if ( 
			_oObjectValidator.apply( o ) 
			&& !Std.is(o,Reference)
			&& (oStorage = _oDatabase.getStorageByObject( o )) != null
			&& !aParent.isEmpty()
		) {
			
			// persist o
			oStorage.persist( o );
			
			//TODO : get mask, get relation key
			// Get field path
			//var oRelation = _getPath( aParent );
			
			// Add relation
			//var oKeyProvider = oStorage.getPrimaryIndexKeyProvider();
			//oStorage.getDescriptor().addRelation( 
				//oKeyProvider.get( aParent.last().parent ), 
				//oRelation.mask,
				//oKeyProvider.get( o ),
				//oRelation.key_list.length == 1 ? 
					//oRelation.key_list.first() : oRelation.key_list
			//);
			// return codex index of StoroRef
			return 20;
			
		}
		
		//else
		return super.getCodexIndex( o, aParent );
	}
	
	function _getPath( aParent :List<ParentReference> ) :{mask:String, key_list:List<Dynamic>} {
		var aPath = new List<String>();
		var aKeyList = new List<Dynamic>();
		
		//var oChildIndexIterator = aChildIndex.iterator();
		for ( oParentRef in aParent ) {
			var iChildIndex = oParentRef.childIndex;
			
			var index = getCodexIndex( oParentRef.parent, new List<ParentReference>() );
			switch( index ) {
				// CodexAtomic (except reference)
				case 0, 1, 2, 3, 4, 5:
					throw 'impossible codex #' + index + 'cannot have any children';
				case 6: // Array
					aKeyList.add(iChildIndex);
					aPath.push( '*' );
				case 7,8: // StringMap
					
					var sKey = _getStringMapKeyByIndex(
						cast( oParentRef.parent, StringMap<Dynamic> ),
						iChildIndex
					);
					if( sKey == null )
						throw 'StringMap does not have child #' + iChildIndex;
					aKeyList.add(sKey);
					aPath.push( '*' );
				case 9: // Class instance
					var aFieldName = _oMappingInfoProvider.getMappingInfo( oParentRef.parent ).getFieldNameAr();
					if ( aFieldName.length <= iChildIndex ) throw 'Index ' + iChildIndex + ' is out of bound for ' +aFieldName;
					aPath.push( aFieldName[ iChildIndex ] ); 
			}
		}
		
		return { mask: aPath.join('.'), key_list: aKeyList };
	}
	
	
	function _getStringMapKeyByIndex( m :StringMap<Dynamic>, iIndex :Int) :Null<String> {
		var i = 0;
		for ( sKey in m.keys() ) {
			if ( i == iIndex ){
				return sKey; 
			}
			i++;
		}
		return null;
	}
}