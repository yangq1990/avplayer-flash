package view
{
	import consts.LayoutConst;
	
	import event.ModelEvent;
	
	import flash.display.StageDisplayState;
	
	import model.Model;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.media.MediaPlayerState;
	
	import view.base.BaseView;
	
	/**
	 * 直播提示界面 
	 * @author yangq
	 * 
	 */	
	public class LiveTipsView extends BaseView
	{
		public function LiveTipsView(m:Model)
		{
			super(m);
			
			if(_ui.LiveTips)
			{
				_skin = _ui.LiveTips;
				_skin.cacheAsBitmap = true;
				addChild(_skin);
				_skin.visible = false;
			}		
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
			
			_m.addEventListener(ModelEvent.LIVE_M3U8, onLiveM3U8);
		}
		
		private function onLiveM3U8(evt:ModelEvent):void
		{
			if(_skin) {
				_skin.visible = true;
				render();
			}
		
		}
		
		override protected function render():void
		{
			if(_skin != null && _skin.visible)
			{
				_skin.x = stageWidth - _skin.width - 10;
				if(displayState == StageDisplayState.NORMAL) {
					_skin.y = LayoutConst.MARGIN_TO_PLAYER_BORDER;
				} else {
					_skin.y = LayoutConst.MARGIN_TO_PLAYER_BORDER + _ui.TopBar.height;
				}
			}
		}
		
		override protected function onMediaPlayerStateChange(evt:MediaPlayerStateChangeEvent):void
		{
			switch(evt.state)
			{
				case MediaPlayerState.PLAYBACK_ERROR:
					if(_skin != null && _skin.visible)
					{
						_skin.visible = false;
					}
					break;
				default:
					break;
			}
		}
	}
}