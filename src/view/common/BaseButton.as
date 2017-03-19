package view.common
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import utils.UIUtil;
	
	/**
	 * 自定义Button基类 
	 * @author yangq
	 * 
	 */	
	public class BaseButton extends Sprite
	{
		protected var _func:Function;
		protected var _tf:TextField;		
		protected var _label:String;
		
		public function BaseButton(label:String)
		{
			super();
			_label = label;
			initUI();
			this.buttonMode = true;
		}
		
		protected function initUI():void
		{
			_tf = new TextField();
			_tf.mouseEnabled = _tf.mouseWheelEnabled = _tf.selectable = false;
			_tf.antiAliasType = AntiAliasType.ADVANCED;
			_tf.text = _label;
			addChild(_tf);
		}
		
		/**
		 * 注册回调函数 
		 * @param callback
		 * 
		 */		
		public function registerCallback(callback:Function):void
		{
			_func = callback;
			this.addEventListener(MouseEvent.CLICK, onMouseClick);
		}
		
		protected function onMouseClick(evt:MouseEvent):void
		{
			(_func != null) && _func.call(null, label);
		}	
		
		/**
		 * Button label属性 
		 * 
		 * @return 
		 * 
		 */		
		public function get label():String
		{
			return _tf.text;
		}
		
		public function set label(value:String):void
		{
			if(_tf.text != value)
			{
				_tf.text = value;
				adjustTF();
			}			
		}
		
		protected function adjustTF():void
		{
			
		}
		
		public function setTextFormat(font:String, size:int, color:uint):void
		{
			var textformat:TextFormat = new TextFormat(font, size, color);
			_tf.setTextFormat(textformat);
			UIUtil.adjustTFWidthAndHeight(_tf);
		}
	}
}