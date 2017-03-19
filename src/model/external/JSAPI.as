package model.external
{

	import event.js.JSEvent;
	
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	import model.vo.ErrorVO;
	
	import org.osmf.utils.AVLog;
	
	/**
	 * JS处理模块，包括注册函数供外部JS调用和调用外部JS函数，单例模式
	 * @author yangq
	 * 
	 */	
	public class JSAPI extends EventDispatcher
	{
		private static var _instance:JSAPI;
		
		public static function getInstance():JSAPI
		{
			if(_instance == null)
				_instance = new JSAPI();
			return _instance;
		}
		
		public function JSAPI()
		{
			if(available)
			{
				try
				{
					ExternalInterface.addCallback("avplayer_pause", avPlayerPause);
					ExternalInterface.addCallback("avplayer_play", avPlayerPlay);
					ExternalInterface.addCallback("avplayer_mute", avPlayerMute);
					ExternalInterface.addCallback("avplayer_unmute", avPlayerUnmute);
					ExternalInterface.addCallback("avplayer_seek", avPlayerSeek);
				}
				catch(err:Error) 
				{
					CONFIG::RELEASE 
					{
						AVLog.error('JSAPI-->' + err.toString(), true);
					}
				}
			}			
		}
	
		private function avPlayerPause():void
		{
			dispatchEvent(new JSEvent(JSEvent.PAUSE));
		}
		
		private function avPlayerPlay():void
		{
			dispatchEvent(new JSEvent(JSEvent.PLAY));
		}
		
		private function avPlayerMute():void
		{
			dispatchEvent(new JSEvent(JSEvent.MUTE));
		}
		
		private function avPlayerUnmute():void
		{
			dispatchEvent(new JSEvent(JSEvent.UNMUTE));	
		}
		
		/** js seek到指定位置播放 **/
		private function avPlayerSeek(time:String):void
		{
			if(!time) { //参数无效
				return;
			}
			dispatchEvent(new JSEvent(JSEvent.SEEK, Number(time)));
		}

		public function reachVideoEnd():void
		{
			available && ExternalInterface.call("reachVideoEnd");
		}
		
		/**
		 * 刷新重试
		 * */
		public function refresh():void
		{
			if(available) 
			{
				//如果js_retry不可用，则刷新整个页面，增加fallback机制
				var result:* = ExternalInterface.call("js_avplayer_retry");
				if(result == null)
				{
					ExternalInterface.call("location.replace(location.href)");
				}
			}
		}
		
		/**
		 * 播放器pause，通知js接口 
		 * 
		 */		
		public function pause():void
		{
			available && ExternalInterface.call("js_avplayer_pause");
		}
		
		/**
		 * 播放器play，通知js接口
		 * 
		 */		
		public function play():void
		{
			available && ExternalInterface.call("js_avplayer_play");
		}
		
		/**
		 * 播放器停止
		 * 
		 */		
		public function stop():void
		{
			available && ExternalInterface.call("js_avplayer_stop");
		}
		
		/**
		 * 播放结束 
		 * 
		 */		
		public function playbackComplete():void
		{
			available && ExternalInterface.call("js_avplayer_playbackComplete");
		}
		
		/**
		 * 播放开始 
		 * 
		 */		
		public function playStart():void
		{
			available && ExternalInterface.call("js_avplayer_playStart");
		}
		
		/**
		 * 播放器在缓冲 
		 * @param id  如果页面上有多个播放器，此id有助于确定是哪个播放器在缓冲
		 * 
		 */		
		public function playerBuffering(id:String=""):void
		{
			available && ExternalInterface.call("js_avplayer_playerBuffering", id);
		}
		
		/**
		 * 播放器缓冲区满开始播放 
		 * @param id 如果页面上有多个播放器，此id有助于确定是哪个播放器在播放
		 */		
		public function playerPlaying(id:String=""):void
		{
			available && ExternalInterface.call("js_avplayer_playerPlaying", id);
		}
		
		/**
		 * 重播 
		 * 
		 */		
		public function replay():void
		{
			available && ExternalInterface.call("js_avplayer_rewind");
		}
		
		/**
		 * 通知js 播放发生了错误并且告诉错误信息 
		 * @param code 错误代码
		 * @param msg 错误内容
		 * 
		 */		
		public function noticeError(err:ErrorVO):void
		{
			if(err.code == -1 || err.msg == null || err.msg == "") //错误信息不明则不通知
				return;
			
			available && ExternalInterface.call("js_avplayer_errorOccurred", err.code, err.msg);
		}
		
		/** 外部接口是否可用 **/
		private function get available():Boolean
		{
			return ExternalInterface.available;
		}
	}
}