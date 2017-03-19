package model.vo
{
	public class LogoVO
	{
		public function LogoVO()
		{
		}
		
		/**
		 * logo路径 
		 */		
		public var url:String;
		
		/**
		 * 状态 0 隐藏； 1 显示 
		 */		
		public var state:int = 0;
		
		/**
		 * 位置
		 * 0 左上角
		 * 1 右上角
		 * 2 左下角
		 * 4 右下角
		 *  
		 */		
		public var pos:int;
		
		/**
		 * 点击后跳转的链接 
		 */		
		public var link:String;
	}
}