package event.bar
{
	import flash.events.Event;
	
	/**
	 * 与LeftBar相关的事件类 
	 * @author yangq
	 * 
	 */		
	public class LeftBarEvent extends Event
	{
		/**
		 * 拖动timetrackbar的时候，leftbar的elapsedTxt文字要立即更改 
		 */		
		public static const VALIDATE_CURRENT_TIME:String = "validate_current_time";
		
		public var data:Number
		
		public function LeftBarEvent(type:String, d:Number = 0, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = d;
		}
		
		override public function clone():Event
		{
			return new LeftBarEvent(type, data);
		}
	}
}