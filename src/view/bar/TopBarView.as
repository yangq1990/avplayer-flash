package view.bar
{
	import com.greensock.TweenLite;
	
	import consts.FontConst;
	import consts.LayoutConst;
	
	import event.HomeTheaterModeEvent;
	import event.VideoViewEvent;
	
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import flashx.textLayout.formats.TextAlign;
	
	import model.Model;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	
	import view.base.BaseView;
	
	/**
	 * 顶部提示条 
	 * @author yangq
	 * 
	 */	
	public class TopBarView extends BaseView
	{
		private var _percent_mc:MovieClip;
		
		private var _selectedMCName:String;
		
		private var _interval:uint; //显示本地时间的定时器
		
		public function TopBarView(m:Model)
		{
			super(m);
			
			if(_ui.TopBar != null)
			{
				_skin = _ui.TopBar;
				addChild(_skin);
				_skin.visible = false;
				
				_percent_mc = _skin.percent_mc;
				_percent_mc.buttonMode = true;
				_percent_mc.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				_percent_mc.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				_percent_mc.addEventListener(MouseEvent.CLICK, onClick);
				
				//默认选中100%
				_selectedMCName = _percent_mc.percent_100_mc.name;
				_percent_mc.percent_100_mc.gotoAndStop(2);
			}		
		}
		
		override protected function render():void
		{
			if(_m.isPlaybackError) //播放出错的情况下return
				return;
			
			if(_skin != null)
			{
				if(displayState != StageDisplayState.NORMAL) //全屏下显示
				{
					!_skin.visible && (_skin.visible = true);
					_skin.x = 0;
					
					_skin.bg.width = stageWidth;
					_percent_mc.x  = LayoutConst.MARGIN_TO_PLAYER_BORDER;
					showLocalTime();
					_skin.TimeTxt.x = stageWidth - _skin.TimeTxt.width - LayoutConst.MARGIN_TO_PLAYER_BORDER;			
					
					if(_m.videoVO.title)
					{
						_skin.TitleTxt.text = _m.videoVO.title;
						_skin.TitleTxt.width = _skin.TitleTxt.textWidth + 10;
						_skin.TitleTxt.x = (stageWidth - _skin.TitleTxt.width) * 0.5;
						_skin.TitleTxt.setTextFormat(getTextFormat());
					}
					
					if(_interval)
					{
						clearInterval(_interval);
						_interval = undefined;						
					}
					_interval = setInterval(showLocalTime, 1000);
					
					_selectedMCName && dispatchEventWithPercentByName(_selectedMCName);
				}
				else
				{
					_skin.visible && (_skin.visible = false);
					if(_interval)
					{
						clearInterval(_interval);
						_interval = undefined;
					}
				}
			}			
		}
		
		override protected function onMediaPlayerStateChange(evt:MediaPlayerStateChangeEvent):void
		{
			_m.isPlaybackError && _skin && (_skin.visible = false);
		}
		
		override protected function onEnterHomeTheaterMode(evt:HomeTheaterModeEvent):void
		{
			if(_skin == null)
				return;
			
			killtween(_skin);
			_tween = TweenLite.to(_skin, 0.4, {y:-_skin.height, onComplete:enterHTMTweenComplete});
		}
		
		override protected function enterHTMTweenComplete():void
		{
			
		}
		
		override protected function onExitHomeTheaterMode(evt:HomeTheaterModeEvent):void
		{
			if(_skin == null || _isExitingHTM || _skin.y == 0) //缓动中或者已经位于正确的位置上
				return;
			
			_isExitingHTM = true;
			_skin.alpha = 1;
			_skin.y = 0;	
			TweenLite.from(_skin, 0.3, {y:-_skin.height, alpha:0, onComplete: exitHTMTweenComplete});
		}
		
		override protected function exitHTMTweenComplete():void
		{
			super.exitHTMTweenComplete();
		}
		
		private function showLocalTime():void
		{
			var date:Date = new Date();
			var hours:String = (date.hours < 10 ? ("0"+date.hours) : date.hours.toString());
			var minutes:String = (date.minutes < 10 ? ("0"+date.minutes) : date.minutes.toString());
			_skin.TimeTxt.text = hours + ":" + minutes;
			_skin.TimeTxt.setTextFormat(getTextFormat());
		}
		
		private function onMouseOver(evt:MouseEvent):void
		{
			evt.target.gotoAndStop(2);
		}
		
		private function onMouseOut(evt:MouseEvent):void
		{
			if(_selectedMCName != evt.target.name)
			{
				evt.target.gotoAndStop(1);
			}
		}
		
		private function onClick(evt:MouseEvent):void
		{
			if(_selectedMCName != evt.target.name)
			{
				_selectedMCName = evt.target.name;
				evt.target.gotoAndStop(2);
				var num:int = _percent_mc.numChildren;
				var mc:MovieClip;
				for(var i:int = 0; i < num; i++)
				{
					mc = _percent_mc.getChildAt(i) as MovieClip;
					if(_selectedMCName != mc.name)
					{
						mc.gotoAndStop(1);
					}
				}		
				
				dispatchEventWithPercentByName(_selectedMCName);
			}			
		}
		
		
		/**
		 * 根据选中mc的name派发 VideoViewEvent.ADJUST_PERCENT事件
		 * @param name percent_*_mc 的name
		 * 
		 */		
		private function dispatchEventWithPercentByName(name:String):void
		{
			var percent:Number;			
			switch(_selectedMCName)
			{
				case "percent_50_mc":
					percent = 0.5;
					break;
				case "percent_75_mc":
					percent = 0.75;
					break;
				case "percent_100_mc":
					percent = 1;
					break;
			}
			
			//派发事件
			eventbus.dispatchEvent(new VideoViewEvent(VideoViewEvent.ADJUST_PERCENT, percent));
		}
		
		private function getTextFormat():TextFormat {
			var format:TextFormat = new TextFormat();
			format.size = 16;
			format.font = FontConst.YAHEI;
			format.align = TextAlign.CENTER;
			return format;
		}
	}
}