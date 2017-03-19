package view.tips
{
	import consts.FontConst;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flashx.textLayout.formats.TextAlign;
	
	/**
	 * 提示文字 
	 * @author yangq
	 * 
	 */	
	public class TipText extends Sprite
	{
		private var _tf:TextField;
		private var _bg:Shape;
		private var _border:Shape;
		private var _triangle:Shape;
		
		private var _txt:String;
		private var _w:uint;
		private var _h:uint;
		private var _triangleHeight:uint;
		private var _fillColor:uint;
		private var _fillAlpha:Number;
		private var _borderThickness:uint;
		private var _borderColor:uint;
		/**
		 * 
		 * @param txt 提示文字
		 * @param w 提示框宽度
		 * @param h 提示框高度
		 * @param triangleHeight 底部小三角形的高度
		 * @param fillColor 填充颜色
		 * @param fillAlpha 填充透明度
		 * @param borderThickness 边框宽度
		 * @param borderColor 边框颜色
		 * 
		 */		
		public function TipText(txt:String, w:uint, h:uint, triangleHeight:uint, fillColor:uint=0x202020, fillAlpha:Number=0.9, borderThickness:uint=1, borderColor:uint=0x57585a)
		{
			super();
			
			_txt = txt;
			_w = w;
			_h = h;
			_triangleHeight = triangleHeight;
			_fillColor = fillColor;
			_fillAlpha = fillAlpha;
			_borderThickness = borderThickness;
			_borderColor = borderColor;
			
			draw(txt, w, h, triangleHeight, fillColor, fillAlpha, borderThickness, borderColor);
		}
		
		private function draw(txt:String, w:uint, h:uint, triangleHeight:uint, fillColor:uint, fillAlpha:Number, borderThickness:uint, borderColor:uint):void {
			//textfield
			var format:TextFormat = new TextFormat(FontConst.YAHEI, 14, 0xffffff);
			format.align = TextAlign.CENTER;
			
			if(_tf == null) {
				_tf = new TextField();
				_tf.mouseEnabled = _tf.mouseWheelEnabled = _tf.multiline = _tf.wordWrap = false;
				_tf.defaultTextFormat = format;
			}
			
			_tf.text = txt;
			_tf.setTextFormat(format);
			_tf.width = _tf.textWidth + 5;
			_tf.height = _tf.textHeight + 5;
			if(_tf.textWidth > w-30) {
				w = _tf.textWidth+30;
			}
			
			_h = h;
			
			//填充背景
			if(_bg == null) {
				_bg = new Shape();
			} 
			var g:Graphics = _bg.graphics;
			g.clear();
			g.beginFill(fillColor, fillAlpha);
			g.drawRect(-w*0.5, -h*0.5, w, h); //注册点在中间
			g.endFill();
			addChild(_bg);
			
			//边框
			if(_border == null){
				_border = new Shape();
			}
			var border_g:Graphics = _border.graphics;
			border_g.clear();
			border_g.lineStyle(borderThickness, borderColor);
			border_g.moveTo(-w*0.5, -h*0.5);
			border_g.lineTo(-w*0.5, h*0.5); //左竖
			border_g.lineTo(-triangleHeight, h*0.5);   //左底横
			border_g.moveTo(triangleHeight, h*0.5);
			border_g.lineTo(w*0.5, h*0.5); //右底横
			border_g.lineTo(w*0.5, -h*0.5); //右竖
			border_g.lineTo(-w*0.5, -h*0.5); //顶横
			addChild(_border);
			
			//底部小三角
			if(_triangle == null) {
				_triangle = new Shape();
			}
			var triangle_g:Graphics = _triangle.graphics;
			triangle_g.clear();
			triangle_g.beginFill(fillColor, fillAlpha);
			triangle_g.lineStyle(borderThickness, borderColor);
			triangle_g.moveTo(-triangleHeight,0);
			triangle_g.lineTo(0,triangleHeight);
			triangle_g.lineTo(triangleHeight, 0);
			triangle_g.lineStyle(borderThickness, fillColor);
			triangle_g.lineTo(-triangleHeight,0);
			triangle_g.endFill();
			addChild(_triangle);
			_triangle.x = 0;
			_triangle.y = h*0.5-borderThickness;
			
			_tf.x = -_tf.width*0.5; 
			_tf.y = -_tf.height*0.5;
			addChild(_tf);
			
			this.mouseChildren = this.mouseEnabled = false;
		}
		
		/**
		 * 已生成过TipText对象，调用此方法替换文字，不用重新生成对象 
		 * @param txt
		 * 
		 */		
		public function setTxt(txt:String):void {
			if(_txt == txt) {
				return; //提示文字相同，直接return
			}
			
			_txt = txt;
			draw(_txt, _w, _h,_triangleHeight, _fillColor, _fillAlpha, _borderThickness, _borderColor);
		}
		
		override public function get height():Number {
			return _h;
		}
	}
}