package view.base
{
	import com.greensock.TweenLite;
	
	import event.HomeTheaterModeEvent;
	import event.ModelEvent;
	
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import model.Model;
	
	import org.osmf.events.MediaPlayerBufferChangeEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.MediaResChangeEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.utils.EventBus;
	import org.osmf.utils.GlobalReference;
	
	import utils.StageReference;
	
	/**
	 * 界面类的基类 
	 * @author yangq
	 * 
	 */	
	public class BaseView extends Sprite
	{
		protected var _m:Model;
		
		/** 播放器皮肤  **/
		protected var _ui:Object;
		
		/** 每个View里对应的皮肤元件 **/
		protected var _skin:MovieClip;
		
		protected var _skinHeight:Number;
		
		protected var _tween:TweenLite;
		/** 是否在进入家庭影院模式的缓动中  
		 *  HTM 即HomeTheaterMode，家庭影院模式
		 * **/
		protected var _isEnteringHTM:Boolean = false;
		/** 是否在退出家庭影院模式的缓动中  **/
		protected var _isExitingHTM:Boolean = false;
		
		/** 是否需要重绘界面  **/
		private var _updateFlag:Boolean = false;
		
		//处理mp4的拖动,yangq
		protected var _seekingKeyframeTime:Number = 0; //离拖动点最近的关键帧的时间戳
		protected var _playerInSeeking:Boolean = false;
		protected var _globalRef:GlobalReference = GlobalReference.getInstance();
		protected var _stageRef:StageReference = StageReference.getInstance();
		
		public function BaseView(m:Model)
		{
			super();
		
			_m = m;
			_ui = m.ui;
			
			addListeners();
		}
	
		/**
		 * 此函数只放非显示对象的事件监听
		 * 显示对象，比如界面元素的事件监听放在构造函数里面 
		 * 
		 */		
		protected function addListeners():void
		{
			_m.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE,onMediaPlayerStateChange);
			_m.addEventListener(PlayEvent.PLAY_STATE_CHANGE,onPlayStateChange);
			_m.addEventListener(MediaPlayerBufferChangeEvent.BUFFER_RATE_CHANGE,onMediaBufferChange);
			_m.addEventListener(MediaResChangeEvent.MEDIA_RES_CHANGE_DONE,onMediaResChangeDone);
			_m.addEventListener(ModelEvent.SHOW_PREROLL_AD, onShowPrerollAd);
			_m.addEventListener(ModelEvent.REMOVE_PREROLL_AD, onRemovePrerollAd);
			_stageRef.stage.addEventListener(Event.RESIZE,onResize);
			_stageRef.stage.addEventListener(Event.RENDER, onRender);
			_stageRef.stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeaveStage);
			
			eventbus.addEventListener(HomeTheaterModeEvent.ENTER, onEnterHomeTheaterMode);
			eventbus.addEventListener(HomeTheaterModeEvent.EXIT, onExitHomeTheaterMode);
		}
		
		private function onResize(evt:Event):void
		{
			_updateFlag = true;
			_stageRef.stage.invalidate();
		}
		
		/** Event.RENDER在FP更新显示列表前触发 **/
		private function onRender(evt:Event):void
		{
			if(_updateFlag)
			{
				render();
				_updateFlag = false;
			}
		}
		
		/**
		 * 交给子类重写, 实现自定义调整尺寸和布局 
		 * 
		 */		
		protected function render():void
		{
			
		}		
		
		/**
		 * 交给子类重写, 实现对MediaPlayerState状态改变的自定义处理 
		 * @param evt
		 * 
		 */		
		protected function onMediaPlayerStateChange(evt:MediaPlayerStateChangeEvent):void
		{
		
		}
	
		/**
		 * 交给子类重写，实现对播放状态的处理 
		 * @param evt
		 * 
		 */		
		protected function onPlayStateChange(evt:PlayEvent):void
		{
			
		}
		
		
		/**
		 * 交给子类重写, 实现缓冲变化时候的缓冲进度处理
		 */
		protected function onMediaBufferChange(evt:MediaPlayerBufferChangeEvent):void
		{
			
		}
		
		/**
		 * 交给子类重写, 实现切换视频res完成后的逻辑
		 */
		protected function onMediaResChangeDone(evt:MediaResChangeEvent):void
		{
			
		}
		
		/**
		 * 各View根据此事件调整自己的显示状态
		 */
		protected function onShowPrerollAd(evt:ModelEvent):void
		{
			
		}
		
		/**
		 * 各View根据此事件调整自己的显示状态
		 */
		protected function onRemovePrerollAd(evt:ModelEvent):void
		{
			
		}
		
		
		/**
		 * 舞台宽度 
		 * @return 
		 * 
		 */		
		protected function get stageWidth():Number
		{
			return _stageRef.stage.stageWidth;
		}
		
		/**
		 * 舞台高度 
		 * @return 
		 * 
		 */		
		protected function get stageHeight():Number
		{
			return _stageRef.stage.stageHeight;
		}
		
		/**
		 * 播放器底部控制条高度 
		 * @return 
		 * 
		 */		
		protected function get controlbarHeight():Number
		{
			if(_ui == null || _ui.BottomBar == null)
			{
				throw new Error("没有正确访问到BottomBar皮肤，请检查代码");
			}
		
			return _ui.BottomBar.height;
		}
		
		/**
		 * 文字输入界面高度 
		 * @return 
		 * 
		 */		
		protected function get textInputViewHeight():Number
		{
			if(_ui == null || _ui.TextInput == null)
			{
				throw new Error("没有正确访问到TextInput皮肤，请检查代码");
			}
			
			return _ui.TextInput.height;
		}
		
		/**
		 * 底部Logo宽度 
		 * @return 
		 * 
		 */		
		protected function get bottomLogoWidth():Number
		{
			if(_ui == null || _ui.BottomLogo == null)
			{
				throw new Error("没有正确访问到BottomLogo皮肤，请检查代码");
			}
			return _ui.BottomLogo.width;
		}
		
		protected function get eventbus():EventBus
		{
			return EventBus.getInstance();
		}
		
		protected function get displayState():String
		{
			return _stageRef.stage.displayState;
		}
		
		/**
		 * 鼠标离开舞台 
		 * @param evt
		 * 
		 */		
		protected function onMouseLeaveStage(evt:Event):void
		{
			
		}
		
		/**
		 * 全屏状态下进入家庭影院模式 
		 * @param evt
		 * 
		 */		
		protected function onEnterHomeTheaterMode(evt:HomeTheaterModeEvent):void
		{
			
		}
		
		/**
		 * 全屏状态下退出家庭影院模式 
		 * @param evt
		 * 
		 */		
		protected function onExitHomeTheaterMode(evt:HomeTheaterModeEvent):void
		{
			
		}
		
		protected function killtween(target:Object):void
		{
			if(_tween)
			{
				TweenLite.killTweensOf(target);
				_tween = null;
			}
		}
		
		/** 
		 * 隐藏，可以是visible为false，也可以是alpha为0
		 * 也可以被子类重写
		 * **/
		protected function hide():void
		{
			_tween && _tween.reverse();
		}
		
		/**
		 * 舞台的焦点是否在TextInputView 
		 * @return 
		 * 
		 */		
		protected function get stageFocusIsTextInputView():Boolean
		{
			return false;
		}
		
		/** 进入家庭影院模式缓动完成 **/
		protected function enterHTMTweenComplete():void
		{
			_isEnteringHTM = false;
		}
		
		/** 退出家庭影院模式缓动完成 **/
		protected function exitHTMTweenComplete():void 
		{
			_isExitingHTM = false;	
		}
		
		/**
		 * 普通屏幕下文字输入界面是否可用 
		 * 非全屏状态下且播放器配置可以弹幕功能，返回true, 否则返回false 
		 * @return 
		 * 
		 */		
		protected function get isTextInputViewAvailable():Boolean
		{
			return false; 
		}
		
		/**
		 * stage移除对MouseMove事件的监听处理 
		 * @param listener 处理MouseMove事件的监听器
		 * 
		 */		
		protected function removeStageMouseMoveListener(listener:Function):void
		{
			_stageRef.stage.removeEventListener(MouseEvent.MOUSE_MOVE, listener);
		}
		
		/**
		 * 禁用交互对象实例，并且设置实例状态为不可用
		 * MovieClip->Srite->InteractiveObject   SimpleButton->InteractiveObject 
		 * @param interactiveObject
		 * 
		 */		
		protected function disable(interactiveObject:InteractiveObject):void
		{
			interactiveObject.mouseEnabled = false;
			if(interactiveObject is Sprite)
			{
				(interactiveObject as Sprite).mouseChildren = false;
			}
			interactiveObject.alpha = 0.6;
		}
		
		/**
		 * 启用交互对象实例，并且设置实例状态为可用
		 * MovieClip->Srite->InteractiveObject   SimpleButton->InteractiveObject 
		 * @param interactiveObject
		 * 
		 */		
		protected function enable(interactiveObject:InteractiveObject):void
		{
			interactiveObject.mouseEnabled = true;
			if(interactiveObject is Sprite)
			{
				(interactiveObject as Sprite).mouseChildren = true;
			}
			interactiveObject.alpha = 1;
		}
		
		/**
		 * 当前是否为直播
		 * */
		protected function get isLive():Boolean
		{
			return _m.videoVO.isLive;
		}
		
		/**
		 * 舞台宽度是否为UI允许的最小宽度 (舞台最小宽度为450px)
		 * @return 
		 * 
		 */		
		protected function get isMinWidth():Boolean
		{
			return (_stageRef.stage.stageWidth <= 450);	
		}
	}
}