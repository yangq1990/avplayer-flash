package model.vo
{
	import consts.FontConst;

	public class BulletVO
	{
		public var uid:Number;
		public var content:String;
		public var timep:Number;
		public var pid:String;
		/**
		 * 字体颜色 
		 */		
		public var color:uint = FontConst.DEFAULT_TXT_COLOR; //默认值为0xffffff		
		/**
		 * 0或1，0表示别人说的话，1表示自己说的话 
		 */		
		public var type:int;
		
		public function BulletVO()
		{
		}
		
	}
}