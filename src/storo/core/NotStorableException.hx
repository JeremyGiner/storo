package storo.core;

/**
 * wrap exception 
 * @author GINER Jeremy
 */
class NotStorableException {
	
	/**
	 * original exception vary depending on platform
	 */
	var _e :Dynamic;

	public function new( e :Dynamic ) {
		_e = e;
	}
	
	public function toString() {
		return 'Object is not storable';
	}
	
}