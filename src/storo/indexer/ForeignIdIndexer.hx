package storo.indexer;
import storo.core.Database;
import storo.tool.VPathAccessor;
import sweet.functor.comparator.IComparator;
import storo.StoroReference;

/**
 * ...
 * @author 
 */
class ForeignIdIndexer<CKey,CEntityId> extends VPathIndexer<CKey,CEntityId> {
	
	var _oDatabase :Database;
	
	public function new( oVPath :VPathAccessor, oComparator :IComparator<CKey> ) {
		super(oVPath,oComparator);
	}
	override function _getIndexKey( oEntity:Dynamic ) :CKey {
		var o = _oVPath.apply(oEntity);
		
		if ( Std.is(o, StoroReference) )
			return o.getEntityId();
		
		return _oDatabase.getStorageByObject(o).getPrimaryIndexKeyProvider().get(o);
	}
}