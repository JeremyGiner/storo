package storo.validator;
import sweet.functor.validator.IValidator;
import Type;

/**
 * ...
 * @author GINER Jeremy
 */
class TypeValidator implements IValidator<ValueType> {

	var _oValueType :ValueType;
	
	public function new( oValueType :ValueType ) {
		_oValueType = oValueType;
	}
	
	public function validate( o :Dynamic ) {
		return Type.typeof(o) == _oValueType;
	}
	
}