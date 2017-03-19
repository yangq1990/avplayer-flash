package controller.task
{
	import event.TaskEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	
	/**
	 * 加载播放器配置 
	 * @author yangq
	 * 
	 */	
	public class ConfigLoader extends EventDispatcher
	{
		public var version:String;  
		
		[Embed(source="../.version",mimeType='application/octet-stream')]
		private var versionXml:Class;
		
		public function ConfigLoader(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function load():void
		{
			var ba:ByteArray = new versionXml as ByteArray;
			var vxml:XML=new XML(ba.readUTFBytes(ba.length));			
			version = (vxml.value + " | " + vxml.date);		
			
			dispatchEvent(new TaskEvent(TaskEvent.LOAD_CONFIG_COMPLETE));
		}
	}
}