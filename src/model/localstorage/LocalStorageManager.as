package model.localstorage
{
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;

	/**
	 * avplayer本地存储管理器 
	 * @author yangq
	 * 
	 */	
	public class LocalStorageManager extends EventDispatcher
	{
		private var _so:SharedObject;
		
		/** 用户是否允许本地存储  **/
		private var _allowable:Boolean = true;
		
		public function LocalStorageManager()
		{
			try
			{
				_so = SharedObject.getLocal("avplayer");
				_so.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			}
			catch(err:Error)
			{
				CONFIG::DEBUG 
				{
					trace("禁用了本地存储");
				}
				_allowable = false;
			}
		}
		
		private function onNetStatus(evt:NetStatusEvent):void
		{
			if(evt.info.code == "SharedObject.Flush.Failed")
			{
				CONFIG::DEBUG {
					trace("无法存储数据到本地");
				}
				_allowable = false;
			}
		}
		
		/**
		 * 获取本地记录的AVPlayer的音量 
		 * @return 
		 * 
		 */		
		public function getPlayerVolume():int
		{
			var volume:int = _so.data.volume;
	
			if(_allowable)
			{		
				if(volume == 0)
				{
					volume = _so.data.volume = 50; //默认值是50；
					_so.flush();
				}
			}
			else
			{
				volume = 70;
			}
			
			return volume;
		}
		
		public function savePlayerVolume(volume:int):void
		{
			if(_allowable)
			{
				_so.data.volume = volume;
				_so.flush();
			}
		}
		
		private function get isAllowed():Boolean
		{
			return _allowable;
		}
	}
}