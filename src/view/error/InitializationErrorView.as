package view.error
{
	import consts.FontConst;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flashx.textLayout.formats.TextAlign;
	
	import utils.StageReference;
	
	/**
	 * 初始化时发生错误展示的界面 
	 * @author yangq
	 * 
	 */	
	public class InitializationErrorView extends Sprite
	{		
		public function InitializationErrorView(errorMsg:String)
		{
			super();
			
			var stageRef:StageReference = StageReference.getInstance();
			
			var g:Graphics = this.graphics;
			g.beginFill(0x000000);
			g.drawRect(0, 0, stageRef.stage.stageWidth, stageRef.stage.stageHeight);
			g.endFill();
			
			var tf:TextField = new TextField();
			var format:TextFormat = new TextFormat(FontConst.YAHEI, FontConst.SIZE, FontConst.DEFAULT_TXT_COLOR);
			format.align = TextAlign.CENTER;
			tf.defaultTextFormat = format;
			tf.text = errorMsg;
			tf.selectable = tf.mouseEnabled = false;
			tf.multiline = tf.wordWrap = true;
			tf.width = stageRef.stage.stageWidth;
			tf.height = tf.textHeight + 10;
			tf.x = (stageRef.stage.stageWidth - tf.width) * 0.5;
			tf.y = (stageRef.stage.stageHeight - tf.height) * 0.5;
			addChild(tf);
			
			this.mouseEnabled = this.mouseChildren = false;
		}
	}
}