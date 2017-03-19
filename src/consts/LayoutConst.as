package consts
{
	/**
	 * 与布局有关的常量类 
	 * @author yangq
	 * 
	 */	
	public class LayoutConst
	{
		/**
		 * leftbar最左边和rightbar最右边距播放器边界的像素值
		 */		
		public static const MARGIN_TO_PLAYER_BORDER:int = 20;
		
		/**
		 * 最小宽度时 leftbar最左边和rightbar最右边距播放器边界的像素值
		 */		
		public static const MARGIN_IN_MIN_WIDTH:int = 15;
		
		/**
		 * 在bottombar上方一个高度为25px的矩形区域(宽度为stagewidth)
		 * 用以检测以便调整TimeTrackBar的显示 
		 */		
		public static const HOTZONE_HEIGHT:int = 25;
		
		/**
		 * 弹幕距离顶部边界的margin 
		 */		
		public static const BARRAGE_TO_TOP_MARGIN:int = 10;
		
		/**
		 * 设置面板按钮间隔, 设计图上14px, 文字的宽度强制设置的比原来宽10px，所以这里设置4
		 */		
		public static const BUTTON_GAP:int = 4;
		
		/**
		 * 设置面板item间隔 
		 */		
		public static const ITEM_GAP:int = 18;
		
		public static const ITEMLABEL_TO_LEFT:int = 10;
		
		/**
		 * 弹幕设置面板上颜色方块间隔 
		 */		
		public static const LUMP_GAP:int = 10;
		
		/**
		 * 弹幕位于视频显示区域上方
		 */		
		public static const UPSIDE:String = "upside";
		
		/**
		 * 弹幕分布于视频显示区域 
		 */		
		public static const FULL:String = "full";
		
		public function LayoutConst()
		{
		}
	}
}