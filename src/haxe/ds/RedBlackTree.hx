package haxe.ds;
import haxe.ds.RedBlackTree.Node;
import sweet.functor.comparator.IComparator;
import sweet.functor.comparator.ReflectComparator;
import haxe.Constraints.IMap;


/**
 * TODO : remake a proper translation
 * https://algs4.cs.princeton.edu/33balanced/RedBlackBST.java.html
 * @author GINER Jeremy
 */
class RedBlackTree<CKey,CValue> implements IMap<CKey,CValue> {

	var _oComparator :IComparator<CKey>;
	var _oRoot :INode<CKey,CValue>;
	
//_____________________________________________________________________________
// 	Constructor

	public function new( oComparator :IComparator<CKey> = null ) {
		_oComparator = ( oComparator == null ) ?
			new ReflectComparator<CKey>() :
			oComparator
		;
		_oRoot = null;
	}
	
	public function copy() {
		throw 'not implemented';
		return null;
	}
	
//_____________________________________________________________________________
// 	Accessor


	public function keyValueIterator() {
		throw 'not implemented';
		return null;
	}

	/**
	 * Returns the value key is bound to.
	 * If key is not bound to any value, null is returned.
	 */
	public function get( key :CKey ) :CValue {
		if (key == null) 
			throw "Key cannot be null";
		if ( isEmpty() ) 
			return null;
		return _oRoot.get( key);
	}

	public function iterator() {
		return new TreeIterator<CKey,CValue>( _oRoot );
	}
	
	public function getComparator() {
		return _oComparator;
	}
	

	/**
	 * Returns the count of key-value pairs in this symbol table.
	 */
	public function getCount() :Int {
		if ( isEmpty() )
			return 0;
		return _oRoot.getCount();
	}
	
	/**
	 * Is this symbol table empty?
	 * @return {@code true} if this symbol table is empty and {@code false} otherwise
	 */
	public function isEmpty() :Bool {
		return _oRoot == null;
	}
	
		/**
	 * Does this symbol table contain the given key?
	 * @param key the key
	 * @return {@code true} if this symbol table contains {@code key} and
	 *	 {@code false} otherwise
	 * @throws IllegalArgumentException if {@code key} is {@code null}
	 */
	public function exists( key :CKey ) :Bool {
		return get(key) != null;
	}
	
	/**
	 * Returns the height of the BST (for debugging).
	 * @return the height of the BST (a 1-node tree has height 0)
	 */
	public function getHeight() :Int {
		if ( isEmpty() )
			return 0;
		return _oRoot.getHeight();
	}
	
	/**
	 * Returns the number of keys in the symbol table in the given range.
	 *
	 * @param  lo minimum endpoint
	 * @param  hi maximum endpoint
	 * @return the number of keys in the sybol table between {@code lo} 
	 *	(inclusive) and {@code hi} (inclusive)
	 * @throws IllegalArgumentException if either {@code lo} or {@code hi}
	 *	is {@code null}
	 */
	public function countByRange( lo :CKey, hi :CKey ) :Int {
		if (lo == null) 
			throw "first argument to size() is null";
		if (hi == null) 
			throw "second argument to size() is null";

		if ( _oComparator.apply( lo, hi ) > 0 ) 
			return 0;
		
		if ( exists(hi) ) 
			return getRank(hi) - getRank(lo) + 1;
		else
			return getRank(hi) - getRank(lo);
	}
	
	/**
	 * Return the number of keys in the symbol table strictly less than {@code key}.
	 * @param key the key
	 * @return the number of keys in the symbol table strictly less than {@code key}
	 * @throws IllegalArgumentException if {@code key} is {@code null}
	 */
	public function getRank( key :CKey ) :Int {
		if (key == null) 
			throw "argument to rank() is null";
		if ( isEmpty() )
			return 0;
		return _oRoot.getRank( key );
	} 
	
	
	/**
	 * Return the key in the symbol table whose rank is {@code k}.
	 * This is the (k+1)st smallest key in the symbol table. 
	 *
	 * @param  k the order statistic
	 * @return the key in the symbol table of rank {@code k}
	 * @throws IllegalArgumentException unless {@code k} is between 0 and
	 *		<em>n</em>–1
	 */
	 public function getKeyByRank( iRank :Int) :CKey {
		if (iRank < 0 || iRank >= getCount() ) {
			throw "argument to select() is invalid: " + iRank;
		}
		var x = _oRoot.getByKeyRank( iRank );
		return x.getKey();
	}


	
	/**
	 * Returns all keys in the symbol table as an {@code Iterable}.
	 * To iterate over all of the keys in the symbol table named {@code st},
	 * use the foreach notation: {@code for (Key key : st.keys())}.
	 * @return all keys in the symbol table as an {@code Iterable}
	 */
	public function keys() {
		//TODO : create a real iterator ?
		if( isEmpty() ) 
			return (new List<CKey>()).iterator();
		
		
		var oQueue = new List<CKey>();
		_oRoot.getKeyList( oQueue, getKeyMin(), getKeyMax() );
		return oQueue.iterator();
	}
	
	/**
	 * Returns the smallest key in the symbol table.
	 * @return the smallest key in the symbol table
	 * @throws NoSuchElementException if the symbol table is empty
	 */
	public function getKeyMin() :CKey {
		if (isEmpty()) 
			throw "calls min() with empty symbol table";
		return _oRoot.getMin().getKey();
	} 

	/**
	 * Returns the largest key in the symbol table.
	 * @return the largest key in the symbol table
	 * @throws NoSuchElementException if the symbol table is empty
	 */
	public function getKeyMax() :CKey {
		if (isEmpty()) 
			throw "calls max() with empty symbol table";
		return _oRoot.getMax().getKey();
	}
	
	/**
	 * Returns all keys in the symbol table in the given range,
	 * as an {@code Iterable}.
	 *
	 * @param  lo minimum endpoint
	 * @param  hi maximum endpoint
	 * @return all keys in the sybol table between {@code lo} 
	 *	(inclusive) and {@code hi} (inclusive) as an {@code Iterable}
	 * @throws IllegalArgumentException if either {@code lo} or {@code hi}
	 *	is {@code null}
	 */
	public function getKeyListByRange( min :CKey, max :CKey ) :Iterable<CKey> {
		if (min == null) 
			throw "first argument to keys() is null";
		if (max == null) 
			throw "second argument to keys() is null";

		var queue = new List<CKey>();
		// if (isEmpty() || lo.compareTo(hi) > 0) return queue;
		_oRoot.getKeyList( queue, min, max );
		
		return queue;
	}
	
	/**
	 * Returns the smallest key in the symbol table greater than or equal to {@code key}.
	 * TODO: rename
	 * 
	 * @param key the key
	 * @return the smallest key in the symbol table greater than or equal to {@code key}
	 * @throws NoSuchElementException if there is no such key
	 * @throws IllegalArgumentException if {@code key} is {@code null}
	 */
	public function getKeyMinSuperiorTo( oMinKey :CKey ) :CKey {
		if (oMinKey == null) 
			throw "argument to ceiling() is null";
		if (isEmpty()) 
			return null;
		
		var x = _oRoot.getByKeyMinSuperiorTo( oMinKey );
		return (x == null) ? null : x.getKey();
	}
	
	/**
	 * Returns the largest key in the symbol table less than or equal to {@code key}.
	 * 
	 * TODO: rename
	 * @param key the key
	 * @return the largest key in the symbol table less than or equal to {@code key}
	 * @throws NoSuchElementException if there is no such key
	 * @throws IllegalArgumentException if {@code key} is {@code null}
	 */
	public function getKeyMaxInferiorTo( oKey :CKey ) {
		if (oKey == null) 
			throw "argument to ceiling() is null";
		if (isEmpty()) 
			return null;
		
		var x = _oRoot.getByKeyMaxInferiorTo( oKey );
		return (x == null) ? null : x.getKey();  
	}
	
	public function toString() {
		var s = new StringBuf();
		s.add("{");
		var it = keys();
		for ( i in it ) {
			s.add(i);
			s.add(" => ");
			s.add(Std.string(get(i)));
			if( it.hasNext() )
				s.add(", ");
		}
		s.add("}");
		return s.toString();
	}
	
	public function clear() {
		throw 'not implemented yet';
	}
	
	
//_____________________________________________________________________________
// 	Modifier

	/**
	 * Inserts the specified key-value pair into the symbol table, overwriting the old 
	 * value with the new value if the symbol table already contains the specified key.
	 * Deletes the specified key (and its associated value) from this symbol table
	 * if the specified value is {@code null}.
	 */
	public function set( key :CKey, value :CValue) {
		
		if (key == null) 
			throw "Key cannot be null";
		
		if (value == null) {
			remove(key);
			return;
		}
		if ( _oRoot == null ) {
			_oRoot = createNode( key, value );
			_oRoot.setBlack();
			return;
		}
			

		_oRoot = _oRoot.set( key, value);
		_oRoot.setBlack();
		
		return ;
	}
	
	/**
	 * Removes the specified key and its associated value from this symbol table	 
	 * (if the key is in this symbol table).	
	 *
	 * @param  key the key
	 * @throws IllegalArgumentException if {@code key} is {@code null}
	 */
	public function remove( key :CKey ) { 
		if (key == null) 
			throw "Key cannot be null";
		
		if (!exists(key)) return false;

		// if both children of _oRoot are black, set _oRoot to red
		if ( 
			_oRoot.getLeft().isBlack()
			&& _oRoot.getRight().isBlack()
		)
			_oRoot.setRed();

		_oRoot = _oRoot.delete( key );
		if (!isEmpty()) _oRoot.setBlack();
		// assert check();
		return true;
	}

	/**
	 * Removes the smallest key and associated value from the symbol table.
	 * @throws NoSuchElementException if the symbol table is empty
	 */
	public function deleteMin() {
		if (isEmpty()) throw "BST underflow";

		// if both children of _oRoot are black, set _oRoot to red
		if ( _oRoot.getLeft().isBlack() && _oRoot.getRight().isBlack() ) 
			_oRoot.setRed();
		
		_oRoot = _oRoot.deleteMin();
		
		if (!isEmpty()) 
			_oRoot.setBlack();
	}
	
	/**
	 * Removes the largest key and associated value from the symbol table.
	 * @throws NoSuchElementException if the symbol table is empty
	 */
	public function deleteMax() {
		if ( isEmpty() ) 
			throw "BST underflow";

		// if both children of _oRoot are black, set _oRoot to red
		if ( _oRoot.getLeft().isBlack() && _oRoot.getRight().isBlack() )
			_oRoot.setRed();

		_oRoot = _oRoot.deleteMax();
		if (!isEmpty()) 
			_oRoot.setBlack();
	}


	
	
   /***************************************************************************
	*  Check integrity of red-black tree data structure.
	***************************************************************************/
	/*
	private boolean check() {
		if (!isBST())			StdOut.println("Not in symmetric order");
		if (!isSizeConsistent()) StdOut.println("Subtree counts not consistent");
		if (!isRankConsistent()) StdOut.println("Ranks not consistent");
		if (!is23())			 StdOut.println("Not a 2-3 tree");
		if (!isBalanced())	   StdOut.println("Not balanced");
		return isBST() && isSizeConsistent() && isRankConsistent() && is23() && isBalanced();
	}

	// does this binary tree satisfy symmetric order?
	// Note: this test also ensures that data structure is a binary tree since order is strict
	private boolean isBST() {
		return isBST(_oRoot, null, null);
	}

	// is the tree _oRooted at x a BST with all keys strictly between min and max
	// (if min or max is null, treat as empty constraint)
	// Credit: Bob Dondero's elegant solution
	private boolean isBST(Node x, Key min, Key max) {
		if (x == null) return true;
		if (min != null && x.key.compareTo(min) <= 0) return false;
		if (max != null && x.key.compareTo(max) >= 0) return false;
		return isBST(x.left, min, x.key) && isBST(x.right, x.key, max);
	} 

	// are the size fields correct?
	private boolean isSizeConsistent() { return isSizeConsistent(_oRoot); }
	private boolean isSizeConsistent(Node x) {
		if (x == null) return true;
		if (x.size != size(x.left) + size(x.right) + 1) return false;
		return isSizeConsistent(x.left) && isSizeConsistent(x.right);
	} 

	// check that ranks are consistent
	private boolean isRankConsistent() {
		for (int i = 0; i < size(); i++)
			if (i != rank(select(i))) return false;
		for (Key key : keys())
			if (key.compareTo(select(rank(key))) != 0) return false;
		return true;
	}

	// Does the tree have no red right links, and at most one (left)
	// red links in a row on any path?
	private boolean is23() { return is23(_oRoot); }
	private boolean is23(Node x) {
		if (x == null) return true;
		if (isRed(x.right)) return false;
		if (x != _oRoot && isRed(x) && isRed(x.left))
			return false;
		return is23(x.left) && is23(x.right);
	} 

	// do all paths from _oRoot to leaf have same number of black edges?
	private boolean isBalanced() { 
		int black = 0;	 // number of black links on path from _oRoot to min
		Node x = _oRoot;
		while (x != null) {
			if (!isRed(x)) black++;
			x = x.left;
		}
		return isBalanced(_oRoot, black);
	}

	// does every path from the _oRoot to a leaf have the given number of black links?
	private boolean isBalanced(Node x, int black) {
		if (x == null) return black == 0;
		if (!isRed(x)) black--;
		return isBalanced(x.left, black) && isBalanced(x.right, black);
	}
	*/
	
//_____________________________________________________________________________
// 	Factory

	public function createNode( key_ :CKey, value_ :CValue ) {
		return new Node<CKey,CValue>( this, key_, value_, Node.RED, 1 );
	}
	
	
}

//=============================================================================
// 	Interface

interface INode<CKey,CValue> {
	public function get( key :CKey ) :CValue;
	
	public function getKey() :CKey;
	public function getValue() :CValue;
	
	public function getLeft() :INode<CKey,CValue>;
	public function getRight() :INode<CKey,CValue>;
	
	public function getColor() :Bool;
	public function isRed() :Bool;
	public function isBlack() :Bool;
	
	public function getCount() :Int;
	public function getHeight() :Int;
	public function getRank( key :CKey ) :Int;
	public function getByKeyRank( iRank :Int ) :INode<CKey,CValue>;
	public function getKeyList( queue :List<CKey>, min :CKey, max :CKey ) :List<CKey>;

	public function getMin() :INode<CKey,CValue>;
	public function getMax() :INode<CKey,CValue>;
	
	// TODO: rename getByKeyMinSuperiorTo and getByKeyMaxInferiorTo
	public function getByKeyMinSuperiorTo( oKey :CKey ) :INode<CKey,CValue>;
	public function getByKeyMaxInferiorTo( oKey :CKey ) :INode<CKey,CValue>;
	
	public function compareKey( key :CKey ) :Int;
	
	public function set( key :CKey, value :CValue ) :INode<CKey,CValue>;
	
	public function setLeft( o :INode<CKey,CValue> ) :INode<CKey,CValue>;
	public function setRight( o :INode<CKey,CValue> ) :INode<CKey,CValue>;
	
	public function setBlack() :INode<CKey,CValue>;
	public function setRed() :INode<CKey,CValue>;
	
	public function toggleColor() :INode<CKey,CValue>;
	
	public function delete( key_ :CKey ) :INode<CKey,CValue>;
	public function deleteMin() :INode<CKey,CValue>;
	public function deleteMax() :INode<CKey,CValue>;
	
	public function balance() :INode<CKey,CValue>;
	
}

//=============================================================================
// 	Sub-class

class Node<CKey,CValue> implements INode<CKey,CValue> {
	
	public var key :CKey;		   // key
	public var value :CValue;		 // associated data
	var _left :Node<CKey,CValue>;
	var _right :Node<CKey,CValue>;  // links to left and right subtrees
	var _bColor :Bool;	 // color of parent link
	public var count :Int;
	
	var _oTree :RedBlackTree<CKey,CValue>;
	
	public static var RED :Bool = true;
	public static var BLACK :Bool = false;
	
	
//_____________________________________________________________________________
// Constructor	

	public function new(
		oTree :RedBlackTree<CKey,CValue>,
		key_ :CKey, 
		value_ :CValue, 
		color_ :Bool, 
		count_ :Int
	) {
		key = key_;
		value = value_;
		_bColor = color_;
		count = count_;
		_oTree = oTree;
	}
	
//_____________________________________________________________________________
// Accessor

	public function getLeft() :Node<CKey,CValue> {
		return _left;
	}
	public function getRight() :Node<CKey,CValue> {
		return _right;
	}

	public function getKey() {
		return key;
	}
	public function getValue() {
		return value;
	}
	public function getColor() {
		return _bColor;
	}
	public function getCount() {
		return count;
	}
	
	public function isRed() {
		return _bColor == RED;
	}
	
	public function isBlack() {
		return _bColor == BLACK;
	}
	
	public function isRightRed() {
		var o = getRight();
		if ( o == null ) // null is black
			return false;
		return o.isRed();
	}
	public function isLeftRed() {
		var o = getLeft();
		if ( o == null ) // null is black
			return false;
		return o.isRed();
	}
	
	public function getTree() {
		return _oTree;
	};
	
	public function getHeight() :Int {
		return 1 
			+ IntTool.max(
				( getLeft() != null ) ? getLeft().getHeight() : -1, 
				( getRight() != null ) ? getRight().getHeight() : -1
			)
		;
	}
	
	public function compareKey( key_ :CKey ) {
		return getTree().getComparator().apply( key_, key );
	}
	
	public function get( key_ :CKey ) :CValue {
		
		var node :INode<CKey,CValue> = this;
		while (node != null) {
			var compare = node.compareKey(key_ );
			if (compare < 0) 
				node = node.getLeft();
			else if (compare > 0) 
				node = node.getRight();
			else
				return node.getValue();
		}
		return null;
	}
	
	
	public function getMin() :INode<CKey,CValue> { 
		// assert x != null;
		if ( getLeft() == null ) 
			return this; 
		return getLeft().getMin(); 
	}
	
	public function getMax() :INode<CKey,CValue> { 
		// assert x != null;
		if ( getRight() == null ) 
			return this; 
		return getRight().getMax(); 
	} 
	
	// add the keys between lo and hi in the subtree _oRooted at x to the queue
	public function getKeyList( queue :List<CKey>, min :CKey, max :CKey ) :List<CKey> { 
		var iCompareMin = compareKey( min ); 
		var iCompareMax = compareKey( max ); 
		
		if (iCompareMin <= 0 && iCompareMax >= 0 )
			queue.add( getKey() );
		
		if (iCompareMin < 0 ) { // Case : min is less
			if ( getLeft() == null )
				return queue;
			queue = getLeft().getKeyList( queue, min, max); 
		} if (iCompareMax > 0) {
			if ( getRight() == null )
				return queue;
			queue = getRight().getKeyList( queue, min, max); 
		}
			
		return queue;
	} 
	
	
	// number of keys less than key in the subtree _oRooted at x
	public function getRank( key_ :CKey ) :Int {
		
		var cmp = compareKey(key_); 
		if (cmp < 0) {
			if ( getLeft() == null )
				return 0;
			return getLeft().getRank( key_ ); 
		} else if (cmp > 0) {
			if ( getRight() == null )
				return 1 + getLeft().getCount();
			return 1 + getLeft().getCount() + getRight().getRank(key_); 
		} else
			return getLeft().getCount(); 
	} 
	
	// the key of rank k in the subtree _oRooted at x
	public function getByKeyRank( iRank :Int ) {
		// assert x != null;
		// assert k >= 0 && k < size(x);
		var t = getLeft().getCount(); 
		if ( t > iRank ) 
			return getLeft().getByKeyRank( iRank ); 
		else if (t < iRank) 
			return getRight().getByKeyRank( iRank-t-1 ); 
		else			
			return this; 
	} 
	
	public function getByKeyMinSuperiorTo( oKey :CKey ) :INode<CKey,CValue> {
		
		var cmp = compareKey( oKey );
		
		if (cmp == 0) 
			return this;
		if (cmp > 0)  
			return ( getRight() == null ) ? 
				null : 
				getRight().getByKeyMinSuperiorTo( oKey )
			;
		
		var t = ( getLeft() == null ) ? 
			null : 
			getLeft().getByKeyMinSuperiorTo( oKey )
		;
		return ( t != null ) ? t : this;
	}
	
	public function getByKeyMaxInferiorTo( oKey :CKey ) :INode<CKey,CValue> {
		
		var cmp = compareKey( oKey );
		
		if (cmp == 0) 
			return this;
		if (cmp < 0)  
			return ( getLeft() == null ) ? 
				null : 
				getLeft().getByKeyMaxInferiorTo( oKey )
			;
		
		var t = ( getRight() == null ) ? 
			null : 
			getRight().getByKeyMaxInferiorTo( oKey )
		;	
		return ( t != null ) ? t : this;
	}
	
//_____________________________________________________________________________
// Modifier


	public function setLeft( oNode :INode<CKey,CValue> ) {
		_left = cast oNode;
		return _left;
	}
	public function setRight( oNode :INode<CKey,CValue> ) {
		_right = cast oNode;
		return _right;
	}
	
	public function setColor( b :Bool ) {
		_bColor;
		return this;
	}

	public function setRed() {
		_bColor = RED;
		return this;
	}
	public function setBlack() {
		_bColor = BLACK;
		return this;
	}
	
	public function toggleColor() {
		setColor( !getColor() );
		return this;
	}

	
//________
	
	// flip the colors of a node and its two children
	public function flipColors() {
		// h must have opposite color of its two children
		// assert (h != null) && (h.left != null) && (h.right != null);
		// assert (!isRed(h) &&  isRed(h.left) &&  isRed(h.right))
		//	|| (isRed(h)  && !isRed(h.left) && !isRed(h.right));
		toggleColor();
		getLeft().toggleColor();
		getRight().toggleColor();
		return this;
	}
	
	public function updateCount() {
		count = 
			(getLeft() == null ? 0 : getLeft().getCount()) 
			+ (getRight() == null ? 0 : getRight().getCount())
			+ 1;
		return this;
	}
	
	// make a left-leaning link lean to the right
	public function rotateRight() {
		// assert (h != null) && isRed(h.left);
		var oNewTopNode :Node<CKey,CValue> = cast getLeft();
		
		setLeft( oNewTopNode.getRight() );
		
		oNewTopNode.setRight( this );
		
		oNewTopNode.setColor( oNewTopNode.getRight().getColor() );
		oNewTopNode.getRight().setRed();
		oNewTopNode.count = this.getCount();
		
		updateCount();
		
		return oNewTopNode;
	}

	// make a right-leaning link lean to the left
	public function rotateLeft() {
		// assert (h != null) && isRed(h.right);
		var oNewTopNode :Node<CKey,CValue> = cast getRight();
		setRight( oNewTopNode.getLeft() );
		
		oNewTopNode.setLeft( this );
		
		oNewTopNode.setColor( oNewTopNode.getLeft().getColor() );
		
		oNewTopNode.getLeft().setRed();
		
		oNewTopNode.count = this.getCount();
		
		updateCount(); //h.size = size(h.left) + size(h.right) + 1;
		
		return oNewTopNode;
	}
	
	// Assuming that h is red and both h.left and h.getLeft().left
	// are black, make h.left or one of its children red.
	public function moveRedLeft() {
		// assert (h != null);
		// assert isRed(h) && !isRed(h.left) && !isRed(h.getLeft().left);

		flipColors();
		
		if ( getRight().getLeft().isBlack() ) 
			return this;
		
		setRight( getRight().rotateRight() );
		
		return rotateLeft().flipColors();
		
	}

	// Assuming that h is red and both h.right and h.getRight().left
	// are black, make h.right or one of its children red.
	public function moveRedRight() {
		// assert (h != null);
		// assert isRed(h) && !isRed(h.right) && !isRed(h.getRight().left);
		flipColors();
		
		if ( getLeft() != null && !getLeft().isLeftRed() ) 
			return this;
		
		return rotateRight().flipColors();
	}
	
	// restore red-black tree invariant
	public function balance() {
		var oNode = this;
		
		if ( oNode.isRightRed() )
			oNode = oNode.rotateLeft();
		
		if ( 
			oNode.isLeftRed() 
			&& oNode.getLeft() != null 
			&& oNode.getLeft().getLeft().isRed() 
		) 
			oNode = oNode.rotateRight();
		
		if ( oNode.isLeftRed() && oNode.isRightRed() )
			oNode.flipColors();

		return oNode.updateCount();
	}
	
	
	// insert the key-value pair in the subtree _oRooted at h
	public function set( key_ :CKey, value_ :CValue) {

		var compare = compareKey( key_ );
		if (compare < 0) {
			if ( getLeft() == null ) 
				setLeft( getTree().createNode( key_, value_ ) );
			else
				setLeft( getLeft().set( key_, value_ ) );
			 
		} else if (compare > 0) {
			if ( getRight() == null )
				setRight( getTree().createNode( key_, value_ ));
			else
				setRight( getRight().set( key_, value_ ) ); 
			
		} else
			value = value_;

		// fix-up any right-leaning links
		var node = this;
		if ( node.isRightRed() && !node.isLeftRed() )
			node = node.rotateLeft();
		
		if ( node.isLeftRed() && node.getLeft() != null && node.getLeft().isLeftRed() ) 
			node = node.rotateRight();
		
		if ( node.isRightRed() && node.isLeftRed() ) 
			node.flipColors();
		
		node.updateCount();

		return node;
	}
	
	// delete the key-value pair with the given key _oRooted at h
	public function delete( key_ :CKey ) { 
		// assert h.get(key) != null;

		var oNode = this;
		if ( oNode.compareKey( key_ ) < 0)  {
			if ( 
				oNode.getLeft() != null
				&& oNode.getLeft().isBlack()
				&& !oNode.getLeft().isLeftRed() 
			) {
				oNode = oNode.moveRedLeft();
			}
			oNode.setLeft( oNode.getLeft().delete( key_ ) );

		} else {
			if ( oNode.isLeftRed() )
				oNode = oNode.rotateRight();
			if ( oNode.compareKey( key_ ) == 0 && oNode.getRight() == null)
				return null;
			if ( !oNode.isRightRed() && !oNode.getRight().isLeftRed() )
				oNode = oNode.moveRedRight();
			if (oNode.compareKey( key_ ) == 0) {
				var x = oNode.getRight().getMin();
				oNode.key = x.getKey();
				oNode.value = x.getValue();
				// h.val = get(h.right, min(h.right).key);
				// h.key = min(h.right).key;
				oNode.setRight( oNode.getRight().deleteMin() );
			} else 
				oNode.setRight( oNode.getRight().delete( key_ ) );
		}
		return oNode.balance();
	}
	

	// delete the key-value pair with the minimum key root at h
	public function deleteMin() { 
		if (getLeft() == null)
			return null;

		var oNode = this;
		if ( getLeft().isBlack() && !getLeft().isLeftRed() )
			oNode = moveRedLeft();

		oNode.setLeft( oNode.getLeft().deleteMin() );
		
		return oNode.deleteMin().balance();
	}
	
	public function deleteMax() {
		
		var oNode = this;
		if( oNode.isLeftRed() )
			oNode = oNode.rotateRight();
		
		if( oNode.getRight() == null)
			return null;
		
		if( oNode.getRight().isBlack() && !oNode.getRight().isLeftRed() )
			oNode = oNode.moveRedRight();

		oNode.setRight( oNode.getRight().deleteMax() );

		return oNode.balance();
	}
	
}

class TreeIterator<CKey,CValue> {
	var _lNode :List<INode<CKey,CValue>>;

	public function new( oRoot :INode<CKey,CValue>) {
		_lNode.add( oRoot );
	}

	public function hasNext() {
		return !_lNode.isEmpty();
	}

	public function next() {
		
		
		while ( true ) {
			var oNode = _lNode.pop();
			
			if( oNode.getRight() != null )
				_lNode.push( oNode.getRight() );
			if ( oNode.getLeft() == null )
				return oNode.getValue();
			// else
			_lNode.push( oNode.getLeft() );
			oNode = oNode.getLeft();
		}
		return null;
	}
}

