package core.entities.components.behaviors.states
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IInput;
   import core.entities.components.states.IState;
   import core.entities.components.utils.ServerTimeProgressionHelper;
   import core.gameobjects.GameItem;
   import core.managers.PopulationManager;
   import core.managers.visitorManager.VisitorManager;
   import displays.popups.RequirementsPopup;
   import displays.popups.RequirementsPopupInfoPopCap;
   import flash.events.Event;
   import sound.StateSound;
   import transactions.TVisitorHelpRedeem;
   import utils.ZGameTimeUtil;
   import zlabs.entity.IEntity;
   import zlabs.managers.PopupManager;
   
   public class SimpleClickState extends BehaviorState implements IInput
   {
      
      private var m_actionDurationSeconds:Number = 0;
      
      public function SimpleClickState(param1:BehaviorStateInit)
      {
         super(param1);
         if(m_data.@actionDuration != undefined)
         {
            this.m_actionDurationSeconds = ZGameTimeUtil.instance.parseTimeAsSeconds(m_data.@actionDuration.toString(),this.m_actionDurationSeconds);
         }
      }
      
      public function onRollOver(param1:Event) : void
      {
      }
      
      private function shouldCheckWorkers() : Boolean
      {
         var _loc1_:GameItem = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
         if(_loc1_.name == "avatar" || _loc1_.name == "visitorAvatar")
         {
            return false;
         }
         if(ZGlobal.isVisiting())
         {
            return false;
         }
         if(!_loc1_.workers || !_loc1_.workers.length)
         {
            return false;
         }
         var _loc2_:String = this.getClickEndState(getClickNextStateIndex());
         var _loc3_:BehaviorState = stateMachine.getState(_loc2_) as BehaviorState;
         if(this.isBuilt() || !_loc3_.isBuilt())
         {
            return false;
         }
         return true;
      }
      
      private function getClickEndState(param1:String) : String
      {
         if(!param1)
         {
            return name;
         }
         var _loc2_:BehaviorState = stateMachine.getState(param1) as BehaviorState;
         if(_loc2_)
         {
            if(_loc2_.getClickNextStateIndex())
            {
               return _loc2_.name;
            }
            if(_loc2_.getAutoNextStateIndex())
            {
               return this.getClickEndState(_loc2_.getAutoNextStateIndex());
            }
         }
         return name;
      }
      
      public function onClick(param1:Event) : void
      {
         var _loc2_:IState = null;
         var _loc3_:RequirementsPopupInfoPopCap = null;
         if(checkRequirements())
         {
            if(this.shouldCheckWorkers() && !this.checkWorkers())
            {
               _loc2_ = getOverridenCheckState();
               BehaviorState(_loc2_).dispatchActionCompleteEvent(stateMachine);
               _loc3_ = new RequirementsPopupInfoPopCap(false);
               PopupManager.instance.push(new RequirementsPopup(_loc3_));
            }
            else
            {
               this.handleClick();
            }
         }
      }
      
      protected function handleClick() : void
      {
         this.clicked();
      }
      
      override public function canRedeemHelp() : Boolean
      {
         if(!super.canRedeemHelp())
         {
            return false;
         }
         if(this.shouldCheckWorkers() && !this.checkWorkers())
         {
            return false;
         }
         return true;
      }
      
      override public function onVisitorHelped() : void
      {
         switch(visitorHelpType)
         {
            case VisitorManager.VISITOR_HELP_BUILD:
            case VisitorManager.VISITOR_HELP_CLEAR:
            case VisitorManager.VISITOR_HELP_HARVEST:
            case VisitorManager.VISITOR_HELP_REVIVE:
            case VisitorManager.VISITOR_HELP_MINE:
            case VisitorManager.VISITOR_HELP_TAX:
            case VisitorManager.VISITOR_HELP_CAPSULE_TAX:
            case VisitorManager.VISITOR_HELP_CREW_TAX:
               this.onClick(null);
               return;
            default:
               super.onVisitorHelped();
               return;
         }
      }
      
      override public function onMultiHarvested() : void
      {
         this.onClick(null);
      }
      
      override public function onVisitorHelpRedeemed(param1:IEntity, param2:String) : void
      {
         var _loc3_:TVisitorHelpRedeem = null;
         switch(visitorHelpType)
         {
            case VisitorManager.VISITOR_HELP_BUILD:
            case VisitorManager.VISITOR_HELP_CLEAR:
            case VisitorManager.VISITOR_HELP_HARVEST:
            case VisitorManager.VISITOR_HELP_REVIVE:
            case VisitorManager.VISITOR_HELP_MINE:
            case VisitorManager.VISITOR_HELP_TAX:
            case VisitorManager.VISITOR_HELP_CAPSULE_TAX:
            case VisitorManager.VISITOR_HELP_CREW_TAX:
               this.onClick(null);
               _loc3_ = new TVisitorHelpRedeem(param1,param2);
               _loc3_.stateMachine = stateMachine;
               TransactionManager.addTransaction(_loc3_,true);
               return;
            default:
               super.onVisitorHelpRedeemed(param1,param2);
               return;
         }
      }
      
      private function checkWorkers() : Boolean
      {
         var _loc1_:GameItem = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
         var _loc2_:String = _loc1_.workers;
         var _loc3_:int = _loc2_.length ? int(parseInt(_loc2_)) : 0;
         var _loc4_:int = PopulationManager.instance.maxWorkers + _loc3_;
         var _loc5_:int = PopulationManager.instance.maxWorkersCap;
         if(_loc4_ > _loc5_)
         {
            return false;
         }
         return true;
      }
      
      protected function clicked() : void
      {
         playSoundEvent(StateSound.ON_CLICK);
         if(this.m_actionDurationSeconds)
         {
            setUpdateHelper(new ServerTimeProgressionHelper(0,this.m_actionDurationSeconds,this.onActionCompleted,this.onActionProgressing));
            startProgressBar();
         }
         else
         {
            clickNextState();
         }
      }
      
      protected function onActionCompleted() : void
      {
         stopProgressBar();
         clickNextState();
      }
      
      protected function onActionProgressing(param1:Number) : void
      {
         updateProgressBar(param1);
      }
   }
}

