package utils
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	/**
	 * URLMonitor 类监视基于 HTTP 或 HTTPS 的服务的可用性 
	 * @author yangq
	 * 
	 */	
	public class URLMonitor
	{
		private var _urlRequest:URLRequest;
		
		//200（正常）
		//202（可接受）
		//204（无内容）
		//205（重置内容）
		//206（部分内容，响应带有 Range 标头的请求）
		private var _acceptableStatusCodes:Array = [200, 202, 204, 205, 206];
		
		private var _available:Boolean = false;// 服务是否 可用，默认为false
		
		private var _callback:Function;
		
		private var _executed:Boolean = false; //回调函数是否执行过
		
		private var _loader:URLLoader;
		
		public function URLMonitor(urlRequest:URLRequest, callback:Function, acceptableStatusCodes:Array = null)
		{
			_urlRequest = urlRequest;
			_callback = callback;			
			if(acceptableStatusCodes != null)
			{
				_acceptableStatusCodes = acceptableStatusCodes;
			}	
		}
		
		public function checkStatus():void
		{
			destroy();
			_loader = new URLLoader();
			_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_loader.addEventListener(Event.COMPLETE, onComplete);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_loader.load(_urlRequest);
		}
		
		private function onHttpStatus(evt:HTTPStatusEvent):void
		{
			if(_acceptableStatusCodes.indexOf(evt.status) != -1)
			{
				available = true;
			}
			else
			{
				available = false;
			}
		}
		
		private function onIOError(evt:IOErrorEvent):void
		{
			available = false;
		}
		
		private function onSecurityError(evt:SecurityErrorEvent):void
		{
			available = false;
		}
		
		private function onComplete(evt:Event):void
		{
			available = true;
		}

		public function get available():Boolean
		{
			return _available;
		}

		public function set available(value:Boolean):void
		{
			if(!_executed)
			{
				_executed = true;
				_available = value;
				_callback.call(null, _available);
			}
			else
			{
				destroy();
			}
		}
		
		private function destroy():void
		{
			if(_loader)
			{
				_loader.close();
				_loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
				_loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_loader.removeEventListener(Event.COMPLETE, onComplete);
				_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				_loader = null;
			}		
		}		
	}
}