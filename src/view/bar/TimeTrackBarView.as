package view.bar
{
	import com.greensock.TweenLite;
	
	import consts.TimerConst;
	
	import event.AVPlayerEvent;
	import event.HomeTheaterModeEvent;
	import event.ModelEvent;
	import event.bar.LeftBarEvent;
	import event.bar.RightBarEvent;
	import event.bar.TimeTrackBarEvent;
	import event.js.JSEvent;
	import event.tips.TipTimeViewEvent;
	
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import model.Model;
	import model.external.JSAPI;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.ToAVPlayerEvent;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.traits.PlayState;
	
	import view.base.BaseTimeChangeView;

	/**
	 * 时间轨迹条 
	 * 通过_skin 获取皮肤里对应的MovieClip
	 * 
	 */	
	public class TimeTrackBarView extends BaseTimeChangeView
	{
		/** 当前播放时间 **/
		private var _current:Number = 0;
		
		/** 鼠标是否在舞台上,即进入舞台  **/
		private var _hasMouse:Boolean = true;
		
		private var _timeout:uint;
		
		private var _icon:Sprite;
		
		/** icon是否在拖动中 **/
		private var  _isDragging:Boolean = false;
		/** 视频已加载的百分比,m3u8文件始终为0 **/
		private var _byteLoadedPercent:Number = 0;
		
		/** 拖动时间 **/
		private var _seekingTime:Number = -1;
		
		/** 上一次currentTime和bufferlength之和 **/
		private var _sumOfLastTimeAndBufferLength:Number = 0;
		/** todefault的缓动变量 **/
		private var _tweenToDefault:TweenLite;
	
		public function TimeTrackBarView(m:Model)
		{
			super(m);	
			
			_skin =  _ui.TimeTrackBar;
			_skin.useHandCursor = true;
			_skin.buttonMode = true;
			_skin.cacheAsBitmap = true;
			_skin.mouseChildren = false;
			this.addChild(_skin);
			
			_skin.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_skin.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			_skin.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			_skin.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			_icon = _skin.icon as Sprite;	
			_icon.x = _icon.width * 0.5;
			_skin.done.width = _skin.mark.width = 0;		
			this.visible = false;
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
			
			eventbus.addEventListener(TimeTrackBarEvent.MOUSE_IN_HOTZONE, onMouseInHotZone);
			eventbus.addEventListener(TimeTrackBarEvent.MOUSE_OUT_HOTZONE, onMouseOutHotZone);
			_m.addEventListener(ModelEvent.BYTES_LOADED_CHANGE, onBytesLoadedChange);
			JSAPI.getInstance().addEventListener(JSEvent.SEEK, onJSSeek);
			eventbus.addEventListener(ToAVPlayerEvent.PLAYER_SEEKING_COMPLETE, onPlayerSeekingComplete);
		}
	
		private function onMouseInHotZone(evt:TimeTrackBarEvent):void
		{
			if(_skin.scaleY == 1) {
				return;
			}
			
			if(_tweenToDefault != null && _tweenToDefault.isActive()) { //正在缓动中
				return;
			}
				
			clearTimer();	
			showDefaultTrackBar();
		}
		
		private function onMouseOutHotZone(evt:TimeTrackBarEvent):void
		{
			if(_skin.scaleY != 1)
			{
				return;
			}
			clearTimer();	
			_timeout = setTimeout(showThinTrackBar, TimerConst.DELAY);
		}
		
		private function onBytesLoadedChange(evt:ModelEvent):void
		{
			//屏蔽播放m3u8时的bytesLoaded处理，只在播放mp4下有效
			if(_m.currentFileFormatIsM3U8 || isNaN(evt.percent)) {  //yangq
				return; 
			}
			
			if(!_m.isPlaybackError) //即使在出错的情况下，有时仍然有数据被加载到，所以这里要做判断
			{
				isNaN(evt.percent) ? (_byteLoadedPercent = 0) : (_byteLoadedPercent = evt.percent);			
				_skin.mark.width = _byteLoadedPercent * _skin.rail.width;
			}
			else
			{
				_skin.mark.width = 0;
			}
		}
		
		private function onMouseOver(evt:MouseEvent):void
		{
			(!isLive) && dispatchShowTipTimeViewEvent(evt.stageX); //点播下才显示提示时间
		}
		
		private function onMouseOut(evt:MouseEvent):void
		{
			eventbus.dispatchEvent(new TipTimeViewEvent(TipTimeViewEvent.HIDE));
		}
		
		private function onMouseMove(evt:MouseEvent):void
		{
			(!isLive) && dispatchShowTipTimeViewEvent(evt.stageX);
		}
		
		private function dispatchShowTipTimeViewEvent(stageX:Number):void
		{
			var data:Object = {};
			data.x = stageX;
			data.y = (!isTextInputViewAvailable	? (stageHeight - controlbarHeight - _skin.height) : (stageHeight - controlbarHeight - textInputViewHeight - _skin.height));
			
			if(_m.mediaPlayer.state == MediaPlayerState.UNINITIALIZED ||  _m.mediaPlayer.state == MediaPlayerState.PLAYBACK_ERROR)
			{
				data.text = "00:00:00";
			}
			else
			{
				var now:Number;
				if(_seekingTime >= 0 && _seekingKeyframeTime >= 0)
				{
					//mp4 seek
					now = (stageX - _icon.width*0.5)  * (duration + _seekingKeyframeTime) / actualWidth;
				}
				else
				{
					now = (stageX - _icon.width*0.5)  * duration / actualWidth;
				}
				now < 0 && (now = 0);
				data.text = _numToTime.toHMS(now);
			}

			eventbus.dispatchEvent(new TipTimeViewEvent(TipTimeViewEvent.SHOW, data));
		}
		
		private function onMouseDown(evt:MouseEvent):void
		{
			if(_m.isPlaybackError || isLive) //直播下不允许拖动
			{
				return;
			}
			
			setPositionAndDispatchEvent(evt.stageX, evt.type);
			
			_stageRef.stage.addEventListener(MouseEvent.MOUSE_MOVE, onDragMoving);
			_stageRef.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			//	bounds:Rectangle (default = null) — 相对于 Sprite 父级的坐标的值，用于指定 Sprite 约束矩形。
			// 被拖动的对象从Rectangle的x开始，移动width像素
			//_icon.startDrag(true, new Rectangle(_icon.width*0.5, -_icon.height*0.5, _skin.rail.width - _icon.width, 0));
			_icon.startDrag(true, new Rectangle(_icon.width*0.5, -_icon.height/3, _skin.rail.width - _icon.width, 0));
		}
		
		/** 拖动时间进度条实时反馈 **/
		private function onDragMoving(evt:MouseEvent):void
		{			
			eventbus.dispatchEvent(new RightBarEvent(RightBarEvent.CHILD_MOUSE_DISABLED));
			_isDragging = true;	
			setPositionAndDispatchEvent(evt.stageX, evt.type);
		}
	
		private function onMouseUp(evt:MouseEvent):void 
		{
			eventbus.dispatchEvent(new RightBarEvent(RightBarEvent.CHILD_MOUSE_ENABLED));
			_icon.stopDrag();
			_isDragging = false;
			_stageRef.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);			
			removeStageMouseMoveListener(onDragMoving);
			
			setPositionAndDispatchEvent(evt.stageX, evt.type);
		}
		
		/**
		 * 重新设置_skin.done的width和_icon的位置 
		 * @param stageX  当前鼠标的x坐标
		 * @param evtType 事件类型
		 */		
		private function  setPositionAndDispatchEvent(stageX:Number, evtType:String):void
		{
			_skin.done.width = _icon.x = stageX;
			var newTime:Number = (stageX - _icon.width*0.5) * duration / actualWidth;
			dispatchSeekEvent(newTime, evtType);
		}	
		
		/**
		 * 派发拖动视频事件 
		 * @param time 拖动时间
		 * @param evtType 触发拖动的event type, 只有在MOUSE_UP或者JSEvent.SEEK才派发拖动视频事件 
		 * 
		 */		
		private function dispatchSeekEvent(time:Number, evtType:String):void 
		{
			eventbus.dispatchEvent(new LeftBarEvent(LeftBarEvent.VALIDATE_CURRENT_TIME, time));
		
			if(evtType == MouseEvent.MOUSE_UP || evtType == JSEvent.SEEK)
			{
				dispatchEvent( new AVPlayerEvent(AVPlayerEvent.SEEK, time));	
			}
		}
		
		private function onJSSeek(evt:JSEvent):void
		{
			var newTime:Number = evt.data;
			//参考setPositionAndDispatchEvent函数的实现
			_skin.done.width = _icon.x = newTime * actualWidth / duration + _icon.width*0.5;
			dispatchSeekEvent(newTime, evt.type);
		}
		
		/**
		 * 时间进度条实际的宽度，实际宽度为rail.width - _icon.width
		 * @return 
		 * 
		 */		
		private function get actualWidth():Number
		{
			return _skin.rail.width - _icon.width;
		}	
		
		private function onPlayerSeekingComplete(evt:ToAVPlayerEvent):void
		{
			_playerInSeeking = false;
		}
		
		override protected function setTime(current:Number, total:Number):void
		{
			if(isNaN(total) == true || _isDragging)
			{
				return;
			}
			
			if(_playerInSeeking)
			{
				_current = _seekingTime; //resize的时候用
			}
			else 
			{
				_current = current; //resize的时候用
				
				setMarkByTimeAndBufferLength(current, total); //设置mark
				setDoneAndIconByTime(current, total); //设置done和icon
			}
		}		
		
		/** 根据当前时间和总时间设置_skin.done和icon的位置  **/
		private function setDoneAndIconByTime(current:Number, total:Number):void
		{
			if(isLive  || _playerInSeeking)
			{
				return;
			}
			
			var temp:Number =  current * actualWidth / total;
			isNaN(temp) && (temp = 0);
			if(temp + _icon.width*0.5 >= _skin.rail.width)
			{
				_icon.x = _skin.rail.width - _icon.width*0.5;
			}
			else
			{
				_icon.x = temp + _icon.width*0.5;							
			}	
			
			_m.isPlaybackComplete ? (_skin.done.width = _skin.rail.width) : (_skin.done.width = _icon.x);
		}
		
		
		/** 鼠标离开舞台 **/
		override protected function onMouseLeaveStage(evt:Event):void
		{
			if(_skin.scaleY == 1)
			{
				clearTimer();
				showThinTrackBar();			
			}			
		}
		
		/** 显示默认状态的trackbar **/
		private function showDefaultTrackBar():void
		{
			if(isLive) { //直播时没有进度条状态
				return;
			}
			
			killtween(_skin);
			_skin.scaleY = 1;
			_skin.alpha = 1;
			!isLive ? (_icon.visible = true) : (_icon.visible = false); //点播时才显示icon，录播时不显示icon
			_tweenToDefault = TweenLite.from(_skin, 0.3, {scaleY:0.2});
		}
		
		/** 显示细的trackbar **/
		private function showThinTrackBar():void
		{
			if(_isEnteringHTM || _skin.scaleY <= 0.2) //有时看到的scaleY是0.199999999996...
				return;
			
			killtween(_skin);
			_skin.scaleY = 0.2;
			_skin.alpha = 1;
			_icon.visible = false;
			_tween = TweenLite.from(_skin, 0.3, {scaleY:1});
		}	
		
		override protected function render():void
		{			
			//这里的逻辑有时间需要优化下，感觉有点不太清晰
			!this.visible && (this.visible = true);			
			TweenLite.killTweensOf(_skin);
			if(!isTextInputViewAvailable)
			{
				if(!isLive) {
					_skin.alpha = _skin.scaleY = 1;
				} else { //直播时显示细条
					_skin.scaleY = 0.2;
					_skin.icon.visible = false;
				}
				
				_skin.y = stageHeight - controlbarHeight;
			}
			else
			{
				if(displayState == StageDisplayState.NORMAL)
				{
					if(!isLive) {
						_skin.alpha = _skin.scaleY = 1;
					} else { //直播时显示细条
						_skin.scaleY = 0.2;
					}
				}
				_skin.y = stageHeight - controlbarHeight - textInputViewHeight
			}
			(_skin.scaleY == 1 && !isLive) && (_skin.icon.visible = true);
			_skin.rail.width = stageWidth;
			
			if(_m.currentFileFormatIsM3U8) {  //m3u8 
				setMarkByTimeAndBufferLength(_current, duration);
			} 
			setDoneAndIconByTime(_current, duration);
			_skin.x = 0;				
		}			
		
		override protected function onEnterHomeTheaterMode(evt:HomeTheaterModeEvent):void
		{
			killtween(_skin);
			clearTimer();
			if(_skin.y == stageHeight - controlbarHeight) 
			{
				_isEnteringHTM = true;
				TweenLite.to(_skin, 0.3, {y:stageHeight, onComplete: enterHTMTweenComplete});
			}
		}
		
		override protected function enterHTMTweenComplete():void
		{
			super.enterHTMTweenComplete();			
			showThinTrackBar();
		}
		
		override protected function onExitHomeTheaterMode(evt:HomeTheaterModeEvent):void
		{
			if(_isExitingHTM || _skin.y == stageHeight - controlbarHeight) //缓动中或者已经位于正确的位置上
				return;
			
			//退出家庭影院模式的时候显示默认的trackbar
			killtween(_skin);
			clearTimer();
			if(!isLive) {
				_skin.scaleY = 1;
				_skin.icon.visible = true
			}
			
			_isExitingHTM = true;			
			_skin.alpha = 1;
			_skin.y = stageHeight - controlbarHeight;	
			TweenLite.from(_skin, 0.3, {y:stageHeight, alpha:0, onComplete: exitHTMTweenComplete});		
		}
		
		//清除定时器
		private function clearTimer():void
		{
			if(_timeout)
			{
				clearTimeout(_timeout);
				_timeout = undefined;
			}
		}
		
		override protected function onShowPrerollAd(evt:ModelEvent):void
		{
			_skin.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_skin.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			_skin.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			disable(_skin);
		}
		
		override protected function onRemovePrerollAd(evt:ModelEvent):void
		{
			_skin.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_skin.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			_skin.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			enable(_skin);
		}
		
		override protected function onPlayStateChange(evt:PlayEvent):void
		{
			if(evt.playState == PlayState.PLAYING)
			{
				if(isLive) {
					//直播时隐藏icon，隐藏done，禁用mouse事件
					_skin.done.visible = _icon.visible = _skin.mouseEnabled = false; 
					_skin.scaleY = 0.2;
				}
			}
		}
		
		/**
		 * 根据播放头位置和bufferLength显示mark，仅在播放录播m3u8时显示
		 * @author yangq
		*/
		private function setMarkByTimeAndBufferLength(current:Number, total:Number):void {
			if(!isLive && _m.currentFileFormatIsM3U8) {
				if(_m.isPlaybackComplete) {
					_skin.mark.width = _skin.rail.width;
				} else {
					//事件流是非常高效的，重复派发没有问题，而UI的调整是比较耗资源的
					//所以这里修改为只有数值发生变化的时候才调整UI，提高程序执行效率    yangq
					if(_sumOfLastTimeAndBufferLength != (current + _m.mediaPlayer.bufferLength)) {
						_sumOfLastTimeAndBufferLength = current + _m.mediaPlayer.bufferLength;
						if(_sumOfLastTimeAndBufferLength / total >= 1) { //避免mark.width > rail.width
							_skin.mark.width = _skin.rail.width;
						} else {
							_skin.mark.width = _sumOfLastTimeAndBufferLength / total * _skin.rail.width;
						}
					}
				}
			}
		}
		
		override protected function onMediaPlayerStateChange(evt:MediaPlayerStateChangeEvent):void 
		{
			if(_m.isPlaybackError) 
			{ //播放出错时，timetrackbar的元素要复位
				if(_icon.x > _icon.width*0.5) 
				{
					_skin.done.width = _skin.mark.width = 0;
					var temp:Number = _skin.icon.x;
					_icon.x = _icon.width*0.5;
					TweenLite.from(_icon, 0.3, {x:temp});
				}
			}
		}
	}
}