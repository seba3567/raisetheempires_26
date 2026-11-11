package displays.screens
{
   import core.gameobjects.CrewTemplateWrapper;
   import core.managers.CrewManager;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import zlabs.events.WorldEvent;
   
   public class CrewGatherSlotOwnerPartial extends CrewGatherSlot
   {
      
      public function CrewGatherSlotOwnerPartial(param1:EventDispatcher, param2:Class, param3:int, param4:CrewTemplateWrapper)
      {
         super(param1,param2,param3,param4);
      }
      
      override protected function updateAction() : void
      {
         if(CrewManager.canSlotBeBought(owner,m_index,m_wrapper))
         {
            m_action = CrewGatherSlot.ACTION_BUY;
         }
      }
      
      override protected function onActionButtonClicked(param1:MouseEvent) : void
      {
         m_dispatcher.dispatchEvent(new WorldEvent(CrewResizablePopUp.SLOT_BOUGHT,m_index));
      }
      
      override protected function enablePortraits() : Boolean
      {
         return false;
      }
   }
}

