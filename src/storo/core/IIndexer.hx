package storo.core;
import sweet.functor.validator.IValidator;

/**
 * 
 * @author GINER Jeremy
 */
interface IIndexer<CKey,CValue> {
	public function getValidator() :IValidator<CValue>;
	public function get( oKey :CKey ) :CValue;
	public function exists( oKey :CKey ) :Bool;
	
	public function add( oValue :CValue ) :Void;
	public function remove( oValue :CValue ) :Void;
}