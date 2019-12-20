package storo;

import storo.core.IKeyProvider;
import storo.core.NotStorableException;
import storo.core.Storage;

/**
 * Access key using getId and setId method
 * @author GINER Jeremy
 */
class KeyProviderDefault implements IKeyProvider<Int,IdOwner<Null<Int>>> {

	var _oStorage :Storage<Int,IdOwner<Null<Int>>>;
	var _oIdGenerator :UniqueIdGenerator;
	
	public function new( 
		oStorage :Storage<Int,IdOwner<Null<Int>>>, 
		oIdGenerator :UniqueIdGenerator 
	) {
		_oStorage = oStorage;
		_oIdGenerator = oIdGenerator;
	}
	
	public function get( o :IdOwner<Null<Int>> ) :Int {
		try {
			if ( o.getId() == null )
				o.setId( _oIdGenerator.generate() );
		} catch ( e :Dynamic ) {
			// TODO: wrap only the exceptions concerning the access of getId 
			//if(  )
			throw new NotStorableException( e );
			// throw e;
		}
		return o.getId();
	}
	
}

