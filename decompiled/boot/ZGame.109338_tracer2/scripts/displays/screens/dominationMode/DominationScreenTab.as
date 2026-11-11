package displays.screens.dominationMode
{
   import core.ui.ZGameButton;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class DominationScreenTab extends ZGameButton
   {
      
      public function DominationScreenTab(param1:MovieClip, param2:Function = null, param3:Number = 1.1, param4:Boolean = false)
      {
         super(param1,param2,param3,param4);
      }
      
      override protected function clickAction(param1:MouseEvent) : void
      {
         this.setInactive();
         super.clickAction(param1);
      }
      
      public function setInactive() : void
      {
         var _loc1_:String = m_target.generic_tf.text;
         this.gotoFrame(4);
         text = _loc1_;
         disable(true);
      }
      
      public function setActive() : void
      {
         var _loc1_:String = m_target.generic_tf.text;
         this.gotoFrame(1);
         text = _loc1_;
         enable();
      }
      
      public function setText(param1:String) : void
      {
         text = param1;
      }
      
      override protected function get canTransformText() : Boolean
      {
         return false;
      }
   }
}

