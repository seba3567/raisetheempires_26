package core.entities.components.behaviors.states
{
   import Engine.Classes.TimerUtil;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsBuildingItem;
   import core.managers.VolcanoReskin6Manager;
   import core.managers.questManager.ZGameQuestManager;
   import dispatchers.UIDispatcher;
   import displays.popups.GenericPopup;
   import displays.popups.SpeechPopup;
   import displays.popups.genericPopup.GenericPopup1B;
   import displays.screens.partsGather.VolcanoReskin6PartsGather;
   import events.CloseEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Timer;
   import transactions.TCollectVR6Coins;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class VolcanoReskin6DialogState extends BuildingPartsDialogState
   {
      
      protected var m_timer:Timer;
      
      public function VolcanoReskin6DialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         var _loc1_:int = 0;
         super.performEnterActions();
         if(ZGlobal.isHome())
         {
            _loc1_ = VolcanoReskin6Manager.instance.timeRemaining;
            if(_loc1_ <= 0)
            {
               this.showTokenRewardPopup();
            }
            else
            {
               this.m_timer = TimerUtil.callHandlerLater(this.showTokenRewardPopup,_loc1_ * 1000);
               UIDispatcher.instance.addEventListener(ZGameQuestManager.QUESTS_PARTSGATHER,this.onShowDialogFromQuestManager,false,0,true);
            }
         }
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
               stateMachine.propertyBag.eventDispatcher.addEventListener(VolcanoReskin6PartsGather.FINISHED,this.onFinished,false,0,true);
               stateMachine.propertyBag.eventDispatcher.addEventListener(CloseEvent.CLOSE,onCloseClick,false,0,true);
               stateMachine.propertyBag.eventDispatcher.addEventListener(VolcanoReskin6PartsGather.FAILURE_SPEECH,this.onFailure,false,0,true);
               _loc3_ = data.@desc;
               if(_loc2_.xml.@buildingPartsDesc != undefined)
               {
                  _loc3_ = _loc2_.xml.@buildingPartsDesc;
               }
               VolcanoReskin6PartsGather.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc2_.code,_loc3_,owner,data.@tit);
               return;
            }
            this.onFinished(null);
         }
      }
      
      protected function onShowDialogFromQuestManager(param1:WorldEvent) : void
      {
         if(param1.eventData.code == VolcanoReskin6Manager.BUILDING_CODE)
         {
            this.showDialog();
         }
      }
      
      protected function onCollect(param1:Event) : void
      {
         onCloseClick(null);
         TransactionManager.addTransaction(new TCollectVR6Coins(owner));
         clickNextStateClientUpdateOnly();
      }
      
      override protected function onFinished(param1:Event) : void
      {
         super.onFinished(param1);
         PopupManager.instance.push(new SpeechPopup("Speech_Volcano_Reskin6_03",this.onSpeechPopupClosed,SpeechPopup.EXIT_TEXT_OK),0,true,false);
      }
      
      protected function onSpeechPopupClosed(param1:Event) : void
      {
      }
      
      protected function onFailure(param1:Event) : void
      {
         PopupManager.instance.push(new SpeechPopup("Speech_Volcano_Reskin6_04",this.onSpeechFailurePopupClosed,SpeechPopup.EXIT_TEXT_OK),0,true,false);
      }
      
      protected function onSpeechFailurePopupClosed(param1:Event) : void
      {
         onCloseClick(null);
         clickNextStateClientUpdateOnly();
      }
      
      protected function showTokenRewardPopup(param1:Event = null) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:GenericPopup1B = null;
         if(this.m_timer)
         {
            this.m_timer.stop();
         }
         this.m_timer = null;
         if(ZGlobal.isHome())
         {
            VolcanoReskin6PartsGather.closePartsGather();
            _loc2_ = ZGameUtils.ZlocT("Quests","quest_QVR6_title");
            _loc3_ = ZGameUtils.ZlocT("Dialogs","VolcanoReskin6_Expired",{"x":VolcanoReskin6Manager.TOKEN_REWARD_COIN_COUNT});
            _loc4_ = new GenericPopup1B(_loc3_,_loc2_,GenericPopup.TYPE_BONUS,this.onCollect);
            _loc4_.setAdvisorMood(GenericPopup.MOOD_SURPRISED);
            PopupManager.instance.push(_loc4_);
         }
      }
      
      override protected function performExitActions(param1:IMachine) : void
      {
         super.performExitActions(param1);
         UIDispatcher.instance.removeEventListener(ZGameQuestManager.QUESTS_PARTSGATHER,this.onShowDialogFromQuestManager);
      }
   }
}

