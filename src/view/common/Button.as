package view.common 
{
	
	import consts.FontConst;
	
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	
	import utils.UIUtil;
	
	/**
	 * 无状态切换的Button
	 * @author yangq
	 * 
	 */	
	public class Button extends BaseButton
	{
		protected var _w:Number;
		protected var _h:Number;
		protected var _back:uint;
		protected var _alpha:Number;
		protected var _isRound:Boolean;
		protected var _mouseOverCallback:Function;
		
		/**
		 *  
		 * @param w 宽
		 * @param h 高
		 * @param back 背景色
		 * @param alpha 透明度
		 * @param isRound 是否圆角矩形
		 * 
		 */		
		public function Button(label:String, w:Number, h:Number, back:uint, alpha:Number=1, isRound:Boolean=false)
		{		
			super(label);
			
			_w = w;
			_h = h;
			_back = back;
			_alpha = alpha;
			_isRound = isRound;
			
			drawBack();
			adjustTF();
			
			this.mouseChildren = false;
			this.mouseEnabled = this.buttonMode = true;		
		}
		
		private function drawBack():void
		{
			var g:Graphics = this.graphics;
			g.clear();
			g.beginFill(_back, _alpha);
			_isRound ? g.drawRoundRect(0, 0, _w, _h, 10, 10) : g.drawRect(0, 0, _w, _h); 
			g.endFill();					
		}
		
		override protected function initUI():void
		{
			super.initUI();
			_tf.setTextFormat(UIUtil.getTextFormat(FontConst.DEFAULT_TXT_COLOR));
			adjustTF();
		}
		
		public function registerMouseOverCallback(mouseOverCallback:Function):void
		{
			_mouseOverCallback = mouseOverCallback;
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);		
		}
		
		private function onMouseOver(evt:MouseEvent):void
		{
			_mouseOverCallback && _mouseOverCallback();
		}
		
		override protected function adjustTF():void
		{
			UIUtil.adjustTFWidthAndHeight(_tf);
			_tf.x = (_w - _tf.width) * 0.5;
			_tf.y = (_h - _tf.height) * 0.5;
		}
		
		override public function get width():Number
		{
			return _w;
		}
		
		override public function set width(value:Number):void
		{
			if(value != _w)
			{
				_w = value;
				drawBack();
				adjustTF();
			}
		}	
		
		override public function get height():Number
		{
			return _h;
		}	
		
		override public function set height(value:Number):void
		{
			if(value != _h)
			{
				_h = value;
				drawBack();
				adjustTF();
			}
		}
	}
}