package displays.screens
{
   import core.ZGlobal;
   import core.gameobjects.CrewTemplateWrapper;
   import core.gameobjects.GameItem;
   import core.managers.CrewManager;
   import core.managers.viralsManager.ViralsManager;
   import entity.GameDataComponent;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   
   public class CrewGatherVisitorPartial extends CrewGather
   {
      
      public function CrewGatherVisitorPartial(param1:IEntity, param2:CrewTemplateWrapper, param3:GameItem, param4:Array)
      {
         super(param1,param2,param3,param4,CrewGatherSlotVisitorPartial);
      }
      
      override protected function getTitleText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","CrewDialogTitleVisitor",getStringTokens());
      }
      
      override protected function getDescriptionText() : String
      {
         var _loc1_:Boolean = CrewManager.isPlayerInCrew(owner,ZGlobal.player.uid);
         if(canFinishBuilding())
         {
            if(_loc1_)
            {
               return ZGameUtils.ZlocT("Dialogs","CrewDialogRemindOwner",getStringTokens());
            }
            return ZGameUtils.ZlocT("Dialogs","CrewDialogAlreadyFilled",getStringTokens());
         }
         if(_loc1_)
         {
            return ZGameUtils.ZlocT("Dialogs","CrewDialogWaitingForComplete",getStringTokens());
         }
         return ZGameUtils.ZlocT("Dialogs","CrewDialogDescVisitor",getStringTokens());
      }
      
      override protected function buyStaff(param1:int, param2:int) : void
      {
         ViralsManager.instance.sendFeed("neighbor_crew_apply",{},ZGlobal.hostPlayer.uid);
      }
      
      override protected function showConfirmButton() : Boolean
      {
         if(this.canSendFinishReminder())
         {
            return true;
         }
         if(CrewManager.canPlayerJoinCrew(owner,ZGlobal.player.uid))
         {
            return true;
         }
         return false;
      }
      
      override protected function onConfirmClick(param1:MouseEvent) : void
      {
         var _loc2_:GameDataComponent = GameDataComponent.getGameDataComponent(owner);
         if(this.canSendFinishReminder())
         {
            ViralsManager.instance.sendNeighborCrewMemberRemind(_loc2_.id);
         }
         else if(CrewManager.canPlayerJoinCrew(owner,ZGlobal.player.uid,_loc2_))
         {
            ViralsManager.instance.sendNeighborCrewMemberApply(_loc2_.id,m_gameItem);
         }
         closeWindow(param1);
      }
      
      override protected function getButtonTextKey() : String
      {
         if(this.canSendFinishReminder())
         {
            return "RemindButton";
         }
         if(CrewManager.canPlayerJoinCrew(owner,ZGlobal.player.uid))
         {
            return "CrewDialogVisitorPartialBuy";
         }
         return "";
      }
      
      override protected function get actionButtonMC() : MovieClip
      {
         return m_mc.build_bt2;
      }
      
      private function canSendFinishReminder() : Boolean
      {
         if(!canFinishBuilding())
         {
            return false;
         }
         if(!CrewManager.isPlayerInCrew(owner,ZGlobal.player.uid))
         {
            return false;
         }
         return true;
      }
   }
}

