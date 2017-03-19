package consts
{
	/**
	 * 视频无法播放提示文字
	 * @author yangq
	 * 
	 */	
	public class ErrorCode
	{
		public function ErrorCode()
		{
		}
		
		/**
		 * 视频地址404
		 */		
		public static const HEX_01:int = 0x01;
		
		/**
		 * 当前网络连接异常，请检查网络设置
		 */		
		public static const HEX_02:int = 0x02;
		
		/**
		 * 视频格式不正确，无法播放
		 */		
		public static const HEX_03:int = 0x03;
		
		/**
		 * 直播已结束
		 */		
		public static const HEX_04:int = 0x04;
		
		/**
		 * 视频内容已损坏，无法播放
		 */		
		public static const HEX_05:int = 0x05;
		
		/**
		 * 下载ts文件超时 
		 */		
		public static const HEX_06:int = 0x06;
		
		/**
		 * 下载ts文件触发安全沙箱错误 
		 */		
		public static const HEX_07:int = 0x07;
		
		/**
		 * 下载m3u8文件触发安全沙箱错误
		 */		
		public static const HEX_08:int = 0x08;
	}
}