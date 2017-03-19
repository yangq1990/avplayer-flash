package utils
{
	import flash.external.ExternalInterface;

	/**
	 * 与URL路径有关的类 
	 * @author yangq
	 * 
	 */	
	public class URLUtil
	{
		/**
		 * 获取当前页面url，并encode
		 * @param callback
		 * @return 
		 * 
		 */		
		public function getHref(callback:Function):void {
			if(ExternalInterface.available) {
				ExternalInterface.addCallback("avplayer_getLocationHref", function(href:String):void {
					callback(true, encodeURIComponent(href));
				});
				
				var swfRef:String = ExternalInterface.objectID; //在浏览器中获取嵌入swf的object或embed对象
				var jsStr:String = "var swfRef=document." + swfRef + "|| window." + swfRef + ";swfRef.avplayer_getLocationHref(window.location.href);"
				
				try {
					ExternalInterface.call("eval", jsStr);
				} catch(err:Error) {
					callback(false, err.toString());
				}
			} else {
				callback(false, "外部接口不可用");
			}
		}
	}
}