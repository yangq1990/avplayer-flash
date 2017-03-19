package view.base
{
	import model.Model;
	
	import org.osmf.events.TimeEvent;
	
	import utils.NumToTime;
	
	/**
	 * 需要对time change事件做出响应的界面类的基类
	 * @author yangq
	 * 
	 */	
	public class BaseTimeChangeView extends BaseView
	{	
		protected var _numToTime:NumToTime;
		
		public function BaseTimeChangeView(m:Model)
		{
			super(m);		
			_numToTime = new NumToTime();
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
			_m.addEventListener(TimeEvent.CURRENT_TIME_CHANGE,onTimeChange);
		}
		
		protected function onTimeChange(evt:TimeEvent):void
		{
			setTime(_m.mediaPlayer.currentTime,_m.mediaPlayer.duration);
		}		
		
		/**
		 * 由子类override 
		 * @param current
		 * @param total
		 * 
		 */		
		protected function setTime(current:Number,total:Number):void
		{
		
		}
		
		/**
		 * 当前播放视频时长 , 当访问不到视频时，默认返回1
		 * @return 
		 * 
		 */		
		protected function get duration():Number
		{
			if(_m.mediaPlayer == null || _m.isPlaybackError)
				return 1;
			return _m.mediaPlayer.duration;
		}
	}
}