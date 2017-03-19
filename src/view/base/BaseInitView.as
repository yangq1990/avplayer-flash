package view.base
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.system.Capabilities;
	import flash.system.IME;
	import flash.system.Security;
	import flash.utils.getTimer;
	
	import org.osmf.utils.AVLog;
	import org.osmf.utils.BasicInfo;
	import org.osmf.utils.GlobalReference;
	
	/**
	 * 初始化基类 
	 * @author yangq
	 * 
	 */	
	public class BaseInitView extends Sprite
	{
		public function BaseInitView()
		{
			super();
			
			stage ? init() : this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(evt:Event):void			
		{
			CONFIG::RELEASE {
				AVLog.info("播放器启动！！！", true);	
			}		
			GlobalReference.getInstance().bootTimestamp = getTimer();
			
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			init();
		}
		
	    protected function init():void
		{
			Security.allowDomain("*");
			Security.allowInsecureDomain("*"); //允许所标识的域中的 SWF 文件和 HTML 文件访问执行调用的 SWF 文件（使用 HTTPS 协议承载）中的对象和变量。
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.HIGH_8X8_LINEAR; //fp 11.3
			if(new BasicInfo().browser != 1 && Capabilities.hasIME) { //非IE下防止输入法对键盘事件的影响
				IME.enabled = false;
				CONFIG::RELEASE {
					AVLog.info('非IE浏览器，禁用IME', true);
				}
			}
		}
	}
}