package event
{
	import flash.events.Event;
	
	/**
	 * Model类派发的事件类 
	 * @author yangq
	 * 
	 */	
	public class ModelEvent extends Event
	{
		/**
		 * 加载mp4进度中派发的事件 
		 */		
		public static const BYTES_LOADED_CHANGE:String = "bytes_loaded_change";
		
		/**
		 * 当前是直播的m3u8,界面类根据此事件类型做出相应改变 
		 */		
		public static const LIVE_M3U8:String = "live_m3u8";
		
		/**
		 * 显示视频前广告 
		 */		
		public static const SHOW_PREROLL_AD:String = "show_preroll_ad";
		
		/**
		 * 移除视频前广告 
		 */		
		public static const REMOVE_PREROLL_AD:String = "remove_preroll_ad";
		
		/**
		 * 显示第一帧图片 
		 */		
		public static const SHOW_FIRSTFRAMEPIC:String = "show_firstframepic";
		
		/**
		 * 显示封面 
		 */		
		public static const SHOW_POSTER:String = "show_poster";
		
		public var percent:Number = 0;
		
		public function ModelEvent(type:String, percent:Number=0, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.percent = percent;
		}
		
		override public function clone():Event
		{
			return new ModelEvent(type, percent);
		}
	}
}