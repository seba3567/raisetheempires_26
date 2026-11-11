package Engine.Display
{
   import flash.display.BlendMode;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class StrokeTextField extends TextField
   {
      
      protected const STROKE_BLUR:int = 3;
      
      protected const STROKE_STRENGTH:int = 200;
      
      public var strokeFilter:GlowFilter;
      
      public function StrokeTextField(param1:uint = 0, param2:Number = 0.8)
      {
         super();
         this.strokeFilter = new GlowFilter(param1,alpha,this.STROKE_BLUR,this.STROKE_BLUR,this.STROKE_STRENGTH);
         this.filters = [this.strokeFilter];
         this.selectable = false;
         this.blendMode = BlendMode.LAYER;
         this.cacheAsBitmap = true;
         this.autoSize = TextFieldAutoSize.LEFT;
         this.mouseEnabled = false;
         this.mouseWheelEnabled = false;
      }
      
      public function set toolTipText(param1:String) : void
      {
         if(param1)
         {
            this.htmlText = param1;
         }
      }
   }
}

