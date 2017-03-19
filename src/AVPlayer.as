package
{
	import controller.Controller;
	
	import model.Model;
	
	import utils.StageReference;
	
	import view.View;
	import view.base.BaseInitView;
	
	/**
	 * 播放器入口类
	 * @author yangq
	 * 
	 */	
	[SWF(backgroundColor="#000000", frameRate=30)]
	public class AVPlayer extends BaseInitView
	{
		private var _m:Model;
		private var _v:View;
		private var _c:Controller;		
		
		public function AVPlayer()
		{
		}
		
		override protected function init():void
		{
			super.init();
			
			StageReference.getInstance().init(this);
			
			_m = new Model();			
			_v = new View(_m);			
			_c = new Controller(_v, _m);			
			
			_c.setupPlayer();			
		}
	}
}