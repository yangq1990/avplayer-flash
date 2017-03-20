package model
{
	import consts.ErrorCode;
	import consts.VideoFormatConst;
	
	import event.ModelEvent;
	import event.VideoViewEvent;
	import event.js.JSEvent;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	import model.external.JSAPI;
	import model.localstorage.LocalStorageManager;
	import model.vo.ErrorVO;
	import model.vo.LogoVO;
	import model.vo.VideoVO;
	
	import org.denivip.osmf.elements.M3U8Loader;
	import org.denivip.osmf.plugins.HLSPluginInfo;
	import org.osmf.containers.MediaContainer;
	import org.osmf.events.HTTPStreamingEventReason;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.events.MediaPlayerBufferChangeEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.MediaResChangeEvent;
	import org.osmf.events.ParseEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.media.URLResource;
	import org.osmf.traits.PlayState;
	import org.osmf.utils.AVLog;
	import org.osmf.utils.BasicInfo;
	import org.osmf.utils.GlobalReference;
	import org.osmf.utils.OSMFSettings;
	
	import utils.ContainerInspection;
	import utils.StageReference;
	import utils.URLMonitor;
	
	
	public class Model extends EventDispatcher
	{	
		private var _mediaFactory:MediaFactory;
		private var _mediaRes:MediaResourceBase;
		private var _mediaElement:MediaElement;
		private var _mediaPlayer:MediaPlayer;
		private var _mediaContainer:MediaContainer;	
		private var _isMediaPlayerReady:Boolean = false;
		private var _isPlaybackComplete:Boolean = false;
		private var _isPlaybackError:Boolean = false;
		private var _autoPlay:Boolean = false;
		private var _debug:Boolean = false;
		private var _skinUrl:String;
		
		private var _currentVideoURL:String="";
	
		private var _videoFormat:String = VideoFormatConst.M3U8;    //视频的格式，默认m3u8

		private var _ui:MovieClip;		
		private var _version:String;		
		private var _muted:Boolean = false;
		private var _volume:int;		
		private var _playState:String;		
		private var _localStorageManager:LocalStorageManager;		
		public  var jsAPI:JSAPI = JSAPI.getInstance();	
		
		/** 错误VO  **/
		private var _errorVO:ErrorVO;
		
		/** 视频VO **/
		private var _videoVO:VideoVO;
		
		private var _logoVO:LogoVO;
		
		private var _autoRewind:Boolean = false; //是否自动重播
		private var _controlbarHoveringOn:Boolean = false; //controlbar悬浮是否开启
		private var _simplifiedUI:Boolean = false; //是否用精简版UI
		
		public function Model()
		{			
			_mediaPlayer = new MediaPlayer();	
			
			_errorVO = new ErrorVO();
			_videoVO = new VideoVO();
			_logoVO = new LogoVO();
			
			getCookieData();							
			
			jsAPI.addEventListener(JSEvent.PAUSE, onFlashPause);
			jsAPI.addEventListener(JSEvent.PLAY, onFlashPlay);
			jsAPI.addEventListener(JSEvent.ENTER_WEBPAGEFULLSCREEN_SUCCESS, function(evt:JSEvent):void { dispatchEvent(evt); });
			jsAPI.addEventListener(JSEvent.EXIT_WEBPAGEFULLSCREEN_SUCCESS, function(evt:JSEvent):void { dispatchEvent(evt); });
		}
	
		private function getCookieData():void
		{
			_localStorageManager = new LocalStorageManager();
			_volume = _localStorageManager.getPlayerVolume();
		}
		
		private function onFlashPause(evt:JSEvent):void
		{
			pause();
		}
		
		private function onFlashPlay(evt:JSEvent):void
		{
			play();
		}
		
		/**
		 * 播放器暂停
		 * 
		 */		
		public function pause():void
		{
			if(!_isMediaPlayerReady)
			{
				return;
			}
			
			if(!_mediaPlayer.paused)
			{
				_mediaPlayer.pause();
				
				jsAPI.pause();
			}	
		}
		
		/**
		 * 播放器播放
		 * 
		 */		
		public function play():void
		{
			if(!_isMediaPlayerReady)
			{
				return;
			}
			
			if(!_mediaPlayer.playing)
			{
				_mediaPlayer.play();
				
				jsAPI.play();
			}		
		}
		
		/**
		 * 初始化MediaPlayer 
		 * @param videoFormat 视频格式
		 * @param videoURL    视频url
		 * 
		 */		
		public function setupMediaPlayer():void
		{	
			GlobalReference.getInstance().osmf_launch_timestamp = getTimer();
			
			CONFIG::RELEASE {
				AVLog.info("播放环境基本信息: " + sysInfo, true);
			}
			
			if(!_autoPlay && _videoVO.firstFramePicURL)
			{
				dispatchEvent(new ModelEvent(ModelEvent.SHOW_FIRSTFRAMEPIC));
			}
			
			if(!autoPlay && _videoVO.poster) 
			{
				dispatchEvent(new ModelEvent(ModelEvent.SHOW_POSTER));
			}
			
			if(videoFormat == VideoFormatConst.M3U8) 
			{				
				if((new BasicInfo()).isMacSafari)
				{
					OSMFSettings.enableStageVideo = false; //mac safari下使用软解码，使用video代替stagevideo						
				}
				
				_mediaFactory = new DefaultMediaFactory();
				_mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onLoadPlugin);
				_mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onError);
				_mediaFactory.loadPlugin(new PluginInfoResource(new HLSPluginInfo()));
				
				_mediaRes = new URLResource( currentVideoURL );
				
				_mediaElement = _mediaFactory.createMediaElement(_mediaRes);
				if(_mediaElement == null)
				{
					_isPlaybackError = true;
					dispatchEvent(new MediaPlayerStateChangeEvent(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, false, false, MediaPlayerState.PLAYBACK_ERROR));
					return;
				}
				else
				{
					_mediaElement.addEventListener(ParseEvent.PARSE_COMPLETE, onParseComplete);		
					_mediaElement.addEventListener(ParseEvent.PARSE_ERROR, onParseError);	
				}
			}
			
			//需要优先注册事件，然后再设置属性，确保事件能监听到
			_mediaElement.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);			
			_mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE,onTimeChange);
			_mediaPlayer.addEventListener(PlayEvent.PLAY_STATE_CHANGE,onPlayStateChange);
			_mediaPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE,onMediaPlayerStateChange);
			_mediaPlayer.addEventListener(MediaPlayerBufferChangeEvent.BUFFER_RATE_CHANGE,onMediaBufferChange);
			_mediaPlayer.addEventListener(MediaResChangeEvent.MEDIA_RES_CHANGE_DONE,onMediaResChangeDone);
			
			//autoPlay属性的设置要在media之前
			_mediaPlayer.autoPlay = _autoPlay;
			_mediaPlayer.media = _mediaElement;		
			_mediaPlayer.volume = _volume/100; //设置为本地记录的音量
			
			_mediaContainer = new MediaContainer();
			_mediaContainer.addMediaElement(_mediaElement);			
			
			this.dispatchEvent(new VideoViewEvent(VideoViewEvent.MEDIA_ELEMENT_ADDED));		
		}
		
		/**
		 * 改变视频内容,对于mp4和m3u8格式分别用不同的机制处理
		 */
		public function ChangeMediaElement():void
		{	
			switch(videoFormat)
			{
				case VideoFormatConst.M3U8:
					var m3u8Loader:M3U8Loader = new M3U8Loader();
					m3u8Loader.resChangeFlag = true;
					m3u8Loader.addEventListener(MediaResChangeEvent.MEDIA_RES_CHANGE,onM3U8ResourceChange);
					m3u8Loader.executeLoadURL(currentVideoURL);
					break;
				default:
					break;
			}
		}
		
		/**
		 * 当m3u8 media resource改变时,更新mediaplayer
		 * @author jinyongqing
		 */
		private function onM3U8ResourceChange(evt:MediaResChangeEvent):void
		{
			_mediaPlayer.updateResource(evt.resource,_mediaPlayer.currentTime);
		}
		
		private function onParseComplete(evt:ParseEvent):void
		{
			_videoVO.isLive = OSMFSettings.isLive;
			if(_videoVO.isLive)
			{
				dispatchEvent(new ModelEvent(ModelEvent.LIVE_M3U8));
			}
		}
		
		private function onParseError(evt:ParseEvent):void
		{
			_errorVO.code = ErrorCode.HEX_06;
		}
		
		private function onMediaError(evt:MediaErrorEvent):void
		{
			if(evt.error.errorID == MediaErrorCodes.MU38_FILE_NOT_FOUND) 
			{
				if(_videoVO.isLive) 
				{ //直播已结束
					_errorVO.code = ErrorCode.HEX_04;
				} 
				else 
				{ //点播地址不存在或者用户网络已断开
					_errorVO.code = ErrorCode.HEX_01;
				}
			} 
			else if(evt.error.errorID == MediaErrorCodes.SECURITY_ERROR) 
			{ //下载m3u8超时
				_errorVO.code = ErrorCode.HEX_08;
			} 
			else if(evt.error.errorID == MediaErrorCodes.NETSTREAM_STREAM_NOT_FOUND) 
			{
				if(evt.error.reason == HTTPStreamingEventReason.SECURITY_ERROR) 
				{
					_errorVO.code = ErrorCode.HEX_07;
				} 
				else if(evt.error.reason == HTTPStreamingEventReason.TIMEOUT) 
				{
					_errorVO.code = ErrorCode.HEX_06;
				}
				else 
				{
					if(_videoVO.isLive) 
					{ //直播已结束
						_errorVO.code = ErrorCode.HEX_04;
					} 
					else 
					{ //点播地址不存在或者用户网络已断开
						_errorVO.code = ErrorCode.HEX_01;
					}
				}
			}
			errorOccurred();
		}
		
		protected function onError(event:MediaFactoryEvent):void
		{
			
		}
		
		protected function onLoadPlugin(event:MediaFactoryEvent):void
		{

		}
		
		protected function onMediaPlayerStateChange(evt:MediaPlayerStateChangeEvent):void
		{	
			CONFIG::LOGGING
			{
				//检查状态
				AVLog.debug("Model---->media player state: " +  evt.state + "     :currentTime-->" + _mediaPlayer.currentTime);
			}
			
			if(evt.state == MediaPlayerState.BUFFERING || evt.state == MediaPlayerState.READY)//The MediaPlayer is ready to be used.
			{
				_isMediaPlayerReady = true;
				//(evt.state == MediaPlayerState.READY) && jsAPI.playStart();
				//缓冲中且播放未结束
				(evt.state == MediaPlayerState.BUFFERING && !_isPlaybackComplete) && jsAPI.playerBuffering(StageReference.getInstance().root.loaderInfo.parameters["vid"]);
			}						
			else if(evt.state == MediaPlayerState.PLAYING)
			{
				(_mediaPlayer.currentTime <= 1) && jsAPI.playStart(); //播放器处于播放状态，并且当前时间进度为0，表示播放开始
				jsAPI.playerPlaying(StageReference.getInstance().root.loaderInfo.parameters["vid"]);
				_isPlaybackComplete && (_isPlaybackComplete = false); //省略这行代码会导致重播后leftbar view显示不正确
			}
			else if(evt.state == MediaPlayerState.PLAYBACK_COMPLETE)
			{
				_isPlaybackComplete = true;
				jsAPI.playbackComplete();
			}
			else if(evt.state == MediaPlayerState.PLAYBACK_ERROR)
			{
				errorOccurred();
			}
			else
			{
				_isPlaybackComplete && (_isPlaybackComplete = false);
			}
			
			this.dispatchEvent(evt);
		}
		
		/**
		 * 播放发生错误，播放终止
		 * 
		 */		
		public function errorOccurred():void
		{
			//播放m3u8失败的时候，会触发onMediaError, 播放mp4失败的时候会触发onMediaError，和mediastatechange事件，可能导致call两次errorOccurred
			//如果_errorVO.code为-1，或者已经call过errorOccurred方法，则return
			//避免告诉js无用信息，也避免重复调用js function
			if(_errorVO.code == -1 || _isPlaybackError)
				return;
			
			jsAPI.stop();
			
			_isPlaybackError = true;
			jsAPI.noticeError(_errorVO);
			dispatchEvent(new MediaPlayerStateChangeEvent(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE,	false,	false,	MediaPlayerState.PLAYBACK_ERROR));
		}
		
		protected function onPlayStateChange(e:PlayEvent):void
		{
			//网络断开或者视频播放完的时候会触发NetStream.Play.Stop， 进而触发PlayState.STOPPED，所以这里要判断是谁触发了PlayState.STOPPED
			if(e.playState == PlayState.STOPPED)
			{
				var urlMonitor:URLMonitor = new URLMonitor(new URLRequest("http://www.baidu.com/"), monitorCallback);
				urlMonitor.checkStatus();
			}
			else
			{
				_playState = e.playState;
				this.dispatchEvent(e);			
			}		
		}
		
		private function monitorCallback(available:Boolean):void
		{
			if(!_isPlaybackError && !available)  //之前没有触发mediaplaybackerror并且网络不可用
			{
				_errorVO.code = ErrorCode.HEX_02;
				dispatchEvent(new MediaPlayerStateChangeEvent(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, false, false, MediaPlayerState.PLAYBACK_ERROR));
				
				jsAPI.stop();
			}
		}
		
		private function onTimeChange(evt:TimeEvent):void
		{
			this.dispatchEvent(evt);
		}
		
		private function onMediaBufferChange(evt:MediaPlayerBufferChangeEvent):void
		{
			this.dispatchEvent(evt);
		}
		
		private function onMediaResChangeDone(evt:MediaResChangeEvent):void
		{
			this.dispatchEvent(evt);
		}
		
		/**
		 * 对OSMF MediaPlayer的引用
		 * @return 
		 * 
		 */		
		public function get mediaPlayer():MediaPlayer
		{
			return _mediaPlayer;
		}
		
		/**
		 * 播放器版本 
		 * @return 
		 * 
		 */		
		public function get version():String
		{
			return _version;
		}
		
		public function set version(value:String):void
		{
			_version = value;
		}
		
		/**
		 * Indicates whether the media is currently ready
		 * @return 
		 * 
		 */		
		public function get isMediaPlayerReady():Boolean
		{
			return _isMediaPlayerReady;
		}
		
		/**
		 * 包含了视频等的显示对象 
		 * @return 
		 * 
		 */		
		public function get mediaContainer():MediaContainer
		{
			return _mediaContainer;
		}
		
		public function get originalWidth():Number
		{
			return _mediaContainer.displayObject.width;
		}
		
		public function get originalHeight():Number
		{
			return _mediaContainer.displayObject.height;
		}
		
		public function get volume():int
		{
			return _volume;
		}
		
		public function set volume(value:int):void
		{
			_volume = value;
		}
		
		public function get muted():Boolean
		{
			return _muted;
		}
		
		public function set muted(value:Boolean):void
		{
			_muted = value;
		}
		
		/**
		 * 把播放器当前音量值记录到本地 
		 * @param volume
		 * 
		 */		
		public function saveVolume2Cookie(volume:int):void
		{
			_localStorageManager.savePlayerVolume(volume);
		}
		
		public function get playState():String
		{
			return _playState;
		}
		
		/**
		 * 视频是否回放结束 
		 * @return 
		 * 
		 */		
		public function get isPlaybackComplete():Boolean
		{
			return _isPlaybackComplete;
		}
		
		/**
		 * 当前文件格式是否是m3u8
		 * @author yangq 
		 * @return 
		 * 
		 */		
		public function get currentFileFormatIsM3U8():Boolean
		{
			return _videoFormat == VideoFormatConst.M3U8;
		}
		
		/**
		 * 设置视频的格式
		 */
		public function set videoFormat(value:String):void
		{
			 _videoFormat = value;
		}
		
		/**
		 * 获取视频的格式
		 */
		public function get videoFormat():String
		{
			return _videoFormat;
		}
		
		/**
		 * flash player版本 
		 * @return 
		 * 
		 */		
		public function get fpVersion():Number
		{
			return (new ContainerInspection()).fpVersion;
		}
		
		/**
		 * 浏览器是否google chrome
		 * chrome在全屏交互模式下无法输入中文，所以对用chrome的用户，暂时不提供全屏交互功能 
		 * @return 
		 * 
		 */		
		public function get isChrome():Boolean
		{
			return (new ContainerInspection()).isChrome;
		}
		
		/**
		 * 系统信息 
		 * @return 
		 * 
		 */		
		public function get sysInfo():String
		{
			var HWAcceleration:String = "硬件加速：" ;
			HWAcceleration += (OSMFSettings.enableStageVideo ? "开" : "关");
			return (new ContainerInspection()).systemInfo + " | 文件格式：" + _videoFormat.toUpperCase() + " | 播放类型：" + (_videoVO.isLive ? "LIVE" : "VOD") + " | " + HWAcceleration;
		}

		/**
		 * 是否自动播放，默认为true 
		 * @return 
		 * 
		 */		
		public function get autoPlay():Boolean
		{
			return _autoPlay;
		}

		public function set autoPlay(value:Boolean):void
		{
			_autoPlay = value;
		}
	
		public function get ui():MovieClip
		{
			return _ui;
		}

		public function set ui(value:MovieClip):void
		{
			_ui = value;
		}
		
		/**
		 * 是否播放出错 
		 * @return 
		 * 
		 */		
		public function get isPlaybackError():Boolean
		{
			return _isPlaybackError;
		}
		
		public function set isPlaybackError(value:Boolean):void
		{
			_isPlaybackError = value;
		}

		/** Error **/
		public function get errorVO():ErrorVO
		{
			return _errorVO;
		}

		public function get videoVO():VideoVO
		{
			return _videoVO;
		}

		public function get autoRewind():Boolean
		{
			return _autoRewind;
		}

		public function set autoRewind(value:Boolean):void
		{
			_autoRewind = value;
		}

		public function get currentVideoURL():String
		{
			return _currentVideoURL;
		}

		public function set currentVideoURL(value:String):void
		{
			_currentVideoURL = value;
		}

		public function get controlbarHoveringOn():Boolean
		{
			return _controlbarHoveringOn;
		}

		public function set controlbarHoveringOn(value:Boolean):void
		{
			_controlbarHoveringOn = value;
		}

		public function get logoVO():LogoVO
		{
			return _logoVO;
		}

		public function set logoVO(value:LogoVO):void
		{
			_logoVO = value;
		}

		public function get debug():Boolean
		{
			return _debug;
		}

		public function set debug(value:Boolean):void
		{
			_debug = value;
		}

		/**
		 * 播放器皮肤url 
		 * @return 
		 * 
		 */		
		public function get skinUrl():String
		{
			return _skinUrl;
		}

		public function set skinUrl(value:String):void
		{
			_skinUrl = value;
		}	

		public function get simplifiedUI():Boolean
		{
			return _simplifiedUI;
		}

		public function set simplifiedUI(value:Boolean):void
		{
			_simplifiedUI = value;
		}

	}
}