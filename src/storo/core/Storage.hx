package storo.core;

import haxe.Json;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.ds.ObjectMap;
import haxe.ds.RedBlackTree;
import haxe.io.Bytes;
import haxe.io.Path;
import storo.StorageDescriptor;
import storo.loading_mask.LoadingMask;
import sweet.functor.comparator.ReflectComparator;
import sweet.ribbon.MappingInfo;
import sweet.ribbon.MappingInfoProvider;
import sweet.ribbon.RibbonDecoder;
import sweet.ribbon.RibbonEncoder;
import sweet.ribbon.RibbonStrategy;
import sys.io.File;
import sys.FileSystem;
import sys.io.FileInput;
import sys.io.FileOutput;
import haxe.Constraints.IMap;
import sys.io.FileSeek;
import sweet.ribbon.RibbonMacro;
import sweet.ribbon.RibbonEncoder.Iterator;

/**
 * TODO : seperate descriptor file handling logic
 * @author GINER Jeremy
 */
class Storage<CKey,CStored> {
	
	var _oDatabase :Database;
	
	var _sId :String;
	var _oFilePath :Path;
	
	var _sDescriptorFilePath :String;
	var _oDescriptor :IStorageDescriptor<CKey>;
	var _oStrategy :RibbonStrategy;
	var _oDescriptorEncoder :RibbonEncoder;
	var _oDescriptorDecoder :RibbonDecoder;
	
	var _oKeyProvider :IKeyProvider<CKey,CStored>;
	
	var _oReader :FileInput;
	var _oWriter :FileOutput;
	
	var _oEncoder :RibbonEncoder;//TODO : use interface + proxy instead
	var _oDecoder :RibbonDecoder;
	
	var _mCacheObject :IMap<CKey,CStored>;//TODO
	var _mCacheSerialized :IMap<CKey,Bytes>;
	
	var _lFlushQueue :List<CStored>;// priority over cached object
	// DEBUG
	var _mFlushCache :ObjectMap<Dynamic,Bool>;
	
//_____________________________________________________________________________
//	Constructor
	
	public function new( 
		oParent :Database,
		sId :String,
		oFilePath :Path, 
		oEncoder :RibbonEncoder, 
		oDecoder :RibbonDecoder,
		oKeyProvider :IKeyProvider<CKey,CStored>
	) {
		_sDescriptorFilePath = null;
		_oDescriptor = null;
		var oMappingInfoProvider = new MappingInfoProvider();
		RibbonMacro.setMappingInfo( oMappingInfoProvider, ReflectComparator);
		RibbonMacro.setMappingInfo( oMappingInfoProvider, StorageDescriptor);
		RibbonMacro.setMappingInfo( oMappingInfoProvider, RedBlackTree);
		RibbonMacro.setMappingInfo( oMappingInfoProvider, Node);
		RibbonMacro.setMappingInfo( oMappingInfoProvider, IntervalInt);
		var oStrategy = new RibbonStrategy(oMappingInfoProvider);
		_oDescriptorEncoder = new RibbonEncoder(oStrategy);
		_oDescriptorDecoder = new RibbonDecoder(oStrategy);
		// DEBUG
		_oStrategy = oStrategy;
		
		//____________
		
		_lFlushQueue = new List<CStored>();
		_mFlushCache = new ObjectMap<Dynamic,Bool>();
		
		_sId = sId;
		
		_oDatabase = oParent;
		_oFilePath = oFilePath;
		
		_oEncoder = oEncoder;
		_oDecoder = oDecoder;
		
		// Loading files
		// Case : no existing file -> create new file
		if ( !_loadDescriptor() ) {
			trace('WRNING : creating storage #'+sId);
			// Check storage file
			if ( FileSystem.exists( _oFilePath.toString() ) )
				throw 'Cannot find descriptor for storage file "'+_oFilePath+'"';
			
			// Create storage and descriptor file
			_createDescriptor();
			_saveDescriptor();
			File.saveContent( oFilePath.toString(), '' );
		} else {
			if ( !FileSystem.exists( _oFilePath.toString() ) ) {
				throw 'Cannot find storage file "'+_oFilePath+'"';
			}
		}
		
		_oKeyProvider = oKeyProvider;
		
		// Open file
		_oReader = File.read( getFilePath(), true );
		_oWriter = File.append( getFilePath(), true );
		
		// Create cache
		_mCacheObject = _createObjectCache();
		_mCacheSerialized = _createSerializedCache(); 
	}
	
//_____________________________________________________________________________
//	Accessor

	public function getId() {
		return _sId;
	}

	public function getDescriptor() :IStorageDescriptor<CKey> {
		return _oDescriptor;
	}

	public function getFilePath() {
		return _oFilePath.toString();
	}
	
	public function getDesciptorFilePathList() :Array<String> {
		// Get all files in storagedirectory/descriptor
		var a :Array<String>;
		try {
			a  = FileSystem.readDirectory( Path.join( [_oFilePath.dir, 'descriptor'] ) );
		} catch ( e :Dynamic ) {
			throw 'Directory "'+ Path.join( [_oFilePath.dir, 'descriptor'] ) + '" is innaccessible'; 
		}
		
		// convert to running relative path
		var aFile = [];
		for (i in 0...a.length) {
			if ( ! StringTools.startsWith(a[i], _oFilePath.file+'.' ) )
				continue;
			aFile.push( Path.join( [_oFilePath.dir, 'descriptor', a[i]] ) );
		}
		return aFile;
	}
	
	public function getPrimaryIndexKeyProvider() {// Necessary ? TODO : remove if not
		return _oKeyProvider;
	}
	
//_____________________________________________________________________________
//	Modifier

	public function remove( iId :CKey ) {
		// TODO : remove from flush
		
		_mCacheObject.remove( iId );
		_mCacheSerialized.remove( iId );
		
		_oDescriptor.getPrimaryIndex().get( iId );
		_oDescriptor.getPrimaryIndex().remove( iId );
		
		// add crate as available
		_oDescriptor.remove( iId );
		
		// remove from foreign index 
		throw 'TODO';
		
		//TODO : return ture on sucess; false else
	}
	
	public function addIndexer( sKey :String, oIndexer :IIndexer<Dynamic,Dynamic> ) {

		var bFlag = false;
		
		for ( o in _oDescriptor.getPrimaryIndex() ) {
			if ( bFlag == false ) {
				bFlag = true;
				trace('WARNING: Creating index with stored entities already existing');
			}
			
			oIndexer.add( o );
		}
		
		_oDescriptor.addIndexer( sKey, oIndexer);
	}
	
//_____________________________________________________________________________
//	Sub-routine	
/*
	function _createDescriptor() {
		
		// TODO : change serializer
		// Serialize Descriptor into his file
		
		var oSerializer = new Serializer();
		
		oSerializer.serialize( new StorageDescriptor() );
		File.saveContent( getDesciptorFilePath(), oSerializer.toString());
	}
	*/
	
	function _createObjectCache() :IMap<CKey,CStored> {
		//return new Map<CKey,CStored>();
		throw 'Override me';//TODO: block at compile time if not overrided
	}
	function _createSerializedCache() :IMap<CKey,Bytes> {
		//return new Map<CKey,Bytes>(); 
		throw 'Override me';
	}
	
	function _loadDescriptor() {
		
		var _sDescriptorFilePath = _getCurrentSwapFile();
		
		// Case : no file found
		if ( _sDescriptorFilePath == null ){
			_sDescriptorFilePath = null;
			_oDescriptor = null;
			return false;
		}
		
		// Unserialize Descriptor from his file
		//var oFileInput = File.read( getDesciptorFilePath(), false );
		_oDescriptor = cast _oDescriptorDecoder.decode( File.getBytes(_sDescriptorFilePath));
		return true;
	}
	
	function _saveDescriptor() {
		
		// Get swap file path
		var sPath = _getDescriptorNextVersionFileName();
		
		// Open writing stream
		trace( 'Saving decriptor ("'+sPath+'", entity count: ) overriding "'+this._getCurrentSwapFile()+'' );
		
		// Save descriptor
		/*
		var i = new Iterator( _oDescriptor, _oStrategy );
		for ( o in i )
			trace(o);
		*/
			Serializer.USE_CACHE = true;
			
		//trace(Serializer.run(_oDescriptor.getPrimaryIndex()));
		var oBytes = _oDescriptorEncoder.encode( _oDescriptor );
		File.saveBytes( sPath, oBytes );
		_sDescriptorFilePath = sPath;
		
		// Swap file
		// swap handled by "last modified" attribute
		//FileSystem.rename( sPath, _getDescriptorNextVersionFileName() );
	}
	
	function _createDescriptor() {
		trace('Creating descriptor :'+_oFilePath.toString() + ':' + _oFilePath.file);
		_sDescriptorFilePath = _getDescriptorNextVersionFileName();
		_oDescriptor = new StorageDescriptor<CKey>();
	}
	
	/**
	 * Retrieve the full path of the currently use desc file or null
	 * retrieve last modified file in descriptor directory
	 */
	function _getCurrentSwapFile() :Null<String> {
		// Get most recent version
		// TODO : use iteration functor or something
		var oMaxDateModif :Date = null;
		var sMostRecentFilePath :String = null;
		for ( sFilePath in getDesciptorFilePathList() ) {
			if ( 
				oMaxDateModif == null 
				|| FileSystem.stat( sFilePath ).mtime.getTime() > oMaxDateModif.getTime()
			) {
				oMaxDateModif = FileSystem.stat( sFilePath ).mtime;
				sMostRecentFilePath = sFilePath;
			}
		}
		return sMostRecentFilePath;
	}
	
	function _getDescriptorNextVersionFileName() {
		if ( _sDescriptorFilePath == null )
			return  Path.join( [_oFilePath.dir, 'descriptor', _oFilePath.file+ '.desc.v0'] );
		
		var i = _sDescriptorFilePath.lastIndexOf('v');
		var iVersion = Std.parseInt( _sDescriptorFilePath.substr( i ))+1;
		return _sDescriptorFilePath.substring(0,i+1)+iVersion;
	}
	
	function _encode( o :Dynamic ) :Bytes {
		return _oEncoder.encode( o );
	}
	
	function _decode( o :Bytes ) :Dynamic {
		return _oDecoder.decode( o );
	}
	
//_____________________________________________________________________________
//	Process
	
	public function persist( o :Dynamic ) :CKey {
		
		if ( o == null )
			throw 'cannot be null';
		
		_lFlushQueue.push(o);
		var oKey = _oKeyProvider.get(o);
		_mCacheObject.set( oKey, o );
		//getDescriptor().getPrimaryIndex().set( oKey,  );
		
		return oKey;
	}
	public function get( iId :CKey, oLoadingMask :LoadingMask = null ) :Dynamic {
		//TODO: implement loading mask
		
		// TODO : get from cache
		
		// Get page
		var oPage = getDescriptor().getCrate( iId );
		
		// Case : not found
		if ( oPage == null ) 
			return null;
		
		// Get Bytes from file using page
		var oData = Bytes.alloc( oPage.getSize() );
		_oReader.seek( oPage.getMin(), FileSeek.SeekBegin );
		_oReader.readFullBytes( 
			oData, 
			0, 
			oPage.getSize() 
		);
		
		// Decode
		var o = _oDecoder.decode( oData );
		
		return o;
	}
	
	public function exist( iId :CKey ) {
		// Get page
		var oPage = getDescriptor().getCrate( iId );
		
		// Case : not found
		if ( oPage == null ) 
			return false;
		return true;
	}
	
	public function close() {
		_mCacheObject = null;
		_mCacheSerialized = null;
		_lFlushQueue = null;
		_oReader.close();
		_oWriter.close();
	}
	
	public function flush() {
		
		// TODO : ? handle case flush called within flush 
		var o = null;
		while ( (o = _lFlushQueue.pop()) != null ) {
			
			// DEBUG
			if ( _mFlushCache.exists( o ) ) {
				trace( 'abnormal persist loop on object "' + o + '"');
				continue;
			}
			_mFlushCache.set(o, true);
			
			// encode object and his childs
			//var mEncoded = new IntMap<List<Bytes>>();
			var oBytes = _encode(o);
			
			// TODO : check if object's apge require update
			// - get previous bytes
			// - compare bytes
			
			// Get available crate 
			var oCrate = getDescriptor().findAvailableCrate( oBytes.length );
			
			// Case : no available -> create new crate at the end
			var bSeeked = false;
			if ( oCrate == null ) {
				bSeeked = true;
				_oWriter.seek( 0, FileSeek.SeekEnd );
				oCrate = new IntervalInt( _oWriter.tell(), oBytes.length );
			}
			
			// ? update cache 
			//_mCacheObject.remove( iId );
			
			// update primary index file
			getDescriptor().getPrimaryIndex().set( 
				_oKeyProvider.get( o ), 
				oCrate
			);
			
			// update storage file
			if( ! bSeeked )
				_oWriter.seek( oCrate.getMin(), FileSeek.SeekBegin );
			_oWriter.writeFullBytes( oBytes, 0, oCrate.getSize() );
			
		}
		_oWriter.flush();
		
		// udpate index file
		_saveDescriptor();
		
		
		_mFlushCache = new ObjectMap<Dynamic,Bool>();
		
		
		
		// TODO : return quantity of obj saved
		// TODO : return total size
		
	}
	
}