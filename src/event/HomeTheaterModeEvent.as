package event
{
	import flash.events.Event;
	
	/**
	 * 家庭影院模式事件类 
	 * @author yangq
	 * 
	 */	
	public class HomeTheaterModeEvent extends Event
	{		
		/**
		 * 进入家庭影院模式，即舞台上只有VideoView，其他界面元素隐藏或者放到不引人注意的地方 
		 */		
		public static const ENTER:String = "enter_home_theater";
		
		/**
		 * 退出家庭影院模式 
		 */		
		public static const EXIT:String = "exit_home_center";
		
		public function HomeTheaterModeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return HomeTheaterModeEvent(type);
		}
	}
}