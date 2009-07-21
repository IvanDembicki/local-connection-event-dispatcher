/**
 * @author iv
 */
package com.realaxy.lc {
	import flash.events.EventDispatcher;	

	/**
	 * LocalConnectionEventDispatcher.
	 * listener in first swf file:
	 * <pre>
	 * LocalConnectionEventDispatcher.getInstance().addEventListener(LocalConnectionEvent.LANGUAGE_CHANGED, onLanguageChanged);
	 * </pre>
	 * dispatcher in another swf file: 
	 * const languageChanged : LocalConnectionEvent = new LocalConnectionEvent(LocalConnectionEvent.LANGUAGE_CHANGED);
	 * LocalConnectionEventDispatcher.getInstance().dispatchLocalConnectionEvent(languageChanged);
	 *  
	 */

	public class LocalConnectionEventDispatcher extends EventDispatcher {

		private static var instance : LocalConnectionEventDispatcher;

		/**
		 * Singleton 
		 */

		public static function getInstance() : LocalConnectionEventDispatcher {
			if (instance == null) {
				instance = new LocalConnectionEventDispatcher(new Singletoniser());
			}
			return instance;
		}

		/**
		 * connection name for LocalConnection 
		 */

		public static function get connectionName() : String {
			return Dispatcher.connectionName;
		}

		// *******************************************
		//    INSTANCE
		// *******************************************

		private var dispatcher : Dispatcher;

		/**
		 * Constructor 
		 */

		public function LocalConnectionEventDispatcher(singletoniser : Singletoniser) {
			if (singletoniser == null) {
				throw new Error("LocalConnectionEventDispatcher is a singleton class, use getInstance() instead.");
			}
			initInstance();
		}

		private function initInstance() : void {
			dispatcher = new Dispatcher(this);
		}

		/**
		 * @param event LocalConnectionEvent.
		 */

		public function dispatchLocalConnectionEvent(event : LocalConnectionEvent) : Boolean {
			return dispatcher.dispatchLocalConnectionEvent(event);
		}
	}
}

import com.realaxy.lc.LocalConnectionEvent;
import com.realaxy.lc.LocalConnectionEventDispatcher;

import flash.events.StatusEvent;
import flash.net.LocalConnection;
import flash.net.SharedObject;

class Dispatcher {

	private static const LOCAL_PATH : String = "/";
	private static const DISPATCHER_PATH : String = "_dispatcher";
	private static const CONNECTIONS : String = "_connections";
	private static const SEPARATOR : String = ",";

	public static var connectionName : String = "";

	private const localConnectionReceiver : LocalConnection = new LocalConnection();

	private var holder : LocalConnectionEventDispatcher;
	private var senders : Array;

	function Dispatcher(holder : LocalConnectionEventDispatcher) {
		initInstance(holder);
	}

	private function initInstance(holder : LocalConnectionEventDispatcher) : void {
		connectionName = getConnectionID();
		this.holder = holder;
		connectToChannel();
		addToReceiversList();
		dispatchLocalConnectionEvent(new LocalConnectionEvent(LocalConnectionEvent.ADD_LISTENER));
	}

	private function getConnectionsList() : Array {
		const sharedObject : SharedObject = SharedObject.getLocal(DISPATCHER_PATH, LOCAL_PATH);
		const connections : String = sharedObject.data[CONNECTIONS] || "";
		const connectionsList : Array = connections.split(SEPARATOR);
		return connectionsList;
	}

	private function getConnectionID() : String {
		const connectionsList : Array = getConnectionsList();
		const busyObject : Object = {};
		
		for (var i : int = 0 ;i < connectionsList.length; i++) {
			busyObject[connectionsList[i]] = true;
		}
		
		for (i = 0;i < 10000; i++) {
			var id : String = "_" + i;
			if (!busyObject[id]) {
				return id;
			}
		}
		
		return null;
	}

	private function connectToChannel() : void {
		localConnectionReceiver.allowDomain("*");
		localConnectionReceiver.client = this;

		try {
			localConnectionReceiver.connect(connectionName);
		} catch (error : ArgumentError) {
			trace("Can't connect to " + connectionName + " ...the connection name is already being used by another SWF");
		}
	}

	public function removeFromReceiversList(connectionID : String) : void {
		const connectionsList : Array = getConnectionsList();
		for (var i : int = 0;i < connectionsList.length; i++) {
			var item : String = connectionsList[i];
			if (item == connectionID) {
				connectionsList.splice(i, 1);
				i--;
			}
		}
		const sharedObject : SharedObject = SharedObject.getLocal(DISPATCHER_PATH, LOCAL_PATH);
		sharedObject.data[CONNECTIONS] = connectionsList.join(SEPARATOR);
		sharedObject.flush();
	}

	private function addToReceiversList() : void {
		const connectionsList : Array = getConnectionsList();

		for (var i : int = 0;i < connectionsList.length; i++) {
			const item : String = connectionsList[i];
			if (item == connectionName) {
				connectionsList.splice(i, 1);
				i--;
			}
		}
		
		const sharedObject : SharedObject = SharedObject.getLocal(DISPATCHER_PATH, LOCAL_PATH);
		connectionsList.push(connectionName);
		sharedObject.data[CONNECTIONS] = connectionsList.join(SEPARATOR);
		sharedObject.flush();
	}

	public function dispatchLocalConnectionEvent(event : LocalConnectionEvent) : Boolean {
		const connectionsList : Array = getConnectionsList();
		
		senders = [];
		
		for (var i : int = 0;i < connectionsList.length; i++) {
			var connectionID : String = connectionsList[i] || "";
			if (connectionID.length) {
				try {
					senders.push(new Sender(this, connectionID, event.type));
				} catch (error : Error) {
					// TraceSender.send("com.realaxy.lc.LocalConnectionEventDispatcher.dispatchEvent: Error " + error.message);
				}
			}
		}
		return true;
	}

	public function receiver(type : String) : void {
		if (type == LocalConnectionEvent.ADD_LISTENER) {
			return;
		}
		if (holder.hasEventListener(type)) {
			const outEvent : LocalConnectionEvent = new LocalConnectionEvent(type);
			holder.dispatchEvent(outEvent);
		}
	}
}

class Sender {

	private static const LOCAL_CONNECTION_STATUS : String = "status";
	private static const LOCAL_CONNECTION_ERROR : String = "error";
	private static const RECEIVER_NAME : String = "receiver";

	private var eventType : String;
	private var connectionName : String;
	private var dispatcher : Dispatcher;
	private var sender : LocalConnection;

	public function Sender(target : Dispatcher, name : String, eventType : String) {
		super();
		initInstance(target, name, eventType);
	}

	private function initInstance(target : Dispatcher, name : String, type : String) : void {
		dispatcher = target;
		connectionName = name;
		eventType = type;
		
		sender = new LocalConnection();
		sender.client = dispatcher;
		sender.addEventListener(StatusEvent.STATUS, onConnectionStatus);
		sender.send(connectionName, RECEIVER_NAME, eventType);
	}

	private function onConnectionStatus(event : StatusEvent) : void {
		switch (event.level) {
			case LOCAL_CONNECTION_STATUS:
				break;
			case LOCAL_CONNECTION_ERROR:
				dispatcher.removeFromReceiversList(connectionName);
				break;
		}
	}
}

class Singletoniser {
}
















