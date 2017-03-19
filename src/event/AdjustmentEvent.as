package event
{
	import flash.events.Event;
	
	/**
	 * 与画面比例调整相关的事件类 
	 * @author yangq
	 * 
	 */	
	public class AdjustmentEvent extends Event
	{
		/**
		 * 调整画面 
		 */		
		public static const ADJUST:String = "adjust";
		
		public var option:String;
		
		public function AdjustmentEvent(type:String, opt:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.option = opt;
		}
		
		override public function clone():Event
		{
			return new AdjustmentEvent(type, option);
		}
	}
}