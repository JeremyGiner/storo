package haxe.ds;
import haxe.ds.BalancedTree;
import sweet.functor.comparator.IComparator;
import sweet.functor.comparator.ReflectComparator;

/**
 * ...
 * @author 
 */
class BalancedTreeFunctor<CKey,CValue> extends BalancedTree<CKey,CValue> {

	var _oComparator :IComparator<CKey>;
	var _iCount = 0;
	
	public function new( oComparator :IComparator<CKey> = null ) {
		super();
		_oComparator = ( oComparator == null ) ?
			new ReflectComparator<CKey>() :
			oComparator
		;
	}
	
	override function compare(k1:CKey, k2:CKey) {
		return _oComparator.apply( k1, k2 );
	}
	
	override public function set(key:CKey, value:CValue) {
		
		if ( !exists( key ) )
			_iCount++;
		super.set(key, value);
	}
	
	override public function clear():Void {
		super.clear();
		_iCount = 0;
	}
	override public function remove(key:CKey) {
		if ( exists( key ) )
			_iCount--;
		return super.remove(key);
	}
	
	override public function copy():BalancedTree<CKey, CValue> {
		throw 'not implemeted yet';
		return null;
	}
	
	public function isEmpty() {
		return _iCount == 0;
	}
	public function getCount() {
		return _iCount;
	}
	
	
	public function getKeyMax() :CKey {
		
		if ( this.root == null )
			return null;
		
		var oNode = root;
		while ( oNode.right != null ) {
			oNode = oNode.right;
		}
		return oNode.key;
	}
}