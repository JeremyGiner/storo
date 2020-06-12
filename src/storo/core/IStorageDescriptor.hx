package storo.core;
import haxe.Constraints.IMap;
import haxe.ds.StringMap;

/**
 * Entity handling the segmentation inside a Storage.
 * Segment are refered as Crate and typed as InteralInt.
 * @author GINER Jeremy
 */
interface IStorageDescriptor<CKey> {
	public function getPrimaryIndex() :IMap<CKey,IntervalInt>;
	public function getCrate( iId :CKey ) :IntervalInt;
	public function findAvailableCrate( iSize :Int ) :IntervalInt;
	//public function add( iId :CKey, oPage :IntervalInt ) :Void;
	public function remove( iId :CKey ) :Bool;
	
	public function getIndexer( sKey :String ) :IIndexer<Dynamic,Dynamic>;
	public function getIndexerMap() :StringMap<IIndexer<Dynamic,Dynamic>>;
	public function addIndexer( sKey :String, oIndexer :IIndexer<Dynamic,Dynamic> ) :Void;
}