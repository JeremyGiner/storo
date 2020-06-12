package storo.indexer;
import storo.tool.VPathAccessor;
import sweet.functor.comparator.IComparator;

/**
 * ...
 * @author 
 */
class VPathIndexer<CKey,CEntityId> extends AIndexerList<CKey,CEntityId> {

	var _oVPath :VPathAccessor;
	
	public function new( oVPath :VPathAccessor, oComparator :IComparator<CKey> ) {
		super(oComparator);
		_oVPath = oVPath;
	}
	override function _getIndexKey( oEntity:Dynamic ) :CKey {
		return cast _oVPath.apply(oEntity);
	}
}