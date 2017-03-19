package view
{
	import model.Model;
	
	import org.osmf.events.MediaPlayerBufferChangeEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.media.MediaPlayerState;
	
	import view.base.BaseView;
	
	/**
	 * 缓冲界面类
	 * 通过 _ui.buffering 获取皮肤里对应的MovieClip
	 * @author yangq
	 * 
	 */	

	public class BufferingView extends BaseView
	{
		private var _realBufferingProgress:int = 0;
		
		public function BufferingView(m:Model)
		{
			super(m);
			
			_skin = _ui.buffering;
			//_skin.cacheAsBitmap = true;
			this.addChild(_skin);
			this.visible = false;
		}
		
		public function bufferingShow():void
		{
			this.visible = true;
		}		
		
		/**
		 * 隐藏loading 
		 * @param easingEffect 是否使用缓动效果的flag，默认是超时后直接隐藏
		 * 
		 */		
		public function bufferingHide(easingEffect:Boolean=false):void
		{
			this.visible && (this.visible = false);
		}
	
		override protected function hide():void
		{			
			this.visible = false;
			_realBufferingProgress = 0;
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
		}
		
		override protected function onMediaPlayerStateChange(evt:MediaPlayerStateChangeEvent):void
		{
			switch(evt.state)
			{
				//直播的时候解析M3U8文件可能会耗较多的时间，所以在此状态时就显示loading，但事实上流还未开始缓冲，所以此时隐藏缓冲进度提示
				//等收到MediaPlayerState.BUFFERING状态的时候，显示缓冲进度提示
				case MediaPlayerState.LOADING:  
					_m.autoPlay && bufferingShow(); //自动播放时才显示loading，非自动播放时隐藏				
					break;
				case MediaPlayerState.BUFFERING:
					if(!_m.isPlaybackComplete && _realBufferingProgress != 100)
					{
						bufferingShow();
					}
					break;
				case MediaPlayerState.PLAYING: //playing, playback_complete, playback_error这三种状态下都隐藏loading
				case MediaPlayerState.PLAYBACK_COMPLETE:
					bufferingHide();
					break;
				case MediaPlayerState.PLAYBACK_ERROR:
					bufferingHide(true);
					break;
				default:
					break;
			}
			
		}	
		
		override protected function onMediaBufferChange(evt:MediaPlayerBufferChangeEvent):void
		{
			_realBufferingProgress = evt.bufferRate;
		}		
		
		override protected function render():void
		{
			if(_skin.visible)
			{
				_skin.x = stageWidth >> 1;
				if(isTextInputViewAvailable)
				{
					_skin.y = (stageHeight - controlbarHeight - textInputViewHeight) >> 1;
				}
				else
				{
					_skin.y = (stageHeight- controlbarHeight) >> 1;
				}			
			}
		}
	}
}