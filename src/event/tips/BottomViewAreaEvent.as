package event.tips
{
	import flash.events.Event;
	
	/**
	 * 与底部提示区域相关的事件类 
	 * @author yangq
	 * 
	 */	
	public class BottomViewAreaEvent extends Event
	{
		public static const SHOW_TIPS:String = "bottomviewarea_showtips";
		
		public static const SHOW_TIPS_NOT_CLOSE:String = "bottomviewarea_showtips_not_close";
		
		public static const HIDE_TIPS:String = "bottomviewarea_hidetips";
		
		public var tips:String;
		
		public function BottomViewAreaEvent(type:String, tips:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.tips = tips;
		}
		
		override public function clone():Event
		{
			return new BottomViewAreaEvent(type, tips);
		}
	}
}