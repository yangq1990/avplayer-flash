package controller
{	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	/**
	 * 任务队列类，按顺序执行任务, FIFO
	 * 全部任务成功执行后，派发Event.COMPLETE事件
	 * @author yangq
	 */
	public class TaskQueue extends EventDispatcher 
	{
		private var _activeTask:Function = null;
		private var _taskIndex:Number = -1;
		
		private var _taskSuccess:Dictionary;
		private var _taskFailure:Dictionary;
		private var _taskOrder:Array;

		private var failureState:Boolean = false;
		private var completed:Boolean = false;
		
		public function TaskQueue() 
		{
			_taskOrder = [];
			_taskSuccess = new Dictionary();
			_taskFailure = new Dictionary();
		}
		
		/**
		 * 把任务放入队列 
		 * @param task 
		 * @param success 任务执行成功后的回调
		 * @param failure 任务执行失败后的回调
		 * 
		 */		
		public function queueTask(task:Function, success:Function=null, failure:Function=null):void 
		{
			_taskOrder.push(task);
			if (success != null)
			{
				_taskSuccess[task] = success;
				_taskFailure[task] = failure;
			}
		}
		
		/**
		 * 开始按顺序执行任务 
		 * 
		 */		
		public function runTasks():void 
		{
			(_activeTask == null) && nextTask();
		}

		public function success(event:Event=null):void 
		{
			if (!failureState) 
			{
				var runSuccess:Function = _taskSuccess[_activeTask] as Function;
				if (runSuccess != null) 
				{
					runSuccess(event);
				}
				nextTask();
			}
		}
		
		public function failure(event:Event):void 
		{
			var runFailure:Function = _taskFailure[_activeTask] as Function;
			if (runFailure != null)
			{
				runFailure(event);
			}
			failureState = true;
		}

		private function nextTask():void 
		{ 
			if (_taskOrder.length > 0) 
			{
				_activeTask = _taskOrder.shift() as Function;
				_taskIndex++;
				_activeTask();
			} 
			else if (!completed) 
			{
				completed = true;
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}

		public function get taskIndex():Number
		{
			return _taskIndex;
		}		
	}
}