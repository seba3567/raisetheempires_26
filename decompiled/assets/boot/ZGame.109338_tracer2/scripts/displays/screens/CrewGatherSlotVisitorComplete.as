package displays.screens
{
   import core.gameobjects.CrewTemplateWrapper;
   import core.managers.CrewManager;
   import core.player.Player;
   import core.ui.Tooltip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   
   public class CrewGatherSlotVisitorComplete extends CrewGatherSlotComplete
   {
      
      public function CrewGatherSlotVisitorComplete(param1:EventDispatcher, param2:Class, param3:int, param4:CrewTemplateWrapper)
      {
         super(param1,param2,param3,param4);
      }
      
      override protected function updateAction() : void
      {
         if(playerInSlotInvitable())
         {
            m_action = CrewGatherSlot.ACTION_INVITE;
         }
      }
      
      override protected function onActionButtonClicked(param1:MouseEvent) : void
      {
         inviteSlotPlayer();
      }
      
      override protected function overrideActionButtonDisplay() : Boolean
      {
         return true;
      }
      
      override public function dispose() : void
      {
         Tooltip.unsubscribe(m_slot.profileloader_mc);
         super.dispose();
      }
      
      override protected function updateContextSensitiveElements(param1:Player, param2:ButtonMouseEventSoundContainer) : void
      {
         Tooltip.subscribe(m_slot.profileloader_mc,CrewManager.getVisitorRewardTooltip(owner,m_index),{
            "duration":false,
            "delay":0
         });
         super.updateContextSensitiveElements(param1,param2);
      }
   }
}

