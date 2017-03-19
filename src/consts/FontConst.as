package consts
{
	/**
	 * 与字体有关的常量类 
	 * @author yangq
	 * 
	 */	
	public class FontConst
	{
		/**
		 * 默认选项字体颜色 
		 */		
		public static const DEFAULT_OPTION_COLOR:uint = 0xa9a9a9;
		
		/**
		 * 选中的文本颜色 
		 */		
		public static const SELECTED_TEXT_COLOR:uint  = 0xf05352;
		
		/**
		 * 默认文本颜色 
		 */		
		public static const DEFAULT_TXT_COLOR:uint = 0xffffff;
		
		/**
		 * rightbar 默认清晰度文本颜色
		 */		
		public static const DEFAULT_QUALITYTXT_COLOR:uint = 0x999999;
		
		/**
		 * 数字字体
		 */		
		public static const NUMBER_FONT:String = "Tahoma";
		
		/**
		 * 中文宋体
		 */		
		public static const CHINESE_FONT:String = "SimSun";
		
		/**
		 * 有些浏览器能识别微软雅黑(如chrome)
		 * 有些浏览器能识别Microsoft YaHei UI
		 * 这样写可保证在不同的浏览器上字体显示的一致性
		 */		
		public static const YAHEI:String = "微软雅黑,Microsoft YaHei";
		
		/**
		 * 字体大小 
		 */		
		public static const SIZE:uint = 14;
		
		/**
		 * 弹幕的子弹字体大小 
		 */		
		public static const BULLET_SIZE:uint = 24;
		
		/**
		 * 珊瑚红 
		 */		
		public static const CORAL:uint = 0xf05352;
		
		public function FontConst()
		{
		}
	}
}