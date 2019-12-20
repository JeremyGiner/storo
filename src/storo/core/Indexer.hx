package storo.core;
import haxe.Constraints.IMap;
import haxe.ds.ListSort;
import haxe.ds.RedBlackTree;
import sweet.functor.comparator.IComparator;
import sweet.functor.validator.IValidator;

interface Indexer<CKey,CValue> {
	public function removeValue( oValue :CValue ) :Void;
}

class IndexerUniqKeyStackValue<CKey,CValue> {
	
	var _m :RedBlackTree<CKey,List<CValue>>;
	var _oComparator :IComparator<CValue>;
	var _oAccessor :IFieldAccessor<CValue,CKey>;
	var _oValidator :IValidator<Dynamic>;
	
	public function new( oValidator :IValidator<Dynamic>, oAccessor :IFieldAccessor<CValue,CKey>, aStructureType :Array<StructureType> ) {
		_m = new RedBlackTree<CKey,List<CValue>>();
		_oValidator = oValidator;
		_oAccessor = oAccessor;
	}
	
//_____________________________________________________________________________
//	Accessor

	public function exists( k :CKey ) {
		return _m.exists( k );
	}
	
	public function get( k :CKey ) :List<CValue> {
		return _m.get( k );
	}
	public function getValidator() {
		return _oValidator;
	}

//_____________________________________________________________________________
//	Modifier
	
	public function set( k :CKey, o :CValue ) {
		var l = new List<CValue>();
		l.add( o );
		_m.set( k, l );
	}
	
	public function add( o :CValue ) {
		
		var k = _oAccessor.apply( o );
		
		if ( !exists(k) ) {
			set( k, o );
			return;
		}
		var l = get(k);
		l.push(o);
		throw 'TODO : sort list';//ListSort.sort( l., function( o:CValue, a :CValue){return 0; });//_oComparator.apply ); 
	}
	
	public function removeValue( oValue :CValue ) {
		var k = _oAccessor.apply( oValue );
		
		var l = _m.get( k );
		
		// Case : no entry
		if ( l == null )
			return;
		
		l.filter(function( o :CValue ) { return o == oValue; });
	}
}



class FieldAccessorDefault<CRoot,CValue> {
	
	var _aFieldName :Array<String>;
	
	public function new( aFieldName :Array<String> ) {
		_aFieldName = aFieldName;
	}
	
	public function apply( o :CRoot ) {
		
		for ( sFieldName in _aFieldName ) {
			if ( Reflect.hasField( o, sFieldName ) )
				throw(o+' does not have a field '+sFieldName);
			o = Reflect.field( o, sFieldName );
		}
		return cast o;
	}
}

enum StructureType {
	ST_HashMap;
	ST_RedBlackTree;
}
