package consts
{
	import flash.utils.Dictionary;

	/**
	 * 错误信息 
	 * @author yangq
	 * 
	 */	
	public class ErrorMsg
	{
		private static var codeMsgMap:Dictionary = new Dictionary();
		{
			codeMsgMap[ErrorCode.HEX_01] = "视频地址404";
			codeMsgMap[ErrorCode.HEX_02] = "当前网络连接异常，请检查网络设置";
			codeMsgMap[ErrorCode.HEX_03] = "视频格式不正确，无法播放";
			codeMsgMap[ErrorCode.HEX_04] = "直播已结束";
			codeMsgMap[ErrorCode.HEX_05] = "视频内容已损坏，无法播放";	
			codeMsgMap[ErrorCode.HEX_06] = "下载ts文件超时";
			codeMsgMap[ErrorCode.HEX_07] = "下载ts文件触发安全沙箱错误 ";
			codeMsgMap[ErrorCode.HEX_08] = "下载m3u8文件触发安全沙箱错误";
		}
		
		/**
		 * 根据错误代码返回错误信息 
		 * @param code 错误代码
		 * @return 
		 * 
		 */		
		public static function getErrorMsg(code:int):String
		{
			return codeMsgMap[code];
		}
	}
}