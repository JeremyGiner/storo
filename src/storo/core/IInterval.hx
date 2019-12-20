package storo.core;

/**
 * @author GINER Jeremy
 */
interface IInterval<C> {
	public function merge( oInteval :IInterval<C> ) :IInterval<C>;
	public function overlap( oInteval :IInterval<C> ) :IInterval<C>;
	public function getMin() :C;
	public function getMax() :C;
	public function getSize() :C;
}