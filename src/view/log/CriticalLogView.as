package view.log
{
	import consts.FontConst;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import model.Model;
	
	import org.osmf.events.ToAVPlayerEvent;
	
	import view.base.BaseView;
	import view.common.TxtBtn;
	
	/**
	 * 重要日志界面，默认隐藏，用户按下shift+l键后呼出
	 * @author yangq
	 * 
	 * */
	public class CriticalLogView extends BaseView
	{
		private var _tf:TextField;
		private var _roundBtn:Sprite;
		private var _copyBtn:TxtBtn;		
		private var _stats:Stats;
		
		public function CriticalLogView(m:Model)
		{
			super(m);
			_tf = new TextField();
			
			var format:TextFormat = new TextFormat();
			format.color = 0xffffff;
			format.size = 13;
			format.font = FontConst.YAHEI;
			_tf.defaultTextFormat = format;
			
			_tf.width = stageWidth;
			_tf.height = stageHeight - controlbarHeight - 20;
			_tf.multiline = _tf.wordWrap = true;
			addChild(_tf);
			
			_roundBtn = new Sprite();
			var g:Graphics = _roundBtn.graphics;
			g.lineStyle(1, FontConst.CORAL);
			g.beginFill(FontConst.CORAL);
			g.drawRoundRect(0.5, 0.5, 48, 22, 18, 18);
			g.endFill();
			
			_copyBtn = new TxtBtn("复制");
			_copyBtn.selected = true;
			_copyBtn.setTextFormat(FontConst.YAHEI, 12, FontConst.DEFAULT_TXT_COLOR);
			_copyBtn.registerCallback(clickBtnHandler);
			_copyBtn.x = (48 - _copyBtn.width) * 0.5;
			_copyBtn.y = (22 - _copyBtn.height) * 0.5;
			_roundBtn.addChild(_copyBtn);
			
			_stats = new Stats();
			addChild(_stats);
			
			addChild(_roundBtn);
			
			this.visible = false;
		}
		
		override protected function addListeners():void 
		{
			super.addListeners();
			
			if(_m.debug) //打开调试面板
			{
				_stageRef.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				eventbus.addEventListener(ToAVPlayerEvent.CRITICAL_LOG, onGetCriticalLog);
			}			
		}
		
		private function clickBtnHandler(label:String):void
		{
			System.setClipboard(_tf.text);
		}
		
		private function onKeyDown(evt:KeyboardEvent):void
		{
			if(evt.keyCode == 76 && evt.shiftKey) 
			{
				if(!this.visible) {
					this.visible = true;
					render();
				} else {
					this.visible = false;
				}
			}
		}
		
		private function onGetCriticalLog(evt:ToAVPlayerEvent):void
		{
			_tf.appendText(evt.log + "\n");
		}
		
		override protected function render():void
		{
			if(this.visible) 
			{
				var g:Graphics = this.graphics;
				g.clear();
				g.beginFill(0x000000, 0.8);
				g.drawRect(0,0,stageWidth, stageHeight - controlbarHeight - 15);
				g.endFill();
				
				_tf.width = stageWidth;
				_tf.height = stageHeight - controlbarHeight - 20;
				
				_roundBtn.y = stageHeight - _roundBtn.height - 100;
				_roundBtn.x = stageWidth - _roundBtn.width - 100;
				
				if(_stats != null) {
					_stats.x = stageWidth - _stats.width;	
				}
			}
		}
	}
}