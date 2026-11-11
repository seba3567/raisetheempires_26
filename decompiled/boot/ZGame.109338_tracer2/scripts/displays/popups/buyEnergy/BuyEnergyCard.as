package displays.popups.buyEnergy
{
   import Engine.Managers.StatsManager;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gamemode.GameMode;
   import core.gamemode.GameModeManager;
   import core.gamemode.battle.Battle;
   import core.gamemode.battle.BattleCampaign;
   import core.gamemode.battle.GMBattle;
   import core.gameobjects.AmmoRefillItem;
   import core.gameobjects.EnergyRefillItem;
   import core.gameobjects.GameItem;
   import core.gameobjects.ManaRefillItem;
   import core.managers.PVPManager;
   import core.managers.promoManager.PromoManager;
   import core.ui.UI;
   import core.ui.ZGameButton;
   import dispatchers.EnergyDispatcher;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.genericPopup.GenericPopup1B;
   import events.EnergyMarketEvent;
   import events.EnergyUpdatedEvent;
   import events.MarketEvent;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   
   public class BuyEnergyCard
   {
      
      public static const ENERGY_CARD_ASK:int = 0;
      
      public static const ENERGY_CARD_PURCHASE:int = 1;
      
      public static const ENERGY_CARD_INVENTORY:int = 2;
      
      public static const ENERGY_CARD_REFILL:int = 3;
      
      public static const ENERGY_CARD_BUY_UNLIMITED:int = 4;
      
      public static const ENERGY_CARD_WATCH_TO_EARN:int = 5;
      
      private static const UNLIMITED_ENERGY_PACKAGE:int = 0;
      
      private static const EP_ICON_PATH:String = "assets/game/GeneralAssetGroup_UI.swf/Cash_24.png";
      
      private var m_clip:MovieClip = null;
      
      private var m_type:int = 0;
      
      private var m_button:ZGameButton = null;
      
      private var m_parent:BuyEnergyPopup = null;
      
      private var m_item:GameItem = null;
      
      private var m_refillItem:EnergyRefillItem = null;
      
      private var m_imageLoaders:Array = new Array();
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_toasterClicked:Boolean;
      
      public function BuyEnergyCard(param1:BuyEnergyPopup, param2:MovieClip, param3:int, param4:String = null, param5:Boolean = false)
      {
         var _loc6_:Object = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         super();
         this.m_clip = param2;
         this.m_type = param3;
         this.m_parent = param1;
         this.m_button = new ZGameButton(param2.ok_bt,this.onClicked);
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(this.m_button.m_overlay,ButtonSound.DEFAULT);
         this.m_toasterClicked = param5;
         this.m_clip.addEventListener(MouseEvent.CLICK,this.onClicked,false,0,true);
         this.m_clip.buttonMode = true;
         this.m_clip.useHandCursor = true;
         if(this.m_clip.sunburst_mc)
         {
            this.m_clip.sunburst_mc.visible = false;
         }
         this.m_clip.cost_tf.visible = false;
         this.m_clip.discount_tf.visible = false;
         switch(this.m_type)
         {
            case ENERGY_CARD_BUY_UNLIMITED:
               if(this.m_clip.sunburst_mc)
               {
                  this.m_clip.sunburst_mc.visible = true;
               }
               _loc6_ = PromoManager.instance.unlimitedEnergyData[UNLIMITED_ENERGY_PACKAGE];
               _loc7_ = ZGameTimeUtil.instance.getTimeString(_loc6_.duration);
               _loc8_ = ZGameUtils.ZlocT("Dialogs","BuyEnergyUnlimitedSubtitle",{"timeStr":_loc7_});
               _loc9_ = ZGameUtils.ZlocT("Dialogs","BuyEnergyUnlimitedTitle");
               TextFieldUtil.processTextField(param2.itemName_tf,_loc9_);
               TextFieldUtil.processTextField(param2.generic_tf,_loc8_);
               param2.icon_01.visible = true;
               this.m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(EP_ICON_PATH),param2.icon_01));
               this.m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(_loc6_.image,param2.icon));
               this.m_button.text = ZGameUtils.ZlocT("Dialogs","BuyEnergyButton",{"amount":_loc6_.cost});
               break;
            case ENERGY_CARD_ASK:
               this.m_button.compactText(ZGameUtils.ZlocT("Dialogs","BuyEnergyAskFriendsCardButton"),{
                  "maxLines":1,
                  "minScale":0.5,
                  "onFail":"return"
               });
               TextFieldUtil.processTextField(param2.itemName_tf,ZGameUtils.ZlocT("Dialogs",this.askTitle));
               TextFieldUtil.processTextField(param2.generic_tf,ZGameUtils.ZlocT("Dialogs","BuyEnergyAskFriendsCardDescription"));
               this.m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.askUrl),param2.icon));
               param2.icon_01.visible = false;
               break;
            case ENERGY_CARD_PURCHASE:
            case ENERGY_CARD_INVENTORY:
               if(param4)
               {
                  this.m_item = ZGlobal.gameSettings.getItemByCode(param4,this.itemClass) as GameItem;
                  if(this.m_type == ENERGY_CARD_PURCHASE)
                  {
                     if(this.m_item.cash < this.m_item.xmlCash)
                     {
                        TextFieldUtil.compactTextField(param2.discount_tf,ZGameUtils.ZlocT("Dialogs","OnSaleExclaim"),{
                           "maxLines":1,
                           "minScale":0.5,
                           "onFail":"return"
                        });
                        this.m_clip.discount_tf.visible = true;
                     }
                     this.m_button.text = ZGameUtils.ZlocT("Dialogs","BuyEnergyButton",{"amount":this.m_item.cash});
                     this.m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(EP_ICON_PATH),param2.icon_01));
                  }
                  else
                  {
                     this.m_button.text = ZGameUtils.ZlocT("Dialogs","Use");
                  }
                  TextFieldUtil.processTextField(param2.itemName_tf,this.m_item.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
                  TextFieldUtil.processTextField(param2.generic_tf,ZGameUtils.ZlocT("Dialogs",this.buyAmountText,{"amount":this.yield}));
                  this.m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(this.m_item.getCachedImage("icon").url,param2.icon));
               }
               break;
            case ENERGY_CARD_REFILL:
               this.m_refillItem = this.refillItem;
               this.updateRefillInfo();
               EnergyDispatcher.instance.addEventListener(EnergyUpdatedEvent.ENERGY,this.updateRefillInfo,false,0,true);
               EnergyDispatcher.instance.addEventListener(EnergyUpdatedEvent.MAX_ENERGY,this.updateRefillInfo,false,0,true);
               TextFieldUtil.processTextField(param2.generic_tf,ZGameUtils.ZlocT("Dialogs",this.buyRefillText));
               this.m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(EP_ICON_PATH),param2.icon_01));
               this.m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.refillUrl),param2.icon));
               break;
            case ENERGY_CARD_WATCH_TO_EARN:
               _loc10_ = ZGlobal.watchToEarn.getBounty();
               this.m_button.compactText(ZGameUtils.ZlocT("Dialogs","BuyEnergyWatchToEarnCardButton"),{
                  "maxLines":1,
                  "minScale":0.5,
                  "onFail":"return"
               });
               TextFieldUtil.processTextField(param2.itemName_tf,ZGameUtils.ZlocT("Dialogs","BuyEnergyWatchToEarnCardTitle"));
               TextFieldUtil.processTextField(param2.generic_tf,ZGameUtils.ZlocT("Dialogs","BuyEnergyWatchToEarnCardDescription",{"amount":_loc10_}));
               this.m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.watchUrl),param2.icon));
               param2.icon_01.visible = false;
         }
         param2.underlay_mc.visible = param2.itemName_tf != null && param2.itemName_tf.numLines > 1;
      }
      
      public function dispose() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_imageLoaders)
         {
            _loc1_.destroy();
         }
         this.m_imageLoaders = null;
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         this.m_button.dispose();
         this.m_button = null;
         this.m_clip.removeEventListener(MouseEvent.CLICK,this.onClicked);
         EnergyDispatcher.instance.removeEventListener(EnergyUpdatedEvent.ENERGY,this.updateRefillInfo);
         EnergyDispatcher.instance.removeEventListener(EnergyUpdatedEvent.MAX_ENERGY,this.updateRefillInfo);
         this.m_parent = null;
         this.m_item = null;
      }
      
      protected function get item() : GameItem
      {
         return this.m_item;
      }
      
      protected function get yield() : int
      {
         return this.m_item.energyYield;
      }
      
      protected function get refillamount() : int
      {
         return ZGlobal.player.m_energy.energyMax - ZGlobal.player.m_energy.energy;
      }
      
      protected function get refillUrl() : String
      {
         return "assets/game/contracts/Contracts_Icons_0.swf/EnergyBattery06_96.png";
      }
      
      protected function get buyAmountText() : String
      {
         return "BuyEnergyAmount";
      }
      
      protected function get buyRefillText() : String
      {
         return "BuyEnergyFullRefill";
      }
      
      protected function get buyQuantityText() : String
      {
         return "BuyEnergyQuantity";
      }
      
      protected function get refillItem() : EnergyRefillItem
      {
         return ZGlobal.gameSettings.getItemByCode(EnergyRefillItem.ITEM_CODE,EnergyRefillItem) as EnergyRefillItem;
      }
      
      protected function get askTitle() : String
      {
         return "BuyEnergyAskFriendsCardTitle";
      }
      
      protected function get askUrl() : String
      {
         return "assets/game/contracts/Contracts_Icons_0.swf/Energy_96.png";
      }
      
      protected function get watchUrl() : String
      {
         return "assets/game/contracts/Contracts_Icons_0.swf/Energy_96.png";
      }
      
      protected function get itemClass() : Class
      {
         return GameItem;
      }
      
      private function updateRefillInfo(param1:EnergyUpdatedEvent = null) : void
      {
         var _loc2_:int = this.refillamount;
         this.m_refillItem.refillAmount = _loc2_;
         if(this.m_refillItem.cash < this.m_refillItem.getBaseCost())
         {
            TextFieldUtil.compactTextField(this.m_clip.discount_tf,ZGameUtils.ZlocT("Dialogs","OnSaleExclaim"),{
               "maxLines":1,
               "minScale":0.5,
               "onFail":"return"
            });
            this.m_clip.discount_tf.visible = true;
         }
         this.m_button.text = ZGameUtils.ZlocT("Dialogs","BuyEnergyButton",{"amount":this.m_refillItem.cash});
         TextFieldUtil.processTextField(this.m_clip.itemName_tf,ZGameUtils.ZlocT("Dialogs",this.buyQuantityText,{"amount":_loc2_}));
      }
      
      private function onClicked(param1:MouseEvent) : void
      {
         switch(this.m_type)
         {
            case ENERGY_CARD_BUY_UNLIMITED:
               this.m_parent.closeDialog();
               this.addStat("unlimited_energy");
               ZGlobal.player.m_energy.buyUnlimitedEnergyWithConfirmation(UNLIMITED_ENERGY_PACKAGE);
               break;
            case ENERGY_CARD_ASK:
               this.addStat("ask_friends");
               this.m_parent.askFriends();
               break;
            case ENERGY_CARD_PURCHASE:
               this.addStat("buy");
               this.purchaseEnergyItem(this.m_item,this.m_item.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME));
               this.m_parent.closeDialog();
               break;
            case ENERGY_CARD_INVENTORY:
               this.addStat("use_inventory");
               this.m_parent.addStat(this.m_parent.genus,"inventory");
               UI.instance.setupForItemPlacement();
               UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_USE,MarketEvent.CONSUMABLE,this.m_item.name,MarketEvent.SOURCE_INVENTORY));
               this.m_parent.closeDialog();
               break;
            case ENERGY_CARD_REFILL:
               this.addStat("buy_refill");
               this.purchaseEnergyItem(this.m_refillItem,ZGameUtils.ZlocT("Dialogs",this.buyRefillText));
               this.m_parent.closeDialog();
               break;
            case ENERGY_CARD_WATCH_TO_EARN:
               this.addStat("watch_to_earn");
               this.m_parent.watchToEarn();
               this.m_parent.closeDialog();
         }
      }
      
      protected function get kingdom() : String
      {
         return "BuyEnergyPopup";
      }
      
      private function addStat(param1:String = "") : void
      {
         StatsManager.count("dialog",this.kingdom,param1);
      }
      
      private function purchaseEnergyItem(param1:GameItem, param2:String) : void
      {
         var _loc3_:GameMode = null;
         var _loc4_:Boolean = false;
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:GenericPopup = null;
         if(Boolean(param1) && ZGlobal.player.canBuyCash(param1.cash,true))
         {
            _loc3_ = GameModeManager.instance.getTopGameMode();
            _loc4_ = _loc3_ as GMBattle != null;
            _loc5_ = {
               "item":param1,
               "genus":this.m_parent.genus,
               "parent":this.m_parent
            };
            if(!_loc4_ || ZGlobal.gameSettings.showConfirmationPopup(param1.cash))
            {
               _loc6_ = ZGameUtils.CashTokenReplacements(param1.cash);
               _loc6_.item = param2;
               _loc6_.amount = param1.cash;
               _loc7_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseMessage",_loc6_);
               _loc8_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle");
               _loc9_ = GenericPopup2B.NewYesNo(_loc7_,_loc8_,this.onCashBuyPopupClose);
               _loc9_.userData = _loc5_;
               PopupManager.instance.push(_loc9_);
            }
            else
            {
               this.buyEnergy(_loc5_);
            }
         }
      }
      
      protected function alreadyAtMaxMessage(param1:GameItem) : String
      {
         var _loc2_:int = 0;
         if(Boolean(param1) && Boolean(param1.energyYield))
         {
            _loc2_ = param1.energyYield + ZGlobal.player.m_energy.energy;
            if(_loc2_ > ZGlobal.player.m_energy.energyMax)
            {
               return "BuyEnergyPurchaseExceedsMax";
            }
         }
         return null;
      }
      
      private function onCashBuyPopupClose(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            this.buyEnergy(param1.userData);
         }
      }
      
      private function buyEnergy(param1:Object) : void
      {
         var _loc6_:Boolean = false;
         var _loc9_:Boolean = false;
         var _loc12_:String = null;
         var _loc13_:GenericPopup = null;
         var _loc2_:GameItem = param1.item as GameItem;
         var _loc3_:String = this.alreadyAtMaxMessage(_loc2_);
         if(_loc3_)
         {
            _loc12_ = ZGameUtils.ZlocT("Dialogs",_loc3_);
            _loc13_ = GenericPopup1B.NewOk(_loc12_,null);
            PopupManager.instance.push(_loc13_);
            return;
         }
         UI.instance.setupForItemPurchase();
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc7_:int = Battle.BATTLE_STATE_NONE;
         var _loc8_:Battle = ZGameStats.currentBattle;
         if(_loc8_)
         {
            _loc7_ = Battle.BATTLE_STATE_ACTIVE;
            _loc4_ = _loc8_ is BattleCampaign;
            _loc5_ = _loc8_.isQuestTreeBattle;
            _loc6_ = _loc8_.isDominationMode;
            _loc9_ = _loc8_.isDeathMatchBattle;
         }
         var _loc10_:Object = {
            "combatPhase":_loc7_,
            "inCampaign":_loc4_,
            "toasterClicked":this.m_toasterClicked,
            "energyDialog":true,
            "gpvp":PVPManager.instance.isVisitGlobalPVP(),
            "questTree":_loc5_,
            "dominance":_loc6_,
            "deathmatch":_loc9_
         };
         var _loc11_:BuyEnergyPopup = param1.parent;
         if(param1.genus)
         {
            _loc10_.genus = param1.genus;
         }
         if(_loc2_.code == EnergyRefillItem.ITEM_CODE || _loc2_.code == ManaRefillItem.ITEM_CODE || _loc2_.code == AmmoRefillItem.ITEM_CODE)
         {
            _loc11_.addStat(_loc10_.genus,"buy_refill");
            UIDispatcher.instance.dispatchEvent(new EnergyMarketEvent(MarketEvent.MARKET_BUY,MarketEvent.CONSUMABLE,"",MarketEvent.SOURCE_NONE,_loc10_,_loc2_));
         }
         else
         {
            _loc11_.addStat(_loc10_.genus,"buy_small");
            UIDispatcher.instance.dispatchEvent(new EnergyMarketEvent(MarketEvent.MARKET_BUY,MarketEvent.CONSUMABLE,_loc2_.name,MarketEvent.SOURCE_NONE,_loc10_,null,this.itemClass));
         }
      }
   }
}

