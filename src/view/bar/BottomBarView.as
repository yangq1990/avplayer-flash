package view.bar
{
	import com.greensock.TweenLite;
	
	import event.HomeTheaterModeEvent;
	import event.bar.TimeTrackBarEvent;
	
	import flash.events.MouseEvent;
	
	import model.Model;
	
	import view.base.BaseView;
	
	/**
	 * 底部背景条 
	 * @author yangq
	 * 
	 */	
	public class BottomBarView extends BaseView
	{
		public function BottomBarView(m:Model)
		{
			super(m);
			
			if(!_m.simplifiedUI) {
				_skin = _ui.BottomBar;
				_skin.cacheAsBitmap = true;
				addChild(_skin);
			
				_skin.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			
				this.visible = false;
			}
		}
		
		private function onMouseOver(evt:MouseEvent):void
		{
			eventbus.dispatchEvent(new TimeTrackBarEvent(TimeTrackBarEvent.MOUSE_IN_HOTZONE));
		}
		
		override protected function addListeners():void {
			if(!_m.simplifiedUI) {
				super.addListeners();
			}
		}
		
		override protected function render():void
		{
			if(_m.simplifiedUI)
				return;
			
			!this.visible && (this.visible = true);
			
			TweenLite.killTweensOf(_skin);
			if(!isTextInputViewAvailable) 
			{
				_skin.y = stageHeight - _skin.height;
			}
			else
			{
				//killtween(_skin);
				_skin.y = stageHeight - textInputViewHeight - _skin.height;
			}
			
			_skin.bg.width = stageWidth;
			_skin.x = 0;
			_skin.alpha = 1;
		
			if(!isMinWidth) {
				_skin.line1.visible = true;
				_skin.line1.x = 71;
			} else {
				_skin.line1.visible = _skin.line2.visible = false;
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