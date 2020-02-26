package storo;

/**
 * ...
 * @author GINER Jeremy
 */
class StoroReference<CKey> {

	var _iEntityId :CKey;
	var _sStorageId :String;
	
	public function new( iEntityId :CKey, sStorageId :String ) {
		_iEntityId = iEntityId;
		_sStorageId = sStorageId;
	}
	
	public function getEntityId() {
		return _iEntityId;
	}
	
	public function getStorageId() {
		return _sStorageId;
	}
	
}