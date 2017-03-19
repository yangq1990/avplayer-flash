package view.tips
{
	import com.greensock.TweenLite;
	
	import consts.FontConst;
	import consts.TimerConst;
	
	import event.HomeTheaterModeEvent;
	import event.tips.BottomViewAreaEvent;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import model.Model;
	
	import org.osmf.events.MediaResChangeEvent;
	
	import view.base.BaseView;
	
	/**
	 * 底部提示区域界面 
	 * @author yangq
	 * 
	 */	
	public class BottomAreaView extends BaseView
	{
		private var _bg:Sprite;
		
		private var _tipsTF:TextField;
		
		private var _timeout:uint;
		
		public function BottomAreaView(m:Model)
		{
			super(m);
			
			_bg = new Sprite();
			addChild(_bg);
			
			_tipsTF = new TextField();
			_tipsTF.defaultTextFormat = new TextFormat(FontConst.YAHEI, FontConst.SIZE-2, FontConst.DEFAULT_OPTION_COLOR);
			addChild(_tipsTF);
			
			this.mouseChildren = this.mouseEnabled = this.visible = false;
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
			
			eventbus.addEventListener(BottomViewAreaEvent.SHOW_TIPS, onShowTips);
			eventbus.addEventListener(BottomViewAreaEvent.SHOW_TIPS_NOT_CLOSE, onShowTipsNotClose);
		}
		
		private function onShowTips(evt:BottomViewAreaEvent):void
		{
			killtween(this);
			
			_tipsTF.text = evt.tips;
			_tipsTF.width = _tipsTF.textWidth + 10;
			_tipsTF.y = 5;
			_tipsTF.x = 10;
			this.alpha = 1;
			this.visible = true;			
			render();
			
			clearTimer();
			_timeout = setTimeout(hide, TimerConst.DELAY);
		}
		
		public function onShowTipsNotClose(evt:BottomViewAreaEvent):void
		{
			killtween(this);
			
			_tipsTF.text = evt.tips;
			_tipsTF.width = _tipsTF.textWidth + 10;
			_tipsTF.y = 5;
			_tipsTF.x = 10;
			this.visible = true;
			this.alpha = 1;
			render();
		}
		
		override protected function hide():void
		{
			clearTimer();
			_tween = TweenLite.to(this, 0.5, {alpha:0, delay:3}); //延迟3s后执行
		}
		
		private function clearTimer():void
		{
			if(_timeout)
			{
				clearTimeout(_timeout);
				_timeout = undefined;
			}
		}
		
		override protected function onMediaResChangeDone(evt:MediaResChangeEvent):void
		{
			hide();
		}
		
		override protected function onEnterHomeTheaterMode(evt:HomeTheaterModeEvent):void
		{
			this.visible = false;
		}
		
		override protected function render():void
		{
			if(this.visible)
			{
				var g:Graphics = _bg.graphics;
				g.beginFill(0x222222, 0.8);
			    g.drawRect(0, 0, stageWidth, 40);
				g.endFill();
				
				isTextInputViewAvailable ? (this.y = stageHeight - controlbarHeight - textInputViewHeight - this.height) 
										 : (this.y = stageHeight - controlbarHeight - this.height);
			}
		}
		
		override public function get width():Number
		{
			return stageWidth;
		}
		
		override public function get height():Number
		{
			return 40;
		}	
	}
}