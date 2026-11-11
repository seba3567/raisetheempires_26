package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.UIControllerComponent;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gameobjects.GameItem;
   import core.managers.CapsuleHousingManager;
   import core.managers.CrewManager;
   import entity.GameDataComponent;
   import zlabs.events.WorldEvent;
   
   public class CapsuleClickState extends SimpleClickState
   {
      
      protected var m_currentWorkers:int;
      
      protected var m_currentWorkersCap:int;
      
      public function CapsuleClickState(param1:BehaviorStateInit)
      {
         super(param1);
         this.m_currentWorkers = this.currentWorkers;
         this.m_currentWorkersCap = this.currentWorkersCap;
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         if(ZGlobal.isVisiting())
         {
            CapsuleHousingManager.visitInstance.initWorkers(this.m_currentWorkers,this.m_currentWorkersCap);
         }
         else
         {
            CapsuleHousingManager.instance.initWorkers(this.m_currentWorkers,this.m_currentWorkersCap);
         }
      }
      
      override protected function updateTooltip(param1:GameItem) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         if(m_data.@tooltip.length() > 0)
         {
            _loc2_ = new Object();
            _loc2_.tooltip = m_data.@tooltip;
            _loc2_.visitTooltip = ZGlobal.isVisiting() ? this.getVisitTooltip() : "";
            _loc2_.tooltipData = "";
            _loc2_.label = m_data.@label;
            _loc2_.tooltipType = m_data.@tooltipType;
            _loc3_ = param1.getStateMachineValuesAsString();
            if(m_data.@tooltipCoins != undefined)
            {
               _loc3_ += "$CollectingTaxesCoins:" + m_data.@tooltipCoins.toString() + ",";
            }
            if(_loc3_.length > 0)
            {
               _loc2_.tooltipData = _loc3_;
            }
            stateMachine.propertyBag.eventDispatcher.dispatchEvent(new WorldEvent(UIControllerComponent.EVENT_TOOLTIP_UPDATE,_loc2_));
         }
      }
      
      private function getVisitTooltip() : String
      {
         if(isVisitHelpLimitReached())
         {
            return "";
         }
         var _loc1_:GameDataComponent = GameDataComponent.getGameDataComponent(owner);
         if(CrewManager.isCrewBuilding(owner,_loc1_))
         {
            if(!CrewManager.isPlayerInCrew(owner,ZGlobal.player.uid,_loc1_))
            {
               return "";
            }
         }
         return m_data.@visitTooltip;
      }
      
      override protected function shouldShowOverlay() : Object
      {
         return {
            "show":true,
            "data":m_data
         };
      }
      
      override public function sell() : void
      {
         CapsuleHousingManager.instance.sell();
         super.sell();
      }
      
      protected function get currentWorkers() : int
      {
         return m_data.@currentWorkers != undefined ? int(parseInt(m_data.@currentWorkers)) : 0;
      }
      
      protected function get currentWorkersCap() : int
      {
         return m_data.@currentWorkers != undefined ? int(parseInt(m_data.@currentWorkersCap)) : 0;
      }
   }
}

