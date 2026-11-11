package displays.popups.promo
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.managers.promoManager.PromoManager;
   import core.player.Player;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import displays.popups.MOTDCountdownClock;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TPromoAction;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class FriendFlashPopup extends GallantPopup
   {
      
      public static const SOURCE_AUTO:String = "Auto";
      
      public static const SOURCE_HUD:String = "HUD";
      
      private var m_bundleInfo:Array;
      
      private var m_optionCards:Vector.<MovieClip>;
      
      private var m_purchaseButtons:Vector.<ZGameButton>;
      
      private var m_clock:MOTDCountdownClock = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = new ButtonMouseEventSoundContainer();
      
      private var m_flashSale:XML = PromoManager.instance.getFlashSale(PromoManager.PROMO_FRIEND_FLASH);
      
      private var m_bonusSelected:int;
      
      private var m_facePileLoaders:Array = new Array();
      
      public function FriendFlashPopup(param1:Array, param2:String)
      {
         this.m_bundleInfo = param1;
         StatsManager.count("dialog","friend_flash",param2);
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_Ep_Gift.swf"));
      }
      
      private function initStrings() : void
      {
         var _loc1_:String = ZGameUtils.ZlocT("Promo","promo_FriendFlash_Dialog_Title");
         TextFieldUtil.compactTextField(m_window.title_tf,_loc1_);
         var _loc2_:String = ZGameUtils.ZlocT("Promo","promo_FriendFlash_Dialog_Desc");
         TextFieldUtil.compactTextField(m_window.info_tf_0,_loc2_);
         var _loc3_:String = ZGameUtils.ZlocT("Promo","promo_FriendFlash_Dialog_Question");
         TextFieldUtil.compactTextField(m_window.question_tf,_loc3_);
         var _loc4_:String = ZGameUtils.ZlocT("Promo","promo_FriendFlash_Dialog_Info1");
         TextFieldUtil.compactTextField(m_window.info_tf_1,_loc4_);
         var _loc5_:String = ZGameUtils.ZlocT("Promo","promo_FriendFlash_Dialog_Info2");
         TextFieldUtil.compactTextField(m_window.info_tf_2,_loc5_);
         var _loc6_:String = ZGameUtils.ZlocT("Dialogs","EPGiftSendSendButtonString");
         TextFieldUtil.compactTextField(m_window.send_tf,_loc6_);
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var _loc3_:String = null;
         var _loc4_:MovieClip = null;
         super.onLoadComplete(param1);
         this.m_optionCards = new Vector.<MovieClip>();
         this.m_purchaseButtons = new Vector.<ZGameButton>();
         var _loc2_:int = 0;
         while(_loc2_ < this.m_bundleInfo.length)
         {
            _loc3_ = "card_" + _loc2_;
            _loc4_ = m_window[_loc3_].card_mc;
            this.m_optionCards.push(_loc4_);
            this.fillOutOptionCard(_loc2_,this.m_bundleInfo[_loc2_]);
            _loc2_++;
         }
      }
      
      override protected function getWindowInstance(param1:SWFResource) : MovieClip
      {
         var _loc2_:Class = param1.getAssetClass("Screen_mc");
         return new _loc2_();
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         this.initStrings();
         this.refreshFacePilePortraits();
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClick,false,0,true);
         UIDispatcher.instance.addEventListener(Player.REQUEST_FRIENDS_LOADED,this.onRequestFriendsLoaded,false,0,true);
         this.m_buttonSounds.addButton(m_window.exit_bt,ButtonSound.DEFAULT);
         TextFieldUtil.processTextField(m_window.countdown_tf,ZGameUtils.ZlocT("Promo","promo_FlashSale_EndsIn"));
         var _loc1_:XML = PromoManager.instance.friendFlashDateXML;
         this.m_clock = new MOTDCountdownClock(m_window.clock_mc,_loc1_);
         StatsManager.count("dialog",this.kingdom,"view");
         TransactionManager.addTransaction(new TPromoAction("view",this.m_flashSale.@type));
      }
      
      private function refreshFacePilePortraits() : void
      {
         var _loc5_:ImageLoader = null;
         if(this.m_facePileLoaders.length)
         {
            return;
         }
         var _loc1_:Array = ZGlobal.player.empireFriends;
         if(!_loc1_ || !_loc1_.length)
         {
            return;
         }
         var _loc2_:Array = [m_window.player_03,m_window.player_02,m_window.player_04,m_window.player_01,m_window.player_05];
         var _loc3_:int = Math.min(_loc1_.length,_loc2_.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = ImageLoaderFactory.CreateImageLoader(_loc1_[_loc4_].pic_square,_loc2_[_loc4_].icon);
            if(_loc5_)
            {
               this.m_facePileLoaders.push(_loc5_);
            }
            _loc4_++;
         }
         while(_loc4_ < _loc2_.length)
         {
            _loc2_[_loc4_].visible = false;
            _loc4_++;
         }
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ZGameButton = null;
         super.deinitDialog();
         UIDispatcher.instance.removeEventListener(Player.REQUEST_FRIENDS_LOADED,this.onRequestFriendsLoaded);
         this.deinitLoaders();
         for each(_loc1_ in this.m_purchaseButtons)
         {
            _loc1_.dispose();
         }
         m_window.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClick);
         this.m_buttonSounds.release();
      }
      
      private function deinitLoaders() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_facePileLoaders)
         {
            _loc1_.destroy();
         }
         this.m_facePileLoaders = [];
      }
      
      protected function fillOutOptionCard(param1:int, param2:XML) : void
      {
         var _loc3_:MovieClip = this.m_optionCards[param1];
         var _loc4_:int = int(param2.@ep);
         TextFieldUtil.processTextField(_loc3_.title_tf,ZGameUtils.ZlocT("Promo","promo_FriendFlash_Option",{"num":param1 + 1}));
         TextFieldUtil.processTextField(_loc3_.points_tf,_loc4_.toString());
         var _loc5_:int = int(param2.@cost);
         var _loc6_:String = ZGameUtils.ZlocT("Promo","promo_MoneyCost",{"cost":_loc5_});
         TextFieldUtil.processTextField(_loc3_.cost_tf,_loc6_);
         var _loc7_:int = int(param2.@bonus);
         var _loc8_:String = ZGameUtils.ZlocT("Promo","promo_FriendFlash_BonusAmt",{"num":_loc7_});
         TextFieldUtil.processTextField(_loc3_.giftValue_tf,_loc8_);
         var _loc9_:String = ZGameUtils.ZlocT("Promo","promo_FriendFlash_BonusLabel");
         TextFieldUtil.processTextField(_loc3_.friends_tf,_loc9_);
         var _loc10_:int = _loc4_ + _loc7_;
         var _loc11_:String = ZGameUtils.ZlocT("Promo","promo_FriendFlash_Total",{"num":_loc10_});
         TextFieldUtil.processTextField(_loc3_.total_tf,_loc11_);
         var _loc12_:int = int(param2.@bonusFrac);
         var _loc13_:String = ZGameUtils.ZlocT("Promo","promo_FriendFlash_BonusSummary",{"bonus":_loc12_});
         TextFieldUtil.processTextField(_loc3_.discount_tf,_loc13_);
         TextFieldUtil.processTextField(_loc3_.currentAmount_tf,ZGameUtils.ZlocT("Promo","promo_FriendFlash_cost",{"amount":_loc5_}));
         var _loc14_:ZGameButton = new ZGameButton(_loc3_.accept_bt,this.onPurchaseClick);
         _loc14_.text = ZGameUtils.ZlocT("Promo","promo_FriendFlash_PurchaseBtn");
         _loc14_.buttonObject = {
            "code":param2.@itemCode,
            "cost":_loc5_,
            "quantity":param2.@ep,
            "bonus":_loc7_
         };
         this.m_purchaseButtons.push(_loc14_);
         this.m_buttonSounds.addButton(_loc14_.m_overlay,ButtonSound.DEFAULT);
      }
      
      protected function onExitClick(param1:MouseEvent) : void
      {
         StatsManager.count("dialog",this.kingdom,"no");
         TransactionManager.addTransaction(new TPromoAction("dismiss",this.m_flashSale.@type));
         close();
      }
      
      private function get kingdom() : String
      {
         return PromoManager.getFlashSaleStatsString(this.m_flashSale,"dialogKingdom");
      }
      
      public function get bonusAmountSelected() : int
      {
         return this.m_bonusSelected;
      }
      
      private function onPurchaseClick(param1:MouseEvent) : void
      {
         var _loc2_:String = param1.currentTarget.buttonObject.code;
         var _loc3_:Number = Number(param1.currentTarget.buttonObject.cost);
         var _loc4_:int = int(param1.currentTarget.buttonObject.quantity);
         this.m_bonusSelected = param1.currentTarget.bonus;
         var _loc5_:String = PromoManager.getFlashSaleStatsString(this.m_flashSale,"purchasePhylumPrefix") + "_code" + _loc2_;
         var _loc6_:PromoData = new PromoData();
         _loc6_.popup = this;
         PromoManager.instance.dispatchEvent(new WorldEvent(PromoManager.EVENT_DIALOG_ACCEPT,{
            "packageType":_loc2_,
            "phylum":_loc5_,
            "promoData":_loc6_,
            "quantity":_loc4_
         }));
         StatsManager.count("dialog",this.kingdom,"yes","cost " + _loc3_,"itemcode: " + _loc2_);
      }
      
      private function onRequestFriendsLoaded(param1:Event) : void
      {
         this.refreshFacePilePortraits();
      }
   }
}

