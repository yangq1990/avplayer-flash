package view
{
	import consts.ErrorCode;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import model.Model;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	
	import view.base.BaseView;
	
	/**
	 * 直播结束提示界面 带电视雪花效果
	 * @author yangq
	 * 
	 */	
	public class LiveEndedView extends BaseView
	{
		private var _noiseBMD:BitmapData; //噪点图像
		private var _noiseBitmap:Bitmap;
		private var _interval:uint;
		
		public function LiveEndedView(m:Model)
		{
			super(m);
			
			if(_ui.LiveEnded != null) {
				_skin = _ui.LiveEnded;
				_skin.cacheAsBitmap = true;
				addChild(_skin);
			}
			
			this.visible = false;
		}
		
		override protected function onMediaPlayerStateChange(evt:MediaPlayerStateChangeEvent):void
		{
			if(_m.isPlaybackError) {
				if(_m.errorVO.code == ErrorCode.HEX_07) {
					show();
				}
			} else if(_m.isPlaybackComplete) {  //直播有时会触发playbackComplete事件而没有playbackError事件
				if(isLive) {
					show();
				}
			}
		}	
		
		private function show():void {
			this.visible = true;
			render();
		}
		
		override protected function render():void {
			if(this.visible) {
				if(_noiseBMD != null) {
					_noiseBMD.dispose();
				}
				_noiseBMD = new BitmapData(stageWidth, stageHeight - controlbarHeight);
				_noiseBitmap = new Bitmap(_noiseBMD);
				_noiseBitmap.alpha = 0.2;
				_interval && clearInterval(_interval);
				addChildAt(_noiseBitmap, 0);
				_interval = setInterval(makeNoise, 50);
				
				_skin.x = (stageWidth - _skin.width) * 0.5;
				_skin.y = (stageHeight - controlbarHeight- _skin.height) * 0.5;
			}
		}
		
		private function makeNoise():void {
			_noiseBMD.noise(int(Math.random() * int.MAX_VALUE), 0, 0xff, 7, true);
		}
	}
}