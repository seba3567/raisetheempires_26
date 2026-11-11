package core.ui
{
   import com.greensock.TweenLite;
   import flash.text.TextField;
   import utils.TextFieldUtil;
   
   public class TextTweener
   {
      
      private var m_textField:TextField = null;
      
      private var m_compactInfo:Object = null;
      
      public function TextTweener(param1:TextField, param2:Object = null)
      {
         super();
         this.m_textField = param1;
         this.m_compactInfo = param2;
         this.m_textField.mouseEnabled = false;
         this.m_textField.selectable = false;
         TextFieldUtil.processTextField(this.m_textField,"");
      }
      
      public function dispose() : void
      {
         TweenLite.killTweensOf(this);
         this.m_textField = null;
      }
      
      public function tweenTo(param1:int, param2:Number, param3:Function = null, param4:Function = null) : void
      {
         if(0 == param2)
         {
            this.value = param1;
         }
         else
         {
            TweenLite.to(this,param2,{
               "value":param1,
               "onUpdate":param3,
               "onComplete":param4
            });
         }
      }
      
      public function set value(param1:int) : void
      {
         if(this.m_compactInfo)
         {
            TextFieldUtil.compactTextField(this.m_textField,param1.toString(),this.m_compactInfo);
         }
         else
         {
            this.m_textField.text = param1.toString();
         }
      }
      
      public function get value() : int
      {
         return parseInt(this.m_textField.text);
      }
      
      public function get textField() : TextField
      {
         return this.m_textField;
      }
   }
}

