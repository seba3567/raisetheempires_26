package core.entities.components.behaviors.states
{
   import Engine.Managers.TransactionManager;
   import ZLocalization.LocalizationObjectToken;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.gameobjects.GameItem;
   import core.gameobjects.SpeedupItem;
   import core.gameobjects.UpgradeItem;
   import core.managers.viralsManager.ViralsManager;
   import core.player.Player;
   import dispatchers.MessageDispatcher;
   import dispatchers.ResearchDispatcher;
   import displays.popups.GenericPopup;
   import displays.screens.SpeedupScreen;
   import displays.screens.SuperOreScreen;
   import entity.GameDataComponent;
   import events.CloseEvent;
   import events.ResearchUpdatedEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import transactions.TSetState;
   import transactions.TSpeedup;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class AutoDialogState extends DialogState
   {
      
      protected var m_cancelNextStateIndex:String;
      
      public function AutoDialogState(param1:BehaviorStateInit)
      {
         super(param1);
         if(m_data.@cancelNext.toString().length > 0)
         {
            this.m_cancelNextStateIndex = m_data.@cancelNext.toString();
         }
      }
      
      override protected function performEnterActions() : void
      {
         MessageDispatcher.instance.addEventListener(MessageDispatcher.SPEEDUP,this.onSpeedupReceived,false,0,true);
         ResearchDispatcher.instance.addEventListener(ResearchUpdatedEvent.DURATION_UPGRADE_ADDED,this.onResearchUpdated,false,0,true);
         super.performEnterActions();
      }
      
      override protected function performExitActions(param1:IMachine) : void
      {
         this.removeListeners();
         super.performExitActions(param1);
      }
      
      override protected function getQualifiedDialogClassName() : String
      {
         return null;
      }
      
      protected function onResearchUpdated(param1:ResearchUpdatedEvent) : void
      {
         var _loc3_:UpgradeItem = null;
         var _loc2_:GameItem = GameItem(ZGlobal.gameSettings.getItemByCode(param1.itemCode,GameItem));
         if(Boolean(_loc2_) && stateMachine.referenceItemName == _loc2_.name)
         {
            _loc3_ = UpgradeItem(ZGlobal.gameSettings.getItemByCode(param1.upgradeCode,UpgradeItem));
            if(_loc3_)
            {
               stopProgressBar();
               updateHelper.setProgress(updateHelper.currentProgress + _loc3_.durationModifier / 100);
               startProgressTimer();
            }
         }
      }
      
      protected function onSpeedupReceived(param1:WorldEvent) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:String = null;
         var _loc5_:GameDataComponent = null;
         var _loc6_:String = null;
         var _loc7_:Player = null;
         var _loc8_:Number = NaN;
         var _loc2_:Object = stateMachine.propertyBag.getProperty(userDataProperty,null);
         if(param1.eventData.target == _loc2_.id)
         {
            _loc3_ = m_durationSeconds.absolute * (param1.eventData.percent / 100);
            _loc3_ = Math.ceil(_loc3_);
            _loc4_ = ZGameTimeUtil.instance.getTimeString(_loc3_);
            _loc5_ = GameDataComponent(IEntity(stateMachine.propertyBag).lookupComponentByType(GameDataComponent));
            _loc6_ = _loc5_.gameData.isResearchItem() ? "UpgradeSpeedupReceived" : "ContractSpeedupReceived";
            _loc7_ = ZGlobal.player.findFriendById(param1.eventData.visitor);
            if(_loc7_)
            {
               PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs",_loc6_,{
                  "user":_loc7_.snUser.firstName,
                  "time":_loc4_
               }),GenericPopup.TYPE_OK));
            }
            _loc8_ = updateHelper.currentProgress + _loc3_ / m_durationSeconds.absolute;
            updateHelper.setProgress(_loc8_);
         }
      }
      
      public function showSpeedupScreen() : void
      {
         this.showDialog();
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:GameItem = null;
         if(!m_window)
         {
            stateMachine.propertyBag.eventDispatcher.addEventListener(SpeedupScreen.EXIT,this.onExit,false,0,true);
            stateMachine.propertyBag.eventDispatcher.addEventListener(SpeedupScreen.CANCEL,this.onCancel,false,0,true);
            stateMachine.propertyBag.eventDispatcher.addEventListener(SpeedupScreen.FINISH,this.onFinish,false,0,true);
            stateMachine.propertyBag.eventDispatcher.addEventListener(SpeedupScreen.SPEEDUP,this.onSpeedupRequest,false,0,true);
            _loc1_ = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
            if(_loc1_.isSuperOre())
            {
               m_window = SuperOreScreen.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc1_.code,owner,null,stateMachine.resourceType,0,true);
            }
            else
            {
               m_window = SpeedupScreen.display(IEntity(stateMachine.propertyBag));
            }
         }
      }
      
      override protected function onProgress(param1:Number) : void
      {
         if(m_window)
         {
            updateProgressBar(param1);
         }
         else
         {
            conditionallyUpdateProgressBar(param1);
         }
      }
      
      protected function onExit(param1:Event) : void
      {
         this.onCloseClick(null);
      }
      
      protected function onCancel(param1:Event) : void
      {
         this.onCloseClick(null);
         stopProgressBar();
         stateMachine.referenceItemName = null;
         stateMachine.researchItemName = null;
         this.cancelNextState();
      }
      
      protected function onSpeedupRequest(param1:Event) : void
      {
         var _loc4_:GameItem = null;
         var _loc5_:GameItem = null;
         var _loc6_:LocalizationObjectToken = null;
         var _loc7_:String = null;
         this.onCloseClick(null);
         var _loc2_:Object = stateMachine.propertyBag.getProperty(userDataProperty,null);
         var _loc3_:GameItem = stateMachine.propertyBag.getProperty(dataProperty,null);
         if(_loc3_.isResearchItem())
         {
            _loc4_ = ZGlobal.gameSettings.getItemByName(stateMachine.researchItemName,GameItem) as GameItem;
            _loc5_ = ZGlobal.gameSettings.getItemByName(stateMachine.referenceItemName,GameItem) as GameItem;
            if(ZGlobal.speedUpViralVarient == ZGlobal.EXPERIMENT_SPEEDUP_VIRAL_v3)
            {
               _loc6_ = _loc4_.getSentenceNameLocalizationObject();
               if(_loc6_)
               {
                  ViralsManager.instance.sendFeed("help_research",{
                     "objectId":_loc2_.id,
                     "ITEMTOKunit":_loc4_.name + "|singular",
                     "itemUpgrade":_loc5_.name
                  },null);
               }
               else
               {
                  _loc7_ = _loc4_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
                  ViralsManager.instance.sendFeed("help_research_2",{
                     "objectId":_loc2_.id,
                     "unit":_loc7_,
                     "itemUpgrade":_loc5_.name
                  },null);
               }
            }
            else
            {
               ZGlobal.navigateImmediatelyTo("speedup.php?itemUpgrade=" + _loc5_.name + "&itemUnit=" + _loc4_.name + "&objectId=" + _loc2_.id + "&isResearch=1");
            }
         }
         else
         {
            _loc4_ = ZGlobal.gameSettings.getItemByName(stateMachine.referenceItemName,GameItem) as GameItem;
            if(ZGlobal.speedUpViralVarient == ZGlobal.EXPERIMENT_SPEEDUP_VIRAL_v3)
            {
               ViralsManager.instance.sendFeed("help_contract",{
                  "objectId":_loc2_.id,
                  "itemContract":_loc4_.name
               },null);
            }
            else
            {
               ZGlobal.navigateImmediatelyTo("speedup.php?itemUpgrade=" + _loc4_.name + "&objectId=" + _loc2_.id + "&isResearch=0");
            }
         }
      }
      
      protected function onFinish(param1:WorldEvent) : void
      {
         this.onCloseClick(null);
         ZGlobal.player.buyItem(GameItem(param1.eventData),true);
         TransactionManager.addTransaction(new TSpeedup(IEntity(stateMachine.propertyBag),SpeedupItem(param1.eventData).elapsedTime));
         stopProgressBar();
         autoNextState();
      }
      
      override protected function onCloseClick(param1:CloseEvent) : void
      {
         if(m_window)
         {
            stateMachine.propertyBag.eventDispatcher.removeEventListener(SpeedupScreen.EXIT,this.onExit);
            stateMachine.propertyBag.eventDispatcher.removeEventListener(SpeedupScreen.CANCEL,this.onCancel);
            stateMachine.propertyBag.eventDispatcher.removeEventListener(SpeedupScreen.FINISH,this.onFinish);
            stateMachine.propertyBag.eventDispatcher.removeEventListener(SpeedupScreen.SPEEDUP,this.onSpeedupRequest);
            m_window = null;
         }
      }
      
      protected function cancelNextState() : void
      {
         if(this.m_cancelNextStateIndex)
         {
            switchToState(this.m_cancelNextStateIndex);
            if(shouldSendSetStateTransaction())
            {
               TransactionManager.addTransaction(new TSetState(stateMachine.propertyBag as IEntity,this.getSetStateReferenceItemName(),true));
            }
         }
         else
         {
            Logger.error(this,"cancelNextState","trying to enter cancelState when it isn\'t set");
         }
      }
      
      override protected function getSetStateReferenceItemName() : String
      {
         var _loc1_:GameItem = null;
         var _loc2_:GameItem = null;
         if(Boolean(stateMachine.referenceItemName) && Boolean(stateMachine.researchItemName))
         {
            _loc1_ = ZGlobal.gameSettings.getItemByName(stateMachine.referenceItemName,GameItem) as GameItem;
            _loc2_ = ZGlobal.gameSettings.getItemByName(stateMachine.researchItemName,GameItem) as GameItem;
            return _loc1_.code + ":" + _loc2_.code;
         }
         return super.getSetStateReferenceItemName();
      }
      
      override protected function removeListeners() : void
      {
         MessageDispatcher.instance.removeEventListener(MessageDispatcher.SPEEDUP,this.onSpeedupReceived);
         ResearchDispatcher.instance.removeEventListener(ResearchUpdatedEvent.DURATION_UPGRADE_ADDED,this.onResearchUpdated);
      }
      
      public function nextState() : void
      {
         stopProgressBar();
         autoNextState();
      }
   }
}

