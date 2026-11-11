package displays.screens.neighborScreen
{
   import core.ZGlobal;
   import core.managers.PVPManager;
   import displays.popups.GenericPopup;
   import displays.popups.ReactivationGiftPopup;
   import flash.events.MouseEvent;
   import zlabs.events.GenericPopupEvent;
   
   public class ContextualMenuWrapperAttack extends ContextualMenuWrapperBase
   {
      
      public function ContextualMenuWrapperAttack(param1:NeighborSlot, param2:UserGrid, param3:Class)
      {
         super(param1,param2,param3);
      }
      
      protected function get checkVictimReactivation() : Boolean
      {
         return true;
      }
      
      protected function onAttackClick(param1:MouseEvent) : void
      {
         if(this.checkVictimReactivation && ZGlobal.neighborReactivationNeeded(uid))
         {
            ReactivationGiftPopup.show(uid);
            return;
         }
         if(PVPManager.instance.canAttackWithImmunityCooldown())
         {
            if(PVPManager.instance.canAttackWithNeighborAssist(uid))
            {
               if(PVPManager.instance.checkImmunityCancel(this.onAcceptConfirmClose,mc.neighborSlot))
               {
                  this.doAttack(mc.neighborSlot);
               }
            }
         }
      }
      
      private function onAcceptConfirmClose(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            this.doAttack(param1.userData as NeighborSlot);
         }
      }
      
      private function doAttack(param1:NeighborSlot) : void
      {
         grid.onAttackClick(param1,continueInvasion);
      }
   }
}

