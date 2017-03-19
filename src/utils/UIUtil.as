package utils
{
	import consts.FontConst;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;

	/**
	 * 与UI调整有关的界面类 
	 * @author yangq
	 * 
	 */	
	public class UIUtil
	{
		public function UIUtil()
		{
		}
		
		/**
		 * 检测字符串是否全部由空格组成 
		 * @param str
		 * @return 
		 * 
		 */		
		public static function isStringComposedOfSpace(str:String):Boolean
		{
			var len:int = str.length;
			var flag:Boolean = true;
			for(var i:int = 0; i < len; i++)
			{
				if(str.charAt(i) != " ")
				{
					flag = false;
					break;
				}
			}
			
			return flag;
		}
		
		/**
		 * 调整textfield的宽度和高度 
		 * @param tf
		 * 
		 */		
		public static function adjustTFWidthAndHeight(tf:TextField):void
		{
			tf.width = tf.textWidth + 10;
			tf.height = tf.textHeight + 5;
		}
		
		/**
		 * 获取文本按钮的textformat 
		 * @param selected
		 * 
		 */		
		public static function getTextFormat(color:uint):TextFormat
		{
			var tf:TextFormat = new TextFormat(FontConst.CHINESE_FONT, FontConst.SIZE, color);
			tf.align = "center";
			return tf;
		}
		
		/**
		 * Panel面板里，生成TextField对象 
		 * @param label 文字
		 * @return 
		 * 
		 */		
		public static function getTextField(label:String):TextField
		{
			var tf:TextField = new TextField();
			tf.mouseEnabled = tf.mouseWheelEnabled = tf.selectable = false;
			tf.defaultTextFormat = UIUtil.getTextFormat(FontConst.DEFAULT_TXT_COLOR);
			tf.text = label;
			tf.width = tf.textWidth + 5;
			tf.height = tf.textHeight + 5;
			
			return tf;
		}
		
		/**
		 * 把textfield转成bitmapdata
		 * @param str 文字
		 * @return 
		 * 
		 */		
		public static function getBitmapDataByTF(str:String):BitmapData
		{
			var tf:TextField = new TextField();
			tf.defaultTextFormat = UIUtil.getTextFormat(FontConst.DEFAULT_TXT_COLOR);
			tf.mouseWheelEnabled = tf.mouseEnabled = tf.selectable = false;
			tf.text = str;			
			tf.width = tf.textWidth + 5;
			tf.height = tf.textHeight + 5;
			
			var bmd:BitmapData = new BitmapData(tf.width, tf.height);
			bmd.colorTransform(new Rectangle(0,0,tf.width,tf.height), new ColorTransform(0,0,0,0)); //设置transform
			bmd.draw(tf, null, null, null, null, true);
			
			return bmd;
		}
		
		/**
		 * 返回Panel Item需要的字典数据 
		 * @param label
		 * @param event
		 * @return 
		 * 
		 */		
		public static function getDictionary(label:String, event:Event=null):Dictionary
		{
			var dict:Dictionary = new Dictionary();
			dict["label"] = label;
			dict["event"] = event;
			return dict;
		}
	}
}