package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import core.managers.MegaseriesManager;
   import core.player.Megaseries;
   import displays.popups.MegaseriesPlayAgain;
   import displays.popups.megaseries.MegaseriesDetailsPopup;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class QuestCompletionState extends DialogState
   {
      
      public static const QUEST_COMPLETE:String = "questcomplete";
      
      private var m_eventParam:String;
      
      public function QuestCompletionState(param1:BehaviorStateInit)
      {
         super(param1);
         this.m_eventParam = m_data.@clickEventParam.toString();
      }
      
      override public function enter(param1:IMachine) : void
      {
         super.enter(param1);
         var _loc2_:GameItem = stateMachine.propertyBag.getProperty(dataProperty,null);
         if(ZGlobal.isVisiting() || ExperimentsManager.instance.getExperimentVariant(this.getMSExperiment(_loc2_.megaseries)) != this.getMSRequiredVariant(_loc2_.megaseries))
         {
            owner.destroy();
            return;
         }
         stateMachine.propertyBag.eventDispatcher.addEventListener(QUEST_COMPLETE,this.onQuestCompletion,false,0,true);
         if(MegaseriesManager.instance.getMegaseries(_loc2_.megaseries) != null)
         {
            if(!MegaseriesManager.instance.getMegaseries(_loc2_.megaseries).checkStageInSyncWithStateMachine(this.stateMachine.currentStateName))
            {
               clickNextState();
            }
         }
         if(MegaseriesManager.instance.getMegaseries(_loc2_.megaseries) != null)
         {
            MegaseriesManager.instance.getMegaseries(_loc2_.megaseries).registerEntryPointEventDispatcher(stateMachine);
         }
      }
      
      private function getMSExperiment(param1:String) : String
      {
         if(MegaseriesManager.instance.getMegaseries(param1) != null)
         {
            return MegaseriesManager.instance.getMegaseries(param1).EXPERIMENT_MEGASERIES_MASTER;
         }
         return null;
      }
      
      private function getMSRequiredVariant(param1:String) : int
      {
         if(MegaseriesManager.instance.getMegaseries(param1) != null)
         {
            return MegaseriesManager.instance.getMegaseries(param1).EXPERIMENT_MEGASERIES_MASTER_VARIANT;
         }
         return -1;
      }
      
      private function onQuestCompletion(param1:WorldEvent) : void
      {
         stateMachine.propertyBag.eventDispatcher.removeEventListener(QUEST_COMPLETE,this.onQuestCompletion);
         var _loc2_:GameItem = stateMachine.propertyBag.getProperty(dataProperty,null);
         MegaseriesManager.instance.getMegaseries(_loc2_.megaseries).setPopupSeenFlag();
         clickNextState();
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:GameItem = stateMachine.propertyBag.getProperty(dataProperty,null);
         var _loc2_:Megaseries = MegaseriesManager.instance.getMegaseries(_loc1_.megaseries);
         if(MegaseriesManager.instance.getActiveQuest(_loc1_.megaseries) == _loc2_.msRewardQuest && _loc2_.stateMachineName == MegaseriesManager.MEGASERIES_STATEMACHINE_NAME && _loc2_.playAgainPopupSeen)
         {
            PopupManager.instance.push(new MegaseriesPlayAgain(_loc1_.megaseries));
         }
         else
         {
            MegaseriesDetailsPopup.show(MegaseriesManager.instance.getActiveQuest(_loc1_.megaseries),_loc1_.megaseries);
         }
      }
   }
}

