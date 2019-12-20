package storo.ds;
import haxe.ds.RedBlackTree;
import storo.tool.BytesReader;
import sweet.ribbon.decoder.ISubDecoderBaseType;
import sweet.ribbon.encoder.ISubEncoderBaseType;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;
import haxe.io.Bytes;

import sweet.ribbon.*;

typedef FilePosition = Null<Int>;
/**
 * TODO :
 * 	- variance with Int64 as key and/or value
 * @author GINER Jeremy
 */
class RedBlackTreeOnDisk extends RedBlackTree<Int,Int> {
	
	var _oFileInput :FileInput;
	var _oFileOutput :FileOutput;
	
	var _mCache :Map<FilePosition,NodeOnDisk>;
	
	/**
	 * 
	 */
	var _aUpdateStack :List<NodeOnDisk>;
	
	var _oEncoder :NodeEncoder;
	
	public function new( sPath :String ) {
		/*
		var oStrategy = new RibbonStrategy( new MappingInfoProvider({
				'storo.ds.RedBlackTreeOnDisk.NodeOnDisk' => new MappingInfo(
					'storo.ds.RedBlackTreeOnDisk.NodeOnDisk',
					[]
				),//TODO : use RibbonMacro to get class name
			}) );
		
		var oEncoder = new RibbonEncoder( oStrategy );
		var oDecoder = new RibbonDecoder( oStrategy );
		*/
		_oFileInput = File.read( sPath );
		_oFileOutput = File.write( sPath );
		super();
		
		_oEncoder = new NodeEncoder();
		_mCache = new Map<FilePosition,NodeOnDisk>();
	}
	
	/**
	 * @return size of 1 node in bytes
	 */
	public function getPageSize() {
		return 17; // 1 + 4 + 4 + 4 + 4 
	}
	
	override public function createNode( key_ :Int, value_ :Int ) {
		return new NodeOnDisk( this, key_, value_, Node.RED, 1 );
	}
	
	public function sync() {
		
		while ( oNode in _aUpdateStack ) {
			oNode = _aUpdateStack.pop();
			
			// Filter node with unwritten childs ( as their file pos is required )
			if ( oNode. ) {
				_aUpdateStack.add( oNode );
				continue;
			}
			
			//____________
			// TODO: kill cache ref
			//____________
			// store modified node on new position
			
			//
			
			// 
			oNode.setFilePosition( _oEncoder.encode( oNode ) );
			
		}
		// change parent reference
		// free backup
	}
	
	public function load( iFilePosition :FilePosition ) {
		
		// Case : loadable from cache
		if ( _mCache.exists( iFilePosition ) )
			return _mCache.get( iFilePosition );
		
		// Decode
		var iLength = getPageSize();
		var oBytes = Bytes.alloc( iLength );
		_oFileInput.readBytes( oBytes, iFilePosition, iLength );
		var oNode = NodeOnDisk.decode( this, iFilePosition, oBytes );
		
		// Update cache
		_mCache.set( iFilePosition, oNode );
		
		return oNode;
	}
	
}

class NodeOnDisk extends Node<Int,Int> { //TODO : use interface only, cache handle node ref
	
	var _iCount :Int;
	var _iLeft :FilePosition;
	var _iRight :FilePosition;
	var _iFilePostion :FilePosition;
	
	var _oKey :Int;
	var _oValue :Int;
	
//_____________________________________________________________________________
// Constructor
	
	public function new(
		oTree :RedBlackTree<Int,Int>,
		key_ :Int, 
		value_ :Int, 
		color_ :Bool, 
		iCount :Int
	) {
		super(oTree, key_, value_, color_, iCount);
		
		_iCount = iCount;
		_iFilePostion = null;
	}
	
	static public function decode( 
		oTree :RedBlackTree<Int,Int>, 
		i :FilePosition, 
		oBytes :Bytes 
	) {
		
		
		var oReader = new BytesReader( oBytes );
		var bColor = oReader.read() == 1 ? true : false;
		var iCount = oReader.readInt32();
		var iLeft = oReader.readInt32();
		var iRight = oReader.readInt32();
		var oKey = oReader.readInt32();
		var oValue = oReader.readInt32();
		
		var o = new NodeOnDisk( oTree, oKey, oValue, bColor, iCount );
		o._iFilePostion = i;
		o._iLeft = iLeft;
		o._iRight = iRight;
		
		return o;
	}
	
//_____________________________________________________________________________
	
	override public function getLeft() {
		return untyped _oTree.load( _iLeft ); // TODO : type correctly
	}
	
	override public function getRight() {
		return untyped _oTree.load( _iRight );// TODO : type correctly
	}
	
	public function getLeftFilePos() {
		return _iLeft;
	}
	public function getRightFilePos() {
		return _iRight;
	}
	
	public function getFilePostion() {
		return _iFilePostion;
	}
	
	public function setFilePosition( iFilePostion :FilePosition) {
		_iFilePostion = iFilePostion;
		return this;
	}
	
	//public function ;
}

class NodeEncoder {
	public function new() {}
	public function encode( o :NodeOnDisk ) {
		var oBytes = Bytes.alloc( 17 );
		oBytes.set( 0, o.getColor() ? 1 : 0 );
		oBytes.setInt32( 1, o.getCount() );
		oBytes.setInt32( 1, o.getLeftFilePos() );
		oBytes.setInt32( 1, o.getRightFilePos() );
		oBytes.setInt32( 1, o.getKey() );
		oBytes.setInt32( 1, o.getValue() );
		//TODO
		return oBytes;
	}
}
