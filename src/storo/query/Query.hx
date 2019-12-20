package storo.query;
import haxe.ds.List;
import storo.tool.ListTool;





/**
 * ...
 * @author GINER Jeremy
 */
class Query {

	public function new() {
		
	}
	
	public function retrieve<CKey,C>( 
		oMask :LoadingMask<C>,
		oClass :Class<C>,
		oIndex :IIndex<C>,
		aKey :Array<CKey>
	) {
		//TODO: use loading mask to get equlaity join
	}
	
	
	public function innerJoin( aList :Array<List<Dynamic>> ) {
		
		// Sort by length desc
		aList.sort( function( a :List<Dynamic>, b :List<Dynamic> ) {
			return b.length - a.length;
		});
		
		var lResult = aList.pop();
		for ( l in aList ) {
			
			if ( lResult.length == 0 )
				break;
			
			lResult = _innerJoinList( lResult, l );
		}
		
		return lResult;
	}
	
	/**
	 * Assume both lost are already sorted
	 * @return return a list of element both contains in list A and B
	 * @param	a
	 * @param	b
	 */
	public function _innerJoinList( a :List<Dynamic>, b :List<Dynamic> ) {
		
		
		var itListA = a.iterator();
		var itListB = b.iterator();
		
		var lResult = new List<Dynamic>();
		
		while ( itListA.hasNext() && itListB.hasNext() ) {
			var oValueA = itListA.next();
			var oValueB = itListB.next();
			while ( oValueA == oValueB && itListB.hasNext() ) {
				oValueB = itListB.next();
			}
			
			if ( oValueA == oValueB )
				lResult.add( oValueA );
		}
		
		return lResult;
	}
	
}

class LoadingMask<C> {
	
}

interface IIndex<C> {
	public function get() :List<C>;
}
/*
class IndexEqual<C> implements IIndex<C> {
	
	var _oSource :IIndex<C>;
	
	public function new( oSource :IIndex<C>, oValue  ) {
		_oSource = oSource;
	}
	
	public function get() {
		return 
	}
}
*/
