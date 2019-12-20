package storo.validator;
import sweet.functor.validator.IValidator;
import sweet.functor.validator.IsObject;

/**
 * Return true if the class of the object is declared in storo
 * @author GINER Jeremy
 */
class IsStoroClass extends IsObject {

	public function new() {
		super();
	}
}