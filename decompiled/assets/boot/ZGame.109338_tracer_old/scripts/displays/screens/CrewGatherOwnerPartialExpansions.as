package displays.screens
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.CrewTemplateWrapper;
   import core.gameobjects.GameItem;
   import core.gameobjects.expansionitem.ExpansionItem;
   import dispatchers.UIDispatcher;
   import entity.GameDataComponent;
   import events.MarketEvent;
   import flash.events.MouseEvent;
   import transactions.TStaffPosition;
   import zlabs.entity.IEntity;
   
   public class CrewGatherOwnerPartialExpansions extends CrewGatherOwnerPartial
   {
      
      public function CrewGatherOwnerPartialExpansions(param1:IEntity, param2:CrewTemplateWrapper, param3:GameItem, param4:Object)
      {
         var _loc5_:GameDataComponent = null;
         _loc5_ = GameDataComponent.getGameDataComponent(param1);
         _loc5_.initCrew();
         m_textInfo = param4;
         super(param1,param2,param3,_loc5_.userData.crewInfo,param4);
         m_wrapper.updateDataForCrewableExpansions();
      }
      
      override protected function getButtonTextKey() : String
      {
         return canFinishBuilding() ? "CrewedExpansionDialogFinishButton" : "CrewDialogButtonHireFriends";
      }
      
      override protected function onConfirmClick(param1:MouseEvent) : void
      {
         super.onConfirmClick(param1);
         UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_EXPANSION_CREW_UNLOCK,0,ExpansionItem.CREWABLE_EXPANSION_ID,MarketEvent.SOURCE_STORE));
         if(canFinishBuilding())
         {
            UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY,MarketEvent.EXPAND_ISLAND,ExpansionItem.CREWABLE_EXPANSION_ID,MarketEvent.SOURCE_STORE));
         }
      }
      
      override protected function exitButtonClicked(param1:MouseEvent) : void
      {
         StatsManager.count("dialog","crew_expansion","","close","click");
         super.exitButtonClicked(param1);
      }
      
      override protected function buyStaff(param1:int, param2:int) : void
      {
         ZGlobal.player.cash -= param1;
         TransactionManager.addTransaction(new TStaffPosition(owner,param2,param1),true);
         StatsManager.count("dialog","crew_expansion","x01","buy_1","click");
         var _loc3_:GameDataComponent = GameDataComponent.getGameDataComponent(owner);
         _loc3_.buyCrewSlot(param1,param2);
         updateElements();
      }
   }
}

