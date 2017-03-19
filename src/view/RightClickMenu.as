package view
{
	import flash.display.Sprite;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import model.Model;
	
	/**
	 * 自定义右键菜单类 
	 * @author yangq
	 * 
	 */	
	public class RightClickMenu
	{
		private var _context:ContextMenu;
		private var _m:Model;
		
		public function RightClickMenu(m:Model, parent:Sprite)
		{
			super();
			
			this._m = m;		
			_context = new ContextMenu();
			_context.hideBuiltInItems();
			parent.contextMenu = _context; //Stage不实现此属性
		}
		
		public function initializeMenu():void
		{
			addItem(new ContextMenuItem(_m.version));
		}
		
		/** Add an item to the contextmenu.**/
		protected function addItem(itm:ContextMenuItem, fcn:Function=null):void 
		{
			itm.separatorBefore = true;
			_context.customItems.push(itm);								
		}
	}
}