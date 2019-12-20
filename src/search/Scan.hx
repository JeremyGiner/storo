package search;
import sweet.functor.validator.IValidator;

/**
 * ...
 * @author GINER Jeremy
 */
class Scan {
	public function scan<CKey,CValue>( 
		oMap :IMap<CKey,CValue>, 
		oValidator :IValidator<IMap<CKey,CValue>>, 
		iLimit :Int 
	) {
		var oResult :List<CValue>;
		for ( oKey in oMap.keys() ) {
			var oValue = oMap.get( oKey)
			if ( !oValidator.apply( oValue ) )
				continue;
			
			oResult.add( oValue );
			
			if ( oResult.length == iLimit )
				break;
		}
		
		return oResult;
	}
}