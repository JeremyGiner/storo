package storo.core;

/**
 * ...
 * @author GINER Jeremy
 */
interface IKeyProvider<CKey,CEntity> {

	/**
	 * @throw
	 */
	public function get( o :CEntity ) :CKey;
	
}