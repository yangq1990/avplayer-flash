package view.bar
{
	import com.greensock.TweenLite;
	
	import consts.LayoutConst;
	
	import event.AVPlayerEvent;
	import event.HomeTheaterModeEvent;
	import event.bar.VolumeBarEvent;
	import event.js.JSEvent;
	import event.tips.BottomViewAreaEvent;
	
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import model.Model;
	import model.external.JSAPI;
	
	import view.base.BaseView;
	
	/**
	 * 音量条界面类 
	 * 通过 _ui.VolumeBar 获取皮肤里对应的MovieClip
	 * VolumeBar的布局，依赖RightBar
	 * @author yangq
	 * 
	 */	
	public class VolumeBarView extends BaseView
	{
		private var _volumeBtn:MovieClip;
		private var _trackBar:MovieClip;
		
		/** 是否在拖动中 **/
		private var _isDragging:Boolean = false;
		
		/** 是否第一次麦克风增益  **/
		private var _firstMicBoost:Boolean = true;
		
		public function VolumeBarView(m:Model)
		{
			super(m);
			
			_skin = _ui.VolumeBar;
			//_skin.cacheAsBitmap = true;
			this.addChild(_skin);
			
			_trackBar = _skin.trackBar;
			_trackBar.buttonMode = true;
			_trackBar.mouseChildren = false;
			_trackBar.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownTrackBar);
			_trackBar.addEventListener(MouseEvent.CLICK, onClickTrackBar);
			
			_volumeBtn = _skin.volumeBtn;
			_volumeBtn.buttonMode = true;
			_volumeBtn.addEventListener(MouseEvent.CLICK, onClickVolumeBtn);
			_volumeBtn.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverVolumeBtn);
			_volumeBtn.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutVolumeBtn);
			
			var volume:int = _m.volume;
			if(volume > 100) {
				volume = 100;
			}
			
			_trackBar.done.width = _trackBar.icon.x = convertVolume2Width(volume);
			
			this.visible = false;
		}
		
		//点击喇叭按钮
		private function onClickVolumeBtn(evt:MouseEvent):void {
			if(_volumeBtn.currentFrame == 1) { //非静音状态下，点击后静音
				muteHandler();
			} else {
				unmuteHandler();
			}
			onMouseOverVolumeBtn();
		}
		
		//mouseover 喇叭按钮
		private function onMouseOverVolumeBtn(evt:MouseEvent=null):void {
			var data:Object = {};
			if(_volumeBtn.currentFrame == 2) { //当前静音状态，提示取消静音
				data.btnName = _volumeBtn.name + "_unmute";
			} else { //当前有声音，提示静音
				data.btnName = _volumeBtn.name + "_mute";
			}
			
			var point:Point = _skin.localToGlobal(new Point(_volumeBtn.x, _volumeBtn.y));
			data.x = point.x + _volumeBtn.width*0.5;
			eventbus.dispatchEvent(new AVPlayerEvent(AVPlayerEvent.SHOW_TIPTEXT, data));
		}
		
		private function onMouseOutVolumeBtn(evt:MouseEvent):void {
			eventbus.dispatchEvent(new AVPlayerEvent(AVPlayerEvent.HIDE_TIPTEXT));
		}
		
		//静音
		private function muteHandler():void {
			_trackBar.icon.x = _trackBar.done.width = 0;
			_volumeBtn.gotoAndStop(2);
			dispatchEvent(new AVPlayerEvent(AVPlayerEvent.MUTE));
		}
		
		//取消静音
		private function unmuteHandler():void {
			var temp:Number = Math.min(Math.ceil(_m.volume * _trackBar.rail.width / 100),Math.ceil(100 * _trackBar.rail.width/100));
			_trackBar.icon.x = _trackBar.done.width = temp;
			_volumeBtn.gotoAndStop(1);
			dispatchEvent(new AVPlayerEvent(AVPlayerEvent.UNMUTE));
		}
		
		private function onFlashMute(evt:JSEvent):void {
			if(!_m.muted) {
				muteHandler();
			}
		}
		
		/** 恢复静音之前状态  **/
		private function onFlashUnmute(evt:JSEvent):void {
			if(_m.muted) {
				if(_m.volume == 0) { //如果之前音量为0，则跳出函数，否则会出现音量为0但是_volumeMC显示声音帧的bug
					return;
				}
				unmuteHandler();
			}
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
			//收到js的调用请求
			JSAPI.getInstance().addEventListener(JSEvent.MUTE,  onFlashMute);
			JSAPI.getInstance().addEventListener(JSEvent.UNMUTE, onFlashUnmute);
			
			_stageRef.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			eventbus.addEventListener(VolumeBarEvent.LAYOUT, onLayout);
		}
		
		protected function onKeyDown(evt:KeyboardEvent):void
		{
			if(!stageFocusIsTextInputView)
			{
				switch(evt.keyCode)
				{
					case Keyboard.UP:
						increase();
						//showVolumeBar(true);
						//eventbus.dispatchEvent(new VolumeBarEvent(VolumeBarEvent.INCREASE));
						break;			
					case Keyboard.DOWN:
						decrease();
						//showVolumeBar(true);
						//eventbus.dispatchEvent(new VolumeBarEvent(VolumeBarEvent.DECREASE));
						break;
					default:
						break;
				}
			}			
		}
		
		/** 按键盘上箭头增加音量 **/
		private function onIncrease(evt:VolumeBarEvent):void
		{
			increase();
		}
		
		private function increase():void
		{
			var currentVolume:int = _m.volume;
			if(currentVolume == 0)
			{
				_volumeBtn.gotoAndStop(1); //取消静音
				dispatchEvent(new AVPlayerEvent(AVPlayerEvent.UNMUTE));
			}
			
			if(currentVolume < 100)
			{
				!_firstMicBoost && (_firstMicBoost = true);
				currentVolume += 5;
				(currentVolume > 100) && (currentVolume = 100);		
				var temp:Number = convertVolume2Width(currentVolume);
				_trackBar.icon.x = _trackBar.done.width = temp;		
			}
			else if(currentVolume >= 100 && currentVolume < 200)
			{
				if(currentVolume == 100 && _firstMicBoost) 		//第一次放大提示
				{
					_firstMicBoost = false;
					eventbus.dispatchEvent(new BottomViewAreaEvent(BottomViewAreaEvent.SHOW_TIPS, "点击键盘↑可以继续放大音量"));
				}
				else
				{
					currentVolume += 10;			
				}					
			}
			else if(currentVolume >= 200 && currentVolume <= 275) //最大音量不能放大超过300%
			{
				currentVolume += 25;
			}
			
			var saveFlag:Boolean = (currentVolume > 100 ? false : true);
			dispatchEvent(new AVPlayerEvent(AVPlayerEvent.ADJUST_VOLUME, {'volume':currentVolume/100}));	
		}
		
		/** 按键盘下箭头减小音量 **/
		private function onDecrease(evt:VolumeBarEvent):void
		{			
			decrease();
		}
		
		private function decrease():void
		{
			var currentVolume:int = _m.volume;			
			if(currentVolume < 100)
			{
				currentVolume -= 5;
				if(currentVolume <= 0)
				{
					
					currentVolume = 0;
					_volumeBtn.gotoAndStop(2);
					dispatchEvent(new AVPlayerEvent(AVPlayerEvent.MUTE));
				}
				
				var temp:Number = convertVolume2Width(currentVolume);
				_trackBar.icon.x = _trackBar.done.width = temp;
			}
			else if(currentVolume >= 100 && currentVolume < 200)
			{
				currentVolume -= 10;				
			}  
			else if(currentVolume >= 200 && currentVolume <= 300)
			{
				currentVolume -= 25;
			}
			
			
			var saveFlag:Boolean = (currentVolume > 100 ? false : true);
			dispatchEvent(new AVPlayerEvent(AVPlayerEvent.ADJUST_VOLUME, {'volume':currentVolume/100}));	
		}
		
		private function onMouseDownTrackBar(evt:MouseEvent):void
		{
			_trackBar.done.width = Math.abs(evt.localX);
			
			_stageRef.stage.addEventListener(MouseEvent.MOUSE_MOVE, onDragMoving);
			_stageRef.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_trackBar.icon.startDrag(true, new Rectangle(0, 0, _trackBar.rail.width, 0));
		}
		
		private function onClickTrackBar(evt:MouseEvent):void
		{
			setVolumeTxtAndTrackBar(evt.localX);
		}
	
		private function onMouseWheel(evt:MouseEvent):void
		{
			(evt.delta > 0) ? increase() : decrease();
		}
		
		/** 拖动音量条实时反馈 **/
		private function onDragMoving(evt:MouseEvent):void
		{			
			_isDragging = true;	
			setVolumeTxtAndTrackBar(_trackBar.icon.x, false);			
		}
		
		private function onMouseUp(evt:MouseEvent):void 
		{
			_trackBar.icon.stopDrag();
			_isDragging = false;
			_stageRef.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			removeStageMouseMoveListener(onDragMoving);
			
			var volume:int = Math.ceil(Math.abs(_trackBar.icon.x) / _trackBar.rail.width * 100);		
			dispatchEvent(new AVPlayerEvent(AVPlayerEvent.ADJUST_VOLUME, {'volume':volume/100}));	
		}
		
		/**
		 * 设置音量文字和trackbar icon及done的位置 
		 * 派发调整音量事件
		 * @param localX 
		 * @param save2cookie 是否立即写入本地存储
		 */		
		private function setVolumeTxtAndTrackBar(localX:Number, save2cookie:Boolean=true):void
		{
			_trackBar.icon.x = localX;
			_trackBar.done.width = Math.abs(localX);
			
			var volume:int = Math.ceil(Math.abs(localX) / _trackBar.rail.width * 100);
			dispatchEvent(new AVPlayerEvent(AVPlayerEvent.ADJUST_VOLUME, {'volume':volume/100}));	
			
			if(volume == 0) {
				if(_volumeBtn.currentFrame == 1) {
					_volumeBtn.gotoAndStop(2);
				}
			} else {
				if(_volumeBtn.currentFrame == 2) {
					_volumeBtn.gotoAndStop(1);
				}
			}
		}
		
		/**
		 * 把音量值转换为布局需要的高度 
		 * @param volume
		 * @return 
		 * 
		 */		
		private function convertVolume2Height(volume:Number):Number
		{
			return volume * _trackBar.rail.height / 100;
		}
		
		/**
		 * 把音量值转换为布局需要的宽度
		 * @param volume
		 * @return 
		 * 
		 */		
		private function convertVolume2Width(volume:Number):Number {
			return volume * _trackBar.rail.width / 100;
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
		
		private function onLayout(evt:VolumeBarEvent):void {
			if(_m.simplifiedUI)
				return;
			
			!this.visible && (this.visible = true);
			TweenLite.killTweensOf(_skin);
			if(!isTextInputViewAvailable)
			{
				_skin.y = stageHeight - controlbarHeight + (controlbarHeight - _skin.height) * 0.5;	
			}
			else 
			{
				//killtween(_skin);
				_skin.y = stageHeight - controlbarHeight - textInputViewHeight + (controlbarHeight - _skin.height) * 0.5;
			}
			
			if(!isMinWidth) {
				_skin.x = stageWidth - evt.data - LayoutConst.MARGIN_TO_PLAYER_BORDER*2 - _skin.width;
			} else {
				_skin.x = stageWidth - evt.data - LayoutConst.MARGIN_IN_MIN_WIDTH*2 - _skin.width;
			}
			
			_skin.alpha = 1;
		}
	}
}