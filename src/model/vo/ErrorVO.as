package model.vo
{
	import consts.ErrorMsg;

	/**
	 * 错误VO 
	 * @author yangq
	 * 
	 */	
	public class ErrorVO
	{
		private var _code:int = -1;
		
		private var _msg:String;
		
		public function ErrorVO()
		{
		}

		/**
		 * 错误代码 
		 */
		public function get code():int
		{
			return _code;
		}

		/**
		 * @private
		 */
		public function set code(value:int):void
		{
			if(_code != value)
			{
				_code = value;
				_msg = ErrorMsg.getErrorMsg(value);
			}
			
		}

		/**
		 * 详细具体的错误消息 
		 */
		public function get msg():String
		{
			return _msg;
		}
	}
}