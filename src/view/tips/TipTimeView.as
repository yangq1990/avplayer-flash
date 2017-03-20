package view.tips
{
	import event.tips.TipTimeViewEvent;
	
	import model.Model;
	
	import view.base.BaseView;
	
	/**
	 * 提示时间界面 
	 * @author yangq
	 * 
	 */	
	public class TipTimeView extends BaseView
	{
		public function TipTimeView(m:Model)
		{
			super(m);
			
			if(!_m.simplifiedUI) {
				_skin = _ui.TipTime;
			} else {
				_skin = _ui.TipTime_simplified;
			}
			
			_skin.mouseChildren = _skin.mouseEnabled = false;
			
			_skin.tempLine.visible = false;
			
			this.addChild(_skin);
			this.visible = false;			
		}
		
		override protected function addListeners():void
		{
			super.addListeners()
			
			eventbus.addEventListener(TipTimeViewEvent.SHOW, onShow);
			eventbus.addEventListener(TipTimeViewEvent.HIDE, onHide);
		}
		
		private function onShow(evt:TipTimeViewEvent):void
		{
			var temp:Number = _skin.width * 0.5;
			if(evt.data.x > stageWidth - temp)
			{
				_skin.tempLine.visible = true;
				_skin.x = stageWidth - temp;
				_skin.triangle.x = evt.data.x - _skin.x;
				if(_skin.triangle.x >= temp - _skin.triangle.width * 0.5) //移动小箭头
				{
					_skin.triangle.x = temp - _skin.triangle.width * 0.5;
				}
			}
			else if(evt.data.x < temp)
			{
				_skin.tempLine.visible = true;
				_skin.x = temp;
				_skin.triangle.x = evt.data.x - temp;
				if(_skin.triangle.x <= -(temp - _skin.triangle.width * 0.5))
				{
					_skin.triangle.x = -(temp - _skin.triangle.width * 0.5);
				}
			}
			else
			{
				_skin.tempLine.visible = false;
				_skin.x = evt.data.x;
				_skin.triangle.x = 0;
			}			
			_skin.y = evt.data.y - _skin.height * 0.5 - 2 ;
			_skin.time.text = evt.data.text;
			this.visible = true;
		}
		
		private function onHide(evt:TipTimeViewEvent):void
		{
			this.visible = false;
		}
	}
}