package storo.indexer;
import haxe.ds.BalancedTreeFunctor;
import sweet.functor.comparator.IComparator;
import storo.core.IIndexer;

/**
 * ...
 * @author 
 */
class AIndexerList<CKey,CEntityId> 
	extends BalancedTreeFunctor<CKey,List<CEntityId>> 
	implements IIndexer<CKey,List<CEntityId>>
{
	var _oReverse :BalancedTreeFunctor<CEntityId,CKey>;
	
	public function new( oComparator :IComparator<CKey> = null, oReverseComparator :IComparator<CEntityId> = null ) {
		super(oComparator);
		_oReverse = new BalancedTreeFunctor(oReverseComparator);
	}
	
	function _getIndexKey( oEntity :Dynamic ) :CKey {
		throw 'override me';
		return null;
	}
	
	public function addEntity( oEntity :Dynamic, oEntityId :Dynamic ) {
		var oKey = _getIndexKey( oEntity );
		
		
		trace(oKey);
		trace(oEntity);
		
		if ( oKey == null )
			return;
		// TODO : check oKey type
		
		if ( !exists( cast oKey ) ) 
			set( oKey, new List<CEntityId>() );
		
		// Case : Update -> Remove previous value
		if ( _oReverse.exists( oEntityId ) ) {
			removeEntity( oEntityId );
		}
		
		// Update value
		get( oKey ).add( oEntityId );
		_oReverse.set( oEntityId, oKey );
	}
	public function removeEntity( oEntityId :Dynamic ) {
		
		var oPreviousKey = _oReverse.get( oEntityId );
		_oReverse.remove( oEntityId );
		get( oPreviousKey ).remove( oEntityId ); // TODO improve
	}
	
}