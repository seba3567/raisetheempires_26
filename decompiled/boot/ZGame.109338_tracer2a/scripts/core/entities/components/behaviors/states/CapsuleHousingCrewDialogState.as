package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.managers.CapsuleHousingManager;
   import core.managers.CrewManager;
   import displays.popups.SpeechPopup;
   import displays.screens.CapsuleHousingCrewGather;
   import displays.screens.CrewResizablePopUp;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class CapsuleHousingCrewDialogState extends CrewDialogState
   {
      
      private static const QUEST_ID:String = "QBB35_02";
      
      protected static const MAX_WORKERS:int = 400;
      
      protected var m_capsuleCrewGather:CapsuleHousingCrewGather = null;
      
      protected var m_currentWorkers:int;
      
      protected var m_currentWorkersCap:int;
      
      protected var m_workersInc:int;
      
      protected var m_workersCapInc:int;
      
      public function CapsuleHousingCrewDialogState(param1:BehaviorStateInit, param2:Boolean = false)
      {
         super(param1,param2);
         this.m_workersInc = this.workersIncrement;
         this.m_workersCapInc = this.workersCapIncrement;
         this.m_currentWorkers = this.currentWorkers;
         this.m_currentWorkersCap = this.currentWorkersCap;
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         var _loc1_:Object = CrewManager.getCrewInfo(owner,null,true);
         if(Boolean(_loc1_) && Boolean(_loc1_.crew))
         {
            m_crewInfo = _loc1_.crew;
         }
         if(this.isCrewAdded())
         {
            this.clickNextState();
         }
         else if(ZGlobal.isVisiting())
         {
            CapsuleHousingManager.visitInstance.initWorkers(this.m_currentWorkers,this.m_currentWorkersCap);
         }
         else
         {
            CapsuleHousingManager.instance.initWorkers(this.m_currentWorkers,this.m_currentWorkersCap);
         }
      }
      
      override protected function showCrewDialog() : void
      {
         if(Boolean(m_wrapper) && ZGlobal.isHome())
         {
            this.m_capsuleCrewGather = this.createCapsulePopup(stateMachine.propertyBag as IEntity);
            m_window = this.m_capsuleCrewGather;
            m_window.addEventListener(CrewResizablePopUp.BUILT,this.onBuy,false,0,true);
            m_window.addEventListener(CrewResizablePopUp.CLOSED,this.onClosed,false,0,true);
            WindowManager.instance.push(m_window);
         }
      }
      
      private function isCrewAdded() : Boolean
      {
         var _loc1_:int = this.getNumCrew();
         return _loc1_ * this.m_workersInc > this.m_currentWorkers;
      }
      
      private function getNumCrew() : int
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         if(m_crewInfo)
         {
            _loc2_ = 0;
            while(_loc2_ < m_crewInfo.length)
            {
               if(m_crewInfo[_loc2_] != null)
               {
                  _loc1_++;
               }
               _loc2_++;
            }
         }
         return _loc1_;
      }
      
      private function get workersIncrement() : int
      {
         return m_data.@workersInc != undefined ? int(parseInt(m_data.@workersInc)) : 0;
      }
      
      private function get workersCapIncrement() : int
      {
         return m_data.@workersCapInc != undefined ? int(parseInt(m_data.@workersCapInc)) : 0;
      }
      
      protected function get currentWorkers() : int
      {
         return m_data.@currentWorkers != undefined ? int(parseInt(m_data.@currentWorkers)) : 0;
      }
      
      protected function get currentWorkersCap() : int
      {
         return m_data.@currentWorkers != undefined ? int(parseInt(m_data.@currentWorkersCap)) : 0;
      }
      
      override public function sell() : void
      {
         CapsuleHousingManager.instance.sell();
         super.sell();
      }
      
      override protected function onClosed(param1:Event) : void
      {
         this.disposeWindow();
      }
      
      private function disposeWindow() : void
      {
         if(m_window)
         {
            m_window.removeEventListener(CrewResizablePopUp.BUILT,this.onBuy);
            m_window.removeEventListener(CrewResizablePopUp.CLOSED,this.onClosed);
            m_window = null;
            this.m_capsuleCrewGather = null;
         }
      }
      
      private function onBuy(param1:Event) : void
      {
      }
      
      protected function createCapsulePopup(param1:IEntity) : CapsuleHousingCrewGather
      {
         return new CapsuleHousingCrewGather(param1,m_wrapper,m_item,QUEST_ID,m_crewInfo,this.textInfo,m_data.@crewBackgroundSWF);
      }
      
      override protected function get textInfo() : Object
      {
         return {
            "title":m_data.@title,
            "desc":m_data.@description,
            "button":{
               "hire":m_data.@buttonHire,
               "finish":m_data.@buttonFinish
            }
         };
      }
      
      override protected function onCrewUpdated(param1:WorldEvent) : void
      {
         super.onCrewUpdated(param1);
         if(this.isCrewAdded())
         {
            if(this.m_capsuleCrewGather)
            {
               this.m_capsuleCrewGather.closeCrewGather();
            }
            if(ZGlobal.isHome())
            {
               PopupManager.instance.push(new SpeechPopup("Speech_Capsule_Housing_02",this.onSpeechPopupClosed,SpeechPopup.EXIT_TEXT_OK),0,true,false);
            }
         }
      }
      
      override public function onMouseOver(param1:MouseEvent) : void
      {
         if(ZGlobal.isHome())
         {
            startProgressBar();
         }
      }
      
      override public function onMouseOut(param1:MouseEvent) : void
      {
         stopProgressBar();
         stateMachine.propertyBag.eventDispatcher.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         stateMachine.propertyBag.eventDispatcher.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
      }
      
      override protected function shouldShowOverlay() : Object
      {
         if(isVisitable())
         {
            return {
               "show":true,
               "data":m_data
            };
         }
         if(!ZGlobal.isVisiting())
         {
            return {
               "show":true,
               "data":m_data
            };
         }
         return {"show":false};
      }
      
      private function onSpeechPopupClosed(param1:Event) : void
      {
         this.clickNextState();
      }
      
      override public function clickNextState() : void
      {
         if(getClickNextStateIndex())
         {
            if(this.m_capsuleCrewGather)
            {
               this.m_capsuleCrewGather.closeCrewGather();
            }
            if(this.m_workersInc > 0 || this.m_workersCapInc > 0)
            {
               if(ZGlobal.isVisiting())
               {
                  CapsuleHousingManager.visitInstance.updateWorkers(this.m_workersInc,this.m_workersCapInc);
               }
               else
               {
                  CapsuleHousingManager.instance.updateWorkers(this.m_workersInc,this.m_workersCapInc);
               }
            }
            super.clickNextState();
         }
      }
   }
}

