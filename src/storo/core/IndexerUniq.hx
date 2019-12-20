package storo.core;
import haxe.ds.RedBlackTree;
import sweet.functor.comparator.IComparator;
import sweet.functor.validator.IValidator;

/**
 * ...
 * @author GINER Jeremy
 */
class IndexerUniq<CKey,CValue> extends IIndexer<CKey,CValue> {

	var _oValidator :IValidator<Dynamic>;
	var _oComparator :IComparator<CValue>;
	var _m :RedBlackTree<CKey,CValue>;
	var _oAccessor :IFieldAccessor<CValue,CKey>;
	
//_____________________________________________________________________________
//	Constructor
	
	public function new( oValidator :IValidator<Dynamic>, oComparator :IComparator<CValue> ) {
		_oComparator = oComparator;
		_oValidator = oValidator;
		_m = new RedBlackTree<CKey,CValue>( _oComparator );
	}
	
//_____________________________________________________________________________
//	Accessor
	
	public function get( oKey :CKey ) {
		return _m.get( oKey );
	}
		
	public function exists( k :CKey ) {
		return _m.exists( k );
	}
	
	public function getValidator() {
		return _oValidator;
	}
	
//_____________________________________________________________________________
//	Modifier
	
	public function add( oValue :CValue ) {
		var k = _oAccessor.apply( o );
		
		if ( _m.exists(k) ) 
			throw 'entry for key [' + k + '] already exist';
		
		_m.set( k, o );
	}
	
	public function remove( oValue :CValue ) {
		var k = _oAccessor.apply( o );
		_m.remove( k );
	}
	
}
