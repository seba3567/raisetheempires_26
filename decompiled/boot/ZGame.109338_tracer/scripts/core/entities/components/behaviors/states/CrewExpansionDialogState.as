package core.entities.components.behaviors.states
{
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.managers.CrewManager;
   import core.managers.WorldObjectManager;
   import dispatchers.UIDispatcher;
   import displays.screens.CrewGatherOwnerPartialExpansions;
   import entity.GameDataComponent;
   import events.ExpansionEvent;
   import events.MarketEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.entity.IEntity;
   
   public class CrewExpansionDialogState extends CrewDialogState
   {
      
      public function CrewExpansionDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override public function onMouseOver(param1:MouseEvent) : void
      {
      }
      
      override protected function get textInfo() : Object
      {
         return {
            "title":"CrewedExpansionDialogTitle",
            "desc":"CrewedExpansionDialogDesc"
         };
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         UIDispatcher.instance.addEventListener(MarketEvent.MARKET_EXPANSION_CASH_UNLOCK,this.onShowDialog,false,0,true);
         UIDispatcher.instance.addEventListener(ExpansionEvent.EXPANSION_TYPE_CREW,this.onExpansionPurchased);
      }
      
      override protected function removeListeners() : void
      {
         super.removeListeners();
         UIDispatcher.instance.removeEventListener(MarketEvent.MARKET_EXPANSION_CASH_UNLOCK,this.onShowDialog);
         UIDispatcher.instance.removeEventListener(ExpansionEvent.EXPANSION_TYPE_CREW,this.onExpansionPurchased);
      }
      
      protected function onShowDialog(param1:Event) : void
      {
         showCrewDialog();
      }
      
      override protected function onClosed(param1:Event) : void
      {
         var _loc3_:IEntity = null;
         var _loc4_:GameDataComponent = null;
         var _loc2_:Dictionary = WorldObjectManager.instance.getObjectsBySubType("expansion","crewExpansion");
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_)
            {
               _loc4_ = GameDataComponent.getGameDataComponent(_loc3_);
               _loc4_.updateCrew();
               break;
            }
         }
         super.onClosed(param1);
      }
      
      private function onExpansionPurchased(param1:Event) : void
      {
         var _loc3_:IEntity = null;
         var _loc2_:Dictionary = WorldObjectManager.instance.getObjectsBySubType("expansion","crewExpansion");
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_)
            {
               CrewManager.clearCrewInfo(_loc3_);
               break;
            }
         }
      }
      
      override protected function createPopup(param1:IEntity) : PopUpBase
      {
         return new CrewGatherOwnerPartialExpansions(param1,m_wrapper,m_item,this.textInfo);
      }
      
      override protected function addEmptySlots() : void
      {
      }
   }
}

