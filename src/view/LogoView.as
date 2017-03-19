package view
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import model.Model;
	
	import org.osmf.utils.AVLog;
	
	import utils.MultifunctionalLoader;
	
	import view.base.BaseView;
	
	/**
	 * LogoView 
	 * @author yangq
	 * 
	 */	
	public class LogoView extends BaseView
	{
		private var _logo:Sprite;
		
		private const MARGIN:int = 20;
		
		public function LogoView(m:Model)
		{
			super(m);
			
			if(m.logoVO.state == 0 || !m.logoVO.url)
			{
				this.visible = false;
			}
			else
			{				
				var loader:MultifunctionalLoader = new MultifunctionalLoader();
				loader.registerFunctions(onComplete, onError);
				loader.load(m.logoVO.url);
			}			
		}
		
		private function onComplete(dp:DisplayObject):void
		{
			_logo = new Sprite();
			_logo.addChild(dp);
			this.addChild(_logo);
			this.mouseChildren = false;
			this.mouseEnabled = true;
			this.addEventListener(MouseEvent.CLICK, onClick);
			render();
		}
		
		override protected function render():void
		{
			if(this.visible && _logo != null)
			{
				switch(_m.logoVO.pos)
				{
					case 0:
						_logo.x = MARGIN;
						_logo.y = MARGIN;
						break;
					case 1:
						if(displayState == StageDisplayState.NORMAL)
						{
							_logo.x = stageWidth - _logo.width - MARGIN;
							_logo.y = MARGIN;
						}
						else
						{
							_logo.x = stageWidth - _logo.width - MARGIN * 2;
							_logo.y = MARGIN * 2;
						}
						break;
					default:
						break;
				}
			}			
		}
		
		private function onClick(evt:MouseEvent):void
		{
			_m.logoVO.link && navigateToURL(new URLRequest(_m.logoVO.link));
		}
		
		private function onError(msg:String):void
		{
			AVLog.error("LogoView" + msg);
		}
	}
}