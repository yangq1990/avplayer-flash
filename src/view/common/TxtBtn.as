package view.common
{
	import consts.FontConst;
	
	import flash.text.TextFormat;
	
	import org.osmf.utils.GlobalReference;
	
	import utils.UIUtil;
	
	/**
	 * 文字Button
	 * @author yangq
	 * 
	 */	
	public class TxtBtn extends BaseButton
	{
		private var _txt:String;
		
		private var _selected:Boolean;
		
		public function TxtBtn(label:String)
		{	
			super(label);
		}
		
		override protected function initUI():void
		{
			super.initUI();
			_tf.setTextFormat(UIUtil.getTextFormat(FontConst.DEFAULT_OPTION_COLOR));
			UIUtil.adjustTFWidthAndHeight(_tf);
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		public function set selected(bool:Boolean):void
		{
			var textformat:TextFormat = (bool ? UIUtil.getTextFormat(FontConst.SELECTED_TEXT_COLOR) : UIUtil.getTextFormat(FontConst.DEFAULT_OPTION_COLOR));
			_tf.setTextFormat(textformat);
		}
		
		override public function get width():Number
		{
			return _tf.width;
		}
		
		override public function get height():Number
		{
			return _tf.height;
		}
	}
}