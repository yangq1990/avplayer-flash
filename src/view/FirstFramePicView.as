package view
{
	import com.greensock.TweenLite;
	
	import event.ModelEvent;
	
	import flash.display.DisplayObject;
	import flash.display.StageDisplayState;
	import flash.ui.Mouse;
	
	import model.Model;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.utils.AVLog;
	
	import utils.Stretcher;
	
	import utils.MultifunctionalLoader;
	
	import view.base.BaseView;
	
	/**
	 * 显示第一帧图片或者视频封面图片的界面 
	 * @author yangq
	 * 
	 */	
	public class FirstFramePicView extends BaseView
	{
		private var _dpInfo:Object;
		private var _preventLateImg:Boolean = false;
		
		public function FirstFramePicView(m:Model)
		{
			super(m);			
			this.visible = false;
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
			_m.addEventListener(ModelEvent.SHOW_FIRSTFRAMEPIC, onShowFirstFramePic);
			_m.addEventListener(ModelEvent.SHOW_POSTER, onShowPoster);
		}
		
		private function onShowFirstFramePic(evt:ModelEvent):void
		{
			var loader:MultifunctionalLoader = new MultifunctionalLoader();
			loader.registerFunctions(onLoadComplete, onLoadError);
			//根据舞台宽高加载缩略图
			loader.load(_m.videoVO.firstFramePicURL+"?ips_thumbnail/0/w/"+stageWidth+"/h/"+stageHeight);
		}
		
		//显示封面
		private function onShowPoster(evt:ModelEvent):void 
		{
			var loader:MultifunctionalLoader = new MultifunctionalLoader();
			loader.registerFunctions(onLoadComplete, onLoadError);
			loader.load(_m.videoVO.poster);
		}
		
		private function onLoadComplete(dp:DisplayObject):void
		{
			_m.removeEventListener(ModelEvent.SHOW_FIRSTFRAMEPIC, onShowFirstFramePic);
			_m.removeEventListener(ModelEvent.SHOW_POSTER, onShowPoster);
			
			if(_preventLateImg) { //阻止迟到图片的显示并释放资源
				dp = null;
				return;
			}
			
			if(!_m.isPlaybackError) { //如果已经playbackError，就不再显示poster
				_dpInfo = {};
				_dpInfo.w = dp.width;
				_dpInfo.h = dp.height;
				this.addChild(dp);
				this.visible = true;
				render();
			}
		}
		
		private function onLoadError(errMsg:String):void
		{
			CONFIG::RELEASE {
				AVLog.error("FirstFramePicView-->" + errMsg, true);
			}
		}
		
		override protected function render():void
		{
			if(this.visible)
			{
				Mouse.show();
				var child:DisplayObject = this.getChildAt(0);
				if(child)
				{
					if(displayState == StageDisplayState.NORMAL)
					{
						(new Stretcher()).stretch(child, stageWidth, stageHeight-controlbarHeight, _dpInfo);
						child.x = (stageWidth - child.width) >> 1;
						child.y = (stageHeight - controlbarHeight - child.height) >> 1;
					}
					else
					{
						(new Stretcher()).stretch(child, stageWidth, stageHeight, _dpInfo);
						child.x = (stageWidth - child.width) >> 1;
						child.y = (stageHeight - child.height) >> 1;
						TweenLite.from(child, 0.3, {alpha:0.3});
					}	
				}				
			}
		}
		
		override protected function onMediaPlayerStateChange(evt:MediaPlayerStateChangeEvent):void
		{
			//视频开始缓冲，或者视频正在播放 或者视频无法播放，移除已下载的图片
			if(evt.state == MediaPlayerState.BUFFERING || evt.state == MediaPlayerState.PLAYING || evt.state == MediaPlayerState.PLAYBACK_ERROR) 
			{
				if(this.visible && (this.numChildren > 0))
				{
					this.visible = false;
					var child:DisplayObject = this.removeChildAt(0);
					child = null;
					_dpInfo = null;
				}
				
				//点击播放按钮，视频开始缓冲播放，如果此时封面图片仍在加载中，并在随后加载完成，也不应该显示图片
				_preventLateImg = true;
			}
		}
	}
}