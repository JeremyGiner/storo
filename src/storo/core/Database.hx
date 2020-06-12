package storo.core;
import haxe.ds.StringMap;
import haxe.io.Path;
import storo.StorageDefault;
import storo.ribbon.StoroRibbonDecoder;
import storo.ribbon.StoroRibbonStrategy;
import storo.tool.VPathAccessor;
import sweet.ribbon.MappingInfoProvider;
import sweet.ribbon.RibbonDecoder;
import sweet.ribbon.RibbonEncoder;
import storo.StoroReference;
import sweet.ribbon.RibbonMacro;
import sweet.ribbon.MappingInfo;

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
		RibbonMacro.setMappingInfo( oMappingInfoProvider, StoroReference );
		_oStrategy = new StoroRibbonStrategy(oMappingInfoProvider,this);
		_oEncoder = new RibbonEncoder( _oStrategy );
		_oDecoder = new StoroRibbonDecoder( _oStrategy );
		
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
	
	public function get( sStorageId :String, iEntityId :Dynamic, bPartial :Bool = false ) :Dynamic {
		
		var oStorage = _mStorage.get( sStorageId );
		if ( oStorage == null )
			return null;
		return oStorage.get( iEntityId, bPartial );
	}
	
	public function loadPartial( o :Dynamic, aField :Array<Dynamic> ) {
	
		// TODO : what is aField in case o an array ?, aField optionnal?
		
		// Get all children, field, 
		if ( Std.is(o, Array) ) {
			var a :Array<Dynamic> = o;
			// TODO: use aField
			for ( i in 0...a.length ) {// TODO : use Lambda.map?
				if( !Std.is(a[i],StoroReference)  )
					continue;
				a[i] = loadReference( a[i] );
			}
			return;
		}
		
		if ( aField == null )
			throw 'invalid parameter aField';
		
		if ( Std.is(o, StringMap) ) {
			var oMap :StringMap<Dynamic> = cast o;
			for ( sFieldName in aField ) {
				if ( !Std.is(sFieldName, String) )
					throw sFieldName+' should be String';
				var oRef :Dynamic = oMap.get(sFieldName);
				if ( !Std.is(oRef, StoroReference) )
					throw oRef+' should be StoroReference for field "'+sFieldName+'"';
				oMap.set(sFieldName, loadReference(cast oRef) );
			}
			return;
		}
		if ( Reflect.isObject( o ) ) {
			for ( sFieldName in aField ) {
				if ( !Std.is(sFieldName, String) )
					throw sFieldName+' should be String';
				var oRef :Dynamic = Reflect.field(o, sFieldName);
				if ( !Std.is(oRef, StoroReference) )
					throw oRef+' should be StoroReference for field "'+sFieldName+'"';
				Reflect.setField( o, sFieldName, loadReference(cast oRef) );
			}
			return;
		}
	}
	
	public function loadReference( o :StoroReference<Dynamic> ) {
		return this.mustGet( o.getStorageId(), o.getEntityId(), true );
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
	
	public function mustGet( sStorageId :String, iEntityId :Dynamic, bPartialMode :Bool = false ) :Dynamic {
		var oStorage = _mStorage.get( sStorageId );
		if ( oStorage == null )// todo throw object
			throw 'Storage #' + sStorageId + ' does not exist';
		if ( !oStorage.exist( iEntityId ) ) // todo throw object
			throw 'Object #'+Std.string(iEntityId)+' in Storage #' + sStorageId + ' does not exist';
		
		return oStorage.get( iEntityId, bPartialMode );
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
	
	public function getDefaultEncoder() {
		return _oEncoder;
	}
	
	public function getDefaultDecoder() {
		return _oDecoder;
	}
	
//_____________________________________________________________________________
// Modifier

	public function setStorage( oStorage :Storage<Dynamic,Dynamic> ) {
		if ( _mStorage.exists( oStorage.getId() ) )
			throw 'Trying to overwrite storage "'+oStorage.getId()+'"';
		_mStorage.set( oStorage.getId(), oStorage );
	}

//_____________________________________________________________________________
// Factory

	public function createRef( o :Dynamic ) {
		var oStorage = getStorageByObject( o );
		if ( oStorage == null )
			throw 'nostorage available for "' + o + '"';
		return new StoroReference<Dynamic>( 
			oStorage.getPrimaryIndexKeyProvider().get(o), 
			oStorage.getId()
		);
	}
	
//_____________________________________________________________________________

	public function persist( o :Dynamic ) {
		
		// Get associated storage
		var oStorage = getStorageByObject( o );
		
		if ( oStorage == null )
			throw new NotStorableException( o );
		
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
		trace( _oStrategy );
		//TODO : make abstract and move content into DatabaseDefault
		var oStorage = new StorageDefault(
			this,
			sStorageId,
			new Path(sStorageId+'.storage'),
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