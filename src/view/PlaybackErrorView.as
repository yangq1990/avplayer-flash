package view
{
	import consts.ErrorCode;
	
	import event.AVPlayerEvent;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import model.Model;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	
	import view.base.BaseView;
	
	/**
	 * 视频播放出错时的提示界面 
	 * @author yangq
	 * 
	 */	
	public class PlaybackErrorView extends BaseView
	{
		private var _retryBtn:MovieClip;

		public function PlaybackErrorView(m:Model)
		{
			super(m);
			
			if(_ui.PlaybackError != null) 
			{
				_skin = _ui.PlaybackError;
				_skin.cacheAsBitmap = true;
				addChild(_skin);
				_retryBtn = _skin.retryBtn;
				_retryBtn.buttonMode = true;
				_retryBtn.mouseChildren = false;
				_retryBtn.addEventListener(MouseEvent.CLICK, onClickRetryBtn);
			}
			
			this.visible = false;
		}
		
		private function onClickRetryBtn(evt:MouseEvent):void {
			dispatchEvent(new AVPlayerEvent(AVPlayerEvent.REFRESH));
		}
		
		override protected function onMediaPlayerStateChange(evt:MediaPlayerStateChangeEvent):void
		{
			if(_m.isPlaybackError) 
			{
				if(_m.errorVO.code != ErrorCode.HEX_07 && !_m.videoVO.isLive) 
				{ //非直播
					this.visible = true;
					render();
				}
			}
		}
		
		override protected function render():void
		{
			if(this.visible) 
			{
				if(stageWidth <= 600 || stageHeight <= 450) 
				{
					if(isMinWidth) 
					{ //最小宽度
						_skin.scaleX = _skin.scaleY = 0.6;
					} else 
					{
						_skin.scaleX = _skin.scaleY = 0.7;	
					}
				}
				else
				{
					_skin.scaleX = _skin.scaleY = 1;
				}
				
				_skin.x = (stageWidth - _skin.width) * 0.5;
				
				if(!_m.controlbarHoveringOn) 
				{
					_skin.y = (stageHeight - _skin.height - controlbarHeight) * 0.5;
				}
				else //controlbar悬浮时
				{ 
					_skin.y = (stageHeight - _skin.height) * 0.5;
				}
			}
		}
	}
}