package displays.screens
{
   import core.gameobjects.CrewTemplateWrapper;
   import flash.events.EventDispatcher;
   
   public class CrewGatherSlotVisitorPartial extends CrewGatherSlot
   {
      
      public function CrewGatherSlotVisitorPartial(param1:EventDispatcher, param2:Class, param3:int, param4:CrewTemplateWrapper)
      {
         super(param1,param2,param3,param4);
      }
      
      override public function get cash() : int
      {
         return 0;
      }
      
      override protected function enablePortraits() : Boolean
      {
         return false;
      }
      
      override protected function overrideActionButtonDisplay() : Boolean
      {
         return true;
      }
   }
}

