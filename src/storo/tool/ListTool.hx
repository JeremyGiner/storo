package storo.tool;

/**
 * ...
 * @author GINER Jeremy
 */
class ListTool {

	static public function indexOf<C>( l :List<C>, o :C ) {
		var i = -1;
		for ( oValue in l ) {
			i++;
			if ( o == oValue )
				return i;
		}
		return i;
	}
}