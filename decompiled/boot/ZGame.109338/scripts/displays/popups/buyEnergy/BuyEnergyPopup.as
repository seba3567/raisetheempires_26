package displays.popups.buyEnergy
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.Watch2EarnHandler;
   import utils.ZGameUtils;
   import zlabs.managers.PopupManager;
   
   public class BuyEnergyPopup extends GenericPopup
   {
      
      private static var m_numShowing:int;
      
      private static var m_showWatchToEarn:Boolean = false;
      
      private var m_cards:Array = null;
      
      private var m_toasterClicked:Boolean = false;
      
      private var m_genus:String = null;
      
      private var m_watchAdButton:ZGameButton = null;
      
      private var m_iconLoader:ImageLoader = null;
      
      public function BuyEnergyPopup(param1:Function = null, param2:Boolean = false, param3:Array = null, param4:String = null)
      {
         super("",GenericPopup.TYPE_CANCEL,param1,param3);
         this.m_toasterClicked = param2;
         this.m_genus = param4;
         ++m_numShowing;
      }
      
      public static function show(param1:Function = null, param2:Boolean = false, param3:Array = null, param4:String = null) : void
      {
         var _loc5_:BuyEnergyPopup = null;
         if(!m_numShowing)
         {
            _loc5_ = new BuyEnergyPopup(param1,param2,param3,param4);
            PopupManager.instance.push(_loc5_);
         }
      }
      
      public static function enableWatchToEarn() : void
      {
         if(ExperimentsManager.instance.getExperimentVariant(Watch2EarnHandler.EXPERIMENT_ZAP_ZAC_W2E) == Watch2EarnHandler.VARIANT_ZAP_ZAC_W2E_ENABLED && Watch2EarnHandler.checkSlotAvailability(Watch2EarnHandler.W2E_SLOT_NAME))
         {
            m_showWatchToEarn = true;
         }
      }
      
      public function closeDialog() : void
      {
         onAccept(null);
      }
      
      public function get genus() : String
      {
         return this.m_genus;
      }
      
      public function addStat(param1:String, param2:String) : void
      {
         if(param1 == "leaderboard")
         {
            StatsManager.count("Dialog","lb_campaign_hint_buy_energy",param2,"","","");
         }
      }
      
      public function askFriends() : void
      {
         onAccept(null);
         var _loc1_:String = ZGameUtils.ZlocTokenGetString(ZGameUtils.ZlocTk("Items","energy_sentenceName","singular"));
         ViralsManager.instance.sendFeed("out_of_energy",{"resource":_loc1_});
      }
      
      public function watchToEarn() : void
      {
         onAccept(null);
         Watch2EarnHandler.launchActivity(Watch2EarnHandler.W2E_SLOT_NAME);
      }
      
      protected function get title() : String
      {
         return "BuyEnergyTitle";
      }
      
      protected function get message() : String
      {
         return ZGlobal.watchToEarn.available ? "BuyEnergyMessageWatchToEarn" : "BuyEnergyMessage";
      }
      
      override protected function setUpLook() : void
      {
         hideAllDialogs();
         m_window.popupBox_mc.energy_mc.visible = true;
         TextFieldUtil.processTextField(m_window.popupBox_mc.energy_mc.title_tf,ZGameUtils.ZlocT("Dialogs",this.title));
         TextFieldUtil.processTextField(m_window.popupBox_mc.energy_mc.popupBox_tf,ZGameUtils.ZlocT("Dialogs",this.message));
         this.m_cards = new Array();
         if(m_showWatchToEarn)
         {
            ViralsManager.instance.disable();
            m_window.popupBox_mc.energy_mc.W2Earn_mc.visible = true;
            this.m_iconLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/contracts/Contracts_Icons_0.swf/Energy_96.png"),m_window.popupBox_mc.energy_mc.W2Earn_mc.icon);
            m_window.popupBox_mc.energy_mc.W2Earn_mc.freeEnergy_tf.text = "+" + Watch2EarnHandler.W2E_ENERGY_REWARD;
            this.m_watchAdButton = new ZGameButton(m_window.popupBox_mc.energy_mc.W2Earn_mc.W2Earn_bt,this.onWatchAdClicked);
            this.m_watchAdButton.compactText(ZGameUtils.ZlocT("WatchToEarn","WatchAdButton"),{
               "maxLines":1,
               "minScale":0.5
            });
            TextFieldUtil.compactTextField(m_window.popupBox_mc.energy_mc.W2Earn_mc.info_tf,ZGameUtils.ZlocT("WatchToEarn","WatchAdDesc"),{
               "maxLines":2,
               "minScale":0.5
            });
            m_showWatchToEarn = false;
         }
         else
         {
            m_window.popupBox_mc.energy_mc.W2Earn_mc.visible = false;
         }
         this.m_cards.push(this.createInventoryOrAskCard(m_window.popupBox_mc.energy_mc.card_mc_01));
         this.m_cards.push(this.createPurchaseCard(m_window.popupBox_mc.energy_mc.card_mc_02));
         this.m_cards.push(this.createRefillCard(m_window.popupBox_mc.energy_mc.card_mc_03));
      }
      
      private function onWatchAdClicked(param1:MouseEvent) : void
      {
         this.watchToEarn();
      }
      
      private function createInventoryOrAskCard(param1:MovieClip) : BuyEnergyCard
      {
         var _loc2_:String = this.highestEnergyInInventory();
         if(_loc2_)
         {
            return this.createInventoryCard(param1,_loc2_);
         }
         return this.createAskCard(param1);
      }
      
      protected function createInventoryCard(param1:MovieClip, param2:String) : BuyEnergyCard
      {
         return new BuyEnergyCard(this,param1,BuyEnergyCard.ENERGY_CARD_INVENTORY,param2);
      }
      
      protected function createAskCard(param1:MovieClip) : BuyEnergyCard
      {
         return new BuyEnergyCard(this,param1,BuyEnergyCard.ENERGY_CARD_ASK);
      }
      
      protected function createPurchaseCard(param1:MovieClip) : BuyEnergyCard
      {
         return new BuyEnergyCard(this,param1,BuyEnergyCard.ENERGY_CARD_PURCHASE,"EN6",this.m_toasterClicked);
      }
      
      protected function createRefillCard(param1:MovieClip) : BuyEnergyCard
      {
         var _loc2_:Boolean = ZGlobal.player.m_energy.canBuyUnlimitedEnergy();
         var _loc3_:int = _loc2_ ? BuyEnergyCard.ENERGY_CARD_BUY_UNLIMITED : BuyEnergyCard.ENERGY_CARD_REFILL;
         return new BuyEnergyCard(this,param1,_loc3_);
      }
      
      protected function createWatchCard(param1:MovieClip) : BuyEnergyCard
      {
         return new BuyEnergyCard(this,param1,BuyEnergyCard.ENERGY_CARD_WATCH_TO_EARN);
      }
      
      protected function get toasterClicked() : Boolean
      {
         return this.m_toasterClicked;
      }
      
      override public function centerWithinStage(param1:Stage) : void
      {
         centerX = param1.stageWidth / 2 + m_origOffsetX - 70;
         centerY = param1.stageHeight / 2 + m_origOffsetY - 50;
      }
      
      override protected function initButtons() : void
      {
         super.initButtons();
         m_window.popupBox_mc.energy_mc.exit_bt.addEventListener(MouseEvent.CLICK,onCancel);
         m_buttonSounds.addButton(m_window.popupBox_mc.energy_mc.exit_bt,ButtonSound.DEFAULT);
      }
      
      override protected function deinitButtons() : void
      {
         super.deinitButtons();
         m_window.popupBox_mc.energy_mc.exit_bt.removeEventListener(MouseEvent.CLICK,onCancel);
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:BuyEnergyCard = null;
         super.deinitDialog();
         for each(_loc1_ in this.m_cards)
         {
            _loc1_.dispose();
         }
         this.m_cards = null;
         if(this.m_iconLoader)
         {
            this.m_iconLoader.destroy();
            this.m_iconLoader = null;
         }
         if(this.m_watchAdButton)
         {
            this.m_watchAdButton.dispose();
            this.m_watchAdButton = null;
         }
      }
      
      protected function getInventoryItems() : Array
      {
         return ["EN7","EN6","EN5","EN4","EN3","EN2","EN1"];
      }
      
      protected function allowItem(param1:String) : Boolean
      {
         return ZGlobal.player.inventory[param1] > 0;
      }
      
      protected function highestEnergyInInventory() : String
      {
         var _loc2_:String = null;
         var _loc1_:Array = this.getInventoryItems();
         for each(_loc2_ in _loc1_)
         {
            if(this.allowItem(_loc2_))
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      override protected function close(param1:Event = null) : void
      {
         if(m_numShowing > 0)
         {
            --m_numShowing;
         }
         super.close(param1);
      }
   }
}

