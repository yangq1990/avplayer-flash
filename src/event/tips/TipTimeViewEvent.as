package event.tips
{
	import flash.events.Event;
	
	public class TipTimeViewEvent extends Event
	{
		public static const SHOW:String = "show_tiptimeview";
		
		public static const HIDE:String = "hide_tiptimeview";
		
		public var data:Object;
		
		public function TipTimeViewEvent(type:String, d:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = d;
		}
		
		override public function clone():Event
		{
			return new TipTimeViewEvent(type, data);
		}
	}
}