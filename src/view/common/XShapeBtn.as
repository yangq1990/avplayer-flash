package view.common
{
	import consts.FontConst;
	import consts.PlayerConst;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * X图形按钮 
	 * @author yangq
	 * 
	 */	
	public class XShapeBtn extends Sprite
	{
		private static const W:uint = 8;
		private static const H:uint = 8;
		protected var _func:Function;
		private var _useEvent:Boolean;
		
		
		public function XShapeBtn(useEvent:Boolean=false)
		{
			super();
			_useEvent = useEvent;
			initUI();
			this.buttonMode = true;	
		}
		
		protected function initUI():void
		{
			var t_shape:Shape = new Shape();	//背景区域
			t_shape.graphics.clear();
			t_shape.graphics.beginFill(PlayerConst.BG_COLOR, 0);
			t_shape.graphics.drawRect(0, 0, W, H);
			t_shape.graphics.endFill();		
			t_shape.graphics.moveTo(0, 0);
			addChild(t_shape);
			
			var line:Shape = new Shape();  //画x
			line.graphics.lineStyle(2, FontConst.DEFAULT_OPTION_COLOR);
			line.graphics.moveTo(0, 0);
			line.graphics.lineTo(W, H);			
			line.graphics.moveTo(W, 0);
			line.graphics.lineTo(0, H);			
			addChild(line);
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
			if(_func != null)
			{
				!_useEvent ? _func() : _func.call(null, evt); 
			}
		}	
		
		override public function get width():Number
		{
			return W;
		}
		
		override public function get height():Number
		{
			return H;
		}
	}
}