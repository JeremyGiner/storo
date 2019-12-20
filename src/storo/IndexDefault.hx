package storo;
import haxe.ds.RedBlackTree;
import sweet.functor.comparator.IntAscComparator;
import storo.KeyProviderDefault.IdOwner;


/**
 * Page indexed by unique id
 * @author GINER Jeremy
 */
class IndexDefault<IdOwner> {

	var _oMap :RedBlackTree<Int,IntervalInt>;
	var _oKeyProvider :KeyProviderDefault;
	var _sIdentifier :String;
	
	public function new() {
		_oMap = new RedBlackTree<Int,IntervalInt>( 
			new IntAscComparator() 
		);
		_oKeyProvider = new KeyProviderDefault( _oPrimaryIndex );
		_sIdentifier = 'example.id';
	}
	
	public function put( o :IdOwner, oPage :IntervalInt ) {
		_oMap.set( _oKeyProvider.get( o ), oPage );
	}
}

interface Index<C> {
	public function get( o :C );
	public function put( o :C, oPage :IntervalInt ) :Void;
}