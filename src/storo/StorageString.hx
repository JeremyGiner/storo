package storo;
import storo.core.Storage;
import storo.core.Database;
import haxe.io.Path;
import sweet.ribbon.RibbonDecoder;
import sweet.ribbon.RibbonEncoder;
import haxe.io.Bytes;

/**
 * ...
 * @author GINER Jeremy
 */
class StorageString<CData> extends Storage<String,CData> {
	
	override function _createObjectCache() {
		return cast new Map<String,CData>();
	}
	
	override function _createSerializedCache() {
		return cast new Map<String,Bytes>(); 
	}
}