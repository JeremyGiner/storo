package storo.core;

/**
 * @author GINER Jeremy
 */
interface IFieldAccessor<CObject,CResult> {
	public function apply( o :CObject ) :CResult;
}