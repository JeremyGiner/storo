package storo;
import storo.core.Storage;
import storo.core.Database;
import haxe.io.Path;
import sweet.ribbon.RibbonDecoder;
import sweet.ribbon.RibbonEncoder;
import haxe.io.Bytes;
import haxe.ds.BalancedTreeFunctor;

/**
 * ...
 * @author GINER Jeremy
 */
class StorageDefault extends Storage<Int,IdOwner<Int>> {
	
	public function new( 
		oParent :Database,
		sId :String,
		oFilePath :Path, 
		oEncoder :RibbonEncoder,
		oDecoder :RibbonDecoder
		
	) {
		// TODO : load offset from config
		
		var oUniqueIdGenerator = new UniqueIdGenerator(0);
		super(
			oParent,
			sId, 
			oFilePath, 
			oEncoder, 
			oDecoder,
			new KeyProviderDefault( 
				this, 
				oUniqueIdGenerator
			) 
		);
		// Update offset
		var oPrimIndex :BalancedTreeFunctor<Int,Dynamic> = cast _oDescriptor.getPrimaryIndex();
		oUniqueIdGenerator.setOffset(oPrimIndex.isEmpty() ? 0 : oPrimIndex.getKeyMax()+1);
		
	}
	
	override function _createObjectCache() {
		return cast new Map<Int,IdOwner<Int>>();
	}
	
	override function _createSerializedCache() {
		return cast new Map<Int,Bytes>(); 
	}
}