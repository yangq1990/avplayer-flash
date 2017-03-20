package controller
{
	import event.AVPlayerEvent;
	import event.TaskEvent;
	
	import flash.display.StageDisplayState;
	
	import model.Model;
	
	import utils.StageReference;
	
	import view.View;

	public class Controller
	{
		private var _v:View;
		private var _m:Model;
	
		public function Controller(v:View, m:Model)
		{
			_v = v;
			_m = m;
			
			addLitseners();
		}
		
		/**
		 * 构建播放器 
		 * 
		 */		
		public function setupPlayer():void 
		{
			var playerSetup:PlayerSetup = new PlayerSetup(_v, _m);
			playerSetup.addEventListener(TaskEvent.ALL_TASKS_COMPLETE, onAllTasksComplete);
			playerSetup.addEventListener(TaskEvent.FATAL_ERROR, onFatalError);
			playerSetup.setup();
		}
		
		private function onAllTasksComplete(evt:TaskEvent):void
		{
			_m.setupMediaPlayer();	
		}
		
		private function onFatalError(evt:TaskEvent):void
		{
			_v.showInitializationErrorView(evt.errorMsg);
		}
		
		/**
		 * 这个函数统一监听View派发过来的事件 
		 * 
		 */		
		private function addLitseners():void
		{
			_v.addEventListener(AVPlayerEvent.PAUSE, onAVPlayerPause);
			_v.addEventListener(AVPlayerEvent.PLAY, onAVPlayerPlay);
			_v.addEventListener(AVPlayerEvent.ADJUST_VOLUME, onAVPlayerAdjustVolume);
			_v.addEventListener(AVPlayerEvent.SEEK, onAVPlayerSeek);
			_v.addEventListener(AVPlayerEvent.CLICK_VIDEO, onClickVideo);
			_v.addEventListener(AVPlayerEvent.TO_FULLSCREEN, onToFullscreen);
			_v.addEventListener(AVPlayerEvent.TO_NORMALSCREEN, onToNormalscreen);
			_v.addEventListener(AVPlayerEvent.MUTE, onAVPlayerMute);
			_v.addEventListener(AVPlayerEvent.UNMUTE, onAVPlayerUnMute);
			_v.addEventListener(AVPlayerEvent.REFRESH, onAVPlayerRefresh);
			_v.addEventListener(AVPlayerEvent.REWIND, onAVPlayerRewind);
		}
		
		private function onAVPlayerPause(evt:AVPlayerEvent):void
		{
			_m.pause();
		}
		
		private function onAVPlayerPlay(evt:AVPlayerEvent):void
		{
			_m.play();
		}
		
		/**
		 * 调整视频音量, 此时evt.data的数据结构为 {'volume':Number, 'save2cookie':Boolean}
		 * volume是当前音量，save2cookie为true，表明需要立即将音量值写入flash本地存储 
		 * @param evt
		 * 
		 */		
		private function onAVPlayerAdjustVolume(evt:AVPlayerEvent):void
		{
			_m.mediaPlayer.volume = evt.data.volume;
			_m.volume = evt.data.volume * 100;
		}
		
		/** 拖动视频 **/
		private function onAVPlayerSeek(evt:AVPlayerEvent):void
		{
			if(_m.mediaPlayer.canSeek)
			{
				_m.mediaPlayer.seek(evt.data as Number);
				//如果播放结束的时候seek,会从seek点继续播放
				if(_m.isPlaybackComplete)
				{
					_m.play();
				}
			}
		}
		
		/** 播放 or 暂停视频 **/
		private function onClickVideo(evt:AVPlayerEvent):void
		{
			if(!_m.isMediaPlayerReady)
			{
				return;
			}
			
			if(_m.isPlaybackComplete)
			{
				if(!_m.videoVO.isLive) //修复直播结束后点击视频区域后seek(0)导致的bug
				{
					_m.mediaPlayer.seek(0);
					_m.play();
				}
				return;			
			}
			
			if(!_m.mediaPlayer.paused)
			{
				_m.pause();
			}	
			else if(!_m.mediaPlayer.playing)
			{
				_m.play();
			}	
		}
		
		/** 切换到全屏状态 **/
		private function onToFullscreen(evt:AVPlayerEvent):void
		{
			var stageRef:StageReference = StageReference.getInstance();
			if(stageRef.stage.allowsFullScreen)
			{
				stageRef.stage.displayState = StageDisplayState.FULL_SCREEN;
			}
		}
		
		/** 切换到普通屏幕状态  **/
		private function onToNormalscreen(evt:AVPlayerEvent):void
		{
			StageReference.getInstance().stage.displayState = StageDisplayState.NORMAL;
		}
		
		/** 静音 **/
		private function onAVPlayerMute(evt:AVPlayerEvent):void
		{
			_m.muted = true;
			_m.mediaPlayer.volume = 0;
		}
		
		/** 取消静音 **/
		private function onAVPlayerUnMute(evt:AVPlayerEvent):void
		{
			_m.muted = false;
			_m.mediaPlayer.volume = _m.volume / 100;
		}
		
		/** 刷新 **/
		private function onAVPlayerRefresh(evt:AVPlayerEvent):void
		{
			_m.jsAPI.refresh();
		}
		
		private function onAVPlayerRewind(evt:AVPlayerEvent):void
		{
			_m.jsAPI.replay();
		}
	}
}