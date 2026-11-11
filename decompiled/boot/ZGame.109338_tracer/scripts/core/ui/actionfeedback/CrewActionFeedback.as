package core.ui.actionfeedback
{
   import core.ui.FloatingText;
   import flash.display.DisplayObjectContainer;
   
   public class CrewActionFeedback extends GenericActionFeedback
   {
      
      public function CrewActionFeedback(param1:Object, param2:String)
      {
         super(param1,param2);
      }
      
      override protected function createFloatingText(param1:DisplayObjectContainer) : FloatingText
      {
         var _loc2_:FloatingText = super.createFloatingText(param1);
         _loc2_.duration = 1;
         return _loc2_;
      }
   }
}

