/**
 * @author iv
 */
package {
	import flash.text.TextField;	

	import com.realaxy.lc.LocalConnectionEvent;
	import com.realaxy.lc.LocalConnectionEventDispatcher;

	import flash.display.Sprite;		

	public class ReceiverExample extends Sprite {

		private var counter : int = 0;
		private var outTxt : TextField;

		public function ReceiverExample() {
			super();
			initInstance();
		}

		private function initInstance() : void {
			initOutTextField();
			LocalConnectionEventDispatcher.getInstance().addEventListener(LocalConnectionEvent.LANGUAGE_CHANGED, onLanguageChanged);
		}
		
		private function onLanguageChanged(event : LocalConnectionEvent) : void {
			outTxt.appendText("\nonLanguageChanged()" + counter++);
			outTxt.scrollV = 1000;
		}

		private function initOutTextField() : void {
			outTxt = new TextField();
			outTxt.width = 600;
			outTxt.height = 400;
			outTxt.border = true;
			addChild(outTxt);
		}
	}
}
