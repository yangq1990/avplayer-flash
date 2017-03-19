package utils
{
	import flash.system.Capabilities;
	import org.osmf.utils.BasicInfo;
	

	/**
	 * 检测运行fp的容器的工具类 
	 * @author yangq
	 * 
	 */	
	public class ContainerInspection
	{
		public function ContainerInspection()
		{
		}
		
		/**
		 * flashplayer版本 
		 * @return 
		 * 
		 */		
		public function get fpVersion():Number
		{
			//版本号的格式为：平台 (platform)，主版本号 (majorVersion)，次版本号 (minorVersion)、生成版本号 (buildNumber)，内部生成版本号 (internalBuildNumber)
			//WIN 9,0,0,0  // Flash Player 9 for Windows
			var version:String = Capabilities.version;
			var spaceIndex:int = version.indexOf(" "); //空格所在的index
			var firstCommaIndex:int = version.indexOf(","); //第一个逗号所在的index
			var majorVersion:int = int(version.slice(spaceIndex, firstCommaIndex));		
			var minorVersion:int = int(version.charAt(firstCommaIndex+1));		
			
			return Number(majorVersion + "." + minorVersion);
		}
		
		/**
		 * 操作系统 
		 * @return 
		 * 
		 */		
		public function get os():String
		{
			return Capabilities.os;
		}
		
		/**
		 * 是否调试版本的flash player 
		 * @return 
		 * 
		 */		
		public function get isDebugger():Boolean
		{
			return Capabilities.isDebugger;
		}
		
		/**
		 * 浏览器是否是Google的chrome 
		 * @return 
		 * 
		 */		
		public function get isChrome():Boolean
		{
			return (Capabilities.manufacturer.toLowerCase().indexOf("google") != -1);
		}
		
		/**
		 * 系统信息 
		 * @return 
		 * 
		 */		
		public function get systemInfo():String
		{
			var browser:String;
			var basicInfo:BasicInfo = new BasicInfo();
			switch(basicInfo.browser) {
				case -1:
					browser = "unknown";
					break;
				case 0:
					browser = "Chrome";
					break;
				case 1:
					browser = "IE";
					break;
				case 2:
					browser = "FireFox";
					break;
				case 3:
					browser = "Safari";
					break;
				default:
					break;
			}
			
			if(browser != "unknown") {
				browser += basicInfo.browser_ver;
			}
			
			return "操作系统：" + Capabilities.os + " | "
				+ "浏览器：" + browser + " | "
				+ "FP版本：" + Capabilities.version + " | " 
				+ "是否调试版本：" + (Capabilities.isDebugger ? "是" : "否") + " | "
				+ "Runtime制造商：" + Capabilities.manufacturer.toLowerCase() + " | "
				+ "stage.quality: " + StageReference.getInstance().stage.quality + " | ";
		}
	}
}