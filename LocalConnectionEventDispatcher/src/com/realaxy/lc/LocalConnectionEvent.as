/**
 * @author iv
 */
package com.realaxy.lc {

	import flash.events.Event;				

	public class LocalConnectionEvent extends Event {

		/*
		 * add your event constants
		 * use SharedObject to share parameters
		 */
		public static const LANGUAGE_CHANGED : String = "languageChanged";
		public static const ADD_LISTENER : String = "addListener";

		public function LocalConnectionEvent(type : String,bubbles : Boolean = false,cancelable : Boolean = false) {
			super(type, bubbles, cancelable);
		}

		override public function clone() : Event {
			return new LocalConnectionEvent(type);
		}
	}
}