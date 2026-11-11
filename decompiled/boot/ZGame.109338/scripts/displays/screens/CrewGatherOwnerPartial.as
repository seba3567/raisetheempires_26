package displays.screens
{
   import core.gameobjects.CrewTemplateWrapper;
   import core.gameobjects.GameItem;
   import core.managers.CrewManager;
   import entity.GameDataComponent;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class CrewGatherOwnerPartial extends CrewGather
   {
      
      protected var m_textInfo:Object = null;
      
      protected var m_restoreOldCrew:Boolean = false;
      
      public function CrewGatherOwnerPartial(param1:IEntity, param2:CrewTemplateWrapper, param3:GameItem, param4:Array, param5:Object, param6:Boolean = false, param7:Class = null)
      {
         this.m_textInfo = param5;
         this.m_restoreOldCrew = param6;
         if(!param7)
         {
            param7 = CrewGatherSlotOwnerPartial;
         }
         super(param1,param2,param3,param4,param7);
         CrewManager.instance.addEventListener(CrewManager.PURCHASED_CREW_SLOT_FULL,this.onPurchasedSlotFull,false,0,true);
      }
      
      override protected function getTitleText() : String
      {
         return ZGameUtils.ZlocTP("Dialogs",this.m_textInfo.title,getStringTokens());
      }
      
      override protected function getDescriptionText() : String
      {
         return ZGameUtils.ZlocTP("Dialogs",this.m_textInfo.desc,getStringTokens());
      }
      
      override protected function getButtonTextKey() : String
      {
         if(this.m_textInfo.button)
         {
            return canFinishBuilding() ? this.m_textInfo.button.finish : this.m_textInfo.button.hire;
         }
         return super.getButtonTextKey();
      }
      
      override protected function onConfirmFinish() : void
      {
         if(canFinishBuilding())
         {
            CrewManager.setCrewInfo(owner,m_crewInfo);
         }
         super.onConfirmFinish();
      }
      
      private function onPurchasedSlotFull(param1:WorldEvent) : void
      {
         var _loc2_:GameDataComponent = GameDataComponent.getGameDataComponent(owner);
         if(Boolean(_loc2_) && _loc2_.id == param1.eventData.objid)
         {
            m_crewInfo = param1.eventData.crew;
            updateElements();
         }
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         CrewManager.instance.removeEventListener(CrewManager.PURCHASED_CREW_SLOT_FULL,this.onPurchasedSlotFull);
      }
   }
}

