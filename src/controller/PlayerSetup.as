package controller
{
	import controller.task.ConfigLoader;
	import controller.task.ParametersParser;
	import controller.task.SkinLoader;
	
	import event.TaskEvent;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	import model.Model;
	
	import org.osmf.utils.AVLog;
	import org.osmf.utils.GlobalReference;
	
	import utils.StageReference;
	
	import view.View;
	
	/**
	 * 初始化播放器需要的数据
	 * @author yangq
	 * 
	 */	
	public class PlayerSetup extends EventDispatcher
	{
		private var _taskQueue:TaskQueue;
		private var _v:View;
		private var _m:Model;	
		
		public function PlayerSetup(v:View, m:Model)
		{
			this._m = m;
			this._v = v;
		}
		
		public function setup():void
		{
			_taskQueue = new TaskQueue();
			_taskQueue.addEventListener(Event.COMPLETE, onTasksComplete);
			
			_taskQueue.queueTask(parseParameter);
			_taskQueue.queueTask(loadSkin);
			_taskQueue.queueTask(loadConfig, loadConfigComplete);		
			_taskQueue.queueTask(setupView);
			
			_taskQueue.runTasks();			
		}
		
		/** 处理网页传入的参数 **/
		private function parseParameter():void
		{
			var parser:ParametersParser = new ParametersParser(_m);
			parser.addEventListener(TaskEvent.PARSE_COMPLETE, _taskQueue.success);
			parser.parse();
		}

		/** 加载皮肤 **/
		private function loadSkin():void
		{
			var skinLoader:SkinLoader = new SkinLoader();
			skinLoader.registerCallback(loadSkinCompleteHandler, loadSkinErrorHandler);
			skinLoader.load(_m.skinUrl);
		}
		
		/** 加载皮肤complete **/
		private function loadSkinCompleteHandler(ui:MovieClip):void
		{
			_m.ui = ui;
			_taskQueue.success();
		}
		
		/** 加载皮肤出错 **/
		private function loadSkinErrorHandler(msg:String):void
		{
			showOrInteractWithLoader();			
			dispatchEvent(new TaskEvent(TaskEvent.FATAL_ERROR, "Task Queue failed at step " + _taskQueue.taskIndex + ":loadSkin  " +  msg));
		}
		
		/** 加载播放器需要的配置文件 **/
		private function loadConfig():void
		{
			var config:ConfigLoader = new ConfigLoader();
			config.addEventListener(TaskEvent.LOAD_CONFIG_COMPLETE, _taskQueue.success);
			config.load();
		}
		
		/** 加载配置文件complete **/
		private function loadConfigComplete(evt:TaskEvent):void
		{
			_m.version = (evt.target as ConfigLoader).version;
		}
		
		private function setupView():void
		{
			try
			{				
				var temp:int = getTimer();
				
				_v.setupView();
				
				CONFIG::RELEASE {
					AVLog.info("构建播放器UI耗时：" + (getTimer() - temp) + "ms", true);
				}
				
				showOrInteractWithLoader();		
			}
			catch(err:Error)
			{
				_v.show();
				AVLog.error('PlayerSetup, setup view出错:' + err.toString() + err.message);
			}
		
			_taskQueue.success();
		}
		
		/**
		 * 判断avplayer.swf的使用方式，如果是被Loader.swf加载显示，调用interactWithLoader函数
		 * 如果是直接独立运行，则调用View类公开的show方法 
		 * 
		 */		
		private function showOrInteractWithLoader():void
		{
			if(StageReference.getInstance().root.parent.name == null) //独立运行，没有被loader.swf加载
			{
				showAVPlayerView();
			}
			else
			{
				interactWithLoader(); //被loader加载
			}
		}
			
		/**
		 * 和Loader.swf交互 
		 * 
		 */		
		private function interactWithLoader():void
		{
			var sharedEvent:EventDispatcher = StageReference.getInstance().root.loaderInfo.sharedEvents;
			sharedEvent.dispatchEvent(new Event("removeLoading")); //通知加载avplayer.swf的Loader.swf，avplayer.swf开始构造界面，Loader.swf收到事件后隐藏loading动画 
			sharedEvent.addEventListener("loadingRemoved", onLoadingRemoved);
		}
		
		private function onLoadingRemoved(evt:Event):void
		{
			StageReference.getInstance().root.loaderInfo.sharedEvents.removeEventListener("loadingRemoved", onLoadingRemoved);
			showAVPlayerView();
		}
		
		private function showAVPlayerView():void
		{
			_v.show();
		}		
		
		/** 队列里所有任务都已完成 **/
		private function onTasksComplete(evt:Event):void
		{
			dispatchEvent(new TaskEvent(TaskEvent.ALL_TASKS_COMPLETE));
		}
	}
}