package core.entities.components
{
   import core.ZGlobal;
   import core.managers.CrewManager;
   import core.player.Player;
   import core.ui.PlayerFeedbackManager;
   import entity.GameDataComponent;
   import utils.ZGameUtils;
   import zlabs.entity.EntityComponent;
   import zlabs.events.WorldEvent;
   
   public class CrewBuildingComponent extends EntityComponent
   {
      
      private var m_id:int;
      
      public function CrewBuildingComponent(param1:int)
      {
         super();
         this.m_id = param1;
      }
      
      override protected function onAdd() : void
      {
         CrewManager.instance.addEventListener(CrewManager.CREW_TEND_UPDATED,this.onCrewTendUpdated,false,0,true);
         CrewManager.instance.addEventListener(CrewManager.PURCHASED_CREW_SLOT_FULL,this.onPurchasedSlotFull,false,0,true);
         CrewManager.instance.addEventListener(CrewManager.CREW_REPLACED,this.onCrewReplaced,false,0,true);
         super.onAdd();
      }
      
      override protected function onRemove() : void
      {
         CrewManager.instance.removeEventListener(CrewManager.CREW_TEND_UPDATED,this.onCrewTendUpdated);
         CrewManager.instance.removeEventListener(CrewManager.PURCHASED_CREW_SLOT_FULL,this.onPurchasedSlotFull);
         CrewManager.instance.removeEventListener(CrewManager.CREW_REPLACED,this.onCrewReplaced);
         super.onRemove();
      }
      
      private function onCrewTendUpdated(param1:WorldEvent) : void
      {
         var _loc3_:GameDataComponent = null;
         var _loc2_:Object = param1.eventData;
         if(_loc2_.objId == this.m_id && _loc2_.world == ZGlobal.hostPlayer.uid)
         {
            _loc3_ = GameDataComponent.getGameDataComponent(owner);
            if(Boolean(_loc3_) && Boolean(_loc3_.userData))
            {
               _loc3_.userData.crewInfo = _loc2_.crew;
               _loc3_.userData.crewTendInfo = _loc2_.tends;
            }
         }
      }
      
      private function onPurchasedSlotFull(param1:WorldEvent) : void
      {
         var _loc2_:GameDataComponent = null;
         if(param1.eventData.objid == this.m_id)
         {
            _loc2_ = GameDataComponent.getGameDataComponent(owner);
            if(Boolean(_loc2_) && Boolean(_loc2_.userData))
            {
               _loc2_.userData.crewInfo = param1.eventData.crew;
            }
         }
      }
      
      private function onCrewReplaced(param1:WorldEvent) : void
      {
         var _loc2_:GameDataComponent = null;
         if(param1.eventData.object_id == this.m_id)
         {
            _loc2_ = GameDataComponent.getGameDataComponent(owner);
            if(Boolean(_loc2_) && Boolean(_loc2_.userData))
            {
               _loc2_.userData.crewInfo[param1.eventData.replaceIndex] = param1.eventData.staffer;
               _loc2_.userData.crewReplaceCount = param1.eventData.crewReplaceCount;
               this.notifyPlayerOfReplace(param1.eventData,_loc2_);
            }
         }
      }
      
      private function notifyPlayerOfReplace(param1:Object, param2:GameDataComponent) : void
      {
         var _loc4_:String = null;
         var _loc3_:Player = ZGlobal.player.findFriendById(param1.staffer);
         if(_loc3_)
         {
            _loc4_ = ZGameUtils.ZlocT("Main","FeedbackCrewReplaced",{
               "crew":_loc3_.firstName,
               "title":param1.title,
               "item":param2.gameData.getSentenceNameLocalizationObject()
            });
            PlayerFeedbackManager.instance.displayToaster(_loc4_);
         }
      }
   }
}

