package storo.ribbon;
import sweet.ribbon.RibbonDecoder;
import storo.ribbon.decoder.StoroRefDecoder;

/**
 * ...
 * @author 
 */
class StoroRibbonDecoder extends RibbonDecoder implements IFullDecoder {

	public function new( oStrategy :StoroRibbonStrategy ) {
		super( oStrategy );
	}
	
	public function setPartialMode( bPartialMode :Bool ) {
		cast(_oStrategy.getDecoder(20), StoroRefDecoder).setPartialMode( bPartialMode );
	}
	
}