package view.bar
{
	import com.greensock.TweenLite;
	
	import consts.LayoutConst;
	
	import event.AVPlayerEvent;
	import event.HomeTheaterModeEvent;
	import event.ModelEvent;
	import event.bar.LeftBarEvent;
	
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import model.Model;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.ToAVPlayerEvent;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.traits.PlayState;
	
	import view.base.BaseTimeChangeView;
	
	/**
	 * 通过 _ui.LeftBar 获取皮肤里对应的MovieClip
	 * 
	 */	
	public class LeftBarView extends BaseTimeChangeView
	{
		private var _playBtn:MovieClip;
		private var _pauseBtn:MovieClip;
		private var _replayBtn:MovieClip;
		private var _elapsedTxt:TextField;
		private var _totalTxt:TextField;
		
		public function LeftBarView(m:Model)
		{						
			super(m);			
			
			_skin = _ui.LeftBar;
			addChild(_skin);
			
			_playBtn = _skin.getChildByName("playBtn") as MovieClip;		
			_pauseBtn = _skin.getChildByName("pauseBtn") as MovieClip;
			_replayBtn = _skin.getChildByName("replayBtn") as MovieClip;
			
			_elapsedTxt = _skin.getChildByName("elapsedTxt") as TextField;
			_totalTxt = _skin.getChildByName("totalTxt") as TextField;
			_elapsedTxt.visible = _totalTxt.visible = _skin.seperatorTxt.visible = true;
			
			_playBtn.visible = true;
			_replayBtn.visible = _pauseBtn.visible = false;			
			
			addMouseEventListeners([_playBtn, _pauseBtn, _replayBtn]);
			
			if(!_m.autoPlay) {  //非自动播放下显示第二帧
				_playBtn.gotoAndStop(2);
			}
			
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
		
		private function onMouseOutBtn(evt:MouseEvent):void
		{
			var mc:MovieClip = evt.target as MovieClip;
			if(mc.totalFrames == 2) {
				mc.gotoAndStop(1);
			}
		
			eventbus.dispatchEvent(new AVPlayerEvent(AVPlayerEvent.HIDE_TIPTEXT));
		}
		
		private function onMouseClickBtn(evt:MouseEvent):void {
			var mc:MovieClip = evt.target as MovieClip;
			switch(mc.name) {
				case "playBtn":
					playHandler();
					break;
				case "pauseBtn":
					pauseHandler();
					break;
				case "replayBtn":
					replayHandler();
					break;
			}
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
			
			eventbus.addEventListener(LeftBarEvent.VALIDATE_CURRENT_TIME, onValidateCurrentTime);
			_stageRef.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			eventbus.addEventListener(ToAVPlayerEvent.PLAYER_SEEKING_COMPLETE, onPlayerSeekingComplete);
		}
		
		private function onValidateCurrentTime(evt:LeftBarEvent):void
		{
			!isLive && setTime(evt.data, duration);	
		}
		
		override protected function onPlayStateChange(evt:PlayEvent):void
		{
			if(evt.playState==PlayState.PLAYING)
			{
				setPlayStatus(true);
			}
			else if(evt.playState==PlayState.PAUSED)
			{
				setPlayStatus(false);
			}
			else if(evt.playState==PlayState.STOPPED)
			{
				if(_m.isPlaybackComplete) {  //播放结束时不再处理这个状态  yangq
					return;
				}
				
				setPlayStatus(false);
				setTime(0,_m.mediaPlayer.duration);
			}
		}
		
		private function setPlayStatus(bool:Boolean):void
		{
			_pauseBtn.visible = bool;
			_playBtn.visible = !bool;
			_replayBtn.visible && (_replayBtn.visible = false);
			
			if(!isLive) //点播
			{
				if(!_elapsedTxt.visible)
				{
					_elapsedTxt.visible = _totalTxt.visible = _skin.seperatorTxt.visible = true;
				}
			}
			else //直播时不显示时间
			{
				if(_elapsedTxt.visible)
				{
					_elapsedTxt.visible = _totalTxt.visible = _skin.seperatorTxt.visible = false;
				}	
			}
		}
		
		private function onPlayerSeekingComplete(evt:ToAVPlayerEvent):void
		{
			_playerInSeeking = false;
			//如果播放器先进入了暂停状态，然后又触发player seeking complet状态，则自动播放
			if(_m.playState == MediaPlayerState.PAUSED) {
				playHandler();
			}
		}
		
		override protected function setTime(current:Number,total:Number):void
		{
			if(total - current < 0.5)
			{
				current = total;
			}
			
			_elapsedTxt.text = _numToTime.toHMS(current);			
			_totalTxt.text = _numToTime.toHMS(total);
		}
		
		private function replayHandler():void
		{
			//重播就是seek(0)，需要重置_globalRef.seek_b，也是一个pause-to-play的过程，因此需要重置_globalRef.pause_b
			//重播后的机制和移动端保持一致，认为是一次新的播放，playid等数据都要重新设值  yangq 20160825
			
			_playBtn.visible = _replayBtn.visible = false;
			if(!isLive)
			{
				_pauseBtn.visible = _elapsedTxt.visible = _totalTxt.visible = _skin.seperatorTxt.visible = true;
			}

			dispatchEvent(new AVPlayerEvent(AVPlayerEvent.SEEK, 0));
		
			dispatchEvent(new AVPlayerEvent(AVPlayerEvent.PLAY));	
		}
		
		override protected function onMediaPlayerStateChange(evt:MediaPlayerStateChangeEvent):void
		{
			if(_m.isPlaybackError)
			{
				this.mouseChildren = false;
				this.alpha = 0.5;
				this.buttonMode = false;
				setPlayStatus(false);
			}
			else
			{
				if(_m.isPlaybackComplete) //显示重播按钮
				{	
					if(!isLive) //vod
					{
						if(_m.autoRewind) { //自动重播
							replayHandler();
						} else {
							_replayBtn.visible = true;
							_pauseBtn.visible = _playBtn.visible = _elapsedTxt.visible = _totalTxt.visible = _skin.seperatorTxt.visible = false;
						}
					}					
					else  //直播结束后重播按钮禁止点击，因为地址已失效，replay没有意义 
					{
						_replayBtn.visible = _pauseBtn.visible = false; //隐藏重播和暂停button
						_playBtn.visible = true;
						_playBtn.mouseEnabled = false;
					}
				}
				else if(!_m.autoPlay && (evt.state == MediaPlayerState.READY)) //非播放结束状态并且player ready
				{
					setPlayStatus(false);
				}
			}			
		}
		
		override protected function render():void
		{	
			!this.visible && (this.visible = true);
			TweenLite.killTweensOf(_skin);
			if(!isTextInputViewAvailable)
			{
				_skin.y = stageHeight - controlbarHeight * 0.5;
			}
			else
			{
				//killtween(_skin);
				_skin.y = stageHeight - textInputViewHeight - controlbarHeight * 0.5;
			}
			
//			if(!isMinWidth) { //正常布局
////				_skin.x = LayoutConst.MARGIN_TO_PLAYER_BORDER + 7;
////				var gap:Number = _elapsedTxt.x - _playBtn.x - _playBtn.width + 7;
////				_elapsedTxt.x = _playBtn.x - 7;
////				_skin.seperatorTxt.x -= gap;
////				_totalTxt.x -= gap;
//			} else { //最小宽度布局
//				_skin.x = LayoutConst.MARGIN_IN_MIN_WIDTH;
//				var temp:Number = _elapsedTxt.x;
//				_elapsedTxt.x = LayoutConst.MARGIN_IN_MIN_WIDTH + _playBtn.width;
//				_skin.seperatorTxt.x -= (temp - _elapsedTxt.x);
//				_totalTxt.x -= (temp - _elapsedTxt.x);
//			}
			
			_skin.alpha = 1;
		}
	
		private function  playHandler():void
		{
			if(_m.isPlaybackError)
			{
				return;
			}
			
			_pauseBtn.visible = true;
			_playBtn.visible = false;			
			dispatchEvent(new AVPlayerEvent(AVPlayerEvent.PLAY));
		}
		
		private function pauseHandler():void
		{
			_pauseBtn.visible = false;
			_playBtn.visible = true;			
			dispatchEvent(new AVPlayerEvent(AVPlayerEvent.PAUSE));			
		}
		
		protected function onKeyDown(evt:KeyboardEvent):void
		{
			if(!stageFocusIsTextInputView)
			{
				if(evt.keyCode == Keyboard.SPACE)
				{
					if(_replayBtn.visible) { //播放已结束，显示重播按钮
						replayHandler();
					} else { 
						_playBtn.visible ? playHandler() : pauseHandler();
					}
				}
			}			
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
		
		override protected function onShowPrerollAd(evt:ModelEvent):void
		{
			disable(_playBtn);
		}
		
		override protected function onRemovePrerollAd(evt:ModelEvent):void
		{
			_playBtn.visible = false;
			_pauseBtn.visible = true;
			enable(_playBtn);
		}
		
		/**
		 * 返回leftbar view的布局宽度 
		 * @return 
		 * 
		 */		
		private function get layoutWidth():Number {
			return LayoutConst.MARGIN_TO_PLAYER_BORDER + _totalTxt.x + _totalTxt.width;
		}
	}
}