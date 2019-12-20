package storo.core;

/**
 * ...
 * @author GINER Jeremy
 */
class IntervalInt implements IInterval<Int> {
	
	var _iOffset :Int;
	var _iSize :Int;
	
//_____________________________________________________________________________
//	Constructor
	
	public function new( iOffset :Int, iSize :Int ) {
		_iOffset = iOffset;
		_iSize = iSize;
	}
	
	public function merge( oInterval :IInterval<Int> ) :IInterval<Int> {
		//TODO
		return null;
	}
	public function overlap( oInterval :IInterval<Int> ) :IInterval<Int> {
		//TODO
		return null;
	}
	
//_____________________________________________________________________________
//	Accessor
	
	public function getMin() :Int {
		return _iOffset;
	}
	
	public function getMax() :Int {
		return _iOffset + _iSize - 1;
	}
	
	public function getSize() :Int {
		return _iSize;
	}
	
	public function toString() {
		return '[' + getMin() + ';' + getMax() + ']';
	}
}