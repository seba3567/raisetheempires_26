package displays.screens
{
   import core.gameobjects.CrewTemplateWrapper;
   import flash.events.EventDispatcher;
   import utils.ZGameUtils;
   
   public class RebuildCrewGatherSlotOwnerPartial extends CrewGatherSlotOwnerPartial
   {
      
      public function RebuildCrewGatherSlotOwnerPartial(param1:EventDispatcher, param2:Class, param3:int, param4:CrewTemplateWrapper)
      {
         super(param1,param2,param3,param4);
      }
      
      override protected function getPositionFriendlyName(param1:String) : String
      {
         return ZGameUtils.ZlocT("Dialogs","Rebuild_Card");
      }
      
      override protected function getPositionFilledFriendlyName(param1:String, param2:String) : String
      {
         return ZGameUtils.ZlocT("Dialogs","Rebuild_Card");
      }
   }
}

