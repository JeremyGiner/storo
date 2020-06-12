package;
import storo.core.Database;
import storo.core.Indexer.FieldAccessorDefault;
import storo.core.Indexer.IndexerUniqKeyStackValue;
import sweet.functor.validator.Const;
import sweet.ribbon.MappingInfoProvider;
//import storo.datatransformer.encoder.BinaryEncoder;
import sweet.ribbon.RibbonMacro;
import sweet.ribbon.MappingInfo;

/**
 * ...
 * @author GINER Jeremy
 */
class Main {

	static public function main() {
		
		var oMappingProvider = new MappingInfoProvider();
		RibbonMacro.setMappingInfo( oMappingProvider, Customer );
		var oDatabase = new Database( oMappingProvider );
		
		//trace( oDatabase.get('Default', 0) );
		
		oDatabase.persist( new Customer('toto', [new Customer('toto.titi'), new Customer('toto.tutu')]) );
		oDatabase.flush();
		
		oDatabase.getStorage('Default')
			.addIndexer( 
				'_sName', 
				new IndexerUniqKeyStackValue(
					Const( true ), 
					new FieldAccessorDefault(['_sName', /*!!TODO handle wildcard ? use as key*/]) ) 
			)
		;
		//trace( oDatabase.get('Default', 1) );
		
		//trace( oDatabase.getStorage('Default').getDescriptor().getRelationIndex() );
		
		trace('The end.'); 
	}
	
}

class Customer {
	
	var _iId :Null<Int>;
	var _sName :String;
	
	var _aChild :Array<Customer>;
	
	public function new( s, aChild :Array<Customer> = null ) {
		name = s;
		_iId = null;
		_aChild = aChild;
	}
	
	public function getId() {
		return _iId;
	}
	public function setId( i :Null<Int> ) {
		_iId = i;
	}
	
	public function toString() {
		return 'Customer#' + _iId+':name='+name;
	}
}
