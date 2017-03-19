package model.vo
{
	public class VideoVO
	{
		/**
		 * 当前是否为真正的直播 
		 */		
		public var isLive:Boolean = false;
		
		/**
		 * 视频标题 
		 */		
		public var title:String; 
		
		/**
		 * 点击底部logo后跳转的链接 
		 */		
		public var link:String;
		
		/**
		 * 第一帧截图url 
		 */		
		public var firstFramePicURL:String;
		
		/**
		 * 视频封面 
		 */		
		public var poster:String;
		
		public function VideoVO()
		{
		}
	}
}