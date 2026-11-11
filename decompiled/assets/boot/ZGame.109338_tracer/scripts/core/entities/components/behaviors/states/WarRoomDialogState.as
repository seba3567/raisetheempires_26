package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import zlabs.events.WorldEvent;
   
   public class WarRoomDialogState extends DialogState
   {
      
      private var OVERLAY_STATE_INACTIVE:int = 0;
      
      private var OVERLAY_STATE_INACTIVE_ELITE:int = 1;
      
      private var OVERLAY_STATE_ACTIVE:int = 2;
      
      private var m_overlayIcons:Array = [{
         "icon":"Pause_42.png",
         "bkgd":"Bubble.png"
      },{
         "icon":"GuitarPic_BuzzardAutogyro_42.png",
         "bkgd":"Bubble.png"
      },{
         "icon":"GuitarPic_BuzzardAutogyro_42.png",
         "bkgd":"Bubble.png"
      }];
      
      public function WarRoomDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function showDialog() : void
      {
         SurvivalModeManager.instance.launchSurvivalMode(SurvivalModeManager.ENTRY_POINT_BUILDING);
      }
      
      override protected function getSetStateReferenceItemName() : String
      {
         var _loc1_:GameItem = ZGlobal.gameSettings.getItemByName(stateMachine.referenceItemName,GameItem) as GameItem;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByName(stateMachine.researchItemName,GameItem) as GameItem;
         return _loc1_.code + ":" + _loc2_.code;
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         SurvivalModeManager.eventDispatcher.addEventListener(SurvivalModeManager.EVENT_UPDATE_HQ_UI,this.onSurvivalStateUpdated);
      }
      
      override protected function performExitActions(param1:IMachine) : void
      {
         this.removeListener();
         super.performExitActions(param1);
      }
      
      override public function stop() : void
      {
         this.removeListener();
         super.stop();
      }
      
      private function get overlayEnabled() : Boolean
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SURVIVALMODE_ENHANCEMENTS) == ExperimentsManager.VARIANT_SURVIVALMODE_ENHANCEMENTS_ENABLED)
         {
            return true;
         }
         return SurvivalModeManager.instance.isInSurvivalMode3Battle;
      }
      
      private function get overlayXML() : XML
      {
         var _loc1_:int = 0;
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:XML = null;
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SURVIVAL_ELITE) == ExperimentsManager.VARIANT_EXPERIMENT_SURVIVAL_ELITE_ON)
         {
            if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SURVIVALMODE_ENHANCEMENTS) == ExperimentsManager.VARIANT_SURVIVALMODE_ENHANCEMENTS_ENABLED)
            {
               _loc1_ = this.OVERLAY_STATE_ACTIVE;
            }
            else
            {
               _loc1_ = SurvivalModeManager.instance.isInBattle ? this.OVERLAY_STATE_ACTIVE : this.OVERLAY_STATE_INACTIVE_ELITE;
            }
            _loc2_ = this.m_overlayIcons[_loc1_].icon;
            _loc3_ = this.m_overlayIcons[_loc1_].bkgd;
            return <data icon={_loc2_} background={_loc3_} backgroundOffset="-25,-180" iconOffset="4,2"/>;
         }
         if(this.overlayEnabled)
         {
            _loc1_ = SurvivalModeManager.instance.isInBattle ? this.OVERLAY_STATE_ACTIVE : this.OVERLAY_STATE_INACTIVE;
            _loc2_ = this.m_overlayIcons[_loc1_].icon;
            _loc3_ = this.m_overlayIcons[_loc1_].bkgd;
            return <data icon={_loc2_} background={_loc3_} backgroundOffset="-25,-180" iconOffset="4,2"/>;
         }
         return null;
      }
      
      private function onSurvivalStateUpdated(param1:WorldEvent) : void
      {
         this.updateOverlay();
      }
      
      private function removeListener() : void
      {
         SurvivalModeManager.eventDispatcher.removeEventListener(SurvivalModeManager.EVENT_UPDATE_HQ_UI,this.onSurvivalStateUpdated);
      }
      
      override protected function updateOverlay() : void
      {
         var _loc1_:XML = null;
         if(this.overlayEnabled && !ZGlobal.isVisiting())
         {
            _loc1_ = this.overlayXML;
            if(_loc1_)
            {
               owner.setProperty(overlayDataProperty,{"xml":_loc1_});
            }
         }
         else
         {
            removeOverlay();
         }
      }
   }
}

