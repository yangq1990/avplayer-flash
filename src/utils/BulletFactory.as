package utils
{
	import model.vo.BulletVO;
	
	import view.barrage.Bullet;

	/**
	 * 弹幕元素的工厂方法
	 * @author yangq1990
	 * 
	 */	
	public class BulletFactory
	{
		/** Bullet对象池 **/
		private static var _pool:Vector.<Bullet> = new Vector.<Bullet>;
		
		public function BulletFactory()
		{
		}
		
		/**
		 * 生产Bullet对象 
		 * @param data {msg, from}
		 * @return 
		 * 
		 */		
		public static function produce(vo:BulletVO):Bullet
		{
			var bullet:Bullet;
			if(_pool.length == 0)
			{
				bullet = new Bullet(vo);
			}
			else
			{
				bullet = _pool.pop() as Bullet;
				bullet.reset(vo);
			}
			return bullet;
		}
		
		/**
		 * Bullet对象默认高度 
		 * @return 
		 * 
		 */		
		public static function get defaultBulletHeight():Number
		{
			var vo:BulletVO = new BulletVO();
			vo.content = "默认";
			var bullet:Bullet = new Bullet(vo);
			return bullet.height;
		}
		
		/**
		 * 回收Bullet对象 
		 * @param bullet
		 * 
		 */		
		public static function reclaim(bullet:Bullet):void
		{
			_pool.push(bullet);
		}
		
		/**
		 * 清空对象池 
		 * 
		 */		
		public static function clear():void
		{
			for each(var bullet:Bullet in _pool)
			{
				bullet.dispose();
				bullet.parent && bullet.parent.removeChild(bullet);
				bullet = null;
			}
			
			_pool.length = 0;
		}
	}
}