/**
 * @author iv
 */
package {
	import com.realaxy.lc.LocalConnectionEvent;
	import com.realaxy.lc.LocalConnectionEventDispatcher;

	import flash.display.Sprite;
	import flash.events.MouseEvent;		

	public class SenderExample extends Sprite {

		public function SenderExample() {
			super();
			initInstance();
		}

		private function initInstance() : void {
			
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
		}

		private function onStageMouseUp(event : MouseEvent) : void {
			dispatchLocalConnectionEvent();
		}

		private function dispatchLocalConnectionEvent() : void {
			trace("SenderExample.dispatchLocalConnectionEvent()");
			const languageChanged : LocalConnectionEvent = new LocalConnectionEvent(LocalConnectionEvent.LANGUAGE_CHANGED);
			LocalConnectionEventDispatcher.getInstance().dispatchLocalConnectionEvent(languageChanged);
		}
	}
}
