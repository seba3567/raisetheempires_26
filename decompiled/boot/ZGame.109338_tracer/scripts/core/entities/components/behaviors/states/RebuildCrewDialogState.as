package core.entities.components.behaviors.states
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.managers.CrewManager;
   import core.managers.mayhemManager.MayhemManager;
   import core.ui.components.PortraitSlidePick.PortraitPick;
   import displays.screens.RebuildCrewGatherOwnerPartial;
   import transactions.TResetParliamentDestroyed;
   import utils.ZGameTime;
   import zlabs.debug.Logger;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class RebuildCrewDialogState extends CrewDialogState
   {
      
      protected var m_oldCrewInfo:Array;
      
      protected var m_actualDurationSeconds:ZGameTime;
      
      private var m_autoFilledCrewPick:PortraitPick;
      
      public function RebuildCrewDialogState(param1:BehaviorStateInit)
      {
         super(param1,true);
         this.m_actualDurationSeconds = m_durationSeconds;
         m_durationSeconds = new ZGameTime(this.getEffectiveDuration());
         Logger.print(this,"JMR: adjustedDuration: " + adjustedDuration);
         this.m_oldCrewInfo = null;
         if(param1.m_gameObject)
         {
            this.m_oldCrewInfo = param1.m_gameObject.oldCrewInfo ? param1.m_gameObject.oldCrewInfo : null;
         }
         if(!this.m_oldCrewInfo)
         {
            this.m_oldCrewInfo = new Array();
         }
      }
      
      override protected function performEnterActions() : void
      {
         if(m_crewInfo.length > 0 && this.m_oldCrewInfo.length == 0)
         {
            this.m_oldCrewInfo = m_crewInfo;
            m_crewInfo = [];
         }
         super.performEnterActions();
      }
      
      override protected function performExitActions(param1:IMachine) : void
      {
         this.m_oldCrewInfo = [];
         m_crewInfo = m_crewInfo;
         MayhemManager.instance.isParliamentDestroyed = false;
         super.performExitActions(param1);
      }
      
      override protected function updateOverrides(param1:XML) : void
      {
         super.updateOverrides(param1);
         this.m_actualDurationSeconds = m_durationSeconds;
         m_durationSeconds = new ZGameTime(this.getEffectiveDuration());
      }
      
      override protected function get textInfo() : Object
      {
         return {
            "title":"RebuildCrewDialogTitle",
            "desc":"RebuildCrewDialogDesc"
         };
      }
      
      override protected function createPopup(param1:IEntity) : PopUpBase
      {
         Logger.print(this,"JMR: RebuildCrewDialogState createPopup called");
         Logger.print(this,"JMR: adjustedDuration: " + adjustedDuration);
         Logger.print(this,"JMR: creating RebuildCrewGatherOwnerPartial");
         return new RebuildCrewGatherOwnerPartial(param1,m_wrapper,m_item,m_crewInfo,this.textInfo,this,m_data.@crewBackgroundSWF);
      }
      
      protected function doCrewRestore() : void
      {
         m_crewInfo = this.m_oldCrewInfo;
         this.m_oldCrewInfo = [];
      }
      
      override protected function onCrewUpdated(param1:WorldEvent) : void
      {
         performRebuildSpeedup();
         super.onCrewUpdated(param1);
         m_startTime = updateHelper.startTime;
         m_durationSeconds = new ZGameTime(this.getEffectiveDuration());
         startProgressTimer();
      }
      
      override protected function onProgressComplete() : void
      {
         var _loc1_:TResetParliamentDestroyed = null;
         if(!ZGlobal.isVisiting())
         {
            super.onProgressComplete();
            Logger.print(this,"JMR: creating time is up!!!!!");
            if(!this.emptyCrew)
            {
               Logger.print(this,"JMR 1. onProgressComplete clickNextState");
               clickNextState();
            }
            else
            {
               Logger.print(this,"JMR 2. onProgressComplete resetParliament");
               MayhemManager.instance.resetParliament();
            }
            _loc1_ = new TResetParliamentDestroyed();
            TransactionManager.addTransaction(_loc1_);
            CrewManager.restoreOldCrewInfo(stateMachine.propertyBag as IEntity);
            if(this.isDialogVisible())
            {
               Logger.print(this,"I am inside the condition");
               (m_window as RebuildCrewGatherOwnerPartial).onDurationComplete();
            }
         }
      }
      
      private function get emptyCrew() : Number
      {
         var _loc1_:Number = 0;
         var _loc2_:Number = 0;
         while(_loc2_ < m_crewInfo.length)
         {
            if(m_crewInfo[_loc2_] == null)
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      override protected function onProgress(param1:Number) : void
      {
         super.onProgress(param1);
         if(this.isDialogVisible())
         {
            (m_window as RebuildCrewGatherOwnerPartial).onDurationProgress(param1,m_durationSeconds.absolute,this.m_actualDurationSeconds.absolute);
         }
      }
      
      protected function getEffectiveDuration() : Number
      {
         return this.m_actualDurationSeconds.absolute;
      }
      
      protected function isDialogVisible() : Boolean
      {
         return m_window != null && m_window is RebuildCrewGatherOwnerPartial;
      }
   }
}

