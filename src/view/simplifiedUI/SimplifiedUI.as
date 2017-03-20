package view.simplifiedUI
{
	import com.greensock.TweenLite;
	
	import event.AVPlayerEvent;
	import event.HomeTheaterModeEvent;
	import event.ModelEvent;
	import event.bar.LeftBarEvent;
	import event.bar.RightBarEvent;
	import event.js.JSEvent;
	import event.tips.BottomViewAreaEvent;
	import event.tips.TipTimeViewEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import model.Model;
	import model.external.JSAPI;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.ToAVPlayerEvent;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.traits.PlayState;
	
	import view.base.BaseTimeChangeView;
	
	/**
	 * 精简版UI 
	 * @author yangq
	 * 
	 */	
	public class SimplifiedUI extends BaseTimeChangeView
	{
		private const MARGIN:uint = 10;
		
		private var _bg:MovieClip;
		private var _pauseBtn:MovieClip;
		private var _playBtn:MovieClip;
		private var _replayBtn:MovieClip;
		private var _timeTrackBar:MovieClip;
		private var _timeTxt:MovieClip;
		private var _volumeBar:MovieClip;
		private var _fullScreenBtn:MovieClip;
		private var _normalScreenBtn:MovieClip;
		
		//volume bar 
		/** 是否在拖动音量条的icon **/
		private var _isDraggingTimeTrackBarIconVolumeBarIcon:Boolean = false;
		/** 是否第一次麦克风增益  **/
		private var _firstMicBoost:Boolean = true;
		
		//timetrackbar
		/** 当前播放时间 **/
		private var _current:Number = 0;
		private var _icon:Sprite;
		/** timetrackbar icon是否在拖动中 **/
		private var  _isDraggingTimeTrackBarIcon:Boolean = false;
		/** 视频已加载的百分比,m3u8文件始终为0 **/
		private var _byteLoadedPercent:Number = 0;
		/** 拖动时间 **/
		private var _seekingTime:Number = -1;
		/** 上一次currentTime和bufferlength之和 **/
		private var _sumOfLastTimeAndBufferLength:Number = 0;
		
		public function SimplifiedUI(m:Model)
		{
			super(m);
			
			if(_m.simplifiedUI && _ui.SimplifiedUI) {
				_skin = _ui.SimplifiedUI;
				_bg = _skin.bg;
				_pauseBtn = _skin.pauseBtn;
				_playBtn = _skin.playBtn;
				_replayBtn = _skin.replayBtn;
				_timeTrackBar = _skin.timeTrackBar;
				_timeTxt = _skin.timeTxt;
				_volumeBar = _skin.volumeBar;
				_fullScreenBtn = _skin.fullScnBtn;
				_normalScreenBtn = _skin.normalScnBtn;
				addChild(_skin);
				
				//bg
				_bg.cacheAsBitmap = true;
								
				//left bar view
				_replayBtn.visible = _pauseBtn.visible = false;
				if(!_m.autoPlay) {  //非自动播放下显示第二帧
					_playBtn.gotoAndStop(2);
				}
				
				//right bar view
				_normalScreenBtn.visible = false;
				
				//volume bar view
				_volumeBar.buttonMode = true;
				_volumeBar.mouseChildren = false;
				var volume:int = _m.volume;
				if(volume > 100) {
					volume = 100;
				}
				_volumeBar.done.width = _volumeBar.icon.x = convertVolume2Width(volume);
				_volumeBar.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownVolumeBar);
				_volumeBar.addEventListener(MouseEvent.CLICK, onClickVolumeBar);
				
				//timetrack bar view
				_timeTrackBar.useHandCursor = true;
				_timeTrackBar.buttonMode = true;
				_timeTrackBar.cacheAsBitmap = true;
				_timeTrackBar.mouseChildren = false;
				_icon = _timeTrackBar.icon as Sprite;
				_icon.x = _icon.width * 0.5;
				_timeTrackBar.done.width = _timeTrackBar.mark.width = 0;		
				_timeTrackBar.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownTimeTrackBar);
				_timeTrackBar.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverTimeTrackBar);
				_timeTrackBar.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutTimeTrackBar);
				_timeTrackBar.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveTimeTrackBar);
				
				//给btn注册事件
				addMouseEventListeners([_playBtn, _pauseBtn, _replayBtn, _fullScreenBtn, _normalScreenBtn]);
				
				this.visible = false;
			}
		}
		
		/**
		 * 把音量值转换为布局需要的宽度
		 * @param volume
		 * @return 
		 * 
		 */		
		private function convertVolume2Width(volume:Number):Number 
		{
			return volume * _volumeBar.rail.width / 100;
		}
		
		private function addMouseEventListeners(mcArr:Array):void 
		{
			for each(var item:MovieClip in mcArr) {
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
			if(mc.totalFrames == 2) {
				mc.gotoAndStop(2);
			}
		}
		
		private function onMouseOutBtn(evt:MouseEvent):void 
		{
			var mc:MovieClip = evt.target as MovieClip;
			if(mc.totalFrames == 2) {
				mc.gotoAndStop(1);
			}
		}
		
		private function onMouseClickBtn(evt:MouseEvent):void 
		{
			evt.stopPropagation();
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
				case "fullScnBtn":
					dispatchEvent(new AVPlayerEvent(AVPlayerEvent.TO_FULLSCREEN));		
					break;
				case "normalScnBtn":
					dispatchEvent(new AVPlayerEvent(AVPlayerEvent.TO_NORMALSCREEN));
					break;
			}
		}
		
		//播放
		private function playHandler():void 
		{
			if(_m.isPlaybackError)
				return;
			
			_pauseBtn.visible = true;
			_playBtn.visible = false;			
			dispatchEvent(new AVPlayerEvent(AVPlayerEvent.PLAY));
		}
		
		//暂停
		private function pauseHandler():void 
		{
			_pauseBtn.visible = false;
			_playBtn.visible = true;			
			dispatchEvent(new AVPlayerEvent(AVPlayerEvent.PAUSE));			
		}
		
		//重播
		private function replayHandler():void 
		{
			_playBtn.visible = _replayBtn.visible = false;
			if(!isLive) {
				_pauseBtn.visible = true;
			}

			dispatchEvent(new AVPlayerEvent(AVPlayerEvent.SEEK, 0));
			dispatchEvent(new AVPlayerEvent(AVPlayerEvent.PLAY));	
		}
		
		private function onMouseDownVolumeBar(evt:MouseEvent):void 
		{
			_volumeBar.done.width = Math.abs(evt.localX);
			
			_stageRef.stage.addEventListener(MouseEvent.MOUSE_MOVE, onDragMoving);
			_stageRef.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpVolumeBar);
			_volumeBar.icon.startDrag(true, new Rectangle(0, 0, _volumeBar.rail.width, 0));
		}
	
		/** 拖动音量条实时反馈 **/
		private function onDragMoving(evt:MouseEvent):void 
		{			
			_isDraggingTimeTrackBarIconVolumeBarIcon = true;	
			setVolumeTxtAndTrackBar(_volumeBar.icon.x, false);			
		}
		
		private function onMouseUpVolumeBar(evt:MouseEvent):void 
		{
			_volumeBar.icon.stopDrag();
			_isDraggingTimeTrackBarIconVolumeBarIcon = false;
			_stageRef.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpVolumeBar);
			removeStageMouseMoveListener(onDragMoving);
			
			var volume:int = Math.ceil(Math.abs(_volumeBar.icon.x) / _volumeBar.rail.width * 100);		
			dispatchEvent(new AVPlayerEvent(AVPlayerEvent.ADJUST_VOLUME, {'volume':volume/100}));	
		}
		
		private function onClickVolumeBar(evt:MouseEvent):void 
		{
			setVolumeTxtAndTrackBar(evt.localX);
		}
		
		private function onMouseDownTimeTrackBar(evt:MouseEvent):void 
		{
			if(_m.isPlaybackError || isLive) {//播放出错、直播时不允许拖动
				return;
			}
			
			setPositionAndDispatchEvent(evt.stageX, evt.type);
			
			_stageRef.stage.addEventListener(MouseEvent.MOUSE_MOVE, onDragTimeTrackBarIconMoving);
			_stageRef.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpTimeTrackBar);
			//	bounds:Rectangle (default = null) — 相对于 Sprite 父级的坐标的值，用于指定 Sprite 约束矩形。
			// 被拖动的对象从Rectangle的x开始，移动width像素
			//_icon.startDrag(true, new Rectangle(_icon.width*0.5, -_icon.height*0.5, _skin.rail.width - _icon.width, 0));
			_icon.startDrag(true, new Rectangle(_icon.width*0.5, 0, _timeTrackBar.rail.width - _icon.width, 0));
		}
		
		/** 拖动时间进度条实时反馈 **/
		private function onDragTimeTrackBarIconMoving(evt:MouseEvent):void 
		{			
			_isDraggingTimeTrackBarIcon = true;	
			setPositionAndDispatchEvent(evt.stageX, evt.type);
		}
		
		private function onMouseUpTimeTrackBar(evt:MouseEvent):void 
		{
			_icon.stopDrag();
			_isDraggingTimeTrackBarIcon = false;
			_stageRef.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpTimeTrackBar);			
			removeStageMouseMoveListener(onDragTimeTrackBarIconMoving);
			
			setPositionAndDispatchEvent(evt.stageX, evt.type);
		}
		
		/**
		 * 重新设置_timeTrackBar.done的width和_icon的位置 
		 * @param stageX  当前鼠标的x坐标
		 * @param evtType 事件类型
		 */		
		private function setPositionAndDispatchEvent(stageX:Number, evtType:String):void 
		{
			stageX -= _timeTrackBar.x;
			_timeTrackBar.done.width = _icon.x = stageX;
			var newTime:Number = (stageX - _icon.width*0.5) * duration / actualWidth;
			dispatchSeekEvent(newTime, evtType);
		}	
		
		private function onMouseOverTimeTrackBar(evt:MouseEvent):void 
		{
			(!isLive) && dispatchShowTipTimeViewEvent(evt.stageX); //点播下才显示提示时间
		}
		
		private function onMouseOutTimeTrackBar(evt:MouseEvent):void 
		{
			eventbus.dispatchEvent(new TipTimeViewEvent(TipTimeViewEvent.HIDE));
		}
		
		private function onMouseMoveTimeTrackBar(evt:MouseEvent):void 
		{
			(!isLive) && dispatchShowTipTimeViewEvent(evt.stageX);
		}
		
		private function dispatchShowTipTimeViewEvent(stageX:Number):void 
		{
			var data:Object = {};
			data.x = stageX;
			data.y = stageHeight - _skin.height;
			
			if(_m.mediaPlayer.state == MediaPlayerState.UNINITIALIZED ||  _m.mediaPlayer.state == MediaPlayerState.PLAYBACK_ERROR) {
				data.text = "00:00:00";
			} else {
				var now:Number;
				stageX -= _timeTrackBar.x;
				if(_seekingTime >= 0 && _seekingKeyframeTime >= 0) {
					//mp4 seek
					now = (stageX - _icon.width*0.5)  * (duration + _seekingKeyframeTime) / actualWidth;
				} else {
					now = (stageX - _icon.width*0.5)  * duration / actualWidth;
				}
				now < 0 && (now = 0);
				data.text = _numToTime.toHMS(now);
			}
			
			eventbus.dispatchEvent(new TipTimeViewEvent(TipTimeViewEvent.SHOW, data));
		}
		
		/**
		 * 设置音量文字和trackbar icon及done的位置 
		 * 派发调整音量事件
		 * @param localX 
		 * @param save2cookie 是否立即写入本地存储
		 */		
		private function setVolumeTxtAndTrackBar(localX:Number, save2cookie:Boolean=true):void 
		{
			_volumeBar.done.width = _volumeBar.icon.x = localX;
			
			var volume:int = Math.ceil(localX / _volumeBar.rail.width * 100);
			dispatchEvent(new AVPlayerEvent(AVPlayerEvent.ADJUST_VOLUME, {'volume':volume/100}));	
		}
		
		override protected function addListeners():void 
		{
			//开启精简版UI功能时才侦听事件
			if(_m.simplifiedUI && _ui.SimplifiedUI) { 
				super.addListeners();
				
				//volume bar 收到js的调用请求
				JSAPI.getInstance().addEventListener(JSEvent.MUTE,  onFlashMute);
				JSAPI.getInstance().addEventListener(JSEvent.UNMUTE, onFlashUnmute);
				_stageRef.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				
				//right bar
				eventbus.addEventListener(RightBarEvent.VIDEO_VIEW_DOUBLE_CLICKED, onVideoViewDoubleClicked);
				
				//timetrack bar
				_m.addEventListener(ModelEvent.BYTES_LOADED_CHANGE, onBytesLoadedChange);
				JSAPI.getInstance().addEventListener(JSEvent.SEEK, onJSSeek);
				eventbus.addEventListener(ToAVPlayerEvent.PLAYER_SEEKING_COMPLETE, onPlayerSeekingComplete);
			}
		}
		
		/** 
		 * 处理视频区域被双击 
		 * yangq  20160614
		 * **/
		private function onVideoViewDoubleClicked(evt:RightBarEvent):void 
		{
			if(displayState == StageDisplayState.NORMAL) {
				//进入全屏前需要判断当前是否处在网页全屏状态，如果是，需要先退出
				dispatchEvent(new AVPlayerEvent(AVPlayerEvent.TO_FULLSCREEN));
			} else { //退出全屏
				dispatchEvent(new AVPlayerEvent(AVPlayerEvent.TO_NORMALSCREEN));
			}
		}
		
		//控制flash播放器静音
		private function onFlashMute(evt:JSEvent):void 
		{
			if(!_m.muted) {
				muteHandler();
			}
		}
		
		/** 恢复静音之前状态  **/
		private function onFlashUnmute(evt:JSEvent):void 
		{
			if(_m.muted) {
				if(_m.volume == 0) { //如果之前音量为0，则跳出函数，否则会出现音量为0但是_volumeMC显示声音帧的bug
					return;
				}
				unmuteHandler();
			}
		}
		
		protected function onKeyDown(evt:KeyboardEvent):void 
		{			
			if(!stageFocusIsTextInputView) {
				switch(evt.keyCode)
				{
					case Keyboard.UP:
						increase();
						break;			
					case Keyboard.DOWN:
						decrease();
						break;
					case Keyboard.SPACE:
						if(_replayBtn.visible) {
							replayHandler();
						} else {
							_playBtn.visible ? playHandler() : pauseHandler();
						}
						break;
					default:
						break;
				}
			}			
		}
		
		//增加音量
		private function increase():void 
		{
			var currentVolume:int = _m.volume;
			if(currentVolume == 0) {
				dispatchEvent(new AVPlayerEvent(AVPlayerEvent.UNMUTE));
			}
			
			if(currentVolume < 100) {
				!_firstMicBoost && (_firstMicBoost = true);
				currentVolume += 5;
				(currentVolume > 100) && (currentVolume = 100);		
				var temp:Number = convertVolume2Width(currentVolume);
				_volumeBar.icon.x = _volumeBar.done.width = temp;		
			} else if(currentVolume >= 100 && currentVolume < 200) {
				if(currentVolume == 100 && _firstMicBoost) 	{	//第一次放大提示
					_firstMicBoost = false;
					eventbus.dispatchEvent(new BottomViewAreaEvent(BottomViewAreaEvent.SHOW_TIPS, "点击键盘↑可以继续放大音量"));
				} else {
					currentVolume += 10;			
				}					
			} else if(currentVolume >= 200 && currentVolume <= 275) {//最大音量不能放大超过300%
				currentVolume += 25;
			}
			
			var saveFlag:Boolean = (currentVolume > 100 ? false : true);
			dispatchEvent(new AVPlayerEvent(AVPlayerEvent.ADJUST_VOLUME, {'volume':currentVolume/100}));	
		}
		
		//减小音量
		private function decrease():void 
		{
			var currentVolume:int = _m.volume;			
			if(currentVolume < 100) {
				currentVolume -= 5;
				if(currentVolume <= 0) {
					currentVolume = 0;
					dispatchEvent(new AVPlayerEvent(AVPlayerEvent.MUTE));
				}
				
				var temp:Number = convertVolume2Width(currentVolume);
				_volumeBar.icon.x = _volumeBar.done.width = temp;
			} else if(currentVolume >= 100 && currentVolume < 200) {
				currentVolume -= 10;				
			}  else if(currentVolume >= 200 && currentVolume <= 300) {
				currentVolume -= 25;
			}
			
			var saveFlag:Boolean = (currentVolume > 100 ? false : true);
			dispatchEvent(new AVPlayerEvent(AVPlayerEvent.ADJUST_VOLUME, {'volume':currentVolume/100}));	
		}
		
		//静音
		private function muteHandler():void 
		{
			_volumeBar.icon.x = _volumeBar.done.width = 0;
			dispatchEvent(new AVPlayerEvent(AVPlayerEvent.MUTE));
		}
		
		//取消静音
		private function unmuteHandler():void 
		{
			var temp:Number = Math.min(Math.ceil(_m.volume * _volumeBar.rail.width / 100),Math.ceil(100 * _volumeBar.rail.width/100));
			_volumeBar.icon.x = _volumeBar.done.width = temp;
			dispatchEvent(new AVPlayerEvent(AVPlayerEvent.UNMUTE));
		}
		
		private function onBytesLoadedChange(evt:ModelEvent):void 
		{
			//屏蔽播放m3u8时的bytesLoaded处理，只在播放mp4下有效
//			if(_m.currentFileFormatIsM3U8 || isNaN(evt.percent)) {  //yangq
//				return; 
//			}
//			
//			if(!_m.isPlaybackError) {//即使在出错的情况下，有时仍然有数据被加载到，所以这里要做判断
//				isNaN(evt.percent) ? (_byteLoadedPercent = 0) : (_byteLoadedPercent = evt.percent);			
//				if(_m.currentFileFormatIsMP4 && _globalRef.pseudoStreaming) { //处理mp4伪流方式播放
//					var temp:Number = evt.percent + _seekingKeyframeTime/(_seekingKeyframeTime+duration);
//					if(temp > 1)
//						temp = 1;
//					
//					_byteLoadedPercent = temp;
//				}
//				
//				_timeTrackBar.mark.width = _byteLoadedPercent * _timeTrackBar.rail.width;
//			} else {
//				_timeTrackBar.mark.width = 0;
//			}
		}
		
		private function onJSSeek(evt:JSEvent):void 
		{
			var newTime:Number = evt.data;
			//参考setPositionAndDispatchEvent函数的实现
			_timeTrackBar.done.width = _icon.x = newTime * actualWidth / duration + _icon.width*0.5;
			dispatchSeekEvent(newTime, evt.type);
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
		
		private function onPlayerSeekingComplete(evt:ToAVPlayerEvent):void 
		{
			_playerInSeeking = false;
			//如果播放器先进入了暂停状态，然后又触发player seeking complet状态，则自动播放
			if(_m.playState == MediaPlayerState.PAUSED) {
				playHandler();
			}
		}
		
		/** 处理播放进度显示 **/
		override protected function setTime(current:Number,total:Number):void 
		{
			if(!this.visible || _timeTxt == null || isNaN(total) == true)
				return;
			
			//left bar 
			if(total - current < 0.5) {
				current = total;
			}
			_timeTxt.elapsedTxt.text = _numToTime.toHMS(current);
			_timeTxt.totalTxt.text = _numToTime.toHMS(total);
			
			if(_isDraggingTimeTrackBarIcon)
				return;
			
			if(_playerInSeeking) {
				_current = _seekingTime; //resize的时候用
			} else {
				_current = current; //resize的时候用
				
				setMarkByTimeAndBufferLength(current, total); //设置mark
				setDoneAndIconByTime(current, total); //设置done和icon
			}
		}
			
		/**
		 * 根据播放头位置和bufferLength显示mark，仅在播放录播m3u8时显示
		 * @author yangq
		 */
		private function setMarkByTimeAndBufferLength(current:Number, total:Number):void 
		{
			if(!isLive && _m.currentFileFormatIsM3U8) {
				if(_m.isPlaybackComplete) {
					_timeTrackBar.mark.width = _timeTrackBar.rail.width;
				} else {
					//事件流是非常高效的，重复派发没有问题，而UI的调整是比较耗资源的
					//所以这里修改为只有数值发生变化的时候才调整UI，提高程序执行效率    yangq
					if(_sumOfLastTimeAndBufferLength != (current + _m.mediaPlayer.bufferLength)) {
						_sumOfLastTimeAndBufferLength = current + _m.mediaPlayer.bufferLength;
						if(_sumOfLastTimeAndBufferLength / total >= 1) { //避免mark.width > rail.width
							_timeTrackBar.mark.width = _timeTrackBar.rail.width;
						} else {
							_timeTrackBar.mark.width = _sumOfLastTimeAndBufferLength / total * _timeTrackBar.rail.width;
						}
					}
				}
			}
		}
		
		/** 根据当前时间和总时间设置_skin.done和icon的位置  **/
		private function setDoneAndIconByTime(current:Number, total:Number):void 
		{
			if(isLive  || _playerInSeeking) {
				return;
			}
			
			var temp:Number =  current * actualWidth / total;
			isNaN(temp) && (temp = 0);
			if(temp + _icon.width*0.5 >= _timeTrackBar.rail.width) {
				_icon.x = _timeTrackBar.rail.width - _icon.width*0.5;
			} else {
				_icon.x = temp + _icon.width*0.5;							
			}	
			
			_m.isPlaybackComplete ? (_timeTrackBar.done.width = _timeTrackBar.rail.width) : (_timeTrackBar.done.width = _icon.x);
		}
			
		/**
		 * 时间进度条实际的宽度，实际宽度为rail.width - _icon.width
		 * @return 
		 * 
		 */		
		private function get actualWidth():Number 
		{
			return _timeTrackBar.rail.width - _icon.width;
		}	
		
		
		override protected function render():void 
		{
			if(_m.simplifiedUI && (_skin != null)) {
				_skin.x = 0;
				_skin.y = stageHeight - _skin.height;
				
				_bg.width = stageWidth;
				if(displayState == StageDisplayState.NORMAL) {
					_fullScreenBtn.visible = true;
					_fullScreenBtn.x = stageWidth - MARGIN - _fullScreenBtn.width + 4;
					_normalScreenBtn.visible = false;
					_volumeBar.x = _fullScreenBtn.x - MARGIN - _volumeBar.width;
					_timeTxt.x = _volumeBar.x - MARGIN - _timeTxt.width;
					_timeTrackBar.x = _playBtn.x + _playBtn.width + MARGIN;
					_timeTrackBar.rail.width = _timeTxt.x - MARGIN - _timeTrackBar.x;
				} else {
					_normalScreenBtn.visible = true;
					_normalScreenBtn.x = stageWidth - MARGIN - _normalScreenBtn.width + 4;
					_fullScreenBtn.visible = false;
					_volumeBar.x = _normalScreenBtn.x - MARGIN - _volumeBar.width;
					_timeTxt.x = _volumeBar.x - MARGIN - _timeTxt.width;
					_timeTrackBar.x = _playBtn.x + _playBtn.width + MARGIN;
					_timeTrackBar.rail.width = _timeTxt.x - MARGIN - _timeTrackBar.x;
				}
				
			
				if(_m.currentFileFormatIsM3U8) {  //m3u8 
					setMarkByTimeAndBufferLength(_current, duration);
				} 
				setDoneAndIconByTime(_current, duration);

				!this.visible && (this.visible = true);
			}
		}
		
		override protected function onMediaPlayerStateChange(evt:MediaPlayerStateChangeEvent):void 
		{
			if(_m.isPlaybackError) {
				setPlayStatus(false);
				//禁用playbtn和timetrackbar
				_playBtn.mouseEnabled = _playBtn.enabled = false; 
				_timeTrackBar.done.width = _timeTrackBar.mark.width = 0;
				_timeTrackBar.mouseEnabled = _timeTrackBar.enabled = false;
				_icon.x = _icon.width * 0.5;
				
				if(displayState != StageDisplayState.NORMAL) { //全屏时如果播放出错，自动退出全屏
					dispatchEvent(new AVPlayerEvent(AVPlayerEvent.TO_NORMALSCREEN));
				}
			} else {
				if(_m.isPlaybackComplete) {	//显示重播按钮
					if(!isLive) {//vod
						if(_m.autoRewind) { //自动重播
							replayHandler();
						} else {
							_replayBtn.visible = true;
							_pauseBtn.visible = _playBtn.visible = false;
						}
					} else  {//直播结束后重播按钮禁止点击，因为地址已失效，replay没有意义 
						_replayBtn.visible = _pauseBtn.visible = false; //隐藏重播和暂停button
						_playBtn.visible = true;
						_playBtn.mouseEnabled = false;
					}
				} else if(!_m.autoPlay && (evt.state == MediaPlayerState.READY)) {//非播放结束状态并且player ready
					setPlayStatus(false);
				}
			}			
		}
		
		private function setPlayStatus(bool:Boolean):void 
		{
			_pauseBtn.visible = bool;
			_playBtn.visible = !bool;
			_replayBtn.visible && (_replayBtn.visible = false);
		}
		
		/**
		 * 播放状态改变
		 * */
		override protected function onPlayStateChange(evt:PlayEvent):void 
		{
			if(evt.playState==PlayState.PLAYING) {
				setPlayStatus(true);
			} else if(evt.playState==PlayState.PAUSED) {
				setPlayStatus(false);
			} else if(evt.playState==PlayState.STOPPED) {
				if(_m.isPlaybackComplete) {  //播放结束时不再处理这个状态  yangq
					return;
				}
				
				setPlayStatus(false);
				setTime(0,_m.mediaPlayer.duration);
			}
		}
		
		override protected function onEnterHomeTheaterMode(evt:HomeTheaterModeEvent):void
		{
			killtween(_skin);
			_tween = TweenLite.to(_skin, 0.4, {y:stageHeight});
		}
		
		override protected function onExitHomeTheaterMode(evt:HomeTheaterModeEvent):void
		{
			if(_isExitingHTM || _skin.y == stageHeight - _skin.height) //缓动中或者已经位于正确的位置上
				return;
			
			_isExitingHTM = true;
			_skin.alpha = 1;
			_skin.y = stageHeight - _skin.height;	
			TweenLite.from(_skin, 0.2, {y:stageHeight, alpha:0.2, onComplete: exitHTMTweenComplete});
		}
	}
}