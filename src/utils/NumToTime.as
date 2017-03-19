package utils
{
	public class NumToTime
	{
		private var hour:int;
		private var min:int;
		private var sec:int;
		
		public function NumToTime()
		{
		}
		
		private function zero(nbr:int):String {
			if (nbr < 10) {
				return '0' + nbr;
			} else {
				return nbr.toString();
			}
		}

		/**
		 * 将number转换为 h:m:s 的时间格式
		 * @param n
		 * @return 
		 * 
		 */		
		public function toHMS(n:Number):String {
			var temp:int = n - (int(n/3600))*3600;
			return zero(int(n/3600)) + ":" + zero(int(temp/60)) + ":" + zero(int(n%60));
		}
	}
}