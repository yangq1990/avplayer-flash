package event
{
	import flash.events.Event;
	
	/**
	 * 与AVPlayer交互操作有关的事件类
	 * @author yangq
	 * 
	 */	
	public class AVPlayerEvent extends Event
	{
		/**
		 * 调整音量 <br/>
		 * 此时数据结构为{'volume':Number} <br/>
		 */		
		public static const ADJUST_VOLUME:String = "adjust_volume";
		
		/**
		 * 播放 
		 */		
		public static const PLAY:String = "play";
		
		/**
		 * 暂停 
		 */		
		public static const PAUSE:String = "pause";
		
		/**
		 * 停止 
		 */		
		public static const STOP:String = "stop";
		
		/**
		 * 拖动 
		 */		
		public static const SEEK:String = "seek";		
		
		/**
		 * 单击视频区域 
		 */		
		public static const CLICK_VIDEO:String = "click_video";
		
		/**
		 * 切换到全屏 
		 */		
		public static const TO_FULLSCREEN:String = "to_fullscreen";
		
		/**
		 * 切换到普通屏 
		 */		
		public static const TO_NORMALSCREEN:String = "to_normalscreen";

		/**
		 * 静音 
		 */		
		public static const MUTE:String = "mute";
		
		/**
		 * 取消静音，恢复静音之前状态 
		 */		
		public static const UNMUTE:String = "unmute";		
		
		/**
		 * 无法播放视频，用户点击刷新
		 */		
		public static const REFRESH:String = "refresh";
		
		/**
		 * 存储设置 
		 */		
		public static const SAVE_SETTINGS:String = "save_settings";
		
		/**
		 * 重播 
		 */		
		public static const REWIND:String = "rewind";
		
		/**
		 * 显示提示文字 
		 */		
		public static const SHOW_TIPTEXT:String = "show_tiptext";
		
		/**
		 * 隐藏提示文字 
		 */		
		public static const HIDE_TIPTEXT:String = "hide_tiptext";
		
		public var data:Object;
		
		public function AVPlayerEvent(type:String, d:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			data = d;
		}
		
		override public function clone():Event
		{
			return new AVPlayerEvent(type, data);
		}
	}
}