package storo;

/**
 * ...
 * @author GINER Jeremy
 */
class UniqueIdGenerator {

	var _iId :Int;
	
	public function new( _iIdOffset :Int = 0 ) {
		_iId = _iIdOffset;
	}
	
	public function setOffset( _iIdOffset :Int ) {
		_iId = _iIdOffset;
	}
	
	public function generate() :Int {
		return _iId++;
	}
	
}