package displays.popups
{
   import core.ZGlobal;
   import core.gameobjects.RewardHelper;
   import core.managers.PVPManager;
   import core.managers.WorldResourceManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   
   public class DailyBonusPopup extends GallantPopup
   {
      
      private var m_loaders:Array = new Array();
      
      private var m_closeCallback:Function = null;
      
      private var m_button:ZGameButton = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_reward:Object = null;
      
      private var m_days:int = 0;
      
      private var m_currentDay:int = 0;
      
      public function DailyBonusPopup(param1:Object, param2:int, param3:Function = null)
      {
         this.m_reward = param1;
         this.m_days = param2;
         this.m_closeCallback = param3;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_DailyBonus.swf"));
      }
      
      override public function onShow() : void
      {
         super.onShow();
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      override protected function initializeScreen() : void
      {
         m_origOffsetX = m_window.x;
         m_origOffsetY = m_window.y;
         super.initializeScreen();
         if(this.m_closeCallback != null)
         {
            addEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback,false,0,true);
         }
         this.setUpPopupUI();
      }
      
      protected function setUpPopupUI() : void
      {
         var _loc1_:int = this.m_days + 1;
         TextFieldUtil.processTextField(m_window.popupBox_mc.title_tf,ZGameUtils.ZlocT("Dialogs","DailyReturnTitle",{"user":ZGameUtils.ZlocTn("",ZGlobal.player.snUser.gender == "F" ? ZGlobal.localizer.FEM : ZGlobal.localizer.MASC)}));
         TextFieldUtil.processTextField(m_window.popupBox_mc.title01_tf,ZGameUtils.ZlocT("Dialogs","DailyReturnSubTitle",{
            "num":_loc1_,
            "day":ZGameUtils.ZlocTk("Objects","day","",_loc1_)
         }));
         var _loc2_:RewardHelper = new RewardHelper(null);
         _loc2_.init(this.m_reward.type,this.m_reward.count,this.m_reward.item);
         var _loc3_:Object = new Object();
         _loc3_.rewardPairs = new Array();
         _loc2_.buildUI(_loc3_,WorldResourceManager.XTRA_LARGE_ICON);
         TextFieldUtil.processTextField(m_window.popupBox_mc.message_tf,ZGameUtils.ZlocT("Dialogs","DailyReturnMain",{
            "amount":_loc3_.rewardPairs[0].count,
            "reward":_loc3_.rewardPairs[0].reward
         }));
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_button = new ZGameButton(m_window.popupBox_mc.orangeButton_01,this.onShare);
         this.m_button.text = ZGameUtils.ZlocT("Dialogs","ShareRewards");
         this.m_buttonSounds.addButton(this.m_button.m_overlay,ButtonSound.DEFAULT);
         m_window.popupBox_mc.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit,false,0,true);
         this.m_buttonSounds.addButton(this.m_button.m_overlay,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(m_window.popupBox_mc.exit_bt,ButtonSound.DEFAULT);
         this.initCards();
         Zlab.processManager.schedule(1000,this,this.onNextCard);
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         this.m_button = null;
      }
      
      override protected function close(param1:Event = null) : void
      {
         m_window.popupBox_mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
         super.close();
      }
      
      private function onShare(param1:MouseEvent) : void
      {
         ViralsManager.instance.sendFeed("daily_bonus",{});
         this.onExit(param1);
      }
      
      private function onExit(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:XML = null;
         var _loc4_:XMLList = null;
         var _loc5_:XML = null;
         if(this.m_reward.type == "xp" && ZGlobal.player.level == PVPManager.pvpMinLevel)
         {
            _loc2_ = ZGlobal.player.xp - this.m_reward.count;
            _loc3_ = ZGlobal.gameSettings.getXML();
            _loc4_ = _loc3_.levels.level;
            _loc5_ = _loc4_[PVPManager.pvpMinLevel - 1];
            if((Boolean(_loc5_)) && _loc2_ < _loc5_.@requiredXP)
            {
               PopupManager.instance.push(new PVPWelcomePopup());
            }
         }
         if(this.m_closeCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback);
         }
         this.close();
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.ACCEPT));
      }
      
      private function get cards() : Array
      {
         return [m_window.popupBox_mc.Bonus_01,m_window.popupBox_mc.Bonus_02,m_window.popupBox_mc.Bonus_03,m_window.popupBox_mc.Bonus_04,m_window.popupBox_mc.Bonus_05,m_window.popupBox_mc.Bonus_06,m_window.popupBox_mc.Bonus_07];
      }
      
      private function initCards() : void
      {
         var _loc4_:MovieClip = null;
         var _loc5_:int = 0;
         var _loc1_:Array = this.cards;
         var _loc2_:int = 0;
         var _loc3_:int = this.m_days % 7;
         for each(_loc4_ in _loc1_)
         {
            _loc4_.questionMark_mc.visible = true;
            _loc4_.check_mc.visible = false;
            if(_loc2_ == _loc3_)
            {
               TextFieldUtil.processTextField(_loc4_.name_tf,ZGameUtils.ZlocT("Dialogs","DailyReturnToday"));
            }
            else
            {
               _loc5_ = int(this.m_days / 7);
               TextFieldUtil.processTextField(_loc4_.name_tf,ZGameUtils.ZlocT("Dialogs","DailyReturnDay",{"num":int(_loc5_ * 7 + _loc2_ + 1)}));
            }
            _loc2_++;
         }
      }
      
      private function onNextCard() : void
      {
         var _loc3_:RewardHelper = null;
         var _loc4_:Object = null;
         var _loc1_:MovieClip = this.cards[this.m_currentDay];
         _loc1_.questionMark_mc.visible = false;
         var _loc2_:int = this.m_days % 7;
         if(this.m_currentDay == _loc2_)
         {
            _loc3_ = new RewardHelper(null);
            _loc3_.init(this.m_reward.type,this.m_reward.count,this.m_reward.item);
            _loc4_ = new Object();
            _loc4_.rewardIcons = new Array();
            _loc3_.buildUI(_loc4_,WorldResourceManager.XTRA_LARGE_ICON);
            ImageLoaderFactory.CreateImageLoader(_loc4_.rewardIcons[0],_loc1_.uiloader_mc);
         }
         else
         {
            _loc1_.check_mc.visible = true;
            ++this.m_currentDay;
            if(this.m_currentDay < this.cards.length)
            {
               Zlab.processManager.schedule(750,this,this.onNextCard);
            }
         }
      }
   }
}

