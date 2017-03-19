package event
{
	import flash.events.Event;
	
	/**
	 * 与任务流程相关的事件类 
	 * @author yangq
	 * 
	 */	
	public class TaskEvent extends Event
	{		
		/**
		 * 解析网页参数complete 
		 */		
		public static const PARSE_COMPLETE:String = "parse_complete";
		
		/**
		 * 只传入vid, 通过http请求加载三次都未成功，表明此视频不可播放，但是这个不影响播放器的构造以及任务流的进行
		 * 如果播放器构造成功，则显示PlayerbackErrorView界面 
		 */		
		public static const LOAD_URLLIST_ERROR:String = "load_urllist_error";
		
		/**
		 * 加载配置complete 
		 */		
		public static const LOAD_CONFIG_COMPLETE:String = "load_config_complete";
		
		/**
		 * 所有的任务都complete 
		 */		
		public static const ALL_TASKS_COMPLETE:String = "all_tasks_complete";
		
		/**
		 * 执行任务流程时发生错误，而且这个错误会导致播放器无法正常构造 
		 */		
		public static const FATAL_ERROR:String = "fatal_error";		
		
		/**
		 * 错误信息 
		 */		
		public var errorMsg:String;
		
		public function TaskEvent(type:String, msg:String="", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			errorMsg = msg;	
		}
		
		override public function clone():Event
		{
			return new TaskEvent(type, errorMsg);
		}
	}
}