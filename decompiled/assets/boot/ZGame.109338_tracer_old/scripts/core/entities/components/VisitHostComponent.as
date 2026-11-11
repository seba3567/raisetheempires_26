package core.entities.components
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.entities.components.utils.ServerTimeProgressionHelper;
   import core.entities.components.utils.YieldHelper;
   import core.gameobjects.GameItem;
   import core.managers.CrewManager;
   import core.managers.visitorManager.VisitorManager;
   import core.ui.PlayerFeedbackManager;
   import dispatchers.StrategicDispatcher;
   import entity.GameDataComponent;
   import events.ProgressBarEvent;
   import events.UnitEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.SoundEvent;
   import transactions.TVisitorHelp;
   import utils.ZGameRandom;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.core.ITickedObject;
   import zlabs.entity.EntityComponent;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   
   public class VisitHostComponent extends EntityComponent
   {
      
      private const MAX_ACTIONS:int = 1;
      
      private var m_id:int = 0;
      
      private var m_actions:int = 0;
      
      private var m_updateHelper:ITickedObject = null;
      
      private var m_dataProperty:PropertyReference = new PropertyReference("@Data.gameData");
      
      private var m_prevHelpType:String;
      
      private var m_activeTargets:Array = null;
      
      private var m_gameItem:GameItem;
      
      private var m_fsmc:BuildingFSMComponent;
      
      private var m_sm:BehaviorStateMachine;
      
      public function VisitHostComponent(param1:int)
      {
         super();
         this.m_id = param1;
         if(!VisitorManager.instance.isObjectIDTendable(this.m_id))
         {
            this.m_actions = this.MAX_ACTIONS;
            this.m_prevHelpType = VisitorManager.VISITOR_HELP_TAX;
         }
      }
      
      public function get gameItem() : GameItem
      {
         var _loc1_:GameDataComponent = null;
         if(!this.m_gameItem)
         {
            _loc1_ = GameDataComponent.getGameDataComponent(owner);
            this.m_gameItem = _loc1_.gameData;
         }
         return this.m_gameItem;
      }
      
      public function get fsmc() : BuildingFSMComponent
      {
         if(!this.m_fsmc)
         {
            this.m_fsmc = BuildingFSMComponent(owner.lookupComponentByType(BuildingFSMComponent));
         }
         return this.m_fsmc;
      }
      
      public function get sm() : BehaviorStateMachine
      {
         if(!this.m_sm && Boolean(this.fsmc))
         {
            this.m_sm = this.fsmc.stateMachine as BehaviorStateMachine;
         }
         return this.m_sm;
      }
      
      public function get helpLimitReached() : Boolean
      {
         return this.m_actions >= this.MAX_ACTIONS;
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         this.m_activeTargets = new Array();
         owner.eventDispatcher.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
      }
      
      override protected function onRemove() : void
      {
         var _loc1_:IEntity = null;
         for each(_loc1_ in this.m_activeTargets)
         {
            _loc1_.eventDispatcher.removeEventListener(UnitEvent.ACTION_COMPLETE,this.onTargetActionComplete);
         }
         this.m_activeTargets = null;
         super.onRemove();
         owner.eventDispatcher.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         this.updateHelper = null;
      }
      
      protected function onProgress(param1:Number) : void
      {
         var _loc2_:String = Math.floor(param1 * 100).toString();
         var _loc3_:ProgressBarEvent = new ProgressBarEvent(ProgressBarEvent.UPDATE_PROGRESS);
         var _loc4_:Object = this.getTendProgressBarLabel(this.m_prevHelpType);
         _loc3_.message = "";
         if(_loc4_)
         {
            _loc3_.message = ZGameUtils.ZlocT(_loc4_.pack,_loc4_.label,{"percent":_loc2_});
         }
         _loc3_.timeRemaining = _loc2_;
         _loc3_.isPercent = true;
         _loc3_.progress = param1;
         owner.eventDispatcher.dispatchEvent(_loc3_);
      }
      
      protected function onProgressComplete() : void
      {
         var _loc1_:XML = null;
         var _loc2_:YieldHelper = null;
         var _loc3_:Number = NaN;
         owner.eventDispatcher.dispatchEvent(new ProgressBarEvent(ProgressBarEvent.STOP_PROGRESS_BAR));
         if(this.sm)
         {
            switch(this.m_prevHelpType)
            {
               case VisitorManager.VISITOR_HELP_SPEEDUP:
                  _loc1_ = VisitorManager.getRewardXML(VisitorManager.VISITOR_HELP_SPEEDUP);
                  break;
               case VisitorManager.VISITOR_HELP_CREW_TAX_MATURING:
                  _loc1_ = VisitorManager.getRewardXML(CrewManager.getCrewRewardLabel(owner));
            }
            if(_loc1_)
            {
               _loc2_ = new YieldHelper();
               _loc2_.initFromData(_loc1_);
               _loc3_ = ZGameRandom.rewardInstance.float();
               _loc2_.saveRandomFloat(_loc3_);
               _loc2_.execute(this.sm,_loc1_);
            }
            if(this.sm.currentState as BehaviorState)
            {
               (this.sm.currentState as BehaviorState).onVisitHelpSuccess();
            }
            this.turnOffActionHint(owner);
         }
      }
      
      protected function performHelp() : void
      {
         ++this.m_actions;
         var _loc1_:BehaviorState = this.sm.currentState as BehaviorState;
         this.sm.propertyBag.eventDispatcher.dispatchEvent(new WorldEvent(UIControllerComponent.EVENT_SPRITE_EFFECT,UIControllerComponent.SPRITE_EFFECT_SELECTED_ON));
         if(_loc1_.visitorHelpType == VisitorManager.VISITOR_HELP_SPEEDUP)
         {
            this.startTendFeedback(VisitorManager.VISITOR_HELP_SPEEDUP);
         }
         if(_loc1_.visitorHelpType == VisitorManager.VISITOR_HELP_CREW_TAX_MATURING)
         {
            this.startTendFeedback(VisitorManager.VISITOR_HELP_CREW_TAX_MATURING);
         }
         else
         {
            this.sm.propertyBag.eventDispatcher.addEventListener(UnitEvent.ACTION_COMPLETE,this.onTargetActionComplete);
            this.m_activeTargets.push(this.sm.propertyBag);
            this.sm.performVisitorHelpRequest();
         }
         this.m_prevHelpType = _loc1_.visitorHelpType;
         var _loc2_:GameItem = owner.getProperty(this.m_dataProperty,null) as GameItem;
         TransactionManager.addTransaction(new TVisitorHelp(ZGlobal.hostPlayer.uid,this.m_id,_loc1_.visitorHelpType,owner,this.sm.referenceItemName));
         ZGlobal.player.visitorEnergySpent();
         var _loc3_:Object = {};
         _loc3_.gameItem = _loc2_;
         _loc3_.visitorHelpType = _loc1_.visitorHelpType;
         StrategicDispatcher.instance.dispatchEvent(new WorldEvent(StrategicDispatcher.ALLY_TEND,_loc3_));
      }
      
      private function onTargetActionComplete(param1:UnitEvent) : void
      {
         var _loc2_:IEntity = param1.eventData as IEntity;
         _loc2_.eventDispatcher.removeEventListener(UnitEvent.ACTION_COMPLETE,this.onTargetActionComplete);
         this.turnOffActionHint(_loc2_);
      }
      
      private function turnOffActionHint(param1:IEntity) : void
      {
         param1.eventDispatcher.dispatchEvent(new WorldEvent(UIControllerComponent.EVENT_SPRITE_EFFECT,UIControllerComponent.SPRITE_EFFECT_SELECTED_OFF));
      }
      
      private function doAlreadyTendedFeedback() : void
      {
         var _loc2_:String = null;
         var _loc1_:BehaviorState = this.sm.currentState as BehaviorState;
         if(Boolean(_loc1_) && Boolean(this.m_prevHelpType))
         {
            switch(this.m_prevHelpType)
            {
               case VisitorManager.VISITOR_HELP_REVIVE:
               case VisitorManager.VISITOR_HELP_TAX:
               case VisitorManager.VISITOR_HELP_CREW_TAX:
               case VisitorManager.VISITOR_HELP_SPEEDUP:
               case VisitorManager.VISITOR_HELP_BUILD:
                  _loc2_ = ZGameUtils.ZlocT("VisitorHelp","VisitorHelpRepeat_" + this.m_prevHelpType);
                  PlayerFeedbackManager.instance.displayFeedback(_loc2_,owner);
            }
         }
      }
      
      protected function onHelpLimitReached() : void
      {
         this.doAlreadyTendedFeedback();
      }
      
      protected function canOwnerBeHelped() : Object
      {
         if(this.sm)
         {
            return this.sm.canVisitorHelp();
         }
         return false;
      }
      
      protected function onHandleHelp(param1:IEntity, param2:Boolean) : Boolean
      {
         return true;
      }
      
      protected function handleHelp() : Boolean
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         if(!this.canOwnerBeHelped())
         {
            return false;
         }
         if(ZGlobal.player.visitorEnergy > 0)
         {
            if(this.helpLimitReached)
            {
               this.onHelpLimitReached();
            }
            else if(Boolean(this.fsmc) && this.onHandleHelp(owner,this.fsmc.isBuilt))
            {
               this.performHelp();
            }
         }
         else
         {
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackNoMoreWork"),owner);
         }
         return true;
      }
      
      private function onMouseUp(param1:Event) : void
      {
         if(this.handleHelp())
         {
            param1.stopImmediatePropagation();
            param1.stopPropagation();
         }
      }
      
      private function set updateHelper(param1:ITickedObject) : void
      {
         if(this.m_updateHelper)
         {
            Zlab.processManager.removeTickedObject(this.m_updateHelper);
         }
         this.m_updateHelper = param1;
         if(this.m_updateHelper)
         {
            Zlab.processManager.addTickedObject(this.m_updateHelper);
         }
      }
      
      private function getTendDurationLabel(param1:String) : String
      {
         switch(param1)
         {
            case VisitorManager.VISITOR_HELP_SPEEDUP:
               return "friendVisitSpeedupActionDuration";
            case VisitorManager.VISITOR_HELP_CREW_TAX_MATURING:
               return "friendVisitCrewTaxMaturingActionDuration";
            default:
               return null;
         }
      }
      
      private function getTendClickSound(param1:String) : String
      {
         switch(param1)
         {
            case VisitorManager.VISITOR_HELP_SPEEDUP:
               return "StartResearch";
            case VisitorManager.VISITOR_HELP_CREW_TAX_MATURING:
               return "money";
            default:
               return null;
         }
      }
      
      private function getTendProgressBarLabel(param1:String) : Object
      {
         switch(param1)
         {
            case VisitorManager.VISITOR_HELP_SPEEDUP:
               return {
                  "pack":"VisitorHelp",
                  "label":"VisitorHelpSpeedupProgressBarText"
               };
            case VisitorManager.VISITOR_HELP_CREW_TAX_MATURING:
               return {
                  "pack":"Main",
                  "label":"CollectingTaxesMessage"
               };
            default:
               return null;
         }
      }
      
      private function startTendFeedback(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc2_:String = this.getTendDurationLabel(param1);
         if(_loc2_)
         {
            _loc3_ = this.getTendClickSound(param1);
            if(_loc3_)
            {
               SoundEvent.getSoundEvent(_loc3_).play();
            }
            _loc4_ = ZGlobal.gameSettings.getNumber(_loc2_);
            this.updateHelper = new ServerTimeProgressionHelper(0,_loc4_,this.onProgressComplete,this.onProgress);
            owner.eventDispatcher.dispatchEvent(new ProgressBarEvent(ProgressBarEvent.START_PROGRESS_BAR));
         }
      }
   }
}

