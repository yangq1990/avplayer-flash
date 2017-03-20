package view
{
	import consts.ErrorCode;
	import consts.LayoutConst;
	import consts.TimerConst;
	
	import event.AVPlayerEvent;
	import event.HomeTheaterModeEvent;
	import event.VideoViewEvent;
	import event.bar.RightBarEvent;
	import event.bar.TimeTrackBarEvent;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	import model.Model;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	
	import view.base.BaseView;
	
	/**
	 * 视频界面类
	 * @author yangq
	 * 
	 */	
	public class VideoView extends BaseView
	{
		private var _mediaContainer:Sprite;
		private var _doubleClicked:Boolean;
		private var _bg:Sprite;
		
		/** 1s之前鼠标的x坐标 **/
		private var _twoSecondsBeforeX:Number;
		/** 1s之前鼠标的y坐标 **/
		private var _twoSecondsBeforeY:Number;			
		/** 全屏状态下每隔1.5s检查鼠标位置是否变动的定时器 **/
		private var _timer:Timer;
		/** 全屏交互状态下与安全对话框相关的定时器 **/
		private var _fullScreenDialogTimer:Timer;
		
		private var _mouseLeftStage:Boolean = false;
		
		public function VideoView(m:Model)
		{
			super(m);
			
			_bg = new Sprite();
			_bg.mouseChildren = false;
			addChild(_bg);
		}
		
		override protected function addListeners():void
		{
			super.addListeners();			
			_m.addEventListener(VideoViewEvent.MEDIA_ELEMENT_ADDED, onMediaElementAdded);		
			eventbus.addEventListener(VideoViewEvent.ADJUST_PERCENT, onAdjustPercent);		
			this.doubleClickEnabled = true; 
			this.addEventListener(MouseEvent.CLICK, onMouseClick);
			this.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);	
			_stageRef.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_stageRef.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			//舞台进入或离开全屏显示模式，Stage 对象就调度 FullScreenEvent 对象
			//全屏可交互状态下，点击允许按钮，会出现事件穿透的bug，比如当前全屏显示视频，点击允许后会导致视频界面也被点击，从而造成视频暂停
			_stageRef.stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenInteractive);
			_stageRef.stage.addEventListener(FullScreenEvent.FULL_SCREEN_INTERACTIVE_ACCEPTED, onFullScreenInteractive);
		}
		
		private function onMediaElementAdded(evt:VideoViewEvent):void
		{
			_mediaContainer = _m.mediaContainer;
			this.addChild(_mediaContainer);
			this.buttonMode = true; //禁用暂停功能时不显示手型光标
			this.mouseChildren = false;
			render();
		}	

		private function onMouseClick(evt:MouseEvent):void
		{
			evt.stopImmediatePropagation();
			
			if(_m.isPlaybackError)//禁用暂停功能后不可点击
			{
				return; 
			}
			
			_doubleClicked = false;
			var timer:Timer = new Timer(260,1);
			timer.addEventListener(TimerEvent.TIMER, onClickTimer);
			timer.start();				
		}
		
		private function onClickTimer(evt:TimerEvent):void
		{
			(evt.target as Timer).removeEventListener(TimerEvent.TIMER, onClickTimer);
			
			if(!_doubleClicked)
			{
				this.dispatchEvent(new AVPlayerEvent(AVPlayerEvent.CLICK_VIDEO));				
			}
		}
		
		//鼠标双击，进入全屏或者退出全屏
		private function onDoubleClick(evt:MouseEvent):void
		{
			evt.stopImmediatePropagation();			
			
			_doubleClicked = true;		
			eventbus.dispatchEvent(new RightBarEvent(RightBarEvent.VIDEO_VIEW_DOUBLE_CLICKED));
		}
		
		private var mouseInHotZone:Boolean = false;
		private function onMouseMove(evt:MouseEvent):void
		{			
			//这里不能用evt.stopPropagation()或evt.stopImmediatePropagation();
			//否则会阻止RightBar中对MouseMove的判断进而影响到VolumeBar的显示
			_mouseLeftStage = false;
			
			//controlbar不悬浮但是在全屏状态下或者controlbar悬浮
			if(displayState != StageDisplayState.NORMAL) {
				_timer && _timer.reset();
				
				eventbus.dispatchEvent(new HomeTheaterModeEvent(HomeTheaterModeEvent.EXIT));
				Mouse.show();
				_twoSecondsBeforeX = evt.stageX;
				_twoSecondsBeforeY = evt.stageY;
				
				_timer && _timer.start();
			}
			
			//var mouseInHotZone:Boolean = false;
			if(!isTextInputViewAvailable) 
			{
				(evt.stageY >= stageHeight - controlbarHeight - LayoutConst.HOTZONE_HEIGHT) ? (mouseInHotZone = true) : (mouseInHotZone = false);
			}
			else
			{
				(evt.stageY >= stageHeight - textInputViewHeight - controlbarHeight - LayoutConst.HOTZONE_HEIGHT) ? (mouseInHotZone = true) : (mouseInHotZone = false);
			}
			
			if(mouseInHotZone) {
				eventbus.dispatchEvent(new TimeTrackBarEvent(TimeTrackBarEvent.MOUSE_IN_HOTZONE));
			} else {
				eventbus.dispatchEvent(new TimeTrackBarEvent(TimeTrackBarEvent.MOUSE_OUT_HOTZONE));
			}			
		}
	
		private function enterHomeTheaterMode():void
		{
			//如果鼠标从热区划过，并且从controlbar底部离开舞台，此时mouseInHotZone为true，所以要判断鼠标是否离开舞台
			if(mouseInHotZone && !_mouseLeftStage) {  //鼠标在热区，不进入家庭影院模式
				Mouse.show();
				return;  
			}
			
			eventbus.dispatchEvent(new HomeTheaterModeEvent(HomeTheaterModeEvent.ENTER));
			Mouse.hide();
		}
		
		override protected function render():void
		{
			var g:Graphics = _bg.graphics;
			g.clear();
			g.beginFill(0xff0000, 0); //背景透明，某些情况下chrome无法显示出来视频
			if(!_m.controlbarHoveringOn) { //controlbar固定显示,不悬浮
				if(displayState == StageDisplayState.NORMAL) //普通屏幕下
				{
					g.drawRect(0, 0, stageWidth, stageHeight - controlbarHeight);
				}
				else //全屏
				{
					g.drawRect(0, 0, stageWidth, stageHeight);
				}
				g.endFill();
				
				if(_mediaContainer)
				{
					destroyTimer();
					
					if(displayState == StageDisplayState.NORMAL)
					{
						Mouse.show(); // 强制显示鼠标
						_mediaContainer.width = stageWidth;
						!isTextInputViewAvailable ? (_mediaContainer.height = stageHeight - controlbarHeight) : (_mediaContainer.height = stageHeight - controlbarHeight - textInputViewHeight);
						//reset MediaContainer position to (0,0);
						_mediaContainer.x = _mediaContainer.y = 0;
					}
					else
					{				
						_timer = new Timer(TimerConst.DELAY);
						_timer.addEventListener(TimerEvent.TIMER, onTimer);
						_timer.start();
						
						_mediaContainer.width = stageWidth;
						_mediaContainer.height = stageHeight;
					}
				}	
			} else {  //controlbar默认悬浮，videoview的高度等同于stage.height
				if(displayState == StageDisplayState.NORMAL) //普通屏幕下
				{
					g.drawRect(0, 0, stageWidth, stageHeight);
				}
				else //全屏
				{
					g.drawRect(0, 0, stageWidth, stageHeight);
				}
				g.endFill();
				
				if(_mediaContainer) {
					destroyTimer();
					
					if(displayState == StageDisplayState.NORMAL) {
						Mouse.show(); // 强制显示鼠标
						_mediaContainer.width = stageWidth;
						!isTextInputViewAvailable ? (_mediaContainer.height = stageHeight) : (_mediaContainer.height = stageHeight  - textInputViewHeight);
						//reset MediaContainer position to (0,0);
						_mediaContainer.x = _mediaContainer.y = 0;
					} else {				
						_mediaContainer.width = stageWidth;
						_mediaContainer.height = stageHeight;
					}
					
					//启动定时器
					_timer = new Timer(TimerConst.DELAY);
					_timer.addEventListener(TimerEvent.TIMER, onTimer);
					_timer.start();
				}	
			}
		}
		
		private function destroyTimer():void
		{
			if(_timer)
			{
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, onTimer);
				_timer = null;
			}
		}
		
		private function onTimer(evt:TimerEvent):void
		{
			check();
		}
		
		/** 每隔1.5s检查鼠标位置是否有变动 **/
		private function check():void
		{
			if((isNaN(_twoSecondsBeforeX) && isNaN(_twoSecondsBeforeY)) //没有记录过鼠标的坐标值
				|| (_twoSecondsBeforeX == stage.mouseX && _twoSecondsBeforeY == stage.mouseY)
				|| (_m.controlbarHoveringOn && _mouseLeftStage)) //controlbar悬浮时鼠标离开舞台
			{
				enterHomeTheaterMode();
			}
		}
		
		//鼠标离开舞台
		override protected function onMouseLeaveStage(evt:Event):void {
			_mouseLeftStage = true;
			if(_m.controlbarHoveringOn) { //鼠标离开舞台时开始计时
				if(_timer) {
					_timer.reset();
					_timer.start();
				}
			}
		}
		
		private function onKeyDown(evt:KeyboardEvent):void
		{
			if(!stageFocusIsTextInputView)
			{
				if(evt.keyCode == Keyboard.ENTER && displayState == StageDisplayState.NORMAL)
				{
					//普通状态下进入全屏
					dispatchEvent(new AVPlayerEvent(AVPlayerEvent.TO_FULLSCREEN));					
				}
			}			
		}
		
		/**
		 * 处理全屏交互模式下点击对话框允许按钮后事件穿透的bug 
		 * 
		 **/
		private function onFullScreenInteractive(evt:FullScreenEvent):void
		{
			if(evt.fullScreen)
			{
				if(evt.type == FullScreenEvent.FULL_SCREEN && evt.interactive)
				{
					this.removeEventListener(MouseEvent.CLICK, onMouseClick);
					
					_fullScreenDialogTimer = new Timer(150, 1);
					_fullScreenDialogTimer.addEventListener(TimerEvent.TIMER_COMPLETE , onFullScreenDialogTimerComplete);
				}
				else if(evt.type == FullScreenEvent.FULL_SCREEN_INTERACTIVE_ACCEPTED)
				{
					_fullScreenDialogTimer.start();
				}
			}
			else
			{
				if(!this.hasEventListener(MouseEvent.CLICK))
				{
					this.addEventListener(MouseEvent.CLICK, onMouseClick);
				}
				
				if(_fullScreenDialogTimer)
				{
					_fullScreenDialogTimer.stop();
					_fullScreenDialogTimer.removeEventListener(TimerEvent.TIMER_COMPLETE , onFullScreenDialogTimerComplete);
					_fullScreenDialogTimer = null;
				}
			}
		}
		
		private function onFullScreenDialogTimerComplete(event:TimerEvent):void
		{
			this.addEventListener(MouseEvent.MOUSE_DOWN, enableClick);
		}
		
		private function enableClick(event:MouseEvent):void
		{
			this.removeEventListener(MouseEvent.MOUSE_DOWN, enableClick);
			this.addEventListener(MouseEvent.CLICK, onMouseClick);
		}
		
		private function onAdjustPercent(evt:VideoViewEvent):void
		{			
			if(_mediaContainer)
			{
				var tempW:Number = stageWidth * evt.percent;
				var tempH:Number = stageHeight * evt.percent;				
				
				_mediaContainer.width = tempW;
				_mediaContainer.height = tempH;
				
				//由于MediaContainer实现了延迟Layout，width, height属性不会立即得到更新
				//所以不能用(stageWidth - _mediaContainer.width) * 0.5重设MediaContainer的x坐标
				//而是用临时数据来判断
				_mediaContainer.x = (stageWidth - tempW) * 0.5;
				_mediaContainer.y = (stageHeight - tempH) * 0.5;
			}
		}
		
		override protected function onMediaPlayerStateChange(evt:MediaPlayerStateChangeEvent):void {
			//直播结束时隐藏画面，显示电视雪花效果
			if((_m.isPlaybackError && _m.errorVO.code == ErrorCode.HEX_07) || 
				(_m.isPlaybackComplete && isLive)) {
					(_mediaContainer != null) && (_mediaContainer.visible = false);
				}
		}
	}
}