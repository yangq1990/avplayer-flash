package event.bar
{
	import flash.events.Event;
	
	/**
	 * 与TimeTrackBar相关的事件类  
	 * @author yangq
	 * 
	 */	
	public class TimeTrackBarEvent extends Event
	{
		/**
		 * 鼠标在热区里 
		 */		
		public static const MOUSE_IN_HOTZONE:String = "mouse_in_hotzone";
		
		/**
		 * 鼠标移除热区 
		 */		
		public static const MOUSE_OUT_HOTZONE:String = "mouse_out_hotzone";
		
		public function TimeTrackBarEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);			
		}
	}
}