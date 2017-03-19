package utils
{
	import flash.display.DisplayObject;
	import flash.display.Stage;

	/**
	 * 持有舞台stage的静态引用的工具类
	 * @author yangq
	 * 
	 */	
	public class StageReference 
	{
		/** 指向舞台的引用 **/ 
		private var _stage:Stage;
		
		private var _root:DisplayObject;	
		
		private static var _instance:StageReference;

		public function StageReference() 
		{
		}
		
		public static function getInstance():StageReference 
		{
			if(_instance == null) 
			{
				_instance = new StageReference();
			}
			return _instance;
		}
		
		public function init(displayObj:DisplayObject):void 
		{
			if(_root == null) 
			{
				_root = displayObj.root;
				_stage = displayObj.stage;
			}
		}
		
		public function get stage():Stage 
		{
			return _stage;
		}
		
		public function set stage(s:Stage):void 
		{
			_stage = s;
		}

		public function get root():DisplayObject
		{
			return _root;
		}

		public function set root(value:DisplayObject):void
		{
			_root = value;
		}

	}
}