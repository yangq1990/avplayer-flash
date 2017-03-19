package event.bar
{
	import flash.events.Event;
	
	/**
	 * 与RightBar相关的事件类 
	 * @author yangq
	 * 
	 */	
	public class RightBarEvent extends Event
	{
		/**
		 * RightBar的volumeMC显示静音状态 
		 */		
		public static const MUTE:String = "rightbar_mute";		
		
		/**
		 * RightBar的volumeMC解除静音状态 
		 */		
		public static const UNMUTE:String = "rightbar_unmute";
		
		/**
		 * 拖动timetrackbar时，禁用掉rightbar对鼠标事件的监听 
		 */		
		public static const CHILD_MOUSE_DISABLED:String = "rightbar_mouse_disabled";
		
		/**
		 * 释放timetrackbar时，恢复 rightbar对鼠标事件的监听 
		 */		
		public static const CHILD_MOUSE_ENABLED:String = "rightbar_mouse_enabled";
		
		/**
		 * 弹幕按钮显示开的状态 
		 */		
		public static const BARRAGE_ON:String = "rightbar_barrage_on";
		
		/**
		 * 弹幕按钮显示关的状态 
		 */		
		public static const BARRAGE_OFF:String = "rightbar_barrage_off";
		
		/**
		 * 弹幕界面隐藏的时候，发送弹幕，弹幕界面自动显示，并且设置界面里也要同步 
		 */		
		public static const BARRAGE_FORCE_ON:String = "rightbar_barrage_force_on";
		
		/**
		 * 视频区域被双击 
		 */		
		public static const VIDEO_VIEW_DOUBLE_CLICKED:String = "video_view_double_clicked";
		
		public function RightBarEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new RightBarEvent(type);
		}
	}
}