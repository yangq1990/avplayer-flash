package view.bar
{
	import com.greensock.TweenLite;
	
	import consts.LayoutConst;
	
	import event.AVPlayerEvent;
	import event.HomeTheaterModeEvent;
	import event.ModelEvent;
	import event.bar.RightBarEvent;
	import event.bar.VolumeBarEvent;
	
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import model.Model;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	
	import view.base.BaseView;

	/**
	 * 通过 _skin 获取皮肤里对应的MovieClip
	 * 
	 */	
	public class RightBarView extends BaseView
	{
		/** 点击后全屏  **/
		private var _toFullScnBtn:MovieClip;		
		/** 点击后退出全屏  **/
		private var _toNormalScnBtn:MovieClip;	
		/** 鼠标是否move到需要显示VolumeBar的区域内  **/
		private var _withinArea:Boolean = false;
		/** rightbar原始的宽**/
		private var _skinWidth:Number = 0; 
		/** 等待进入网页全屏模式  **/
		private var _waitingToEnterWebpageFullScreen:Boolean = false;
		
		public function RightBarView(m:Model)
		{		
			super(m);			
			
			_skin = _ui.RightBar;
			_skinWidth = _skin.width;
			addChild(_skin);
			
			_toFullScnBtn = _skin.getChildByName("fullScnBtn") as MovieClip;
			_toNormalScnBtn = _skin.getChildByName("smallScnBtn") as MovieClip;
			
			_toFullScnBtn.visible = true;
			_toNormalScnBtn.visible = false;			
			
			addMouseEventListeners([_toFullScnBtn, _toNormalScnBtn]);
			
			this.visible = false;
		}
		
		private function addMouseEventListeners(mcArr:Array):void 
		{
			for each(var item:MovieClip in mcArr) 
			{
				item.buttonMode = true;
				item.mouseChildren = false;
				item.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverBtn);
				item.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutBtn);
				item.addEventListener(MouseEvent.CLICK, onMouseClickBtn);
			}
		}
		
		private function removeMouseEventListeners(mcArr:Array):void 
		{
			for each(var item:MovieClip in mcArr) 
			{
				item.enabled = false;
				item.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOverBtn);
				item.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOutBtn);
				item.removeEventListener(MouseEvent.CLICK, onMouseClickBtn);
			}
		}
		
		private function onMouseOverBtn(evt:MouseEvent):void 
		{
			var mc:MovieClip = evt.target as MovieClip;
			if(mc.totalFrames == 2) 
			{
				mc.gotoAndStop(2);
			}
			
			//显示提示文字
			var data:Object = {};
			data.btnName = mc.name;
			var point:Point = _skin.localToGlobal(new Point(mc.x, mc.y));
			data.x = point.x + mc.width*0.5;
			eventbus.dispatchEvent(new AVPlayerEvent(AVPlayerEvent.SHOW_TIPTEXT, data));
		}
		
		private function onMouseOutBtn(evt:MouseEvent):void {
			var mc:MovieClip = evt.target as MovieClip;
			if(mc.totalFrames == 2) {
				mc.gotoAndStop(1);
			}
			eventbus.dispatchEvent(new AVPlayerEvent(AVPlayerEvent.HIDE_TIPTEXT));
		}
		
		private function onMouseClickBtn(evt:MouseEvent):void {
			evt.stopPropagation();
			var mc:MovieClip = evt.target as MovieClip;
			switch(mc.name) {
				case "fullScnBtn":
					dispatchEvent(new AVPlayerEvent(AVPlayerEvent.TO_FULLSCREEN));		
					break;
				case "smallScnBtn":
					dispatchEvent(new AVPlayerEvent(AVPlayerEvent.TO_NORMALSCREEN));
					break;
			}
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
		
			eventbus.addEventListener(RightBarEvent.VIDEO_VIEW_DOUBLE_CLICKED, onVideoViewDoubleClicked);
			eventbus.addEventListener(RightBarEvent.CHILD_MOUSE_DISABLED, function(evt:RightBarEvent):void { _skin.mouseChildren=false; });
			eventbus.addEventListener(RightBarEvent.CHILD_MOUSE_ENABLED, function(evt:RightBarEvent):void { _skin.mouseChildren=true; });
			
			_m.addEventListener(ModelEvent.LIVE_M3U8, onLiveM3U8);
		}
		
		/** 
		 * 处理视频区域被双击 
		 * yangq  20160614
		 * **/
		private function onVideoViewDoubleClicked(evt:RightBarEvent):void 
		{
			if(displayState == StageDisplayState.NORMAL) 
			{
				dispatchEvent(new AVPlayerEvent(AVPlayerEvent.TO_FULLSCREEN));
			} 
			else 
			{ //退出全屏
				dispatchEvent(new AVPlayerEvent(AVPlayerEvent.TO_NORMALSCREEN));
			}
		}
		
		override protected function render():void
		{			
			!this.visible && (this.visible = true);
			TweenLite.killTweensOf(_skin);
			if(displayState == StageDisplayState.NORMAL) 
			{
				_toFullScnBtn.visible = true;
				_toNormalScnBtn.visible = false;		
			} 
			else 
			{
				_toFullScnBtn.visible = false;
				_toNormalScnBtn.visible = true;	
			}
			
			_skin.y = stageHeight - controlbarHeight + (controlbarHeight - this.height) * 0.5;
			
			if(isMinWidth) 
			{ //最小布局宽度
				_skin.x = stageWidth - _skinWidth -  LayoutConst.MARGIN_IN_MIN_WIDTH;
			}
			else 
			{
				_skin.x = stageWidth - _skinWidth -  LayoutConst.MARGIN_TO_PLAYER_BORDER;		
			}
			
			_skin.alpha = 1;
			
			
			isLive && showLiveView();
			//通知RightBarView布局
			eventbus.dispatchEvent(new VolumeBarEvent(VolumeBarEvent.LAYOUT, this.width));
		}
		
		override protected function onEnterHomeTheaterMode(evt:HomeTheaterModeEvent):void
		{
			killtween(_skin);
			_tween = TweenLite.to(_skin, 0.2, {alpha:0});
		}
		
		override protected function onExitHomeTheaterMode(evt:HomeTheaterModeEvent):void
		{
			if(_isExitingHTM || _skin.alpha == 1) //缓动中或者已经位于正确的位置上
				return;
			
			_isExitingHTM = true;
			_skin.alpha = 1;	
			TweenLite.from(_skin, 0.4, {alpha:0, onComplete: exitHTMTweenComplete});
		}
		
		/** 显示直播界面  **/
		private function onLiveM3U8(evt:ModelEvent):void
		{
			showLiveView();
		}
		
		/**
		 * 显示直播状态下的RightBarView 
		 * @param evt
		 * 
		 */		
		private function showLiveView():void
		{
		
		}
	
		override protected function onMediaPlayerStateChange(evt:MediaPlayerStateChangeEvent):void
		{
			if(_m.isPlaybackError)
			{
				if(displayState != StageDisplayState.NORMAL) //全屏时如果播放出错，自动退出全屏 
				{ 
					dispatchEvent(new AVPlayerEvent(AVPlayerEvent.TO_NORMALSCREEN));
				}
			}
		}
		
		/**
		 * 返回RightBar的高度，由于_qualityText的高度可能大于22，所以这里强制设置
		 * @return 
		 * 
		 */		
		override public function get height():Number 
		{
			return _toFullScnBtn.height;
		}
		
		/**
		 * 返回RightBar实际的展示的宽度 
		 * @return 
		 * 
		 */		
		override public function get width():Number 
		{
			return _toFullScnBtn.width;			
		}
	}
}