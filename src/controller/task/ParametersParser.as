package controller.task
{
	import consts.VideoFormatConst;
	
	import event.TaskEvent;
	
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	import model.Model;
	
	import org.osmf.utils.AVLog;
	import org.osmf.utils.GlobalReference;
	import org.osmf.utils.OSMFSettings;
	
	import utils.StageReference;
	import utils.URLUtil;
	
	/**
	 * 处理页面参数
	 * @author yangq
	 * 
	 */	
	public class ParametersParser extends EventDispatcher
	{
		private var _m:Model;		
		private var _globalRef:GlobalReference = GlobalReference.getInstance();
		
		public function ParametersParser(m:Model)
		{
			_m = m;
		}
		
		public function parse():void
		{
			var parameters:Object = StageReference.getInstance().root.loaderInfo.parameters;
//			parameters["url"] = "http://yycloudvod1376526695.bs2dl.yy.com/djVmMGRhYjRlZDI4MjkzYjZmYmE5MTAwODk3MzI4ZDU0MTM5NzUxNTk3MGhi.m3u8";
			parameters["skinUrl"] = "./skin.swf";
			parameters["debug"] = "1";
//			parameters["autoPlay"] = "1";
//			parameters["autoRewind"] = "1";
			
			if(parameters["debug"] == "true" || parameters["debug"] == "1")
			{
				_m.debug = true;
			}
			
			if(parameters["skinUrl"])
			{
				_m.skinUrl = parameters["skinUrl"];
			}
			
			if(parameters["title"]) //视频标题
			{
				_m.videoVO.title = parameters["title"];
			}
			
			if(parameters["autoPlay"] == "true" || parameters["autoPlay"] == "1") 
			{
				_m.autoPlay = true;
			}
			
			if(parameters["autoRewind"] == "true" || parameters["autoRewind"] == "1") 
			{
				_m.autoRewind = true;
			}
			
			if(parameters["disableHWAccel"] == "true" || parameters["disableHWAccel"] == "1") //禁止硬件加速
			{
				OSMFSettings.enableStageVideo = false; 
			}
			
			if(parameters["poster"] != "") { //封面地址
				_m.videoVO.poster = parameters["poster"];
			}
			
			if( parameters["url"] )
			{
				var url:String = parameters["url"];
				
				_m.currentVideoURL = url;
				
				if(url.indexOf("m3u8")!=-1) 
				{
					_m.videoFormat = VideoFormatConst.M3U8;
				}
				else //others
				{
					
				}
				
				CONFIG::RELEASE {		
					AVLog.info("从播放器启动到参数解析结束耗时:" + (getTimer() - _globalRef.bootTimestamp) + "ms", true); 
				}
			}
			
			dispatchEvent(new TaskEvent(TaskEvent.PARSE_COMPLETE));
			
			new URLUtil().getHref(onGetHref); //获取播放器所在页面url
		}
		
		private function onGetHref(success:Boolean, href:String):void 
		{
			if(success) 
			{
				CONFIG::RELEASE 
				{
					AVLog.info("当前页面地址: " + href, true);
				}
			}
		}
	}
}