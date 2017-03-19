package event.bar
{
	import flash.events.Event;
	
	/**
	 * 与VolumeBar界面有关的事件 
	 * @author yangq
	 * 
	 */	
	public class VolumeBarEvent extends Event
	{
		/**
		 * 音量条显示静音状态 
		 */		
		public static const MUTE:String = "mute_volumebar";
		
		/**
		 * 音量调解除静音状态 
		 */		
		public static const UNMUTE:String = "unmute_volumebar";
		
		/**
		 * 显示音量条 
		 */		
		public static const SHOW:String = "show_volumebar";		
		
		/**
		 * 隐藏音量条 
		 */		
		public static const HIDE:String = "hide_volumebar";
		
		/**
		 * 按下键盘上箭头增加音量 
		 */		
		public static const INCREASE:String = "increase_volume";
		
		/**
		 * 按下键盘下箭头减小音量
		 */		
		public static const DECREASE:String = "decrease_volume";
		
		/**
		 * volumebar布局 
		 */		
		public static const LAYOUT:String = "layout_volume_bar";
		
		public var data:*;
		
		public function VolumeBarEvent(type:String, d:*=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = d;
		}
		
		override public function clone():Event
		{
			return new VolumeBarEvent(type, data);
		}
	}
}