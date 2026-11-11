package core.entities.components.behaviors.states
{
   import Engine.Classes.TimerUtil;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsBuildingItem;
   import core.gameobjects.RewardHelper;
   import core.managers.TimedBuildableManager;
   import core.managers.WorldResourceManager;
   import displays.popups.GenericPopup;
   import displays.popups.TBPlayAgainPopup;
   import displays.popups.genericPopup.GenericPopup1B;
   import displays.screens.partsGather.TimedBuildablePartsGather;
   import events.CloseEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Timer;
   import transactions.TCollectTimedBuildableCoins;
   import transactions.TResetTimedBuildable;
   import transactions.TTBCollectRewards;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class TBPlayAgainDialogState extends BuildingPartsDialogState
   {
      
      public static const COLLECT_REWARD:String = "TBCollectReward";
      
      public static const PLAY_AGAIN:String = "TBPlayAgain";
      
      public static const TB_EXPIRY:String = "TBExpiry";
      
      protected var m_timer:Timer;
      
      protected var m_rewards:Array;
      
      protected var m_shouldGrantReward:Boolean = false;
      
      public function TBPlayAgainDialogState(param1:BehaviorStateInit)
      {
         super(param1);
         this.m_rewards = param1.m_gameObject.currentRewards ? param1.m_gameObject.currentRewards : null;
      }
      
      override protected function performEnterActions() : void
      {
         var _loc1_:int = 0;
         super.performEnterActions();
         if(ZGlobal.isHome())
         {
            _loc1_ = TimedBuildableManager.instance.getTimeRemainingForIndex(m_data.@reskinID.toString());
            if(_loc1_ <= 0)
            {
               this.showTokenRewardPopup();
            }
            else
            {
               this.m_timer = TimerUtil.callHandlerLater(this.showTokenRewardPopup,_loc1_ * 1000);
               stateMachine.propertyBag.eventDispatcher.addEventListener(COLLECT_REWARD,this.onCollectReward,false,0,true);
               stateMachine.propertyBag.eventDispatcher.addEventListener(PLAY_AGAIN,this.onPlayAgain,false,0,true);
            }
         }
      }
      
      override protected function showDialog() : void
      {
         if(ZGlobal.isHome())
         {
            if(!this.m_rewards)
            {
               this.showBuildingPartsDialog();
            }
            else if(this.m_shouldGrantReward)
            {
               this.grantRewards();
               this.showPlayAgainPopup();
            }
            else
            {
               this.showPlayAgainPopup();
            }
         }
      }
      
      protected function showBuildingPartsDialog() : void
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
               TimedBuildablePartsGather.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc2_.code,_loc2_.name,m_data.@reskinID.toString(),_loc3_,owner,data.@title.toString(),null,this.getTextInfo(),this.getRewardsXml(m_data.@reskinID.toString()));
               return;
            }
            this.onFinished(null);
         }
      }
      
      protected function showPlayAgainPopup() : void
      {
         var _loc1_:Array = null;
         var _loc2_:Object = null;
         var _loc3_:RewardHelper = null;
         if(ZGlobal.isHome())
         {
            _loc1_ = this.getRewardHelpers();
            _loc2_ = new Object();
            _loc2_.rewardPairs = new Array();
            _loc2_.rewardIcons = new Array();
            for each(_loc3_ in _loc1_)
            {
               _loc3_.buildUI(_loc2_,WorldResourceManager.XTRA_LARGE_ICON);
            }
            PopupManager.instance.push(new TBPlayAgainPopup(stateMachine.propertyBag.eventDispatcher,this.getPlayAgainTextInfo(),_loc2_,this.getPlayAgainPopupUrl()));
         }
      }
      
      protected function grantRewards() : void
      {
         var _loc2_:RewardHelper = null;
         var _loc1_:Array = this.getRewardHelpers();
         for each(_loc2_ in _loc1_)
         {
            _loc2_.execute();
         }
         this.m_shouldGrantReward = false;
      }
      
      protected function getRewardHelpers() : Array
      {
         var _loc2_:GameItem = null;
         var _loc3_:XMLList = null;
         var _loc4_:XML = null;
         var _loc1_:Array = new Array();
         if(this.m_rewards)
         {
            _loc2_ = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
            _loc3_ = TimedBuildableManager.instance.getRewards(m_data.@reskinID.toString());
            for each(_loc4_ in _loc3_)
            {
               if(this.m_rewards.indexOf(_loc4_.@id.toString()) >= 0)
               {
                  _loc1_.push(new RewardHelper(_loc4_));
               }
            }
         }
         return _loc1_;
      }
      
      override protected function onFinished(param1:Event) : void
      {
         TransactionManager.addTransaction(new TTBCollectRewards(owner,stateMachine.propertyBag.eventDispatcher));
      }
      
      protected function onCollectReward(param1:WorldEvent) : void
      {
         this.m_shouldGrantReward = true;
         this.m_rewards = param1.eventData.rewards;
         if(ZGlobal.isHome())
         {
            this.grantRewards();
            this.showPlayAgainPopup();
         }
      }
      
      protected function onPlayAgain(param1:WorldEvent) : void
      {
         TransactionManager.addTransaction(new TResetTimedBuildable(owner));
         this.m_rewards = null;
         this.m_shouldGrantReward = false;
         this.showBuildingPartsDialog();
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
            TimedBuildablePartsGather.closePartsGather();
            stateMachine.propertyBag.eventDispatcher.dispatchEvent(new WorldEvent(TB_EXPIRY));
            _loc2_ = ZGameUtils.localizedStringForToken(m_data.@tit.toString());
            _loc3_ = ZGameUtils.localizedStringForToken(m_data.@expired.toString(),null,{"amount":TimedBuildableManager.TOKEN_REWARD_COIN_COUNT});
            _loc4_ = new GenericPopup1B(_loc3_,_loc2_,GenericPopup.TYPE_BONUS,this.collectTokenReward);
            _loc4_.setAdvisorMood(GenericPopup.MOOD_DEFAULT);
            PopupManager.instance.push(_loc4_);
         }
      }
      
      protected function collectTokenReward(param1:Event = null) : void
      {
         onCloseClick(null);
         TransactionManager.addTransaction(new TCollectTimedBuildableCoins(owner,m_data.@reskinID.toString()));
         clickNextStateClientUpdateOnly();
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
      
      protected function getPlayAgainTextInfo() : Object
      {
         var _loc1_:Object = new Object();
         _loc1_.title = m_data.@paTitle.toString();
         _loc1_.desc = m_data.@paDesc.toString();
         _loc1_.button = m_data.@paButton.toString();
         return _loc1_;
      }
      
      override protected function removeListeners() : void
      {
         stateMachine.propertyBag.eventDispatcher.removeEventListener(COLLECT_REWARD,this.onCollectReward);
         stateMachine.propertyBag.eventDispatcher.removeEventListener(PLAY_AGAIN,this.onPlayAgain);
      }
      
      public function getRewardsXml(param1:String) : XMLList
      {
         return TimedBuildableManager.instance.getRewards(param1);
      }
      
      public function getPlayAgainPopupUrl() : String
      {
         var _loc1_:GameItem = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
         if(Boolean(_loc1_) && _loc1_.xml.@playAgainPopup != undefined)
         {
            return "assets/displays/dialogs/" + _loc1_.xml.@playAgainPopup.toString() + ".swf";
         }
         return "assets/displays/dialogs/Timed_playAgain.swf";
      }
   }
}

