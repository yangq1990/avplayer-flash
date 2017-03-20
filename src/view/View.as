package view
{
	import com.greensock.plugins.AutoAlphaPlugin;
	import com.greensock.plugins.TweenPlugin;
	
	import event.AVPlayerEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import model.Model;
	
	import utils.StageReference;
	
	import view.bar.BottomBarView;
	import view.bar.LeftBarView;
	import view.bar.RightBarView;
	import view.bar.TimeTrackBarView;
	import view.bar.TopBarView;
	import view.bar.VolumeBarView;
	import view.error.InitializationErrorView;
	import view.log.CriticalLogView;
	import view.simplifiedUI.SimplifiedUI;
	import view.tips.TipTextView;
	import view.tips.TipTimeView;

	/**
	 * View.as里持有对各个界面类的引用，各个界面类内部派发的事件统一再由View.as冒泡出去，在Controller.as里监听处理 
	 * @author yangq
	 * 
	 */	
	public class View extends EventDispatcher
	{		
		private var _videoView:VideoView;		
		
		private var _playbackErrorView:PlaybackErrorView;
		
		private var _root:Sprite;	
		
		private var _topBar:TopBarView;
		private var _bottomBar:BottomBarView;
		private var _leftBar:LeftBarView;
		private var _rightBar:RightBarView;
		private var _trackBar:TimeTrackBarView;		
		private var _volumeBar:VolumeBarView;
		
		private var _bufferingView:BufferingView;
		
		private var _tipTimeView:TipTimeView;
		
		private var _logoView:LogoView;
		
		private var _liveTipsView:LiveTipsView;
		
		private var _firstFramePicView:FirstFramePicView;
		
		private var _criticalLogView:CriticalLogView;
		
		private var _tipTextView:TipTextView;
		
		private var _liveEndedView:LiveEndedView;
		
		private var _simplifiedUI:SimplifiedUI;
		
		private var _m:Model;
		
		public function View(m:Model)
		{
			_m = m;
			
			_root = new Sprite();
			_root.visible = false; //默认隐藏
			_root.name = 'root';
			StageReference.getInstance().stage.addChildAt(_root, 0);
			
			TweenPlugin.activate([AutoAlphaPlugin]); //activation is permanent in the SWF, so this line only needs to be run once.
		}
		
		/**
		 * 初始化各界面类 
		 * 
		 */		
		public function setupView():void
		{			
			_videoView = new VideoView(_m);
			_videoView.name = "VideoView";
			_videoView.addEventListener(AVPlayerEvent.CLICK_VIDEO, function(evt:AVPlayerEvent):void{ dispatchEvent(evt); });
			_videoView.addEventListener(AVPlayerEvent.TO_FULLSCREEN, function(evt:AVPlayerEvent):void{ dispatchEvent(evt); });
			_videoView.addEventListener(AVPlayerEvent.TO_NORMALSCREEN, function(evt:AVPlayerEvent):void{ dispatchEvent(evt); });			
			_videoView.visible = false;
			_root.addChild(_videoView);
		
			_playbackErrorView = new PlaybackErrorView(_m);
			_playbackErrorView.name = "PlaybackErrorView";
			_playbackErrorView.addEventListener(AVPlayerEvent.REFRESH, function(evt:AVPlayerEvent):void{ dispatchEvent(evt); });
			_root.addChild(_playbackErrorView);		
			
			_liveEndedView = new LiveEndedView(_m);
			_liveEndedView.name = "LiveEndedView";
			_root.addChild(_liveEndedView);
			
			initUi();
			
			_simplifiedUI = new SimplifiedUI(_m);
			_simplifiedUI.name = "SimplifiedUI";
			_simplifiedUI.addEventListener(AVPlayerEvent.PAUSE, function(evt:AVPlayerEvent):void{ dispatchEvent(evt); });
			_simplifiedUI.addEventListener(AVPlayerEvent.PLAY, function(evt:AVPlayerEvent):void{ dispatchEvent(evt); });
			_simplifiedUI.addEventListener(AVPlayerEvent.SEEK, function(evt:AVPlayerEvent):void{ dispatchEvent(evt); });		
			_simplifiedUI.addEventListener(AVPlayerEvent.REWIND, function(evt:AVPlayerEvent):void{ dispatchEvent(evt); });
			_simplifiedUI.addEventListener(AVPlayerEvent.TO_FULLSCREEN, function(evt:AVPlayerEvent):void { dispatchEvent(evt);  });
			_simplifiedUI.addEventListener(AVPlayerEvent.TO_NORMALSCREEN, function(evt:AVPlayerEvent):void { dispatchEvent(evt);  });
			_simplifiedUI.addEventListener(AVPlayerEvent.ADJUST_VOLUME, function(evt:AVPlayerEvent):void { dispatchEvent(evt);  });
			_simplifiedUI.addEventListener(AVPlayerEvent.MUTE, function(evt:AVPlayerEvent):void { dispatchEvent(evt);  });
			_simplifiedUI.addEventListener(AVPlayerEvent.UNMUTE, function(evt:AVPlayerEvent):void { dispatchEvent(evt);  });
			_root.addChild(_simplifiedUI);
			
			_bufferingView = new BufferingView(_m);
			_bufferingView.name = "BufferingView";
			_root.addChild(_bufferingView);
			
			_tipTimeView = new TipTimeView(_m);
			_tipTimeView.name = "TipTimeView";
			_root.addChild(_tipTimeView);
			
			_liveTipsView = new LiveTipsView(_m);
			_liveTipsView.name  "LiveTipsView";
			_root.addChild(_liveTipsView);
			
			_tipTextView = new TipTextView(_m);
			_tipTextView.name = "TipTextView";
			_root.addChild(_tipTextView);
			
			var rightclickmenu:RightClickMenu = new RightClickMenu(_m, _root);
			rightclickmenu.initializeMenu();			
			
			StageReference.getInstance().stage.dispatchEvent(new Event(Event.RESIZE));
		}
		
		private function initUi():void
		{
			_firstFramePicView = new FirstFramePicView(_m);
			_root.addChild(_firstFramePicView);
			
			initTopBar();	
			initBottomBar();
			initLeftBar();
			initRightBar();
			initTrackBar();		
			initVolumeBar();
			
			_criticalLogView = new CriticalLogView(_m);
			_root.addChild(_criticalLogView);
		}
		
		private function initTopBar():void
		{
			_topBar = new TopBarView(_m);
			_topBar.name = "TopBarView";
			_root.addChild(_topBar);
		}
		
		private function initBottomBar():void
		{
			_bottomBar = new BottomBarView(_m);
			_bottomBar.name = "BottomBarView";
			_root.addChild(_bottomBar);		
		}
		
		private function initLeftBar():void
		{
			_leftBar = new LeftBarView(_m);			
			_leftBar.name = "LeftBarView";
			_root.addChild(_leftBar);		
			_leftBar.addEventListener(AVPlayerEvent.PAUSE, function(evt:AVPlayerEvent):void{ dispatchEvent(evt); });
			_leftBar.addEventListener(AVPlayerEvent.PLAY, function(evt:AVPlayerEvent):void{ dispatchEvent(evt); });
			_leftBar.addEventListener(AVPlayerEvent.SEEK, function(evt:AVPlayerEvent):void{ dispatchEvent(evt); });		
			_leftBar.addEventListener(AVPlayerEvent.REWIND, function(evt:AVPlayerEvent):void{ dispatchEvent(evt); });
		}
		
		private function initRightBar():void
		{
			_rightBar = new RightBarView(_m);
			_rightBar.name = "RightBarView";
			_root.addChild(_rightBar);		
			_rightBar.addEventListener(AVPlayerEvent.TO_FULLSCREEN, function(evt:AVPlayerEvent):void { dispatchEvent(evt);  });
			_rightBar.addEventListener(AVPlayerEvent.TO_NORMALSCREEN, function(evt:AVPlayerEvent):void { dispatchEvent(evt);  });
		}
		
		private function initTrackBar():void
		{
			_trackBar = new TimeTrackBarView(_m);
			_trackBar.name = "TimeTrackBarView";
			_root.addChild(_trackBar);		
			_trackBar.addEventListener(AVPlayerEvent.SEEK, function(evt:AVPlayerEvent):void{ dispatchEvent(evt); });
		}
	
		private function initVolumeBar():void
		{
			_volumeBar = new VolumeBarView(_m);
			_volumeBar.name = "VolumeBarView";
			_volumeBar.addEventListener(AVPlayerEvent.ADJUST_VOLUME, function(evt:AVPlayerEvent):void { dispatchEvent(evt);  });
			_volumeBar.addEventListener(AVPlayerEvent.MUTE, function(evt:AVPlayerEvent):void { dispatchEvent(evt);  });
			_volumeBar.addEventListener(AVPlayerEvent.UNMUTE, function(evt:AVPlayerEvent):void { dispatchEvent(evt);  });
			_root.addChild(_volumeBar);		
		}
		
		/**
		 * 显示播放器初始化错误界面，区分于播放错误界面，提示初始化错误步骤，及错误信息，方便修正 
		 * @param errorMsg 导致初始化中断的错误的提示信息
		 * 
		 */		
		public function showInitializationErrorView(errorMsg:String):void
		{
			var initializationErrorView:InitializationErrorView = new InitializationErrorView(errorMsg);
			_root.addChild(initializationErrorView);
		}
		
		/**
		 * _root visible 设置为true
		 * avplayer.swf不被loader.swf加载或者
		 * 被加载后收到loader.swf发送过来的loadingRemoved事件时调用
		 * 
		 */		
		public function show():void
		{
			_root.visible = true;
			//播放器autoplay设置为1，即开启自动播放功能后，有可能显示视频画面的时候loadering.swf还在显示
			//这段代码是为了避免上述的情况
			_videoView && (_videoView.visible = true);
			StageReference.getInstance().stage.dispatchEvent(new Event(Event.RESIZE));
		}
	}
}