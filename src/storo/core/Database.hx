package storo.core;
import haxe.ds.StringMap;
import haxe.io.Path;
import storo.StorageDefault;
import storo.ribbon.StoroRibbonStrategy;
import sweet.ribbon.MappingInfoProvider;
import sweet.ribbon.RibbonDecoder;
import sweet.ribbon.RibbonEncoder;

/**
 * ...
 * @author GINER Jeremy
 */
class Database {

	/**
	 * Indexed by storage id
	 */
	var _mStorage :StringMap<Storage<Dynamic,Dynamic>>;
	
	var _oStrategy :StoroRibbonStrategy;
	var _oEncoder :RibbonEncoder;
	var _oDecoder :RibbonDecoder;
	
//_____________________________________________________________________________
// Constructor
	
	public function new( 
		oMappingInfoProvider :MappingInfoProvider,
		oConfig :Dynamic = null
	) {
		_mStorage = new StringMap<Storage<Dynamic,Dynamic>>();
		// TODO : load config
		// load storage from config
		
		// TODO : make customizable
		_oStrategy = new StoroRibbonStrategy(oMappingInfoProvider,this);
		_oEncoder = new RibbonEncoder( _oStrategy );
		_oDecoder = new RibbonDecoder( _oStrategy );
		
		// Case : load default config
		if ( oConfig == null ) {
			//TODO
			
			_createStorage('Default');
		} 
		// Case : load storage from config
		else {
			//var oConfig :AnyObjectMap = Yaml.read(sConfigPath); 
		}
		
	}
	
//_____________________________________________________________________________
// Accessor
	
	public function get<CKey>( sStorageId :String, iEntityId :CKey ) {
		var oStorage = _mStorage.get( sStorageId );
		if ( oStorage == null )
			return null;
		return oStorage.get( iEntityId );
	}
	
	public function getStorage( sStorageId :String ) :Storage<Dynamic,Dynamic> {
		return _mStorage.get( sStorageId );
	}
	
	public function remove<CKey>( sStorageId :String, iEntityId :CKey ) {
		var oStorage = _mStorage.get( sStorageId );
		if ( oStorage == null )
			return null;
		return oStorage.remove( iEntityId );
	}
	
	public function mustGet<CKey>( sStorageId :String, iEntityId :CKey ) {
		var oStorage = _mStorage.get( sStorageId );
		if ( oStorage == null )// todo throw object
			throw 'Storage #' + sStorageId + ' does not exist';
		if ( !oStorage.exist( iEntityId ) ) // todo throw object
			throw 'Object #'+Std.string(iEntityId)+' in Storage #' + sStorageId + ' does not exist';
		return oStorage.get( iEntityId );
	}
	
	public function getStorageByObject( o :Dynamic ) {
		//TODO : map object to a storage
		// ? check interface/typedef
		try {
			_mStorage.get('Default').getPrimaryIndexKeyProvider().get( o );
		} catch ( e :NotStorableException ) {
			return null;
		}
		
		return _mStorage.get('Default');
	}
	
//_____________________________________________________________________________

	public function persist( o :Dynamic ) {
		
		// Get associated storage
		var oStorage = getStorageByObject( o );
		
		// save
		oStorage.persist(o);
		
		
	}
	
	public function flush() {
		for ( oStorage in _mStorage )
			oStorage.flush();
		//TODO log changes
	}
	
	public function close() {
		for ( oStorage in _mStorage )
			oStorage.close();
		_mStorage = null;
	}
	
//_____________________________________________________________________________
// Sub-routine
	
	
	function _createStorage( sStorageId :String ) {
		//TODO : make abstract and move content into DatabaseDefault
		var oStorage = new StorageDefault(
			this,
			sStorageId,
			new Path('Default.storage'),
			_oEncoder,
			_oDecoder
		);
		_mStorage.set( sStorageId, oStorage );
	}
	
//_____________________________________________________________________________
// Utils
	
	static public function getDefaultConfig() {
		return {
			//name: 'Some DataBase',
			// encoder, decoder ?,
			working_directory: './storage',
			storage: [
				
				'default_storage' => {
					// key prodiver ?
					// cache strategy ?
				}
			]
		}
	}
	
}