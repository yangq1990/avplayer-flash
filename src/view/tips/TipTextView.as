package view.tips
{
	import com.greensock.TweenLite;
	
	import event.AVPlayerEvent;
	
	import model.Model;
	
	import view.base.BaseView;
	
	/**
	 * 展示提示文字的界面 
	 * @author yangq
	 * 
	 */	
	public class TipTextView extends BaseView
	{
		private var _tiptext:TipText;
		private var _tweenlite:TweenLite;
		private var _lastX:Number;
		
		public function TipTextView(m:Model)
		{
			super(m);
		}
		
		override protected function addListeners():void {
			eventbus.addEventListener(AVPlayerEvent.SHOW_TIPTEXT, onShowTipText);
			eventbus.addEventListener(AVPlayerEvent.HIDE_TIPTEXT, onHideTipText);
		}
		
		private function onShowTipText(evt:AVPlayerEvent):void {
			if(!evt.data) {
				return;
			}
			
			var label:String="";
			switch(evt.data.btnName) {
				case "playBtn":
					label = "播放";
					break;
				case "pauseBtn":
					label = "暂停";
					break;
				case "replayBtn":
					label = "重播";
					break;
				case "nextEpisodeBtn":
					label = "下一集";
					break;
				case "fullScnBtn":
					label = "全屏";
					break;
				case "smallScnBtn":
					label = "退出全屏";
					break;
				case "webpageFullScnBtn":
					label = "网页全屏";
					break;
				case "exitWebpageFullScnBtn":
					label = "退出网页全屏";
					break;
				case "volumeBtn_mute":
					label = "静音";
					break;
				case "volumeBtn_unmute":
					label = "取消静音";
					break;
				case "enableDanmuBtn":
					label = "开启";
					break;
				case "disableDanmuBtn":
					label = "关闭";
					break;
				default:
					break;
			}
			
			if(_tiptext == null) {
				_tiptext = new TipText(label, 58, 35, 5);
			} else {
				_tiptext.setTxt(label);
				_tiptext.visible = true;
			}
			_tiptext.cacheAsBitmap = true;
			_tiptext.x = evt.data.x;
			_tiptext.y = stageHeight - controlbarHeight - _tiptext.height*0.5;
			stage.addChild(_tiptext);
			
			_tweenlite = TweenLite.from(_tiptext, 0.1, {alpha:0.1});
			//,y:stageHeight - controlbarHeight - 8
		}
		
		private function onHideTipText(evt:AVPlayerEvent):void {
			if(_tiptext && _tiptext.visible) {
				_tiptext.visible = false;
			}
			
			if(_tweenlite) {
				TweenLite.killTweensOf(_tiptext);
				_tiptext.alpha = 1;
				_tweenlite = null;
			}
		}
	}
}