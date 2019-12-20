package storo;
import storo.core.Storage;
import storo.core.Database;
import haxe.io.Path;
import sweet.ribbon.RibbonDecoder;
import sweet.ribbon.RibbonEncoder;
import haxe.io.Bytes;
import haxe.ds.RedBlackTree;

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
		super(oParent, sId, oFilePath, oEncoder, oDecoder );
		//TODO use abstract function
		// TODO : load offset from config
		
		var oPrimIndex :RedBlackTree<Int,Dynamic> = cast _oDescriptor.getPrimaryIndex();
		_oKeyProvider = new KeyProviderDefault( 
			this, 
			new UniqueIdGenerator(
				oPrimIndex.isEmpty() ? 0 : oPrimIndex.getKeyMax()+1
			) 
		);
	}
	
	override function _createObjectCache() {
		return cast new Map<Int,IdOwner<Int>>();
	}
	
	override function _createSerializedCache() {
		return cast new Map<Int,Bytes>(); 
	}
}