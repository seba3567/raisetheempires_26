package core.entities.components
{
   import core.ui.feedbacktext.QuantifiedFeedbackText;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   import utils.TextFieldUtil;
   import zlabs.entity.EntityComponent;
   
   public class ObjectHighlightComponent extends EntityComponent
   {
      
      protected var m_textFields:Array = new Array();
      
      protected var m_sprite:Sprite = new Sprite();
      
      protected var m_container:Sprite = new Sprite();
      
      public function ObjectHighlightComponent()
      {
         super();
         this.m_container.mouseEnabled = false;
         this.m_container.mouseChildren = false;
      }
      
      public function get sprite() : Sprite
      {
         return this.m_sprite;
      }
      
      protected function cleanupTextFields() : void
      {
         var _loc1_:Object = null;
         for each(_loc1_ in this.m_textFields)
         {
            _loc1_.tf.parent.removeChild(_loc1_.tf);
            _loc1_.tf = null;
            _loc1_.mc = null;
         }
         this.m_textFields = new Array();
      }
      
      protected function addFeedbackString(param1:QuantifiedFeedbackText) : void
      {
         var _loc2_:MovieClip = new LootText();
         var _loc3_:TextField = _loc2_.text_tf;
         var _loc4_:String = param1.friendlyName;
         TextFieldUtil.processSingleLineTextField(_loc3_,_loc4_,15);
         _loc3_.textColor = param1.color;
         _loc3_.scaleX = _loc3_.scaleY = 1.5;
         var _loc5_:int = this.m_textFields.length * _loc3_.height;
         _loc3_.y = -(_loc5_ + 50);
         _loc3_.x -= _loc3_.width * 0.5;
         _loc3_.x += this.m_sprite.parent.x + this.m_sprite.x;
         _loc3_.y += this.m_sprite.parent.y + this.m_sprite.y;
         this.m_container.addChild(_loc3_);
         this.m_textFields.push({
            "tf":_loc3_,
            "mc":_loc2_
         });
      }
      
      protected function addFeedback(param1:QuantifiedFeedbackText) : void
      {
         this.addFeedbackString(param1);
         this.m_sprite.parent.parent.addChild(this.m_container);
      }
      
      protected function removeFeedback() : void
      {
         this.cleanupTextFields();
      }
   }
}

