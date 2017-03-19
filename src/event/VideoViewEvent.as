package event
{
	import flash.events.Event;
	
	/**
	 * 与video界面相关的事件类 
	 * @author yangq
	 * 
	 */	
	public class VideoViewEvent extends Event
	{		
		/**
		 * MediaElement被添加到MediaContainer 
		 */		
		public static const MEDIA_ELEMENT_ADDED:String = "media_element_added";
		
		/**
		 * 调整视频画面百分比 
		 */		
		public static const ADJUST_PERCENT:String = "adjust_percent";
		
		public var percent:Number;
		
		public function VideoViewEvent(type:String, percent:Number=1, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.percent = percent;
		}
		
		override public function clone():Event
		{
			return new VideoViewEvent(type);
		}
	}
}