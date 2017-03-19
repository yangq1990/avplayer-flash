package controller.task
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	import org.osmf.utils.AVLog;
	
	/**
	 * 加载播放器皮肤类 
	 * @author yangq
	 * 
	 */	
	public class SkinLoader extends EventDispatcher
	{
		private var _swfLoader:URLLoader;
		private var _completeCallback:Function;
		private var _errorCallback:Function;
		private var _path:String;
		
		private var _dl_skin_start:int;
		
		public function SkinLoader(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		/**
		 *  
		 * @param completeCallback
		 * @param errorCallback
		 * 
		 */		
		public function registerCallback(completeCallback:Function, errorCallback:Function):void
		{
			_completeCallback = completeCallback;
			_errorCallback =  errorCallback;			
		}
		
		/**
		 * 根据路径加载皮肤swf 
		 * @param path
		 * 
		 */		
		public function load(path:String):void
		{
			if(path)
			{
				_path = path;
				_swfLoader = new URLLoader();
				_swfLoader.dataFormat = URLLoaderDataFormat.BINARY; //接收二进制数据，下载完成后 _swfLoader.data是ByteArray对象，可以直接给Loader类的loadBytes加载使用
				_swfLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_swfLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);	
				_swfLoader.addEventListener(Event.COMPLETE, onComplete);
				_swfLoader.load(new URLRequest(path));
				_dl_skin_start = getTimer(); //下载皮肤起始时间戳
			}
			else
			{
				_errorCallback && _errorCallback("找不到播放器皮肤路径！！！");
			}
		}
		
		private function onIOError(evt:IOErrorEvent):void
		{
			removeListeners();
			_errorCallback(evt.toString());
			destroy();
		}
		
		private function onSecurityError(evt:SecurityErrorEvent):void
		{
			removeListeners();
			_errorCallback(evt.toString());
			destroy();
		}
		
		private function onComplete(evt:Event):void
		{
			removeListeners();
			CONFIG::RELEASE {
				AVLog.info("下载皮肤耗时: " + (getTimer() - _dl_skin_start) + "ms", true);
			}
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadBytesComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadBytesIOError);
			loader.loadBytes(_swfLoader.data); //loadBytes() 方法是异步的
		}
		
		private function onLoadBytesComplete(evt:Event):void 
		{
			var lf:LoaderInfo = evt.target as LoaderInfo;
			lf.removeEventListener(Event.COMPLETE, onLoadBytesComplete);
			lf.removeEventListener(IOErrorEvent.IO_ERROR, onLoadBytesIOError);
			
			var getSkinElement_start:int = getTimer(); //获取皮肤元素起始时间戳
			
			var uiCls:Class = lf.applicationDomain.getDefinition("AVPLAYER_UI") as Class;				
			var ui:MovieClip = new uiCls() as MovieClip;
			
			CONFIG::RELEASE {
				AVLog.info("获取皮肤元素耗时: " + (getTimer() - getSkinElement_start) + "ms", true);
			}			
			
			_completeCallback.call(null, ui);	
			
			destroy();
		}
		
		//当运行时无法分析字节数组中的数据时由 contentLoaderInfo 对象调度
		private function onLoadBytesIOError(evt:IOErrorEvent):void
		{
			_errorCallback(evt.toString());
		}
		
		private function removeListeners():void
		{
			if(_swfLoader) {
				_swfLoader.removeEventListener(Event.COMPLETE, onComplete);
				_swfLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_swfLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			}
		}
		
		/**
		 * 释放资源 
		 * 
		 */		
		private function destroy():void
		{
			if(_swfLoader) 
			{
				try 
				{
					_swfLoader.close();
				} 
				catch(err:Error) 
				{}
				_swfLoader = null;
			}
		}
	}
}