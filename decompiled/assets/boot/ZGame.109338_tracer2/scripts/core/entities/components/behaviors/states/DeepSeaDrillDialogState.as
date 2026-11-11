package core.entities.components.behaviors.states
{
   import Engine.Classes.TimerUtil;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsBuildingItem;
   import core.managers.DeepSeaDrillManager;
   import displays.popups.GenericPopup;
   import displays.popups.SpeechPopup;
   import displays.popups.genericPopup.GenericPopup1B;
   import displays.screens.partsGather.DeepSeaDrillPartsGather;
   import events.CloseEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Timer;
   import transactions.TCollectDeepSeaDrillCoins;
   import utils.ZGameUtils;
   import zlabs.managers.PopupManager;
   
   public class DeepSeaDrillDialogState extends BuildingPartsDialogState
   {
      
      protected var m_timer:Timer;
      
      public function DeepSeaDrillDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         var _loc1_:int = 0;
         super.performEnterActions();
         if(ZGlobal.isHome())
         {
            _loc1_ = DeepSeaDrillManager.instance.timeRemaining;
            if(_loc1_ <= 0)
            {
               this.showTokenRewardPopup();
            }
            else
            {
               this.m_timer = TimerUtil.callHandlerLater(this.showTokenRewardPopup,_loc1_ * 1000);
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
               stateMachine.propertyBag.eventDispatcher.addEventListener(DeepSeaDrillPartsGather.FINISHED,this.onFinished,false,0,true);
               stateMachine.propertyBag.eventDispatcher.addEventListener(CloseEvent.CLOSE,onCloseClick,false,0,true);
               _loc3_ = data.@desc;
               if(_loc2_.xml.@buildingPartsDesc != undefined)
               {
                  _loc3_ = _loc2_.xml.@buildingPartsDesc;
               }
               DeepSeaDrillPartsGather.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc2_.code,_loc3_,owner,data.@tit);
               return;
            }
            this.onFinished(null);
         }
      }
      
      override protected function onFinished(param1:Event) : void
      {
         PopupManager.instance.push(new SpeechPopup("Speech_Deep_Sea_Drill_02",this.onSpeechPopupClosed,SpeechPopup.EXIT_TEXT_OK),0,true,false);
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
            DeepSeaDrillPartsGather.closePartsGather();
            _loc2_ = ZGameUtils.ZlocT("Dialogs","DeepSeaDrill_Title");
            _loc3_ = ZGameUtils.ZlocT("Dialogs","DeepSeaDrill_Expired",{"x":DeepSeaDrillManager.TOKEN_REWARD_COIN_COUNT});
            _loc4_ = new GenericPopup1B(_loc3_,_loc2_,GenericPopup.TYPE_BONUS,this.collectTokenReward);
            _loc4_.setAdvisorMood(GenericPopup.MOOD_SURPRISED);
            PopupManager.instance.push(_loc4_);
         }
      }
      
      protected function collectTokenReward(param1:Event) : void
      {
         onCloseClick(null);
         TransactionManager.addTransaction(new TCollectDeepSeaDrillCoins(owner));
         clickNextStateClientUpdateOnly();
      }
      
      protected function onSpeechPopupClosed(param1:Event) : void
      {
         onCloseClick(null);
         clickNextState();
      }
   }
}

