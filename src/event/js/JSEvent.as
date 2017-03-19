package event.js
{
	import flash.events.Event;
	
	/**
	 * 与JS有关的事件类 
	 * @author yatsen_yang
	 * 
	 */	
	public class JSEvent extends Event
	{
		/**
		 * 截图 
		 */		
		public static const SCREENSHOT:String = "screenshot";
		
		/**
		 * 二维码 
		 */		
		public static const QRCODE:String = "qrcode";
		
		/**
		 * 暂停 
		 */		
		public static const PAUSE:String = "fl_pause";
		
		/**
		 * 播放 
		 */		
		public static const PLAY:String = "fl_play";
		
		/**
		 * 登录 
		 */		
		public static const LOGGEDIN:String = "fl_loggedin";
		
		/**
		 * 弹幕 
		 */		
		public static const BARRAGE_MSG:String = "fl_barrage_msg";
		
		/**
		 * 静音 
		 */		
		public static const MUTE:String = "fl_mute";
		
		/**
		 *取消静音 
		 */		
		public static const UNMUTE:String = "fl_unmute";
		
		/**
		 * Seek
		 * */
		public static const SEEK:String = "fl_seek";
		
		/**
		 * 成功进入网页全屏模式 
		 */		
		public static const ENTER_WEBPAGEFULLSCREEN_SUCCESS:String = "enter_webpagefullscreen_success";
		
		/**
		 * 成功退出网页全屏模式 
		 */		
		public static const EXIT_WEBPAGEFULLSCREEN_SUCCESS:String = "exit_webpagefullscreen_success";
		
		
		public var data:*;
		
		public function JSEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
		
		override public function clone():Event
		{
			return new JSEvent(type, data, bubbles, cancelable);
		}
	}
}