package core.ui
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import ZLocalization.LocalizationObjectToken;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import core.gamemode.expansion.GMExpansion;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.gameobjects.expansionitem.ExpansionItem;
   import core.managers.PVPManager;
   import core.managers.PriceTestManager;
   import core.managers.TierSurfacingManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.viralSurfacingManager.ViralSurfacingManager;
   import core.player.Player;
   import core.ui.menuitem.FriendsBarMessageTabUIItem;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import events.MarketEvent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TBuyItem;
   import utils.BitArray;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class ImpulsePurchasePopUp extends MovieClip
   {
      
      private static const MAX_WIDTH:Number = 300;
      
      private static const ASSET_FILE:String = "assets/ui/ViralNotification.swf";
      
      private static const X_OFFSET:int = -20;
      
      public static const FADE:int = 0;
      
      public static const IMMEDIATE:int = 1;
      
      protected var m_mc:MovieClip;
      
      protected var m_item:GameItem = null;
      
      protected var m_button:ZGameButton = null;
      
      protected var m_unlockBt:ZGameButton = null;
      
      private var m_obj:Object;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = new ButtonMouseEventSoundContainer();
      
      private var m_durationSeconds:int = 10;
      
      private var m_forceClose:Boolean;
      
      private var m_loaders:Array = [];
      
      private var m_discountCost:int = 0;
      
      public function ImpulsePurchasePopUp(param1:Object, param2:int)
      {
         super();
         this.m_obj = param1;
         this.m_durationSeconds = param2;
         var _loc3_:String = ZGlobal.getAssetURL(ASSET_FILE);
         Zlab.resourceManager.load(_loc3_,SWFResource,this.onLoadComplete);
         PVPManager.instance.addEventListener(PVPManager.GLOBALPVP_UI_STATECHANGE,this.onGPVPStateChange,false,0,true);
         UIDispatcher.instance.addEventListener(FriendsBarMessageTabUIItem.NEW_MESSAGE,this.onNewToasterMessage,false,0,true);
         x += X_OFFSET;
      }
      
      public static function create(param1:Object, param2:int) : ImpulsePurchasePopUp
      {
         return new ImpulsePurchasePopUp(param1,param2);
      }
      
      protected function get assetClass() : String
      {
         return "impulseSurfacing_mc";
      }
      
      protected function get economyBuyType() : String
      {
         return "impulse_purchase";
      }
      
      protected function onLoadComplete(param1:SWFResource) : void
      {
         if(this.m_forceClose)
         {
            this.close(IMMEDIATE);
            return;
         }
         var _loc2_:Class = param1.getAssetClass(this.assetClass);
         if(_loc2_)
         {
            this.m_mc = new _loc2_();
            addChild(this.m_mc);
         }
         this.initialize();
         Zlab.processManager.schedule(this.m_durationSeconds * 1000,this,this.onDurationExpired);
      }
      
      protected function get discountStringKey() : String
      {
         return "ImpulsePurchasingDescItemDiscount_desc";
      }
      
      protected function get noDiscountStringKey() : String
      {
         return "ImpulsePurchasingDescItemNoDiscount_desc";
      }
      
      protected function get resizable() : Boolean
      {
         return true;
      }
      
      protected function get showDiscount() : Boolean
      {
         return true;
      }
      
      protected function get hasUnlockButton() : Boolean
      {
         return true;
      }
      
      protected function initialize() : void
      {
         var _loc7_:Number = NaN;
         var _loc8_:String = null;
         y = this.m_mc.height;
         TweenLite.to(this,1,{"y":-26});
         alpha = 0;
         TweenLite.to(this,1,{"alpha":1});
         this.m_mc.icon.visible = true;
         if(this.resizable)
         {
            _loc7_ = Number(this.m_mc.messageTabC_mc.width);
            this.m_mc.messageTabC_mc.width = MAX_WIDTH;
            this.m_mc.messageTabR_mc.x -= _loc7_ - MAX_WIDTH;
            this.m_mc.message_tf.width -= _loc7_ - MAX_WIDTH;
            this.m_mc.discount_mc.x -= _loc7_ - MAX_WIDTH;
         }
         if(this.showDiscount)
         {
            TextFieldUtil.compactTextField(this.m_mc.discount_mc.percent_tf,ZGameUtils.ZlocT("Dialogs","BoldSale"),{
               "maxLines":1,
               "minScale":0.5
            });
            this.m_mc.discount_mc.visible = true;
         }
         else
         {
            this.m_mc.discount_mc.visible = false;
         }
         this.m_item = ZGlobal.gameSettings.getItemByCode(this.m_obj.code,GameItem) as GameItem;
         if(this.m_item)
         {
            if(this.m_item.isExpansionItem)
            {
               this.m_item = ZGlobal.gameSettings.getItemByCode(this.m_obj.code,ExpansionItem) as ExpansionItem;
            }
            else if(this.m_item.xml.unit != undefined)
            {
               this.m_item = ZGlobal.gameSettings.getItemByCode(this.m_obj.code,UnitItem) as UnitItem;
            }
         }
         var _loc1_:String = ZGlobal.gameSettings.getImageByName(this.m_item.name,"icon");
         var _loc2_:ImageLoader = ImageLoaderFactory.CreateImageLoader(_loc1_,this.m_mc.icon);
         if(_loc2_)
         {
            _loc2_.smooth = true;
            this.m_loaders.push(_loc2_);
         }
         if(this.m_item as UnitItem)
         {
            TextFieldUtil.processTextField(this.m_mc.strength_mc.value_tf,String((this.m_item as UnitItem).getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(this.m_obj.code))));
            if(TierSurfacingManager.instance.tierSurfacingEnabled && this.m_mc.tierRating_mc != null)
            {
               TextFieldUtil.compactTextField(this.m_mc.tierRating_mc.tier_tf,String((this.m_item as UnitItem).tier));
               this.m_mc.tierRating_mc.visible = true;
            }
            else if(this.m_mc.tierRating_mc != null)
            {
               this.m_mc.tierRating_mc.visible = false;
            }
         }
         else
         {
            this.m_mc.strength_mc.visible = false;
            if(this.m_mc.tierRating_mc != null)
            {
               this.m_mc.tierRating_mc.visible = false;
            }
         }
         this.m_discountCost = this.applyDiscount(this.m_item.cash);
         var _loc3_:LocalizationObjectToken = this.m_item.getSentenceNameLocalizationObject("singular,definite");
         if(this.m_obj.discount > 0)
         {
            _loc8_ = this.m_obj.discount + "%";
            TextFieldUtil.processTextField(this.m_mc.message_tf,ZGameUtils.ZlocT("Dialogs",this.discountStringKey,{
               "item":_loc3_,
               "discount":_loc8_
            }));
         }
         else
         {
            TextFieldUtil.processTextField(this.m_mc.message_tf,ZGameUtils.ZlocT("Dialogs",this.noDiscountStringKey,{"item":_loc3_}));
         }
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         if(this.m_obj.unlock != undefined)
         {
            switch(int(this.m_obj.unlock))
            {
               case 0:
                  _loc5_ = this.hasUnlockButton;
                  break;
               case 2:
                  _loc4_ = true;
                  _loc5_ = this.hasUnlockButton;
                  break;
               default:
                  _loc4_ = true;
            }
         }
         else
         {
            _loc4_ = true;
         }
         var _loc6_:int = this.m_item.contractCost;
         if(_loc6_ <= 0 || !this.m_item.contractLocked || !this.m_item.canBuyContract() || this.isLevelLocked(this.m_item))
         {
            _loc5_ = false;
            _loc4_ = true;
         }
         if(_loc5_ && !_loc4_)
         {
            this.m_mc.unlock_bt.y = this.m_mc.confirm_bt.y;
         }
         if(_loc4_)
         {
            this.m_button = new ZGameButton(this.m_mc.confirm_bt,this.onClicked);
            this.m_button.text = ZGameUtils.ZlocT("Dialogs","BuyForAmount",{"amount":this.m_discountCost});
            this.m_buttonSounds.addButton(this.m_button.m_overlay,ButtonSound.DEFAULT);
         }
         this.m_mc.confirm_bt.visible = _loc4_;
         if(_loc5_)
         {
            this.m_unlockBt = new ZGameButton(this.m_mc.unlock_bt,this.onUnlock);
            this.m_unlockBt.text = ZGameUtils.ZlocT("Dialogs","UnlockForAmount",{"amount":_loc6_});
            this.m_buttonSounds.addButton(this.m_unlockBt.m_overlay,ButtonSound.DEFAULT);
         }
         if(this.hasUnlockButton)
         {
            this.m_mc.unlock_bt.visible = _loc5_;
         }
         this.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClicked,false,0,true);
         this.m_buttonSounds.addButton(this.exit_bt as DisplayObject,ButtonSound.DEFAULT);
      }
      
      private function isLevelLocked(param1:GameItem) : Boolean
      {
         var _loc2_:BitArray = ZGlobal.player.checkGate(param1);
         return _loc2_.isBitSet(Player.GATE_FAILURE_LEVEL);
      }
      
      protected function get exit_bt() : EventDispatcher
      {
         return this.m_mc.messageTabR_mc.exit_bt;
      }
      
      public function applyDiscount(param1:int) : int
      {
         var _loc3_:int = 0;
         var _loc2_:int = param1;
         if(this.m_obj.discount > 0)
         {
            _loc3_ = int(Math.floor(param1 * this.m_obj.discount / 100));
            _loc2_ -= _loc3_;
         }
         return _loc2_;
      }
      
      public function dispose() : void
      {
         var _loc1_:ImageLoader = null;
         UIDispatcher.instance.removeEventListener(FriendsBarMessageTabUIItem.NEW_MESSAGE,this.onNewToasterMessage);
         if(parent)
         {
            parent.removeChild(this);
         }
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         this.m_loaders = [];
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         this.m_mc = null;
         if(this.m_button)
         {
            this.m_button.dispose();
         }
         if(this.m_unlockBt)
         {
            this.m_unlockBt.dispose();
         }
         this.disable();
      }
      
      private function onDurationExpired() : void
      {
         this.close(FADE);
      }
      
      private function close(param1:int) : void
      {
         if(param1 == FADE)
         {
            this.disable();
            if(this.m_mc)
            {
               TweenLite.to(this,1,{"y":this.m_mc.height});
               TweenLite.to(this,1,{
                  "alpha":0,
                  "onComplete":this.onTweenOutComplete
               });
            }
         }
         else
         {
            ViralSurfacingManager.instance.dispatchEvent(new Event(ViralSurfacingManager.POPUP_CLOSED));
            this.dispose();
         }
      }
      
      private function disable() : void
      {
         if(this.m_button)
         {
            this.m_button.dispose();
            this.m_button = null;
         }
         if(this.m_mc)
         {
            this.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClicked);
         }
         Zlab.processManager.removeScheduledObject(this);
         UIDispatcher.instance.removeEventListener(FriendsBarMessageTabUIItem.NEW_MESSAGE,this.onNewToasterMessage);
      }
      
      private function onTweenOutComplete() : void
      {
         this.close(IMMEDIATE);
      }
      
      private function onGPVPStateChange(param1:WorldEvent) : void
      {
         if(!PVPManager.instance.isStrangerBarStable)
         {
            this.logAction("no");
            this.m_forceClose = true;
            this.close(IMMEDIATE);
         }
      }
      
      private function onNewToasterMessage(param1:Event) : void
      {
         this.logAction("no");
         this.m_forceClose = true;
         this.close(IMMEDIATE);
      }
      
      protected function get showConfirmation() : Boolean
      {
         return true;
      }
      
      private function onClicked(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:GenericPopup = null;
         if(ZGlobal.player.canBuyCash(this.m_discountCost,true))
         {
            _loc2_ = new Object();
            _loc2_.discountedCost = this.m_discountCost;
            _loc2_.impulseBuy = true;
            _loc3_ = {
               "discountInfo":_loc2_,
               "item":this.m_item
            };
            if(this.showConfirmation && ZGlobal.gameSettings.showConfirmationPopup(this.m_discountCost))
            {
               _loc4_ = ZGameUtils.CashTokenReplacements(this.m_item.cash);
               _loc4_.item = this.m_item.getSentenceNameLocalizationObject("singular,definite");
               _loc4_.amount = this.m_discountCost;
               _loc5_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseMessage",_loc4_);
               _loc6_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle");
               _loc7_ = GenericPopup2B.NewYesNo(_loc5_,_loc6_,this.onCashBuyPopupClose);
               _loc7_.userData = _loc3_;
               PopupManager.instance.push(_loc7_);
            }
            else
            {
               this.buyItem(_loc3_);
            }
         }
         else
         {
            this.logAction("no");
         }
         this.close(FADE);
      }
      
      private function onUnlock(param1:MouseEvent) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:GenericPopup = null;
         var _loc2_:int = this.m_item.contractCost;
         if(ZGlobal.player.canBuyCash(_loc2_,true))
         {
            _loc3_ = {"item":this.m_item};
            if(this.showConfirmation && ZGlobal.gameSettings.showConfirmationPopup(_loc2_))
            {
               _loc4_ = ZGameUtils.CashTokenReplacements(_loc2_);
               _loc4_.item = this.m_item.getSentenceNameLocalizationObject("singular,definite");
               _loc4_.amount = _loc2_;
               _loc5_ = ZGameUtils.ZlocT("Dialogs","ConfrumCashUnlockContractMessage",_loc4_);
               _loc6_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle");
               _loc7_ = GenericPopup2B.NewYesNo(_loc5_,_loc6_,this.onUnlockPopupClose);
               _loc7_.userData = _loc3_;
               PopupManager.instance.push(_loc7_);
            }
            else
            {
               this.buyUnlock(_loc3_);
            }
         }
         else
         {
            this.logAction("no_unlock");
         }
         this.close(FADE);
      }
      
      private function onCashBuyPopupClose(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            this.buyItem(param1.userData);
         }
      }
      
      protected function get priceTestType() : String
      {
         return PriceTestManager.ADDITIONALTYPE_IMPULSE;
      }
      
      private function buyItem(param1:Object) : void
      {
         var _loc4_:Object = null;
         var _loc2_:Object = param1.discountInfo;
         var _loc3_:GameItem = param1.item;
         if(_loc3_ as ExpansionItem)
         {
            GameModeManager.instance.addGameMode(new GMExpansion(_loc3_ as ExpansionItem,_loc2_));
         }
         else
         {
            ZGlobal.player.buyItem(_loc3_,true,1,null,false,_loc2_);
            ZGlobal.player.addToInventory(_loc3_.code);
            _loc4_ = new Object();
            _loc4_.buyType = this.economyBuyType;
            TransactionManager.addTransaction(new TBuyItem(_loc3_.code,true,1,_loc4_,this.priceTestType));
            PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","ItemPlacedIntoInventory")),100);
            this.logAction("yes");
         }
      }
      
      private function onUnlockPopupClose(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            this.buyUnlock(param1.userData);
         }
      }
      
      private function buyUnlock(param1:Object) : void
      {
         var _loc2_:Object = null;
         if(this.m_item.contractLocked && this.m_item.canBuyContract())
         {
            _loc2_ = {"type":"impulse_unlock"};
            UI.instance.setupForItemPurchase();
            UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_UNLOCK_CONTRACT,0,this.m_item.name,MarketEvent.SOURCE_STORE,_loc2_));
            this.logAction("yes_unlock");
         }
      }
      
      private function onExitClicked(param1:MouseEvent) : void
      {
         this.logAction("no");
         this.close(FADE);
      }
      
      private function logAction(param1:String) : void
      {
         var _loc2_:String = "toast";
         var _loc3_:String = "item_discount";
         var _loc4_:String = this.m_obj.code;
         var _loc5_:String = param1;
         var _loc6_:String = this.m_obj.discount;
         StatsManager.count(_loc2_,_loc3_,_loc4_,_loc5_,_loc6_);
      }
   }
}

