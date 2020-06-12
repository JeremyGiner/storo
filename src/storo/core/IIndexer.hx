package storo.core;

/**
 * 
 * @author GINER Jeremy
 */
interface IIndexer<CKey,CValue> {
	public function get( oKey :CKey ) :CValue;
	public function exists( oKey :CKey ) :Bool;
	
	public function addEntity( oEntity :Dynamic,  oEntityId :Dynamic ) :Void;
	public function removeEntity( oEntityId :Dynamic ) :Void;
}