package displays.screens
{
   import core.gameobjects.CrewTemplateWrapper;
   import core.managers.CrewManager;
   import core.managers.viralsManager.ViralsManager;
   import core.player.Player;
   import entity.GameDataComponent;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   
   public class CrewGatherSlotOwnerComplete extends CrewGatherSlotComplete
   {
      
      private var m_playerID:String;
      
      public function CrewGatherSlotOwnerComplete(param1:EventDispatcher, param2:Class, param3:int, param4:CrewTemplateWrapper)
      {
         super(param1,param2,param3,param4);
      }
      
      override protected function updateAction() : void
      {
         var _loc1_:Object = CrewManager.getPlayerIDByCrewIndex(owner,m_index);
         if(Boolean(_loc1_) && Boolean(_loc1_.success))
         {
            this.m_playerID = String(_loc1_.id);
            if(this.m_playerID != Player.FAKE_PLAYER_ID)
            {
               m_action = CrewGatherSlot.ACTION_REMIND;
            }
         }
      }
      
      override protected function onActionButtonClicked(param1:MouseEvent) : void
      {
         var _loc2_:GameDataComponent = null;
         if(m_action == CrewGatherSlot.ACTION_REMIND)
         {
            _loc2_ = GameDataComponent.getGameDataComponent(owner);
            ViralsManager.instance.sendNeighborCrewTendRemind(_loc2_.id,_loc2_.gameData,this.m_playerID);
         }
      }
      
      override protected function overrideActionButtonDisplay() : Boolean
      {
         return true;
      }
   }
}

