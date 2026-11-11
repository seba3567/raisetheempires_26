package core.entities.components.behaviors.states
{
   import Engine.Classes.TimerUtil;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.entities.components.states.IMachine;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsBuildingItem;
   import core.managers.TimedBuildableManager;
   import core.managers.WorldObjectManager;
   import core.managers.questManager.ZGameQuestManager;
   import dispatchers.UIDispatcher;
   import displays.popups.GenericPopup;
   import displays.popups.genericPopup.GenericPopupWithCompactText;
   import displays.screens.partsGather.TimedBuildablePartsGather;
   import entity.GameDataComponent;
   import events.CloseEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import transactions.TCollectTimedBuildableCoins;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class TimedBuildableDialogState extends BuildingPartsDialogState
   {
      
      protected var m_timer:Timer;
      
      public function TimedBuildableDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         var _loc1_:int = TimedBuildableManager.instance.getTimeRemainingForIndex(m_data.@reskinID.toString());
         if(_loc1_ <= 0)
         {
            this.showTokenRewardPopup();
         }
         else
         {
            this.m_timer = TimerUtil.callHandlerLater(this.showTokenRewardPopup,_loc1_ * 1000);
         }
         UIDispatcher.instance.addEventListener(ZGameQuestManager.QUESTS_PARTSGATHER,this.onShowDialogFromQuestManager,false,0,true);
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:GameItem = null;
         var _loc2_:PartsBuildingItem = null;
         var _loc3_:String = null;
         if(ZGlobal.isHome())
         {
            _loc1_ = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
            _loc2_ = ZGlobal.gameSettings.getItemByCode(_loc1_.code,PartsBuildingItem) as PartsBuildingItem;
            if(Boolean(_loc2_) && Boolean(_loc2_.numParts > 0) && _loc2_.requiresAnyParts())
            {
               stateMachine.propertyBag.eventDispatcher.addEventListener(TimedBuildablePartsGather.FINISHED,this.onFinished,false,0,true);
               stateMachine.propertyBag.eventDispatcher.addEventListener(CloseEvent.CLOSE,onCloseClick,false,0,true);
               _loc3_ = data.@desc;
               if(_loc2_.xml.@buildingPartsDesc != undefined)
               {
                  _loc3_ = _loc2_.xml.@buildingPartsDesc;
               }
               TimedBuildablePartsGather.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc2_.code,_loc2_.name,m_data.@reskinID.toString(),_loc3_,owner,data.@title.toString(),null,this.getTextInfo(),this.getRewardsXml(m_data.@reskinID.toString()));
               return;
            }
            this.onFinished(null);
         }
      }
      
      protected function showTokenRewardPopup(param1:Event = null) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:GenericPopupWithCompactText = null;
         if(this.m_timer)
         {
            this.m_timer.stop();
         }
         this.m_timer = null;
         if(ZGlobal.isHome())
         {
            TimedBuildablePartsGather.closePartsGather();
            _loc2_ = ZGameUtils.localizedStringForToken(m_data.@title.toString());
            _loc3_ = ZGameUtils.localizedStringForToken(m_data.@expired.toString(),null,{"amount":TimedBuildableManager.TOKEN_REWARD_COIN_COUNT});
            _loc4_ = new GenericPopupWithCompactText(_loc3_,_loc2_,GenericPopup.TYPE_BONUS,this.collectTokenReward);
            _loc4_.setAdvisorMood(GenericPopup.MOOD_SURPRISED);
            PopupManager.instance.push(_loc4_);
         }
      }
      
      protected function collectTokenReward(param1:Event = null) : void
      {
         onCloseClick(null);
         TransactionManager.addTransaction(new TCollectTimedBuildableCoins(owner,m_data.@reskinID.toString()));
         clickNextStateClientUpdateOnly();
      }
      
      protected function onShowDialogFromQuestManager(param1:WorldEvent) : void
      {
         var _loc2_:GameItem = null;
         var _loc3_:Dictionary = null;
         var _loc4_:Object = null;
         var _loc5_:GameDataComponent = null;
         var _loc6_:BuildingFSMComponent = null;
         var _loc7_:BehaviorStateMachine = null;
         var _loc8_:GameItem = null;
         var _loc9_:PartsBuildingItem = null;
         var _loc10_:String = null;
         if(m_data.@buildingCode == param1.eventData.code)
         {
            _loc2_ = ZGlobal.gameSettings.getItemByCode(param1.eventData.code,GameItem) as GameItem;
            if(_loc2_)
            {
               _loc3_ = WorldObjectManager.instance.getObjectsBySubType(_loc2_.type,_loc2_.subType);
               for each(_loc4_ in _loc3_)
               {
                  _loc5_ = GameDataComponent(_loc4_.lookupComponentByType(GameDataComponent));
                  if((Boolean(_loc5_)) && _loc5_.gameData.code == param1.eventData.code)
                  {
                     _loc6_ = BuildingFSMComponent(_loc4_.lookupComponentByType(BuildingFSMComponent));
                     if(_loc6_.isBuilt && Boolean(_loc6_.stateMachine))
                     {
                        _loc7_ = BehaviorStateMachine(_loc6_.stateMachine);
                        _loc8_ = _loc6_.stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
                        _loc9_ = ZGlobal.gameSettings.getItemByCode(_loc8_.code,PartsBuildingItem) as PartsBuildingItem;
                        if((Boolean(_loc9_)) && Boolean(_loc9_.numParts > 0) && _loc9_.requiresAnyParts())
                        {
                           _loc7_.propertyBag.eventDispatcher.addEventListener(TimedBuildablePartsGather.FINISHED,this.onFinished,false,0,true);
                           _loc7_.propertyBag.eventDispatcher.addEventListener(CloseEvent.CLOSE,onCloseClick,false,0,true);
                           _loc10_ = data.@desc;
                           if(_loc9_.xml.@buildingPartsDesc != undefined)
                           {
                              _loc10_ = _loc9_.xml.@buildingPartsDesc;
                           }
                           TimedBuildablePartsGather.display(EventDispatcher(_loc7_.propertyBag.eventDispatcher),_loc9_.code,_loc9_.name,m_data.@reskinID.toString(),_loc10_,owner,data.@title.toString(),null,this.getTextInfo(),this.getRewardsXml(m_data.@reskinID.toString()));
                           return;
                        }
                        this.onFinished(null);
                     }
                  }
               }
            }
         }
      }
      
      override protected function onFinished(param1:Event) : void
      {
         super.onFinished(param1);
      }
      
      protected function onSpeechPopupClosed(param1:Event) : void
      {
      }
      
      override protected function removeListeners() : void
      {
         UIDispatcher.instance.removeEventListener(ZGameQuestManager.QUESTS_PARTSGATHER,this.onShowDialogFromQuestManager);
      }
      
      override protected function performExitActions(param1:IMachine) : void
      {
         super.performExitActions(param1);
      }
      
      public function getRewardsXml(param1:String) : XMLList
      {
         return TimedBuildableManager.instance.getRewards(param1);
      }
      
      protected function getTextInfo() : Object
      {
         var _loc1_:Object = new Object();
         _loc1_.title = m_data.@title;
         _loc1_.desc = m_data.@desc;
         _loc1_.hint = m_data.@hint;
         _loc1_.dayCount = m_data.@dayCount;
         return _loc1_;
      }
   }
}

