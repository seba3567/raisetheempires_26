package core.managers.promoManager
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gamemode.GameMode;
   import core.gamemode.GameModeManager;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.island.GMIsland;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import core.managers.MOTDManager.MessageOfTheDayManager;
   import core.managers.WorldObjectManager;
   import core.managers.viralsManager.ViralsManager;
   import core.managers.visitorManager.VisitorManager;
   import core.player.Player;
   import core.ui.PlayerFeedbackManager;
   import core.ui.UI;
   import core.ui.UIManager;
   import core.ui.menuitem.FriendFlashUIItem;
   import core.ui.menuitem.HCxPromoUIItem;
   import core.ui.menuitem.PromoMenuItemContainer;
   import core.ui.menuitem.XPromoHUDItem;
   import dispatchers.MessageDispatcher;
   import dispatchers.UIDispatcher;
   import displays.popups.GallantPopup;
   import displays.popups.LowEPPopup;
   import displays.popups.XPromoIncentivePopup;
   import displays.popups.XPromoMOTDPopup;
   import displays.popups.fbCredits.FBCreditsPurchaseConfirmationPopup;
   import displays.popups.fbCredits.FBCreditsPurchasePromptPopup;
   import displays.popups.promo.BundledItemsPromoPopup;
   import displays.popups.promo.FlashSalePopup;
   import displays.popups.promo.FriendFlashPopup;
   import displays.popups.promo.MechLabDiscountPromoPopup;
   import displays.popups.promo.PickYourOwnPromoPopup;
   import displays.popups.promo.PromoData;
   import displays.popups.promo.RepeatPayerPopup;
   import displays.popups.promo.StarterPackPopup;
   import displays.popups.promo.StarterPackRewardPopup;
   import displays.popups.promo.UnlimitedEnergyPopup;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.Store;
   import displays.screens.friendFlash.FriendFlashThankYouInput;
   import displays.screens.friendFlash.FriendFlashThankYouReceived;
   import displays.screens.requests.EPGiftSendFriendSelectDialog;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.utils.Dictionary;
   import transactions.TCheckForPromoRewards;
   import transactions.TGetFBCreditPromoStatus;
   import transactions.TSetFBCreditParticipation;
   import transactions.TSetTag;
   import utils.CriteriaUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class PromoManager extends EventDispatcher
   {
      
      private static var m_instance:PromoManager;
      
      public static const LIGHTNINGDEAL_ITEMCOUNT_UPDATED:String = "lightningDealItemPurchased";
      
      public static const GIFTABLE_EP_GRANTED:String = "giftableEPGranted";
      
      public static const LD_MC_KEY_DATEEND:String = "LIGHTINGDEAL_DATEEND";
      
      public static const LD_MC_KEY_ITEMCODE:String = "LIGHTNINGDEAL_ITEMCODE";
      
      public static const LD_MC_KEY_AMOUNT:String = "LIGHTNINGDEAL_AMOUNT";
      
      public static const LD_MC_KEY_CURRENT:String = "LIGHTNINGDEAL_CURRENT";
      
      public static const LD_MC_KEY_MINLEVEL:String = "LIGHTNINGDEAL_MINLEVEL";
      
      public static const LD_MC_KEY_MAXLEVEL:String = "LIGHTNINGDEAL_MAXLEVEL";
      
      public static const LD_MC_KEY_TOASTER_DURATION:String = "LIGHTNINGDEAL_TOASTER_DURATION";
      
      public static const LD_MC_KEY_PAYER_THRESHOLD_0:String = "LIGHTNINGDEAL_PAYER_THRESHOLD_0";
      
      public static const LD_MC_KEY_PAYER_THRESHOLD_1:String = "LIGHTNINGDEAL_PAYER_THRESHOLD_1";
      
      public static const SURVIVAL_MODE_MC_KEY_TOASTER_DURATION:String = "SURVIVAL_MODE_TOASTER_DURATION";
      
      public static const INITIALIZED:String = "initialized";
      
      public static const EVENT_DIALOG_ACCEPT:String = "promoDialogAccept";
      
      public static const EVENT_DIALOG_DECLINE:String = "promoDialogDecline";
      
      public static const EVENT_SHOWN_ALL_MESSAGES:String = "promoShownAllMessages";
      
      public static const EVENT_IN_APP_PURCHASE_COMPLETE:String = "promoInAppComplete";
      
      public static const EVENT_CLOSE_STARTER_PACK_HUD_ICON:String = "closeStarterPackHUDIcon";
      
      public static const BUNDLE_POPUP_CLOSED:String = "bundle_popup_closed";
      
      public static const FRIENDFLASH_EP_BANK_CHANGED:String = "friendFlashEPBankChanged";
      
      public static const XPROMO_ACCEPT_TRANSACTION_COMPLETED:String = "xpromoAcceptTransactionComplete";
      
      public static const EVENT_REQUEST_INCOMPLETE_BUILDABLES:String = "request_incomplete_buildables";
      
      public static const FLAG_STARTER_PACK_ANNOUNCEMENT_POPUP:String = "stp_announce";
      
      public static const FLAG_STARTER_PACK_HUD_ICON:String = "stp_hud_icon";
      
      public static const FLAG_STARTER_PACK_OUT_OF_CASH:String = "stp_outOfCash";
      
      public static const FLAG_STARTER_PACK_CLICKED_BUY_EP:String = "stp_clickBuyEP";
      
      public static const FLAG_STARTER_PACK_ON_IDLE:String = "stp_idle";
      
      public static const FLAG_SESSION_STARTER_PACK_POPUP:String = "stp_session_popup";
      
      private static const LABOR_DAY_2011_BUNDLE_ENABLED_VARIANT:int = 2;
      
      private static const BUNDLE_BY_WALLET_ENABLED_VARIANT:int = 3;
      
      private static const BUNDLE_PICK_YOUR_OWN_ENABLED_MIN_VARIANT:int = 2;
      
      private static const MECH_LAB_DISCOUNT_ENABLED_MIN_VARIANT:int = 1;
      
      private static const MECH_LAB_DISCOUNT_TAG:String = "MECH_LAB_DISCOUNT";
      
      private static const MECH_LAB_DISCOUNT_THROTTLE:int = 24 * 60 * 60;
      
      private static const MAX_FLASH_SALES_VIEWS_AT_HIGHEST_DISCOUNT:int = 10;
      
      public static const PROMO_REPEAT_PAYER:String = "repeatPayer";
      
      public static const PROMO_FLASH_SALE_CONTROLLED:String = "controlled";
      
      public static const PROMO_FLASH_SALE_NEW_BUYER:String = "newBuyer";
      
      public static const PROMO_FLASH_SALE_DEAD_BUYER:String = "deadBuyer";
      
      public static const PROMO_FLASH_SALE_AUTOPROMO:String = "autopromo";
      
      public static const PROMO_UNLIMITED_ENERGY:String = "unlimitedEnergy";
      
      public static const PROMO_FRIEND_FLASH:String = "friendFlash";
      
      public static const FLAG_UNLIMITED_ENERGY_POPUP:String = "unlimitedEnergySeen";
      
      public static const PROMO_PICK_YOUR_OWN:String = "pick_your_own";
      
      public static const PROMO_MECH_LAB_DISCOUNT:String = "mech_lab_discount";
      
      public static const XPROMO_ADD_CARD:String = "XPROMO_ADD_CARD";
      
      public static const XPROMO_VISIBLE_CARD:String = "XPROMO_VISIBLE_CARD";
      
      public static const AUTOPROMO_EXP_OFF_VARIANT:Number = 2;
      
      public static const AUTOPROMO_TYPE_FLASH:String = "flashsale";
      
      public static const AUTOPROMO_TYPE_FRIENDFLASH:String = "friendflash";
      
      public static const AUTOPROMO_TYPE_FGWP:String = "fgwp";
      
      public static const AUTOPROMO_TYPE_PYOB:String = "pyob";
      
      private const CHECK_AW_XPROMO_REWARD:int = 3;
      
      private const CHECK_MW2_XPROMO_REWARD:int = 3;
      
      private const CHECK_CASTLE_XPROMO_REWARD:int = 3;
      
      private const CHECK_HC_XPROMO_REWARD:int = 2;
      
      private var m_PayerBundleExpireTime:String = "8/1/2000";
      
      private var m_PayerBundleExpireUnixTimeStamp:Number = 0;
      
      private var m_xml:XMLList;
      
      private var m_xpromo_xml:XMLList;
      
      private var m_paidThisSession:Boolean = false;
      
      private var m_urlRedirect:Boolean = false;
      
      private var m_promoQueue:Vector.<ZGamePopUp> = new Vector.<ZGamePopUp>();
      
      private var m_currentPromoData:PromoData = null;
      
      private var m_itemBundleCandidates:Vector.<XML> = new Vector.<XML>();
      
      private var m_itemBundleSequelsPending:int = 0;
      
      private var m_promoOverrides:Object = null;
      
      private var m_buildableDiscounts:Object = null;
      
      private var m_unlimitedEnergyExpireTime:String = "8/1/2000";
      
      private var m_unlimitedEnergyExpireUnixTimeStamp:Number = 0;
      
      private var m_unlimitedEnergyData:Array = new Array();
      
      private var m_friendFlashExpireTime:String = "8/1/2000";
      
      private var m_friendFlashExpireUnixTimeStamp:Number = 0;
      
      private var m_flashSaleVariantOverrides:Dictionary = new Dictionary();
      
      private var m_qualifyingPromotion:String = null;
      
      private var m_initialized:Boolean = false;
      
      private var m_impulsePurchases:Object = null;
      
      private var m_recentCashPurchase:String = null;
      
      private var m_specialCards:Dictionary = new Dictionary();
      
      private var m_motdsComplete:Boolean = false;
      
      private var m_exitedBattle:Boolean = false;
      
      private var m_lastInputTS:int = 0;
      
      private var m_epReceivedInfo:Object;
      
      private var m_epReceivedThankYouInfo:Object;
      
      private var m_requestFriendsLoaded:Boolean;
      
      private var m_autoPromoOverride:Boolean;
      
      private var m_acceptedCrossPromos:Object;
      
      private var m_availableCrossPromos:Object;
      
      private var m_promoMenuItemContainer:PromoMenuItemContainer;
      
      private var HUDIconPresent:Boolean = true;
      
      public function PromoManager()
      {
         super();
         this.m_xpromo_xml = ZGlobal.gameSettings.getXPromos();
         UIDispatcher.instance.addEventListener(Player.REQUEST_FRIENDS_LOADED,this.onRequestFriendsLoaded,false,0,true);
         addEventListener(GIFTABLE_EP_GRANTED,this.onGiftableEPGranted,false,0,true);
      }
      
      public static function get instance() : PromoManager
      {
         if(!m_instance)
         {
            m_instance = new PromoManager();
         }
         return m_instance;
      }
      
      public static function getFlashSaleStatsString(param1:XML, param2:String) : String
      {
         return param1.stats[param2];
      }
      
      public function getXPromoById(param1:int) : Object
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         param1 = Math.abs(param1);
         var _loc2_:uint = 0;
         if(this.m_availableCrossPromos != null)
         {
            _loc2_ = 0;
            while(_loc2_ < this.m_availableCrossPromos.length)
            {
               _loc3_ = this.m_availableCrossPromos[_loc2_];
               if(_loc3_.id == param1)
               {
                  return _loc3_;
               }
               _loc2_++;
            }
         }
         if(this.m_acceptedCrossPromos != null)
         {
            _loc2_ = 0;
            while(_loc2_ < this.m_acceptedCrossPromos.length)
            {
               _loc4_ = this.m_acceptedCrossPromos[_loc2_];
               if(_loc4_.id == param1)
               {
                  return _loc4_;
               }
               _loc2_++;
            }
         }
         return null;
      }
      
      public function initialize(param1:Object, param2:Object) : void
      {
         MessageDispatcher.instance.addEventListener(MessageDispatcher.STARTER_PACK_COMPLETE,this.onStarterPackItemReceived);
         MessageDispatcher.instance.addEventListener(MessageDispatcher.GRANT_FACEBOOK_CREDIT_OFFER1,this.onGrantFacebookCreditOffer1);
         MessageDispatcher.instance.addEventListener(MessageDispatcher.GRANT_FACEBOOK_CREDIT_OFFER2,this.onGrantFacebookCreditOffer2);
         addEventListener(PromoManager.EVENT_DIALOG_ACCEPT,this.onDialogAccept,false,0,true);
         addEventListener(PromoManager.EVENT_DIALOG_DECLINE,this.onDialogDecline,false,0,true);
         MessageDispatcher.instance.addEventListener(MessageDispatcher.GRANT_EP,this.onGrantEp);
         addEventListener(PromoManager.EVENT_SHOWN_ALL_MESSAGES,this.onShownAllMessages,false,0,true);
         Zlab.mainStage.addEventListener(MouseEvent.MOUSE_UP,this.onSawInput);
         Zlab.mainStage.addEventListener(MouseEvent.MOUSE_WHEEL,this.onSawInput);
         Zlab.mainStage.addEventListener(MouseEvent.MOUSE_DOWN,this.onSawInput);
         this.onSawInput();
         this.m_motdsComplete = false;
         MessageOfTheDayManager.instance.addEventListener(MessageOfTheDayManager.EVENT_SHOWN_ALL_MESSAGES,this.onMOTDComplete,false,0,true);
         if(this.getAutoPromotionExperimentVariant() <= AUTOPROMO_EXP_OFF_VARIANT)
         {
            this.evaluatePromotions();
         }
         else
         {
            this.initAutoPromotion();
         }
         this.m_initialized = true;
         this.m_promoMenuItemContainer = UIManager.instance.getChildById(PromoMenuItemContainer.ITEM_ID) as PromoMenuItemContainer;
         dispatchEvent(new Event(INITIALIZED));
         if(ZGlobal.player.enableOnetimePopup && ExperimentsManager.instance.getExperimentVariant("xpromo_holdout") == 2)
         {
            this.m_acceptedCrossPromos = param1;
            this.m_availableCrossPromos = param2;
            this.initMOTD();
         }
         if(ExperimentsManager.instance.getExperimentVariant("xpromo_holdout") == 2)
         {
            this.initHUDIcons();
            this.initRewardCheck();
            this.initFriendCards();
         }
         this.initFriendFlashHUDIcon();
         this.initMechLabDiscountListeners();
         this.initPromotionInstances();
         var _loc3_:int = ZGlobal.player.friendFlashEPBank;
         this.updateFriendFlashUIItem(_loc3_,_loc3_,false);
      }
      
      public function initHUDIcons() : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc1_:uint = 0;
         if(this.HUDIconPresent)
         {
            _loc1_ = 0;
            while(_loc1_ < this.m_availableCrossPromos.length)
            {
               _loc2_ = this.m_availableCrossPromos[_loc1_];
               if(_loc2_.state == CriteriaUtil.XPROMO_STATE_NEW || _loc2_.state == CriteriaUtil.XPROMO_STATE_ACCEPTED)
               {
                  this.m_promoMenuItemContainer.addItem(new XPromoHUDItem(_loc2_));
               }
               _loc1_++;
            }
            _loc1_ = 0;
            while(_loc1_ < this.m_acceptedCrossPromos.length)
            {
               _loc3_ = this.m_acceptedCrossPromos[_loc1_];
               if(_loc3_.state == CriteriaUtil.XPROMO_STATE_NEW || _loc3_.state == CriteriaUtil.XPROMO_STATE_ACCEPTED)
               {
                  this.m_promoMenuItemContainer.addItem(new XPromoHUDItem(_loc3_));
               }
               _loc1_++;
            }
            this.HUDIconPresent = false;
         }
      }
      
      public function onRequestFriendsLoaded(param1:Event) : void
      {
         var _loc2_:int = ZGlobal.player.friendFlashEPBank;
         this.updateFriendFlashUIItem(_loc2_,_loc2_,false);
         this.m_requestFriendsLoaded = true;
         this.showEPReceivedFeedback();
      }
      
      private function getEmpireFriendInfo(param1:String) : Object
      {
         var _loc3_:Object = null;
         var _loc2_:Array = ZGlobal.player.empireFriends;
         if(!_loc2_)
         {
            return null;
         }
         for each(_loc3_ in _loc2_)
         {
            if(String(_loc3_.zid) == param1)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      private function launchEPGiftDialog(param1:Object, param2:Function) : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         if(param1)
         {
            for(_loc3_ in param1)
            {
               _loc4_ = _loc3_.slice(1);
               _loc5_ = param1[_loc3_];
               delete param1[_loc3_];
               _loc6_ = this.getEmpireFriendInfo(_loc4_);
               if(_loc6_)
               {
                  param2(_loc6_,_loc5_);
                  return true;
               }
            }
            param1 = null;
         }
         return false;
      }
      
      private function handleEPGiftReceive(param1:Object, param2:int) : void
      {
         PopupManager.instance.push(new FriendFlashThankYouInput(param1,param2));
      }
      
      private function handleEPThankYouReceive(param1:Object, param2:String) : void
      {
         PopupManager.instance.push(new FriendFlashThankYouReceived(param1,param2));
      }
      
      private function showNextEPReceivedInfo() : void
      {
         if(!this.launchEPGiftDialog(this.m_epReceivedInfo,this.handleEPGiftReceive))
         {
            this.launchEPGiftDialog(this.m_epReceivedThankYouInfo,this.handleEPThankYouReceive);
         }
      }
      
      private function initFriendFlashHUDIcon() : void
      {
         addEventListener(FRIENDFLASH_EP_BANK_CHANGED,this.onFriendFlashEPBankChanged,false,0,true);
         var _loc1_:int = ZGlobal.player.friendFlashEPBank;
         this.updateFriendFlashUIItem(0,_loc1_,false);
      }
      
      private function createOrDestroyFriendFlash(param1:Boolean) : FriendFlashUIItem
      {
         var _loc3_:FriendFlashUIItem = null;
         var _loc2_:FriendFlashUIItem = FriendFlashUIItem.instance;
         if(Boolean(_loc2_) && !param1)
         {
            UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.UI_REMOVE_UI_ITEM,_loc2_));
            return null;
         }
         if(!_loc2_ && param1 && Boolean(this.m_promoMenuItemContainer))
         {
            _loc3_ = new FriendFlashUIItem();
            this.m_promoMenuItemContainer.addItem(_loc3_);
            return _loc3_;
         }
         return _loc2_;
      }
      
      public function sortIcons() : void
      {
         this.m_promoMenuItemContainer.sortIcons();
      }
      
      private function onFriendFlashEPBankChanged(param1:WorldEvent) : void
      {
         this.updateFriendFlashUIItem(param1.eventData.oldAmt,param1.eventData.newAmt,true);
      }
      
      private function updateFriendFlashUIItem(param1:int, param2:int, param3:Boolean) : void
      {
         var _loc4_:Boolean = param1 > 0;
         var _loc5_:Boolean = param2 > 0;
         var _loc6_:FriendFlashUIItem = this.createOrDestroyFriendFlash(_loc5_);
         if(_loc6_)
         {
            _loc6_.setAmount(param2);
         }
         if(param3 && !_loc4_ && _loc5_)
         {
            EPGiftSendFriendSelectDialog.show();
         }
      }
      
      public function initFriendCards() : void
      {
         dispatchEvent(new WorldEvent(XPROMO_ADD_CARD,{
            "availableXPromos":this.m_availableCrossPromos,
            "acceptedXPromos":this.m_acceptedCrossPromos
         }));
      }
      
      private function popupReward(param1:Object) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:GallantPopup = null;
         var _loc6_:GameItem = null;
         if(param1.rewards != undefined)
         {
            _loc2_ = param1.rewards;
            if(_loc2_.length > 0)
            {
               _loc3_ = 0;
               while(_loc3_ < _loc2_.length)
               {
                  _loc6_ = GameItem(ZGlobal.gameSettings.getItemByCode(_loc2_[_loc3_].code,GameItem));
                  if(_loc6_ != null)
                  {
                     ZGlobal.player.addToInventory(_loc2_[_loc3_].code,1);
                  }
                  _loc3_++;
               }
               _loc4_ = {
                  "xPromoItem":param1,
                  "suppressTransaction":true,
                  "dialogLabel":param1.ui.completed_text
               };
               _loc5_ = new XPromoIncentivePopup(_loc4_);
               PopupManager.instance.push(_loc5_,0,false,true,false);
            }
         }
      }
      
      public function initRewardCheck() : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc1_:uint = 0;
         _loc1_ = 0;
         while(_loc1_ < this.m_availableCrossPromos.length)
         {
            _loc2_ = this.m_availableCrossPromos[_loc1_];
            if(_loc2_.justRewarded)
            {
               this.popupReward(_loc2_);
            }
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this.m_acceptedCrossPromos.length)
         {
            _loc3_ = this.m_acceptedCrossPromos[_loc1_];
            if(_loc3_.justRewarded)
            {
               this.popupReward(_loc3_);
            }
            _loc1_++;
         }
      }
      
      public function initMOTD() : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc1_:uint = 0;
         _loc1_ = 0;
         while(_loc1_ < this.m_availableCrossPromos.length)
         {
            _loc2_ = this.m_availableCrossPromos[_loc1_];
            if(_loc2_.state == CriteriaUtil.XPROMO_STATE_NEW)
            {
               PopupManager.instance.push(new XPromoMOTDPopup(_loc2_),0,true,true);
            }
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this.m_acceptedCrossPromos.length)
         {
            _loc3_ = this.m_acceptedCrossPromos[_loc1_];
            if(_loc3_.state == CriteriaUtil.XPROMO_STATE_NEW)
            {
               PopupManager.instance.push(new XPromoMOTDPopup(_loc3_),0,true,true);
            }
            _loc1_++;
         }
      }
      
      public function addSpecialCard(param1:String, param2:MovieClip) : void
      {
         this.m_specialCards[param1] = param2;
         dispatchEvent(new WorldEvent(XPROMO_VISIBLE_CARD,{"specialCards":this.m_specialCards}));
      }
      
      public function isInitialized() : Boolean
      {
         return this.m_initialized;
      }
      
      public function initFromSettings(param1:XMLList) : void
      {
         this.m_xml = param1;
      }
      
      public function get qualifyingPromotion() : String
      {
         return this.m_qualifyingPromotion;
      }
      
      public function get paidThisSession() : Boolean
      {
         return this.m_paidThisSession;
      }
      
      public function getCurrentAutopromotion() : XML
      {
         var _loc1_:String = ZGlobal.player.getOngoingAutopromoName();
         var _loc2_:XML = this.getAutoPromotionByName(_loc1_);
         if(_loc2_ != null)
         {
            return _loc2_;
         }
         return null;
      }
      
      private function initAutoPromotion() : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:XMLList = null;
         this.m_autoPromoOverride = true;
         var _loc1_:String = ZGlobal.player.getOngoingAutopromoName();
         _loc2_ = this.getAutoPromotionByName(_loc1_);
         if(_loc2_ != null)
         {
            _loc3_ = _loc2_.@type;
            switch(_loc3_)
            {
               case AUTOPROMO_TYPE_FLASH:
                  this.m_qualifyingPromotion = PROMO_FLASH_SALE_AUTOPROMO;
                  this.runAutoPromoFlashSale(_loc2_);
                  break;
               case AUTOPROMO_TYPE_FRIENDFLASH:
                  this.m_qualifyingPromotion = PROMO_FRIEND_FLASH;
                  this.openPromoFriendFlash(FriendFlashPopup.SOURCE_AUTO);
                  break;
               case AUTOPROMO_TYPE_FGWP:
                  this.m_qualifyingPromotion = PROMO_REPEAT_PAYER;
                  this.runPromoRepeatPayerPack();
                  break;
               case AUTOPROMO_TYPE_PYOB:
                  this.m_qualifyingPromotion = PROMO_PICK_YOUR_OWN;
                  _loc4_ = _loc2_.child(0);
                  this.m_itemBundleCandidates.push(_loc4_[0]);
                  this.runPromoBundledItemsPromo();
            }
         }
         if(this.m_promoQueue.length == 0)
         {
            dispatchEvent(new WorldEvent(EVENT_SHOWN_ALL_MESSAGES));
         }
         this.checkForPromoRewards();
      }
      
      private function getAutoPromotionByName(param1:String) : XML
      {
         var autoPromotions:XMLList = null;
         var p:XMLList = null;
         var promo:XML = null;
         var promoName:String = param1;
         autoPromotions = this.m_xml.autopromotions.promotions.children();
         p = autoPromotions.(@name == promoName);
         promo = p[0];
         if(promo != null)
         {
            return promo;
         }
         return null;
      }
      
      public function runAutoPromoFlashSale(param1:XML) : void
      {
         var _loc2_:XMLList = this.m_xml.autopromotions.options.children();
         var _loc3_:XMLList = param1.discount;
         var _loc4_:Boolean = false;
         if(ExperimentsManager.instance.getExperimentVariant("empire_flash_sale_special_strings") == 2)
         {
            _loc4_ = true;
         }
         var _loc5_:FlashSalePopup = new FlashSalePopup(param1,_loc2_,_loc3_,_loc4_);
         this.m_promoQueue.push(_loc5_);
         _loc5_.addEventListener(ZGamePopUp.CLOSED,this.onPromoPopupClosed);
         PopupManager.instance.push(_loc5_,0,true,false);
      }
      
      public function getAutoPromotionExperimentVariant() : int
      {
         return ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_AUTOPROMOTIONS);
      }
      
      public function getOngoingAutopromoParamByName(param1:String) : String
      {
         var _loc3_:Array = null;
         var _loc5_:String = null;
         var _loc2_:String = ZGlobal.player.getOngoingAutopromoParams();
         if(_loc2_ == "")
         {
            return "";
         }
         var _loc4_:Array = _loc2_.split("|");
         for each(_loc5_ in _loc4_)
         {
            if(_loc5_.indexOf(param1 + "=") != -1)
            {
               _loc3_ = _loc5_.split("=");
               if(_loc3_[1] != null)
               {
                  return _loc3_[1];
               }
               break;
            }
         }
         return "";
      }
      
      private function evaluatePromotions() : void
      {
         var _loc1_:XML = this.getHighestDiscountEligibleFlashSale();
         if(!(!this.m_urlRedirect && this.evaluateUrlRedirectStarterPack()))
         {
            if(Boolean(_loc1_) && _loc1_.@type == PROMO_FLASH_SALE_CONTROLLED)
            {
               if(ZGlobal.player.meetsCriteriaLowWalletOnly)
               {
                  this.m_qualifyingPromotion = PROMO_FLASH_SALE_CONTROLLED;
                  this.runPromoFlashSale(_loc1_);
               }
            }
            else if(this.meetsCriteriaFriendFlash())
            {
               this.m_qualifyingPromotion = PROMO_FRIEND_FLASH;
               this.openPromoFriendFlash(FriendFlashPopup.SOURCE_AUTO);
            }
            else if(this.meetsCriteriaRepeatPayerPack())
            {
               this.m_qualifyingPromotion = PROMO_REPEAT_PAYER;
               this.runPromoRepeatPayerPack();
            }
            else if(Boolean(_loc1_) && _loc1_.@type == PROMO_FLASH_SALE_NEW_BUYER)
            {
               this.m_qualifyingPromotion = PROMO_FLASH_SALE_NEW_BUYER;
               this.runPromoFlashSale(_loc1_);
            }
            else if(Boolean(_loc1_) && _loc1_.@type == PROMO_FLASH_SALE_DEAD_BUYER)
            {
               this.m_qualifyingPromotion = PROMO_FLASH_SALE_DEAD_BUYER;
               this.runPromoFlashSale(_loc1_);
            }
            else if(this.meetsCriteriaStarterPack())
            {
               this.runPromoStarterPack();
            }
            else if(this.meetsCriteriaUnlimitedEnergy())
            {
               this.m_qualifyingPromotion = PROMO_UNLIMITED_ENERGY;
               this.runUnlimitedEnergySale();
            }
         }
         if(this.meetsCriteriaBundledItemsPromo())
         {
            if(!this.m_qualifyingPromotion)
            {
               this.m_qualifyingPromotion = PROMO_PICK_YOUR_OWN;
            }
            this.runPromoBundledItemsPromo();
         }
         if(this.m_promoQueue.length == 0)
         {
            dispatchEvent(new WorldEvent(EVENT_SHOWN_ALL_MESSAGES));
         }
         this.checkForPromoRewards();
      }
      
      private function onShownAllMessages(param1:WorldEvent) : void
      {
         TransactionManager.addTransaction(new TGetFBCreditPromoStatus(this.onFBCreditPromoStatus));
         if(this.m_recentCashPurchase != null && int(this.m_recentCashPurchase) > 0)
         {
            this.tryAutoPopStoreDialog();
         }
      }
      
      private function onFBCreditPromoStatus(param1:Object) : void
      {
         Logger.print(this,"**** onFBCreditPromoStatus(), result.result is " + param1.result + " (needs to be == 1 to pop dialog)");
         if(param1.result == 1 && FBCreditsPurchasePromptPopup.canShow)
         {
            PopupManager.instance.push(new FBCreditsPurchasePromptPopup(param1.offer1,param1.offer2));
         }
      }
      
      private function evaluateUrlRedirectStarterPack() : Boolean
      {
         var _loc1_:Object = null;
         var _loc2_:String = null;
         var _loc3_:Number = NaN;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:PromoData = null;
         if(ZGame.instance.parameters)
         {
            _loc1_ = {
               "starter1":"5:130",
               "starter2":"5:129",
               "starter3":"5:131"
            };
            _loc2_ = GlobalEngine.getFlashVar("pack") as String;
            if(Boolean(_loc2_) && _loc1_.hasOwnProperty(_loc2_))
            {
               this.m_urlRedirect = true;
               _loc3_ = 1;
               _loc4_ = _loc1_[_loc2_];
               _loc5_ = "email_in_game_v" + ZGlobal.starterBundleVariant + "_code" + _loc4_;
               _loc6_ = new PromoData();
               _loc6_.trackingConfirmPromoKingdom = "MOTDPopup_conf_starter_pack";
               _loc6_.shareFeedFunction = ViralsManager.instance.feedStarterPackShare;
               this.m_currentPromoData = _loc6_;
               this.addEventListener(EVENT_IN_APP_PURCHASE_COMPLETE,this.onAppPurchaseComplete);
               ExternalInterface.call("openInAppPurchaseAPI",ZGlobal.GAME_ID.toString(),ZGlobal.snid.toString(),ZGlobal.snuid,ZGlobal.clientID,_loc4_,_loc3_.toString(),_loc5_);
               return true;
            }
         }
         return false;
      }
      
      public function meetsCriteriaStarterPack(param1:Boolean = true) : Boolean
      {
         if(param1 && (this.meetsCriteriaFlashSale(PROMO_FLASH_SALE_CONTROLLED) || this.meetsCriteriaFlashSale(PROMO_FLASH_SALE_NEW_BUYER) || this.meetsCriteriaFlashSale(PROMO_FLASH_SALE_DEAD_BUYER) || this.meetsCriteriaRepeatPayerPack()))
         {
            return false;
         }
         if(ZGlobal.starterBundleVariant != StarterPackPopup.VARIANT_1 && ZGlobal.starterBundleVariant != StarterPackPopup.VARIANT_2 && ZGlobal.starterBundleVariant != StarterPackPopup.VARIANT_3)
         {
            return false;
         }
         if(ZGlobal.player.level < ZGlobal.gameSettings.getInt("promoLevelMin"))
         {
            return false;
         }
         if((ZGlobal.player.isPayingUser() || this.paidThisSession) && ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_STARTER_PACK_V2) == ExperimentsManager.VARIANT_VALUE_STARTER_PACK_V2_NON_PAYERS)
         {
            return false;
         }
         return ZGlobal.meetsCriteriaStarterPack;
      }
      
      public function meetsCriteriaUnlimitedEnergy(param1:Boolean = true) : Boolean
      {
         var _loc5_:Boolean = false;
         if(param1)
         {
            _loc5_ = this.meetsCriteriaFlashSale(PROMO_FLASH_SALE_CONTROLLED) || this.meetsCriteriaFlashSale(PROMO_FLASH_SALE_NEW_BUYER) || this.meetsCriteriaFlashSale(PROMO_FLASH_SALE_DEAD_BUYER) || this.meetsCriteriaRepeatPayerPack() || this.meetsCriteriaStarterPack();
            if(_loc5_)
            {
               return false;
            }
         }
         var _loc2_:int = ZGlobal.gameSettings.getInt("UnlimitedEnergyMinLevel",6);
         if(ZGlobal.player.level < _loc2_)
         {
            return false;
         }
         var _loc3_:int = ExperimentsManager.instance.getExperimentVariant("empire_unlimited_energy");
         if(_loc3_ != 2)
         {
            return false;
         }
         if(!ZGlobal.player.m_energy.isValidUnlimitedEnergyTarget)
         {
            return false;
         }
         var _loc4_:Number = ZGlobal.player.timeWarpSeconds;
         if(this.m_unlimitedEnergyExpireUnixTimeStamp <= GlobalEngine.serverTime / 1000 + _loc4_)
         {
            return false;
         }
         return true;
      }
      
      private function runPromoStarterPack() : void
      {
         if(ZGlobal.player.getSeenFlag(FLAG_STARTER_PACK_ANNOUNCEMENT_POPUP) == false)
         {
            addEventListener(PromoManager.EVENT_DIALOG_ACCEPT,this.onStarterPackAnnouncementPopupViewed,false,0,true);
            addEventListener(PromoManager.EVENT_DIALOG_DECLINE,this.onStarterPackAnnouncementPopupViewed,false,0,true);
            this.openStarterPackPopup();
         }
      }
      
      public function get unlimitedEnergyLapsedPayersTargets() : XMLList
      {
         return this.m_xml.unlimitedEnergy.lapsedPayersTargets.target;
      }
      
      private function runUnlimitedEnergySale() : void
      {
         if(!ZGlobal.player.m_energy.updateAndCheckUnlimitedEnergy() && !ZGlobal.player.getSeenFlag(FLAG_UNLIMITED_ENERGY_POPUP))
         {
            ZGlobal.player.setSeenFlag(FLAG_UNLIMITED_ENERGY_POPUP);
            this.openUnlimitedEnergyPopup();
         }
      }
      
      public function openStarterPackPopup(param1:Function = null) : void
      {
         var _loc2_:StarterPackPopup = null;
         _loc2_ = new StarterPackPopup(this.m_xml.starterPacks,ZGlobal.starterBundleVariant);
         _loc2_.addEventListener(ZGamePopUp.CLOSED,this.onPromoPopupClosed);
         if(param1 != null)
         {
            _loc2_.addEventListener(ZGamePopUp.CLOSED,param1);
         }
         PopupManager.instance.push(_loc2_);
         this.m_promoQueue.push(_loc2_);
      }
      
      public function meetsCriteriaFriendFlash(param1:Boolean = true) : Boolean
      {
         return ZGlobal.player.meetsCriteriaLowWalletOnly && ZGlobal.player.friendFlashValid;
      }
      
      public function meetsCriteriaRepeatPayerPack(param1:Boolean = true) : Boolean
      {
         if(!ZGlobal.player.meetsCriteriaLowWalletOnly)
         {
            return false;
         }
         if(param1 && this.meetsCriteriaFlashSale(PROMO_FLASH_SALE_CONTROLLED))
         {
            return false;
         }
         var _loc2_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_FREE_GIFT_WITH_PURCHASE);
         if(_loc2_ != 2 && _loc2_ != 3 && _loc2_ != 4)
         {
            return false;
         }
         if(ZGlobal.player.level < 6)
         {
            return false;
         }
         var _loc3_:Boolean = ZGlobal.player.isPayingUser();
         if(_loc2_ == 2 && !_loc3_)
         {
            return false;
         }
         if(_loc2_ == 3 && _loc3_)
         {
            return false;
         }
         var _loc4_:Number = ZGlobal.player.timeWarpSeconds;
         if(this.m_PayerBundleExpireUnixTimeStamp <= GlobalEngine.serverTime / 1000 + _loc4_)
         {
            return false;
         }
         return true;
      }
      
      public function openPromoFriendFlash(param1:String) : void
      {
         var _loc3_:FriendFlashPopup = null;
         var _loc2_:Array = this.friendFlashBundleInfo;
         if(Boolean(_loc2_) && _loc2_.length == 3)
         {
            _loc3_ = new FriendFlashPopup(_loc2_,param1);
            this.m_promoQueue.push(_loc3_);
            _loc3_.addEventListener(ZGamePopUp.CLOSED,this.onPromoPopupClosed);
            PopupManager.instance.push(_loc3_);
         }
      }
      
      private function runPromoRepeatPayerPack() : void
      {
         this.openRepeatPayerPackPopup(true);
      }
      
      public function openRepeatPayerPackPopup(param1:Boolean = false) : void
      {
         var _loc2_:RepeatPayerPopup = null;
         var _loc3_:XMLList = this.starterpacksForRepeatPayer;
         _loc2_ = new RepeatPayerPopup(_loc3_,param1);
         this.m_promoQueue.push(_loc2_);
         _loc2_.addEventListener(ZGamePopUp.CLOSED,this.onPromoPopupClosed);
         PopupManager.instance.push(_loc2_);
      }
      
      public function openUnlimitedEnergyPopup() : void
      {
         var _loc1_:UnlimitedEnergyPopup = new UnlimitedEnergyPopup();
         this.m_promoQueue.push(_loc1_);
         _loc1_.addEventListener(ZGamePopUp.CLOSED,this.onPromoPopupClosed);
         PopupManager.instance.push(_loc1_);
      }
      
      public function getRepeatPayerXML() : XML
      {
         var _loc1_:XML = this.getDataByCodeName(RepeatPayerPopup.REPEAT_PACK_CODE_NAME);
         if(Boolean(_loc1_) && Boolean(_loc1_.requiredDate))
         {
            _loc1_.requiredDate.@end = this.m_PayerBundleExpireTime;
         }
         return _loc1_;
      }
      
      public function get unlimitedEnergyXML() : XML
      {
         var _loc1_:XML = this.m_xml..unlimitedEnergy[0];
         if(Boolean(_loc1_) && Boolean(_loc1_.requiredDate))
         {
            _loc1_.requiredDate.@end = this.m_unlimitedEnergyExpireTime;
         }
         return _loc1_;
      }
      
      public function get friendFlashDateXML() : XML
      {
         var _loc1_:XML = this.getFlashSale(PROMO_FRIEND_FLASH);
         if(Boolean(_loc1_) && Boolean(_loc1_.criteria.requiredDate))
         {
            _loc1_.criteria.requiredDate.@end = this.m_friendFlashExpireTime;
         }
         return _loc1_..criteria[0];
      }
      
      public function get unlimitedEnergyImages() : XMLList
      {
         return this.m_xml.unlimitedEnergy.images..image;
      }
      
      public function getUnlimitedEnergySmallImage(param1:int) : String
      {
         var _loc3_:XML = null;
         var _loc2_:XMLList = this.m_xml.unlimitedEnergy.imagesSmall..image;
         if(param1 < _loc2_.length())
         {
            _loc3_ = _loc2_[param1];
            if(_loc3_.@url != undefined)
            {
               return _loc3_.@url.toString();
            }
         }
         return null;
      }
      
      private function getDataByCodeName(param1:String) : XML
      {
         var _loc2_:XML = null;
         for each(_loc2_ in this.m_xml.starterPacks.starterPack)
         {
            if(_loc2_.attribute("code") == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function setPromoExpireTime(param1:String, param2:String, param3:String) : void
      {
         var expireDate:Date = null;
         var stringAttr:String = param1;
         var timeStampAttr:String = param2;
         var str:String = param3;
         this[timeStampAttr] = 0;
         try
         {
            expireDate = new Date(str);
         }
         catch(e:Error)
         {
            Logger.debug(this,stringAttr,e.message);
         }
         this[stringAttr] = str;
         this[timeStampAttr] = Math.round(expireDate.getTime() / 1000);
      }
      
      public function setPayerBundleExpireTime(param1:String) : void
      {
         this.setPromoExpireTime("m_PayerBundleExpireTime","m_PayerBundleExpireUnixTimeStamp",param1);
      }
      
      public function setUnlimitedEnergyExpireTime(param1:String) : void
      {
         this.setPromoExpireTime("m_unlimitedEnergyExpireTime","m_unlimitedEnergyExpireUnixTimeStamp",param1);
      }
      
      public function setFriendFlashExpireTime(param1:String) : void
      {
         this.setPromoExpireTime("m_friendFlashExpireTime","m_friendFlashExpireUnixTimeStamp",param1);
      }
      
      private function meetsCriteriaFlashSale(param1:String) : Boolean
      {
         var _loc3_:XMLList = null;
         if(param1 == PROMO_FLASH_SALE_CONTROLLED && !ZGlobal.player.meetsCriteriaLowWalletOnly)
         {
            return false;
         }
         var _loc2_:XML = this.getFlashSale(param1);
         if(_loc2_)
         {
            _loc3_ = _loc2_.criteria;
            if(CriteriaUtil.meetsCriteria(_loc3_))
            {
               return true;
            }
         }
         return false;
      }
      
      public function getFlashSale(param1:String) : XML
      {
         var currentPromo:XML = null;
         var flashSales:XMLList = null;
         var flashSale:XMLList = null;
         var type:String = param1;
         if(this.m_autoPromoOverride == true || type == PROMO_FLASH_SALE_AUTOPROMO)
         {
            currentPromo = this.getCurrentAutopromotion();
            if(currentPromo == null)
            {
               return null;
            }
            return currentPromo;
         }
         flashSales = this.m_xml.flashSales.types.flashSale;
         if(flashSales)
         {
            flashSale = flashSales.(@type == type);
            if(Boolean(flashSale) && flashSale.length() > 0)
            {
               return flashSale[0];
            }
         }
         return null;
      }
      
      private function getHighestDiscountEligibleFlashSale() : XML
      {
         var _loc4_:XML = null;
         var _loc5_:int = 0;
         var _loc1_:int = -1;
         var _loc2_:XML = null;
         var _loc3_:Array = this.getEligibleFlashSalesAndPerformVariantOverrides();
         for each(_loc4_ in _loc3_)
         {
            _loc5_ = this.getFlashSaleDiscount(_loc4_);
            if(_loc5_ > _loc1_)
            {
               _loc2_ = _loc4_;
               _loc1_ = _loc5_;
            }
         }
         return _loc2_;
      }
      
      public function getFlashSaleDiscount(param1:XML) : int
      {
         var _loc2_:XMLList = this.getFlashSaleDiscountXML(param1);
         if(_loc2_)
         {
            return _loc2_.@percent;
         }
         return 0;
      }
      
      private function getFlashSaleDiscountXML(param1:XML) : XMLList
      {
         var discount:XMLList = null;
         var flashSaleExperiment:String = null;
         var flashSaleExperimentVariant:int = 0;
         var experimentData:XMLList = null;
         var flashSale:XML = param1;
         flashSaleExperiment = flashSale.experiment.@name;
         flashSaleExperimentVariant = this.getFlashSaleExperimentVariant(flashSaleExperiment);
         experimentData = flashSale.experiment.variant.(@num == flashSaleExperimentVariant);
         if(experimentData)
         {
            if(flashSale.@type == PROMO_FLASH_SALE_DEAD_BUYER && this.qualifiesForHigherDeadBuyerDiscount(flashSale,flashSaleExperimentVariant))
            {
               discount = this.m_xml.flashSales.discounts.discount.(@itemCode == experimentData.@itemCode_higherDiscount);
            }
            else
            {
               discount = this.m_xml.flashSales.discounts.discount.(@itemCode == experimentData.@itemCode);
            }
         }
         return discount;
      }
      
      private function getEligibleFlashSalesAndPerformVariantOverrides() : Array
      {
         var _loc2_:XML = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc1_:Array = new Array();
         var _loc3_:Object = ZGlobal.player.getAllPromos();
         for(_loc4_ in _loc3_)
         {
            if(_loc3_[_loc4_].expireTS > GlobalEngine.serverTime / 1000 + ZGlobal.player.timeWarpSeconds)
            {
               _loc2_ = this.getFlashSale(_loc4_);
               this.overrideExperimentVariant(_loc2_,false);
               _loc1_.push(_loc2_);
               return _loc1_;
            }
         }
         if(this.meetsCriteriaFlashSale(PROMO_FLASH_SALE_NEW_BUYER))
         {
            _loc2_ = this.getFlashSale(PROMO_FLASH_SALE_NEW_BUYER);
            if(Boolean(_loc3_[PROMO_FLASH_SALE_NEW_BUYER]) && _loc3_[PROMO_FLASH_SALE_NEW_BUYER].cooldownTS < GlobalEngine.serverTime / 1000 + ZGlobal.player.timeWarpSeconds)
            {
               _loc5_ = _loc2_.experiment.@name;
               _loc6_ = int(_loc2_.experiment.variant[_loc2_.experiment.variant.length() - 1].@num);
               _loc7_ = ExperimentsManager.instance.getExperimentVariant(_loc5_);
               if(_loc7_ != _loc3_[PROMO_FLASH_SALE_NEW_BUYER].variant)
               {
                  _loc1_.push(_loc2_);
               }
               else if(_loc7_ + _loc3_[PROMO_FLASH_SALE_NEW_BUYER].variantIndex + 1 <= _loc6_ && _loc3_[PROMO_FLASH_SALE_NEW_BUYER].dismiss >= 1)
               {
                  this.overrideExperimentVariant(_loc2_,true);
                  _loc1_.push(_loc2_);
               }
               else if(_loc7_ + _loc3_[PROMO_FLASH_SALE_NEW_BUYER].variantIndex + 1 <= _loc6_ && _loc3_[PROMO_FLASH_SALE_NEW_BUYER].dismiss == 0 || _loc7_ + _loc3_[PROMO_FLASH_SALE_NEW_BUYER].variantIndex + 1 > _loc6_ && _loc7_ + _loc3_[PROMO_FLASH_SALE_NEW_BUYER].variantIndex + 1 < _loc6_ + MAX_FLASH_SALES_VIEWS_AT_HIGHEST_DISCOUNT)
               {
                  this.overrideExperimentVariant(_loc2_,false);
                  _loc1_.push(_loc2_);
               }
            }
            else if(!_loc3_ || !_loc3_[PROMO_FLASH_SALE_NEW_BUYER])
            {
               _loc1_.push(_loc2_);
            }
         }
         else if(this.meetsCriteriaFlashSale(PROMO_FLASH_SALE_DEAD_BUYER))
         {
            _loc2_ = this.getFlashSale(PROMO_FLASH_SALE_DEAD_BUYER);
            if(Boolean(_loc3_[PROMO_FLASH_SALE_DEAD_BUYER]) && _loc3_[PROMO_FLASH_SALE_DEAD_BUYER].cooldownTS < GlobalEngine.serverTime / 1000 + ZGlobal.player.timeWarpSeconds)
            {
               if(!_loc3_[PROMO_FLASH_SALE_DEAD_BUYER].variantIndex == 0 || _loc3_[PROMO_FLASH_SALE_DEAD_BUYER].variantIndex < MAX_FLASH_SALES_VIEWS_AT_HIGHEST_DISCOUNT)
               {
                  _loc1_.push(_loc2_);
               }
            }
            else if(!_loc3_ || !_loc3_[PROMO_FLASH_SALE_DEAD_BUYER])
            {
               _loc1_.push(_loc2_);
            }
         }
         if(this.meetsCriteriaFlashSale(PROMO_FLASH_SALE_CONTROLLED))
         {
            _loc2_ = this.getFlashSale(PROMO_FLASH_SALE_CONTROLLED);
            _loc1_.push(_loc2_);
         }
         return _loc1_;
      }
      
      private function overrideExperimentVariant(param1:XML, param2:Boolean) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:Object = ZGlobal.player.getAllPromos();
         var _loc4_:String = param1.experiment.@name;
         if(param1.@type == PROMO_FLASH_SALE_CONTROLLED && Boolean(_loc3_[PROMO_FLASH_SALE_CONTROLLED]))
         {
            this.m_flashSaleVariantOverrides[_loc4_] = _loc3_[PROMO_FLASH_SALE_CONTROLLED].variant;
         }
         else if(param1.@type == PROMO_FLASH_SALE_NEW_BUYER && Boolean(_loc3_[PROMO_FLASH_SALE_NEW_BUYER]))
         {
            _loc5_ = param2 ? 1 : 0;
            _loc6_ = int(param1.experiment.variant[param1.experiment.variant.length() - 1].@num);
            this.m_flashSaleVariantOverrides[_loc4_] = Math.min(parseInt(_loc3_[PROMO_FLASH_SALE_NEW_BUYER].variant) + parseInt(_loc3_[PROMO_FLASH_SALE_NEW_BUYER].variantIndex) + _loc5_,_loc6_);
         }
         else if(param1.@type == PROMO_FLASH_SALE_DEAD_BUYER && Boolean(_loc3_[PROMO_FLASH_SALE_DEAD_BUYER]))
         {
            this.m_flashSaleVariantOverrides[_loc4_] = _loc3_[PROMO_FLASH_SALE_DEAD_BUYER].variant;
         }
      }
      
      private function getFlashSaleExperimentVariant(param1:String) : int
      {
         if(this.m_flashSaleVariantOverrides.hasOwnProperty(param1))
         {
            return this.m_flashSaleVariantOverrides[param1];
         }
         return ExperimentsManager.instance.getExperimentVariant(param1);
      }
      
      public function runPromoFlashSale(param1:XML) : void
      {
         var flashSaleExperiment:String = null;
         var flashSaleExperimentVariant:int = 0;
         var experimentData:XMLList = null;
         var isSpecial:Boolean = false;
         var options:XMLList = null;
         var discount:XMLList = null;
         var popup:FlashSalePopup = null;
         var flashSale:XML = param1;
         flashSaleExperiment = flashSale.experiment.@name;
         flashSaleExperimentVariant = this.getFlashSaleExperimentVariant(flashSaleExperiment);
         experimentData = flashSale.experiment.variant.(@num == flashSaleExperimentVariant);
         isSpecial = false;
         if(ExperimentsManager.instance.getExperimentVariant("empire_flash_sale_special_strings") == 2)
         {
            isSpecial = true;
         }
         if(experimentData)
         {
            options = this.m_xml.flashSales.defaultOptions.option;
            discount = this.getFlashSaleDiscountXML(flashSale);
            popup = new FlashSalePopup(flashSale,options,discount,isSpecial);
            this.m_promoQueue.push(popup);
            popup.addEventListener(ZGamePopUp.CLOSED,this.onPromoPopupClosed);
            PopupManager.instance.push(popup,0,true,false);
         }
      }
      
      private function qualifiesForHigherDeadBuyerDiscount(param1:XML, param2:int) : Boolean
      {
         var promos:Object = null;
         var experimentData:XMLList = null;
         var deadBuyerFlashSale:XML = param1;
         var flashSaleExperimentVariant:int = param2;
         promos = ZGlobal.player.getAllPromos();
         experimentData = deadBuyerFlashSale.experiment.variant.(@num == flashSaleExperimentVariant);
         if(deadBuyerFlashSale.@type == PROMO_FLASH_SALE_DEAD_BUYER && (Boolean(ZGlobal.player.secondsSinceLastEPPurchase >= ZGameTimeUtil.instance.parseTimeAsSeconds(experimentData.@timeSinceLastEPPurchase_higherDiscount,0)) || Boolean(promos[PROMO_FLASH_SALE_DEAD_BUYER] && promos[PROMO_FLASH_SALE_DEAD_BUYER].variantIndex > 0)))
         {
            return true;
         }
         return false;
      }
      
      public function setFlashSaleExpireTime(param1:String, param2:String) : void
      {
         var _loc3_:XML = null;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         if(param1)
         {
            _loc3_ = this.getFlashSale(param2);
            if(param2 == PROMO_FLASH_SALE_NEW_BUYER || param2 == PROMO_FLASH_SALE_DEAD_BUYER)
            {
               _loc4_ = ZGlobal.player.getAllPromos();
               if((Boolean(_loc4_)) && Boolean(_loc4_[param2]) && _loc4_[param2].expireTS > GlobalEngine.serverTime / 1000 + ZGlobal.player.timeWarpSeconds)
               {
                  param1 = (_loc4_[param2].expireTS * 1000).toString();
               }
               else
               {
                  _loc5_ = ZGameTimeUtil.instance.parseTimeAsSeconds(param1,0) * 1000;
                  param1 = String(GlobalEngine.serverTime + ZGlobal.player.timeWarpSeconds * 1000 + _loc5_);
               }
            }
            if(_loc3_)
            {
               _loc3_.criteria.requiredDate.@end = param1;
            }
         }
      }
      
      public function meetsCriteriaBundledItemsPromo() : Boolean
      {
         var _loc1_:XML = null;
         var _loc2_:XML = null;
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_LABORDAY_2011) != LABOR_DAY_2011_BUNDLE_ENABLED_VARIANT && ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_BUNDLE_BY_WALLET) != BUNDLE_BY_WALLET_ENABLED_VARIANT && ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_BUNDLE_PICK_YOUR_OWN) < BUNDLE_PICK_YOUR_OWN_ENABLED_MIN_VARIANT)
         {
            return false;
         }
         if(Boolean(this.m_xml) && Boolean(this.m_xml.itemBundles))
         {
            for each(_loc1_ in this.m_xml.itemBundles.itemBundle)
            {
               if(CriteriaUtil.meetsCriteria(_loc1_.criteria))
               {
                  if(!(_loc1_.@type == PROMO_PICK_YOUR_OWN && (Boolean(this.m_qualifyingPromotion) || Boolean(_loc1_.@itemChoices == undefined))))
                  {
                     if(!(_loc1_.@manualTrigger != undefined && _loc1_.@manualTrigger == "true"))
                     {
                        this.m_itemBundleCandidates.push(_loc1_);
                     }
                  }
               }
            }
         }
         this.m_itemBundleCandidates.sort(this.compareBundledItemsCriteria);
         this.m_itemBundleSequelsPending = 0;
         for each(_loc1_ in this.m_itemBundleCandidates)
         {
            if(_loc1_.@sequel != undefined)
            {
               for each(_loc2_ in this.m_itemBundleCandidates)
               {
                  if(_loc2_.@name.toString() == _loc1_.@sequel.toString())
                  {
                     ++this.m_itemBundleSequelsPending;
                     break;
                  }
               }
            }
         }
         return this.m_itemBundleCandidates.length > 0;
      }
      
      private function compareBundledItemsCriteria(param1:XML, param2:XML) : Number
      {
         if(param1.@priority == param2.@priority)
         {
            return 0;
         }
         return param1.@priority - param2.@priority;
      }
      
      private function runPromoBundledItemsPromo() : void
      {
         this.openBundledItemsPromoPopup();
      }
      
      private function initMechLabDiscountListeners() : void
      {
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_COMPLETE_HOST,this.onBattleEnd);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_PAUSE,this.onBattleEnd);
         VisitorManager.instance.addEventListener(VisitorManager.WORLD_LOADED,this.onWorldLoaded);
      }
      
      private function initPromotionInstances() : void
      {
         LowEPPromotion.instance.initialize();
         if(LowEPPromotion.instance.canRunPromotion)
         {
            Zlab.processManager.schedule(LowEPPromotion.instance.popupDelay * 1000,this,this.tryRunLowEPPromotion);
         }
      }
      
      private function tryRunLowEPPromotion() : void
      {
         if(Boolean(this.m_promoQueue.length) || Boolean(PopupManager.instance.windows.length) || Boolean(WindowManager.instance.windows.length) || this.secondsInactive < LowEPPromotion.instance.inactiveDelay)
         {
            Zlab.processManager.schedule(500,this,this.tryRunLowEPPromotion);
         }
         else
         {
            LowEPPromotion.instance.runPromotion();
         }
      }
      
      private function onBattleEnd(param1:WorldEvent) : void
      {
         if(!ZGlobal.isHome())
         {
            this.m_exitedBattle = true;
         }
         else
         {
            if(this.meetsCriteriaMechLabDiscountPromo())
            {
               this.runPromoMechLabDiscountPromo();
            }
            this.m_exitedBattle = false;
         }
      }
      
      private function onWorldLoaded(param1:Event) : void
      {
         if(ZGlobal.isHome() && this.m_exitedBattle)
         {
            if(this.meetsCriteriaMechLabDiscountPromo())
            {
               this.runPromoMechLabDiscountPromo();
            }
         }
         this.m_exitedBattle = false;
      }
      
      private function getMechLabDisountPromo() : XML
      {
         var _loc1_:XML = null;
         if(Boolean(this.m_xml) && Boolean(this.m_xml.itemBundles))
         {
            for each(_loc1_ in this.m_xml.itemBundles.itemBundle)
            {
               if(_loc1_.@type != undefined && _loc1_.@type == PROMO_MECH_LAB_DISCOUNT)
               {
                  return _loc1_;
               }
            }
         }
         return null;
      }
      
      public function meetsCriteriaMechLabDiscountPromo() : Boolean
      {
         var _loc2_:Object = null;
         var _loc1_:XML = this.getMechLabDisountPromo();
         if(Boolean(_loc1_) && CriteriaUtil.meetsCriteria(_loc1_.criteria))
         {
            if(ZGlobal.isHome() && WorldObjectManager.instance.getNumberObjectsWithCode(_loc1_.@buildingItemCode) > 0 && WorldObjectManager.instance.getNumberBuiltObjectsWithCode(_loc1_.@buildingItemCode) == 0)
            {
               _loc2_ = ZGlobal.player.getTag(MECH_LAB_DISCOUNT_TAG);
               if(!_loc2_ || !_loc2_.seen || GlobalEngine.serverTime / 1000 + ZGlobal.player.timeWarpSeconds - _loc2_.seen >= MECH_LAB_DISCOUNT_THROTTLE)
               {
                  if(MechLabDiscountPromoPopup.anyPartsNeeded(_loc1_))
                  {
                     return true;
                  }
               }
            }
         }
         return false;
      }
      
      public function runPromoMechLabDiscountPromo() : void
      {
         var _loc2_:Object = null;
         var _loc3_:GallantPopup = null;
         var _loc1_:XML = this.getMechLabDisountPromo();
         if(_loc1_)
         {
            _loc2_ = {"seen":GlobalEngine.serverTime / 1000 + ZGlobal.player.timeWarpSeconds};
            ZGlobal.player.setTag(MECH_LAB_DISCOUNT_TAG,_loc2_);
            TransactionManager.addTransaction(new TSetTag(MECH_LAB_DISCOUNT_TAG,_loc2_));
            _loc3_ = new MechLabDiscountPromoPopup(_loc1_);
            addEventListener(BUNDLE_POPUP_CLOSED,this.onBundlePopupClosed,false,0,true);
            _loc3_.addEventListener(ZGamePopUp.CLOSED,this.onPromoPopupClosed);
            PopupManager.instance.push(_loc3_);
            this.m_promoQueue.push(_loc3_);
         }
      }
      
      public function get availableCrossPromos() : Object
      {
         return this.m_availableCrossPromos;
      }
      
      public function get acceptedCrossPromos() : Object
      {
         return this.m_acceptedCrossPromos;
      }
      
      public function openBundledItemsPromoPopup(param1:String = null) : void
      {
         var _loc3_:GallantPopup = null;
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         if(param1 != null)
         {
            _loc2_ = -1;
            _loc4_ = 0;
            while(_loc4_ < this.m_itemBundleCandidates.length)
            {
               if(this.m_itemBundleCandidates[_loc4_].@name == param1)
               {
                  _loc2_ = _loc4_;
                  break;
               }
               _loc4_++;
            }
            if(_loc2_ < 0)
            {
               return;
            }
         }
         if(this.m_itemBundleCandidates[_loc2_].@type == PROMO_PICK_YOUR_OWN)
         {
            _loc3_ = new PickYourOwnPromoPopup(this.m_itemBundleCandidates[_loc2_]);
         }
         else
         {
            _loc3_ = new BundledItemsPromoPopup(this.m_itemBundleCandidates[_loc2_]);
         }
         this.addEventListener(BUNDLE_POPUP_CLOSED,this.onBundlePopupClosed,false,0,true);
         _loc3_.addEventListener(ZGamePopUp.CLOSED,this.onPromoPopupClosed);
         PopupManager.instance.push(_loc3_);
         this.m_promoQueue.push(_loc3_);
      }
      
      public function setBundleExpireTime(param1:String, param2:String) : void
      {
         var expireDate:Date = null;
         var itemBundle:XML = null;
         var type:String = param1;
         var str:String = param2;
         if(Boolean(type) && Boolean(str))
         {
            try
            {
               expireDate = new Date(str);
            }
            catch(e:Error)
            {
               Logger.debug(this,"setBundleExpireTime",e.message);
            }
            if(Boolean(this.m_xml) && Boolean(this.m_xml.itemBundles))
            {
               for each(itemBundle in this.m_xml.itemBundles.itemBundle)
               {
                  if(itemBundle.@type != undefined && itemBundle.@type.toString() == type)
                  {
                     itemBundle.criteria.requiredDate.@end = str;
                  }
               }
            }
         }
      }
      
      public function setPickYourOwnVariables(param1:Object) : void
      {
         var _loc2_:XML = null;
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Array = null;
         var _loc9_:Array = null;
         var _loc10_:Array = null;
         var _loc11_:XML = null;
         var _loc12_:String = null;
         var _loc13_:String = null;
         if(PromoManager.instance.getAutoPromotionExperimentVariant() <= AUTOPROMO_EXP_OFF_VARIANT)
         {
            if(Boolean(this.m_xml) && Boolean(this.m_xml.itemBundles))
            {
               for each(_loc2_ in this.m_xml.itemBundles.itemBundle)
               {
                  if(_loc2_.@type != undefined && _loc2_.@type.toString() == PROMO_PICK_YOUR_OWN)
                  {
                     if(_loc2_.criteria.cash.@minMaxVar != undefined && param1.hasOwnProperty(_loc2_.criteria.cash.@minMaxVar))
                     {
                        _loc3_ = ZGlobal.player.cash;
                        _loc4_ = param1[_loc2_.criteria.cash.@minMaxVar].split(";");
                        _loc5_ = -1;
                        _loc6_ = -1;
                        _loc7_ = 0;
                        while(_loc7_ < _loc4_.length)
                        {
                           _loc8_ = _loc4_[_loc7_].split(",");
                           if(_loc8_.length == 2)
                           {
                              if(_loc3_ >= _loc8_[0] && _loc3_ <= _loc8_[1] && _loc8_[1] > _loc5_)
                              {
                                 _loc5_ = int(_loc8_[1]);
                                 _loc6_ = _loc7_;
                              }
                           }
                           _loc7_++;
                        }
                        if(_loc6_ == -1)
                        {
                           _loc6_ = 0;
                        }
                        _loc8_ = _loc4_[_loc6_].split(",");
                        if(_loc8_.length == 2 && _loc2_.@itemChoicesVar != undefined && param1.hasOwnProperty(_loc2_.@itemChoicesVar))
                        {
                           _loc9_ = param1[_loc2_.@itemChoicesVar].split(";");
                           if(_loc9_.length > _loc6_)
                           {
                              _loc2_.criteria.cash.@min = _loc8_[0];
                              _loc2_.criteria.cash.@max = _loc8_[1];
                              _loc2_.@itemChoices = _loc9_[_loc6_];
                           }
                        }
                     }
                     if(_loc2_.criteria.cash.@min == undefined || _loc2_.criteria.cash.@max == undefined)
                     {
                        _loc2_.criteria.cash.@min = int.MAX_VALUE;
                        _loc2_.criteria.cash.@max = int.MAX_VALUE;
                     }
                     if(_loc2_.@titleVar != undefined && param1.hasOwnProperty(_loc2_.@titleVar))
                     {
                        _loc2_.@title = param1[_loc2_.@titleVar];
                     }
                     if(_loc2_.criteria.seenFlag.@minMaxVar != undefined && param1.hasOwnProperty(_loc2_.criteria.seenFlag.@minMaxVar))
                     {
                        _loc10_ = param1[_loc2_.criteria.seenFlag.@minMaxVar].split(",");
                        if(_loc10_.length == 2)
                        {
                           _loc2_.criteria.seenFlag.@min = _loc10_[0];
                           _loc2_.criteria.seenFlag.@max = _loc10_[1];
                        }
                     }
                     if(_loc2_.criteria.requiredDate.@endVar != undefined && param1.hasOwnProperty(_loc2_.criteria.requiredDate.@endVar))
                     {
                        _loc2_.criteria.requiredDate.@end = param1[_loc2_.criteria.requiredDate.@endVar];
                     }
                  }
               }
            }
         }
         else
         {
            _loc11_ = this.getCurrentAutopromotion();
            _loc2_ = _loc11_..itemBundle[0];
            _loc12_ = ZGlobal.player.getOnGoingAutopromoExpireTime();
            _loc2_.criteria.requiredDate.@end = _loc12_;
            _loc13_ = PromoManager.instance.getOngoingAutopromoParamByName("items");
            _loc2_.@itemChoices = _loc13_;
         }
      }
      
      public function getPickYourOwnXML() : XML
      {
         var _loc1_:XML = null;
         if(Boolean(this.m_xml) && Boolean(this.m_xml.itemBundles))
         {
            for each(_loc1_ in this.m_xml.itemBundles.itemBundle)
            {
               if(_loc1_.@type != undefined && _loc1_.@type.toString() == PROMO_PICK_YOUR_OWN)
               {
                  return _loc1_;
               }
            }
         }
         return null;
      }
      
      private function onDialogAccept(param1:WorldEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         if(WindowManager.isFullScreen())
         {
            WindowManager.toggleFullScreen();
         }
         if(param1.eventData != null && param1.eventData.hasOwnProperty("packageType"))
         {
            _loc2_ = param1.eventData.packageType;
            _loc3_ = "";
            if(param1.eventData.phylum)
            {
               _loc3_ = param1.eventData.phylum;
            }
            _loc4_ = param1.eventData.quantity ? int(param1.eventData.quantity) : 1;
            if(this.m_currentPromoData)
            {
               Logger.debug(this,"onDialogAccept","Warning, m_currentPromoData already is set to something...");
            }
            this.m_currentPromoData = param1.eventData.promoData;
            this.addEventListener(EVENT_IN_APP_PURCHASE_COMPLETE,this.onAppPurchaseComplete);
            ExternalInterface.call("openInAppPurchaseAPI",ZGlobal.GAME_ID.toString(),ZGlobal.snid.toString(),ZGlobal.snuid,ZGlobal.clientID,_loc2_,_loc4_.toString(),_loc3_);
         }
      }
      
      public function buyBuildMenuStarterPack(param1:String) : void
      {
         if(WindowManager.isFullScreen())
         {
            WindowManager.toggleFullScreen();
         }
         var _loc2_:XML = this.getStarterPackPaymentFromCodeName(param1);
         if(!_loc2_ || _loc2_.@itemCode == undefined)
         {
            return;
         }
         if(this.m_currentPromoData)
         {
            Logger.debug(this,"onDialogAccept","Warning, m_currentPromoData already is set to something...");
         }
         var _loc3_:PromoData = new PromoData();
         _loc3_.trackingConfirmPromoKingdom = "buildmenu_starter_pack";
         _loc3_.shareFeedFunction = ViralsManager.instance.feedStarterPackShare;
         _loc3_.fromBuildMenu = true;
         this.m_currentPromoData = _loc3_;
         this.addEventListener(EVENT_IN_APP_PURCHASE_COMPLETE,this.onAppPurchaseComplete);
         var _loc4_:String = "build_menu_starterpack_surfacing";
         var _loc5_:String = "1";
         ExternalInterface.call("openInAppPurchaseAPI",ZGlobal.GAME_ID.toString(),ZGlobal.snid.toString(),ZGlobal.snuid,ZGlobal.clientID,_loc2_.@itemCode.toString(),_loc5_,_loc4_);
      }
      
      private function onDialogDecline(param1:WorldEvent) : void
      {
         this.m_currentPromoData = null;
      }
      
      private function onMOTDComplete(param1:Event) : void
      {
         this.m_motdsComplete = true;
      }
      
      private function tryAutoPopStoreDialog() : void
      {
         if(this.m_motdsComplete)
         {
            this.autoPopStoreDialog();
         }
         else
         {
            Zlab.processManager.schedule(2000,this,this.tryAutoPopStoreDialog);
         }
      }
      
      private function onAppPurchaseComplete(param1:WorldEvent) : void
      {
         var _loc2_:ZGamePopUp = null;
         var _loc3_:int = 0;
         this.removeEventListener(EVENT_IN_APP_PURCHASE_COMPLETE,this.onAppPurchaseComplete);
         if(param1.eventData == null || param1.eventData.success == false)
         {
            Logger.debug(this,"onAppPurchaseComplete","Payments says this failed");
            return;
         }
         this.m_paidThisSession = true;
         if(this.m_currentPromoData)
         {
            if(Boolean(this.m_currentPromoData.popup) && this.m_currentPromoData.popup is FriendFlashPopup)
            {
               _loc3_ = (this.m_currentPromoData.popup as FriendFlashPopup).bonusAmountSelected;
               ZGlobal.player.friendFlashEPBank += _loc3_;
            }
            else if(this.m_currentPromoData.fromBuildMenu)
            {
               _loc2_ = new StarterPackRewardPopup(this.m_currentPromoData);
               PopupManager.instance.push(_loc2_);
               this.m_promoQueue.unshift(_loc2_);
            }
            else if(this.m_currentPromoData.congratsPopup)
            {
               _loc2_ = new this.m_currentPromoData.congratsPopup();
               PopupManager.instance.push(_loc2_);
            }
            else if(Boolean(this.m_currentPromoData.popup) && !(this.m_currentPromoData.popup is FlashSalePopup))
            {
               _loc2_ = new StarterPackRewardPopup(this.m_currentPromoData);
               PopupManager.instance.push(_loc2_);
               this.m_promoQueue.unshift(_loc2_);
            }
            if(this.m_currentPromoData.popup)
            {
               this.m_currentPromoData.popup.forceClose();
            }
            this.m_currentPromoData = null;
         }
         this.autoPopStoreDialog();
         if(this.m_urlRedirect)
         {
            this.evaluatePromotions();
            this.m_urlRedirect = false;
         }
      }
      
      private function autoPopStoreDialog() : void
      {
         if(ExperimentsManager.instance.experimentObjectEnabled(ExperimentsManager.EXPERIMENT_AUTOPOP_STORE))
         {
            UI.instance.displayStoreDialog({"tab":Store.TAB_NEW_ITEMS_LABEL});
         }
      }
      
      private function onPromoPopupClosed(param1:Event) : void
      {
         param1.currentTarget.removeEventListener(ZGamePopUp.CLOSED,this.onPromoPopupClosed);
         if(this.m_promoQueue.length > 0)
         {
            this.m_promoQueue.shift();
         }
         if(this.m_promoQueue.length == 0 && this.m_itemBundleSequelsPending == 0)
         {
            dispatchEvent(new WorldEvent(EVENT_SHOWN_ALL_MESSAGES));
         }
      }
      
      private function onStarterPackAnnouncementPopupViewed(param1:WorldEvent) : void
      {
         removeEventListener(PromoManager.EVENT_DIALOG_ACCEPT,this.onStarterPackAnnouncementPopupViewed);
         removeEventListener(PromoManager.EVENT_DIALOG_DECLINE,this.onStarterPackAnnouncementPopupViewed);
         ZGlobal.player.setSeenFlag(FLAG_STARTER_PACK_ANNOUNCEMENT_POPUP);
      }
      
      private function onStarterPackItemReceived(param1:WorldEvent) : void
      {
         var _loc2_:String = null;
         var _loc4_:GameItem = null;
         var _loc5_:String = null;
         var _loc3_:Array = [];
         if(param1.eventData == null)
         {
            Logger.debug(this,"onStarterPackItemReceived","No data received!!!");
            return;
         }
         if(param1.eventData.ep)
         {
            ZGlobal.player.cash += parseInt(param1.eventData.ep);
            this.toasterDisplayResourceUpdate("Cash",param1.eventData.ep);
         }
         if(param1.eventData.coins)
         {
            ZGlobal.player.coins += parseInt(param1.eventData.coins);
            this.toasterDisplayResourceUpdate("Coins",param1.eventData.coins);
         }
         _loc2_ = param1.eventData.item_codes as String;
         if(_loc2_)
         {
            _loc3_ = _loc2_.split(",");
         }
         for each(_loc5_ in _loc3_)
         {
            ZGlobal.player.addToInventory(_loc5_);
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc5_,GameItem) as GameItem;
            PlayerFeedbackManager.instance.displayToaster(ZGameUtils.ZlocT("Main","FeedbackGiftReceived",{"item":_loc4_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME)}),null,true);
         }
      }
      
      private function onGrantFacebookCreditOffer1(param1:WorldEvent) : void
      {
         Logger.print(this,"**** onGrantFacebookCreditOffer1, sending TSetFBCreditParticipation transaction to server and initiating ExternalInterface call to openInAppPurchaseAPI for item 6:167");
         TransactionManager.addTransaction(new TSetFBCreditParticipation());
         var _loc2_:String = "facebook_credits_discount_conversion";
         var _loc3_:String = "1";
         ExternalInterface.call("openInAppPurchaseAPI",ZGlobal.GAME_ID.toString(),ZGlobal.snid.toString(),ZGlobal.snuid,ZGlobal.clientID,"6:167",_loc3_,_loc2_);
      }
      
      private function onGrantFacebookCreditOffer2(param1:WorldEvent) : void
      {
         var _loc2_:String = param1.eventData.code as String;
         var _loc3_:Number = 1;
         Logger.print(this,"**** onGrantFacebookCreditOffer2(), code is " + _loc2_);
         if(param1.eventData.quantity !== undefined)
         {
            _loc3_ = parseInt(param1.eventData.quantity);
         }
         this.grantRewardBundle(_loc2_,_loc3_);
         var _loc4_:String = this.getFirstItemRewardInBundle(_loc2_);
         PopupManager.instance.push(new FBCreditsPurchaseConfirmationPopup(_loc4_));
      }
      
      public function grantRewardBundle(param1:String, param2:int = 1) : void
      {
         var _loc4_:XML = null;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:GameItem = null;
         Logger.print(this,"**** grantRewardBundle(), code is " + param1);
         var _loc3_:XML = this.getRewardBundle(param1);
         if(_loc3_)
         {
            for each(_loc4_ in _loc3_.reward)
            {
               _loc5_ = param2;
               if(_loc4_.@quantity != undefined)
               {
                  _loc5_ *= _loc4_.@quantity;
               }
               _loc6_ = {"amount":_loc5_};
               _loc7_ = _loc4_.@type.toString();
               switch(_loc7_)
               {
                  case "item":
                     _loc8_ = _loc4_.@code;
                     if(_loc8_)
                     {
                        Logger.print(this,"**** grantRewardBundle(), adding " + _loc5_ + " of item code " + _loc8_);
                        ZGlobal.player.addToInventory(_loc8_,_loc5_);
                        _loc9_ = ZGlobal.gameSettings.getItemByCode(_loc8_,GameItem) as GameItem;
                        _loc6_.item = _loc9_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME);
                        if(_loc5_ > 1)
                        {
                           PlayerFeedbackManager.instance.displayToaster(ZGameUtils.ZlocT("Main","FeedbackResourcesGiftReceived",_loc6_),null,true);
                        }
                        else
                        {
                           PlayerFeedbackManager.instance.displayToaster(ZGameUtils.ZlocT("Main","FeedbackGiftReceived",_loc6_),null,true);
                        }
                     }
                     break;
                  case "cash":
                     Logger.print(this,"**** grantRewardBundle(), adding " + _loc5_ + " CASH");
                     ZGlobal.player.cash += _loc5_;
                     _loc6_.item = ZGameUtils.ZlocT("Main","Cash");
                     PlayerFeedbackManager.instance.displayToaster(ZGameUtils.ZlocT("Main","FeedbackResourcesEpReceived",_loc6_),null,true);
               }
            }
         }
      }
      
      private function getFirstItemRewardInBundle(param1:String) : String
      {
         var _loc3_:XML = null;
         var _loc2_:XML = this.getRewardBundle(param1);
         if(_loc2_)
         {
            for each(_loc3_ in _loc2_.reward)
            {
               if(_loc3_.@type.toString() == "item" && _loc3_.@code != undefined)
               {
                  return _loc3_.@code.toString();
               }
            }
         }
         return null;
      }
      
      private function getRewardBundle(param1:String) : XML
      {
         var _loc2_:XML = null;
         for each(_loc2_ in this.m_xml.rewardBundles.rewardBundle)
         {
            if(_loc2_.@code == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function onGrantEp(param1:WorldEvent) : void
      {
         this.autoPopStoreDialog();
         TransactionManager.addTransaction(new TSetTag(LowEPPopup.TAG_LOW_EP_POPUP_VIEWCOUNT,0));
      }
      
      private function onBundlePopupClosed(param1:WorldEvent) : void
      {
         var _loc2_:int = 0;
         this.removeEventListener(BUNDLE_POPUP_CLOSED,this.onBundlePopupClosed);
         if(Boolean(param1.eventData) && Boolean(param1.eventData.bundleName))
         {
            _loc2_ = 0;
            while(_loc2_ < this.m_itemBundleCandidates.length)
            {
               if(this.m_itemBundleCandidates[_loc2_].@name == param1.eventData.bundleName)
               {
                  if(this.m_itemBundleCandidates[_loc2_].@sequel != undefined)
                  {
                     --this.m_itemBundleSequelsPending;
                     this.openBundledItemsPromoPopup(this.m_itemBundleCandidates[_loc2_].@sequel);
                     return;
                  }
               }
               _loc2_++;
            }
         }
      }
      
      private function checkForPromoRewards() : void
      {
         if(ExperimentsManager.instance.getExperimentVariant("empire_aw_xpromo_reward") == this.CHECK_AW_XPROMO_REWARD)
         {
            TransactionManager.addTransaction(new TCheckForPromoRewards("CP_AW1"));
         }
         if(ExperimentsManager.instance.getExperimentVariant("empire_mw2_xpromo_reward") == this.CHECK_MW2_XPROMO_REWARD)
         {
            TransactionManager.addTransaction(new TCheckForPromoRewards("CP_MW2"));
         }
         if(ExperimentsManager.instance.getExperimentVariant("empire_castle_xpromo_master") >= this.CHECK_CASTLE_XPROMO_REWARD && ExperimentsManager.instance.getExperimentVariant("empire_castle_xpromo_reward") == this.CHECK_CASTLE_XPROMO_REWARD)
         {
            TransactionManager.addTransaction(new TCheckForPromoRewards("CP_Castle"));
         }
         if(ExperimentsManager.instance.getExperimentVariant("empire_hiddenchronicles_xpromo_reward") == this.CHECK_HC_XPROMO_REWARD && CriteriaUtil.xpromoAcceptedState(HCxPromoUIItem.XPROMO_ID,CriteriaUtil.XPROMO_STATE_COMPLETED))
         {
            TransactionManager.addTransaction(new TCheckForPromoRewards("CP_HC"));
         }
      }
      
      public function get promoOverrides() : Object
      {
         return this.m_promoOverrides;
      }
      
      public function set promoOverrides(param1:Object) : void
      {
         this.m_promoOverrides = param1;
      }
      
      public function get buildableDiscounts() : Object
      {
         return this.m_buildableDiscounts;
      }
      
      public function set buildableDiscounts(param1:Object) : void
      {
         this.m_buildableDiscounts = param1;
      }
      
      public function get impulsePurchases() : Object
      {
         return this.m_impulsePurchases;
      }
      
      public function set impulsePurchases(param1:Object) : void
      {
         this.m_impulsePurchases = param1;
      }
      
      public function get unlimitedEnergyData() : Array
      {
         return this.m_unlimitedEnergyData;
      }
      
      public function playerHasValidDiscountBuilding() : String
      {
         var code:String = null;
         var endDate:String = null;
         var expireDate:Date = null;
         var currentDate:Date = null;
         var numOwned:int = 0;
         var ed:Object = null;
         for(code in this.m_buildableDiscounts)
         {
            endDate = this.m_buildableDiscounts[code].expiration;
            expireDate = null;
            try
            {
               expireDate = new Date(this.m_buildableDiscounts[code].expiration);
            }
            catch(e:Error)
            {
               Logger.debug(this,m_buildableDiscounts[code].expiration,e.message);
            }
            if(expireDate)
            {
               currentDate = new Date();
               if(currentDate.getTime() <= expireDate.getTime())
               {
                  numOwned = WorldObjectManager.instance.getNumberObjectsWithCode(code);
                  if(numOwned > 0)
                  {
                     ed = new Object();
                     ed.code = code;
                     ed.itemExists = false;
                     dispatchEvent(new WorldEvent(EVENT_REQUEST_INCOMPLETE_BUILDABLES,ed));
                     if(ed.itemExists)
                     {
                        return code;
                     }
                  }
               }
            }
         }
         return null;
      }
      
      public function getEndDate(param1:String) : String
      {
         if(Boolean(this.m_buildableDiscounts) && Boolean(this.m_buildableDiscounts[param1]))
         {
            return this.m_buildableDiscounts[param1].expiration;
         }
         return null;
      }
      
      public function set unlimitedEnergyData(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:XMLList = null;
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         if(param1)
         {
            _loc2_ = 0;
            _loc3_ = ExperimentsManager.instance.getExperimentVariant("empire_unlimited_energy_cost");
            _loc4_ = this.unlimitedEnergyImages;
            for each(_loc5_ in param1)
            {
               if(_loc5_.hasOwnProperty("duration") && _loc5_.hasOwnProperty("costs") && _loc5_.costs is Array && _loc3_ < _loc5_.costs.length && _loc2_ < _loc4_.length())
               {
                  _loc6_ = ZGameTimeUtil.instance.parseTimeAsSeconds(_loc5_.duration,0);
                  _loc7_ = int(_loc5_.costs[_loc3_]);
                  _loc8_ = ZGlobal.getAssetURL(_loc4_[_loc2_].@url.toString());
                  this.m_unlimitedEnergyData.push({
                     "duration":_loc6_,
                     "cost":_loc7_,
                     "image":_loc8_
                  });
               }
               _loc2_++;
            }
         }
      }
      
      public function set recentCashPurchase(param1:String) : void
      {
         this.m_recentCashPurchase = param1;
      }
      
      public function get starterPackSurfacingEnabled() : Boolean
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_STARTER_PACK_SURFACING);
         if(_loc1_ != ExperimentsManager.VARIANT_STARTER_PACK_SURFACING)
         {
            return false;
         }
         if(!this.meetsCriteriaStarterPack(false))
         {
            return false;
         }
         return true;
      }
      
      private function toasterDisplayResourceUpdate(param1:String, param2:Number) : void
      {
         var _loc3_:String = ZGameUtils.ZlocT("Main",param1);
         PlayerFeedbackManager.instance.displayToaster(ZGameUtils.ZlocT("Main","FeedbackResourcesGiftReceived",{
            "item":_loc3_,
            "amount":param2
         }),null,true);
      }
      
      public function getStarterPackPaymentFromCodeName(param1:String) : XML
      {
         var _loc3_:XML = null;
         var _loc2_:XMLList = this.m_xml.starterPacks;
         for each(_loc3_ in _loc2_.starterPackPayment)
         {
            if(_loc3_.attribute("code") == param1)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      private function onSawInput(param1:Event = null) : void
      {
         this.m_lastInputTS = GlobalEngine.currentTime;
      }
      
      public function get secondsInactive() : Number
      {
         return (GlobalEngine.currentTime - this.m_lastInputTS) / 1000;
      }
      
      public function getEPItemXMLForPricePoint(param1:Number) : XML
      {
         var _loc4_:XML = null;
         var _loc2_:XML = null;
         var _loc3_:Number = Number.MAX_VALUE;
         for each(_loc4_ in this.m_xml.epPackages.epPackage)
         {
            if(Math.abs(_loc4_.@cost - param1) < _loc3_)
            {
               _loc2_ = _loc4_;
               _loc3_ = Math.abs(_loc4_.@cost - param1);
            }
         }
         return _loc2_;
      }
      
      public function getEPItemXMLForEP(param1:Number) : XML
      {
         var _loc4_:XML = null;
         var _loc2_:XML = null;
         var _loc3_:Number = Number.MAX_VALUE;
         for each(_loc4_ in this.m_xml.epPackages.epPackage)
         {
            if(Math.abs(_loc4_.@ep - param1) < _loc3_)
            {
               _loc2_ = _loc4_;
               _loc3_ = Math.abs(_loc4_.@ep - param1);
            }
         }
         return _loc2_;
      }
      
      private function get flashFriendOffers() : Dictionary
      {
         var _loc6_:XML = null;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         var _loc1_:Dictionary = new Dictionary();
         var _loc2_:XML = this.getFlashSale(PROMO_FRIEND_FLASH);
         if(!_loc2_)
         {
            return _loc1_;
         }
         var _loc3_:XMLList = _loc2_.offer;
         var _loc4_:String = String(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_FRIEND_FLASH_GIFT_SIZE));
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_.length())
         {
            _loc6_ = _loc3_[_loc5_];
            if(!(_loc6_.@variants == undefined || _loc6_.@cost == undefined))
            {
               _loc7_ = _loc6_.@variants.toString();
               _loc8_ = _loc7_.split(",");
               if(_loc8_.indexOf(_loc4_) >= 0)
               {
                  _loc1_[_loc6_.@cost.toString()] = _loc6_;
               }
            }
            _loc5_++;
         }
         return _loc1_;
      }
      
      private function get flashFriendBundles() : Array
      {
         var _loc5_:XML = null;
         var _loc6_:String = null;
         var _loc7_:Array = null;
         var _loc8_:String = null;
         var _loc1_:XML = this.getFlashSale(PROMO_FRIEND_FLASH);
         if(!_loc1_)
         {
            return [];
         }
         var _loc2_:XMLList = _loc1_.bundle;
         var _loc3_:String = String(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_FRIEND_FLASH_OPTIONS));
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.length())
         {
            _loc5_ = _loc2_[_loc4_];
            if(!(_loc5_.@variants == undefined || _loc5_.@amounts == undefined))
            {
               _loc6_ = _loc5_.@variants.toString();
               _loc7_ = _loc6_.split(",");
               if(_loc7_.indexOf(_loc3_) >= 0)
               {
                  _loc8_ = _loc5_.@amounts.toString();
                  return _loc8_.split(",");
               }
            }
            _loc4_++;
         }
         return null;
      }
      
      public function get friendFlashBundleInfo() : Array
      {
         var _loc2_:String = null;
         var _loc3_:XML = null;
         var _loc4_:* = undefined;
         var _loc5_:Dictionary = null;
         var _loc6_:Array = null;
         var _loc7_:String = null;
         var _loc1_:Array = new Array();
         if(this.m_autoPromoOverride == true)
         {
            _loc2_ = ZGlobal.player.getOngoingAutopromoName();
            _loc3_ = this.getAutoPromotionByName(_loc2_);
            for each(_loc4_ in _loc3_.offer)
            {
               _loc1_.push(_loc4_);
            }
         }
         else
         {
            _loc5_ = this.flashFriendOffers;
            _loc6_ = this.flashFriendBundles;
            if(!_loc6_)
            {
               return null;
            }
            for each(_loc7_ in _loc6_)
            {
               if(_loc5_[_loc7_] != undefined)
               {
                  _loc1_.push(_loc5_[_loc7_]);
               }
            }
         }
         return _loc1_;
      }
      
      public function get starterpacksForRepeatPayer() : XMLList
      {
         var _loc1_:XMLList = null;
         if(this.m_autoPromoOverride == true)
         {
            _loc1_ = this.m_xml.autopromotions.fgwpPacks;
         }
         else
         {
            _loc1_ = this.m_xml.starterPacks;
         }
         return _loc1_;
      }
      
      public function postInit() : void
      {
         this.showEPReceivedFeedback();
      }
      
      public function setReceivedEPInfo(param1:Object) : void
      {
         if(Boolean(param1) && !(param1 as Array))
         {
            this.m_epReceivedInfo = param1;
         }
      }
      
      public function setReceivedEPThankYouInfo(param1:Object) : void
      {
         if(Boolean(param1) && !(param1 as Array))
         {
            this.m_epReceivedThankYouInfo = param1;
         }
      }
      
      private function onIslandModeEntered(param1:Event) : void
      {
         GameModeManager.instance.removeEventListener(GMIsland.ISLAND_MODE_ENTERED,this.onIslandModeEntered);
         this.showEPReceivedFeedback();
      }
      
      private function onLastWindow(param1:Event) : void
      {
         WindowManager.instance.removeEventListener(WindowManager.LAST_HIDE_SCREEN,this.onLastWindow);
         this.showEPReceivedFeedback();
      }
      
      private function onLastPopupOrWindow(param1:Event) : void
      {
         PopupManager.instance.removeEventListener(WindowManager.LAST_HIDE_SCREEN,this.onLastWindow);
         this.showEPReceivedFeedback();
      }
      
      public function EPGiftThankYouClosed() : void
      {
         this.showEPReceivedFeedback();
      }
      
      private function showEPReceivedFeedback() : void
      {
         if(!this.m_requestFriendsLoaded)
         {
            return;
         }
         if(!this.inIslandMode)
         {
            GameModeManager.instance.addEventListener(GMIsland.ISLAND_MODE_ENTERED,this.onIslandModeEntered,false,0,true);
            return;
         }
         if(WindowManager.instance.displayedWindow)
         {
            WindowManager.instance.addEventListener(WindowManager.LAST_HIDE_SCREEN,this.onLastWindow,false,0,true);
            return;
         }
         if(PopupManager.instance.displayedWindow)
         {
            PopupManager.instance.addEventListener(WindowManager.LAST_HIDE_SCREEN,this.onLastPopupOrWindow,false,0,true);
            return;
         }
         this.showNextEPReceivedInfo();
      }
      
      private function get inIslandMode() : Boolean
      {
         var _loc1_:GameMode = GameModeManager.instance.getTopGameMode();
         return Boolean(_loc1_) && _loc1_ is GMIsland;
      }
      
      private function onGiftableEPGranted(param1:WorldEvent) : void
      {
         var _loc2_:int = int(param1.eventData.amount);
         ZGlobal.player.friendFlashEPBank += _loc2_;
         var _loc3_:String = ZGameUtils.ZlocT("Main","CashGiftable");
         var _loc4_:Object = {
            "item":_loc3_,
            "amount":_loc2_
         };
         var _loc5_:String = ZGameUtils.ZlocT("Main","FeedbackResourcesEpReceived",_loc4_);
         PlayerFeedbackManager.instance.displayToaster(_loc5_,null,true);
      }
   }
}

