package storo;
import haxe.ds.List;
import haxe.ds.BalancedTreeFunctor;
import haxe.ds.StringMap;
import storo.core.IIndexer;
import storo.core.IStorageDescriptor;
import storo.core.IntervalInt;

/**
 * BalancedTreeFunctor based Storage descriptor
 * @todo implement delete
 * @author GINER Jeremy
 */
class StorageDescriptor<CKey> implements IStorageDescriptor<CKey> {

	//var aIndex :Array<Index>;
	var _mPrimaryIndex :BalancedTreeFunctor<CKey,IntervalInt>;
	var _mIndexer :StringMap<IIndexer<Dynamic,Dynamic>>;
	var _mAvailablePageBySize :BalancedTreeFunctor<Int,List<IntervalInt>>;
	/**
	 * child id indexed by mask, !!!parent id, relation key
	 * - on create : 
	 * - on update : 
	 * - on delete : 
	 * 		- obj id get all parent relation -> list masks, parents id, relation key
	 * 		- get mask, get child id, get relation key, remove 
	 * ??? garbage collector
	 */
	/*
	var _mRelationIndex :StringMap<BalancedTreeFunctor<Dynamic,CKey>>;
	var _mEntityToRelationIndex :BalancedTreeFunctor<CKey,List<Relation>>;
	var _mReverserelationIndex :StringMap<BalancedTreeFunctor<Dynamic,CKey>>;
	var _mEntityToReverseRelationIndex :BalancedTreeFunctor<CKey,List<Relation>>;
	*/
	//var _oFilePath :Path;
	
	//var _oIdGenerator :UniqueIdFactory;
	
	public function new() {
		_mPrimaryIndex = new BalancedTreeFunctor<CKey,IntervalInt>();
		_mIndexer = new StringMap<IIndexer<Dynamic,Dynamic>>();
		//_oIdGenerator = new UniqueIdFactory();
		
		/*
		_mRelationIndex = new StringMap<BalancedTreeFunctor<Dynamic,CKey>>();
		_mEntityToRelationIndex = new BalancedTreeFunctor<CKey,List<Relation>>();
		
		_mReverserelationIndex = new StringMap<BalancedTreeFunctor<Dynamic,CKey>>();
		_mEntityToReverseRelationIndex = new BalancedTreeFunctor<CKey,List<Relation>>();
		*/
		_mAvailablePageBySize = new BalancedTreeFunctor<Int,List<IntervalInt>>();
		
	}
	
	public function getPrimaryIndex() {
		return _mPrimaryIndex;
	}
	
	public function findAvailableCrate( iSize :Int ) :IntervalInt {
		if ( _mAvailablePageBySize.exists( iSize ) ) {
			throw 'TODO: ? pop from list';
			return _mAvailablePageBySize.get(iSize).first();
		}
		return null;
	}
	
	//public function add( iId :CKey, oPage :IntervalInt ) {
		//_mPrimaryIndex.set( iId, oPage );
	//}
	
	public function getCrate( iId :CKey ) :IntervalInt {
		return _mPrimaryIndex.get( iId );
	}
	/*
	public function getRelationIndex() {
		return _mRelationIndex;
	}
	*/
	/*
	public function getIdGenerator() {
		return _oIdGenerator;
	}
	*/
	
	public function remove( iId :CKey ) {
		var oCrate = _mPrimaryIndex.get( iId );
		if ( oCrate == null ) return false;
		
		_mPrimaryIndex.remove( iId );
		
		/*
		var lRelation :List<Relation> = _mEntityToRelationIndex.get( iId );
		if ( lRelation != null )
		for ( oRelation in lRelation ) {
			_mRelationIndex.get( oRelation.mask ).get( oRelation.key );
			//m.remove(  );
		}
		*/
		return true;
	}
	
	public function getIndexerMap() :StringMap<IIndexer<Dynamic,Dynamic>> {
		return _mIndexer;
	}
	
	public function addIndexer( sKey :String, oIndexer :IIndexer<Dynamic,Dynamic> ) {
		_mIndexer.set( sKey, oIndexer );
	}
	
	public function getIndexer( sKey :String ) {
		return _mIndexer.get( sKey );
	}
	

}