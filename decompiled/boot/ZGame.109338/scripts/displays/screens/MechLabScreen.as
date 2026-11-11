package displays.screens
{
   import Engine.Managers.StatsManager;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsBuildingItem;
   import core.managers.MechLabDailyRewardManager;
   import core.managers.viralsManager.ViralsManager;
   import core.player.Player;
   import core.ui.ZGameButton;
   import core.ui.ZGameBuyButton;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import entity.GameDataComponent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.displays.GenericButton;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class MechLabScreen extends ZGamePopUp
   {
      
      private var m_activateButton:ZGameButton = null;
      
      private var m_stateEventDispatcher:EventDispatcher = null;
      
      private var m_stateEntity:IEntity = null;
      
      protected var m_partsItem:PartsBuildingItem = null;
      
      private var m_askButton:ZGameButton = null;
      
      private var m_buyButton:ZGameBuyButton = null;
      
      private var m_imageLoaders:Array = [];
      
      private var m_openConsumablePanelButton:GenericButton = null;
      
      private var m_closeConsumablePanelButton:ZGameButton = null;
      
      private const PART_CODE:String = "B289";
      
      private var m_partImageLoader:ImageLoader = null;
      
      private var m_panelPartImageLoader:ImageLoader = null;
      
      private var m_panelCollectButton:ZGameButton = null;
      
      private var m_consumableCollectButton:ZGameButton = null;
      
      public function MechLabScreen(param1:EventDispatcher, param2:IEntity, param3:String)
      {
         this.m_stateEventDispatcher = param1;
         this.m_stateEntity = param2;
         var _loc4_:GameItem = (this.m_stateEntity.lookupComponentByType(GameDataComponent) as GameDataComponent).gameData;
         this.m_partsItem = ZGlobal.gameSettings.getItemByCode(_loc4_.code,PartsBuildingItem) as PartsBuildingItem;
         super(param3);
      }
      
      protected static function updateProgressBar(param1:MovieClip, param2:int, param3:int) : void
      {
         var _loc4_:int = param1.loadBase_mc.width * Number(param2 / param3);
         TweenLite.to(param1.loadBar_mc,0.5,{"width":_loc4_});
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         m_window = param1.clip as MovieClip;
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      override public function onShow() : void
      {
         if(m_window)
         {
            super.onShow();
            this.setUpUI();
            if(this.kingdom != null)
            {
               StatsManager.count("dialog",this.kingdom,"view");
            }
         }
      }
      
      private function setUpUI() : void
      {
         this.contentWidth = 716;
         this.contentHeight = 593;
         this.initDialog();
         addChild(m_window);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      protected function get screen() : MovieClip
      {
         return window.getChildAt(0) as MovieClip;
      }
      
      protected function get kingdom() : String
      {
         return null;
      }
      
      override protected function initDialog() : void
      {
         var _loc2_:String = null;
         super.initDialog();
         this.initUI();
         this.screen.frame_mc.mouseEnabled = false;
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit,false,0,true);
         TextFieldUtil.processTextField(this.screen.leftPanel_mc.meterTitle_tf,ZGameUtils.ZlocT("Dialogs","MechLabMeterTitle"));
         TextFieldUtil.processTextField(this.screen.leftPanel_mc.titanProgress01_mc.meterNumber_tf,"1");
         TextFieldUtil.processTextField(this.screen.leftPanel_mc.titanProgress01_mc.meterName_tf,ZGameUtils.ZlocT("Dialogs","MechLabMeter1"));
         TextFieldUtil.processTextField(this.screen.leftPanel_mc.titanProgress02_mc.meterNumber_tf,"2");
         TextFieldUtil.processTextField(this.screen.leftPanel_mc.titanProgress02_mc.meterName_tf,ZGameUtils.ZlocT("Dialogs","MechLabMeter2"));
         TextFieldUtil.processTextField(this.screen.leftPanel_mc.titanProgress03_mc.meterNumber_tf,"3");
         TextFieldUtil.processTextField(this.screen.leftPanel_mc.titanProgress03_mc.meterName_tf,ZGameUtils.ZlocT("Dialogs","MechLabMeter3"));
         TextFieldUtil.processTextField(this.screen.leftPanel_mc.titanProgress04_mc.meterNumber_tf,"4");
         TextFieldUtil.processTextField(this.screen.leftPanel_mc.titanProgress04_mc.meterName_tf,ZGameUtils.ZlocT("Dialogs","MechLabMeter4"));
         TextFieldUtil.processTextField(this.screen.leftPanel_mc.titanProgress05_mc.meterNumber_tf,"5");
         TextFieldUtil.processTextField(this.screen.leftPanel_mc.titanProgress05_mc.meterName_tf,ZGameUtils.ZlocT("Dialogs","MechLabMeter5"));
         var _loc1_:uint = 1;
         while(_loc1_ <= 5)
         {
            _loc2_ = "titanProgress0" + String(_loc1_) + "_mc";
            if(_loc1_ < this.currentActivationStage)
            {
               this.screen.leftPanel_mc[_loc2_].gotoAndStop("complete");
            }
            else if(_loc1_ == this.currentActivationStage)
            {
               this.screen.leftPanel_mc[_loc2_].gotoAndStop("active");
            }
            else
            {
               this.screen.leftPanel_mc[_loc2_].gotoAndStop("locked");
            }
            _loc1_++;
         }
         this.m_activateButton = new ZGameButton(this.screen.leftPanel_mc.activate_bt,null);
         this.m_activateButton.text = ZGameUtils.ZlocT("Dialogs","MechLabButtonActivate");
         this.m_activateButton.disable();
         TextFieldUtil.processTextField(this.screen.leftPanel_mc.screenDesc_mc.title_tf,ZGameUtils.ZlocT("Dialogs","MechLabDescriptionTitle"));
         TextFieldUtil.processTextField(this.screen.leftPanel_mc.screenDesc_mc.desc_tf,ZGameUtils.ZlocT("Dialogs","MechLabDescription"));
         this.initConsumablePanel();
      }
      
      protected function initUI() : void
      {
      }
      
      override protected function deinitDialog() : void
      {
         this.m_activateButton.dispose();
         this.screen.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
         this.deinitConsumablePanel();
         super.deinitDialog();
      }
      
      override protected function close(param1:Event = null) : void
      {
         if(this.kingdom != null)
         {
            StatsManager.count("dialog",this.kingdom,"close");
         }
         super.close(param1);
      }
      
      protected function get stateEventDispatcher() : EventDispatcher
      {
         return this.m_stateEventDispatcher;
      }
      
      protected function get stateEntity() : IEntity
      {
         return this.m_stateEntity;
      }
      
      protected function get currentActivationStage() : uint
      {
         return 0;
      }
      
      protected function onExit(param1:MouseEvent) : void
      {
         this.close();
      }
      
      protected function get panel() : MovieClip
      {
         return null;
      }
      
      private function initConsumablePanel() : void
      {
         var _loc1_:GameItem = null;
         var _loc2_:ImageLoader = null;
         var _loc3_:String = null;
         if(this.hasConsumablePanel)
         {
            _loc1_ = ZGlobal.gameSettings.getItemByCode(this.PART_CODE,GameItem) as GameItem;
            _loc2_ = null;
            _loc3_ = ZGlobal.getAssetURL("assets/game/quests/Quests_Icons_0.swf/TitanPlating_01_96.png");
            UIDispatcher.instance.addEventListener(Player.INVENTORY_UPDATED,this.onInventoryUpdated,false,0,true);
            TextFieldUtil.processTextField(this.screen.screenTitle_tf,ZGameUtils.ZlocT("Dialogs","MechLabConsumableTitle"));
            TextFieldUtil.processTextField(this.screen.consumablePanel_mc.desc_tf,ZGameUtils.ZlocT("Dialogs","MechLabConsumableDescription"));
            _loc2_ = ImageLoaderFactory.CreateImageLoader(_loc3_,this.panel.titanPlates_mc.icon);
            _loc2_.smooth = true;
            this.m_imageLoaders.push(_loc2_);
            _loc2_ = null;
            this.updateNumberOfConsumableParts(this.panel);
            if(this.allowsCollect)
            {
               this.m_panelCollectButton = new ZGameButton(this.panel.titanPlates_mc.collectTab_mc,this.onCollect);
               this.m_panelCollectButton.text = ZGameUtils.ZlocT("Dialogs","MechLabConsumableCollect");
               if(MechLabDailyRewardManager.instance.hasCollected)
               {
                  this.m_panelCollectButton.hide();
               }
               else
               {
                  this.m_panelCollectButton.enable();
               }
            }
            else
            {
               this.panel.titanPlates_mc.collectTab_mc.visible = false;
            }
            this.screen.consumablePanel_mc.visible = false;
            this.initButtons();
            this.initBonusIcons();
            this.m_openConsumablePanelButton = new GenericButton(this.panel.titanPlates_mc.add_bt,this.onOpenConsumablePanel);
            this.screen.consumablePanel_mc.titanPlates_mc.add_bt.visible = false;
            this.m_closeConsumablePanelButton = new ZGameButton(this.screen.consumablePanel_mc.back_bt,this.onCloseConsumablePanel);
            this.m_closeConsumablePanelButton.text = ZGameUtils.ZlocT("Dialogs","Back");
            _loc2_ = ImageLoaderFactory.CreateImageLoader(_loc3_,this.screen.consumablePanel_mc.titanPlates_mc.icon);
            _loc2_.smooth = true;
            this.m_imageLoaders.push(_loc2_);
            this.updateNumberOfConsumableParts(this.screen.consumablePanel_mc);
            if(this.allowsCollect)
            {
               this.m_consumableCollectButton = new ZGameButton(this.screen.consumablePanel_mc.titanPlates_mc.collectTab_mc,this.onCollect);
               this.m_consumableCollectButton.text = ZGameUtils.ZlocT("Dialogs","MechLabConsumableCollect");
               if(MechLabDailyRewardManager.instance.hasCollected)
               {
                  this.m_consumableCollectButton.hide();
               }
               else
               {
                  this.m_consumableCollectButton.enable();
               }
            }
            else
            {
               this.screen.consumablePanel_mc.titanPlates_mc.collectTab_mc.visible = false;
            }
         }
      }
      
      private function onCollect(param1:MouseEvent) : void
      {
         MechLabDailyRewardManager.instance.onCollect();
         this.m_panelCollectButton.hide();
         this.m_consumableCollectButton.hide();
         this.updateNumberOfConsumableParts(this.screen.consumablePanel_mc);
         this.updateNumberOfConsumableParts(this.panel);
      }
      
      private function initBonusIcons() : void
      {
         var _loc2_:MovieClip = null;
         var _loc4_:GameItem = null;
         var _loc6_:MovieClip = null;
         var _loc10_:int = 0;
         var _loc12_:ImageLoader = null;
         var _loc13_:Object = null;
         var _loc14_:Object = null;
         var _loc1_:int = 4;
         var _loc3_:MovieClip = this.screen.consumablePanel_mc;
         var _loc5_:String = "";
         _loc4_ = ZGlobal.gameSettings.getItemByCode(this.PART_CODE,GameItem) as GameItem;
         var _loc7_:String = ZGlobal.gameSettings.getImageByName(_loc4_.name,"icon");
         var _loc8_:int = MechLabDailyRewardManager.instance.getDayTier();
         var _loc9_:int = MechLabDailyRewardManager.instance.sequentialLogins;
         var _loc11_:String = _loc4_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
         TextFieldUtil.processTextField(_loc3_.total_tf,"" + ZGlobal.player.getNumberOfInventoryItems(this.PART_CODE));
         TextFieldUtil.compactTextField(_loc3_.title_tf,_loc11_,{"minScale":0.6});
         _loc12_ = ImageLoaderFactory.CreateImageLoader(_loc7_,_loc3_.icon);
         this.m_imageLoaders.push(_loc12_);
         _loc10_ = 0;
         while(_loc10_ <= _loc1_)
         {
            _loc2_ = _loc3_["bonus0" + _loc10_ + "_mc"];
            _loc6_ = _loc3_["bonusDay0" + _loc10_ + "_mc"];
            _loc2_.gotoAndStop("locked");
            _loc6_.gotoAndStop("locked");
            if(_loc10_ <= _loc8_)
            {
               _loc2_.gotoAndStop("complete");
               _loc6_.gotoAndStop("completed");
            }
            _loc12_ = ImageLoaderFactory.CreateImageLoader(_loc7_,_loc2_.icon);
            this.m_imageLoaders.push(_loc12_);
            _loc5_ = "+" + MechLabDailyRewardManager.instance.getTierReward(_loc10_) + " " + _loc11_;
            TextFieldUtil.compactTextField(_loc2_.bonus_tf,_loc5_,{
               "maxLines":2,
               "minScale":0.7
            });
            _loc14_ = {"count":MechLabDailyRewardManager.instance.getTierDay(_loc10_,true) + 1};
            _loc5_ = ZGameUtils.ZlocT("Dialogs","MechLabConsumableDay",_loc14_);
            TextFieldUtil.compactTextField(_loc6_.day_tf,_loc5_,{
               "maxLines":2,
               "minScale":0.7
            });
            _loc10_++;
         }
      }
      
      private function initButtons() : void
      {
         var _loc1_:GameItem = ZGlobal.gameSettings.getItemByCode(this.PART_CODE,GameItem) as GameItem;
         this.m_askButton = new ZGameButton(this.screen.consumablePanel_mc.ask_bt,this.onAskClicked);
         this.m_buyButton = new ZGameBuyButton(this.screen.consumablePanel_mc.buy_bt,this.generateBuyButtonData(),this.onBuyClicked);
         var _loc2_:String = _loc1_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
         this.m_askButton.text = ZGameUtils.ZlocT("Dialogs","MechLabPartDetailButtonAsk",{"item":_loc2_});
         var _loc3_:Object = ZGameUtils.CashTokenReplacements(_loc1_.cash);
         _loc3_.item = _loc2_;
         this.m_buyButton.text = ZGameUtils.ZlocT("Dialogs","MechLabPartDetailButtonBuy",_loc3_);
      }
      
      private function generateBuyButtonData() : Object
      {
         var _loc1_:GameItem = ZGlobal.gameSettings.getItemByCode(this.PART_CODE,GameItem) as GameItem;
         var _loc2_:Object = new Object();
         _loc2_.cash = _loc1_.cash;
         _loc2_.confirmationData = new Object();
         _loc2_.confirmationData.title = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle");
         var _loc3_:Object = ZGameUtils.CashTokenReplacements(_loc1_.cash);
         _loc3_.item = _loc1_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
         _loc2_.confirmationData.message = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseMessage",_loc3_);
         return _loc2_;
      }
      
      private function deinitConsumablePanel() : void
      {
         var _loc1_:ImageLoader = null;
         if(this.hasConsumablePanel)
         {
            for each(_loc1_ in this.m_imageLoaders)
            {
               _loc1_.destroy();
            }
            this.m_imageLoaders = null;
            this.m_askButton.dispose();
            this.m_askButton = null;
            this.m_buyButton.dispose();
            this.m_buyButton = null;
            this.m_openConsumablePanelButton = null;
            this.m_closeConsumablePanelButton.dispose();
            this.m_closeConsumablePanelButton = null;
            UIDispatcher.instance.removeEventListener(Player.INVENTORY_UPDATED,this.onInventoryUpdated);
         }
      }
      
      private function updateNumberOfConsumableParts(param1:MovieClip) : void
      {
         var _loc2_:int = ZGlobal.player.getNumberOfInventoryItems(this.PART_CODE);
         TextFieldUtil.compactTextField(param1.titanPlates_mc.total_tf,_loc2_.toString());
      }
      
      private function onOpenConsumablePanel(param1:MouseEvent) : void
      {
         this.consumablePanelVisible = true;
      }
      
      protected function set consumablePanelVisible(param1:Boolean) : void
      {
         this.screen.consumablePanel_mc.visible = param1;
         this.panel.visible = !param1;
         StatsManager.count("dialog","consumable_screen",param1 ? "view" : "close");
      }
      
      private function onAskClicked(param1:MouseEvent) : void
      {
         var _loc3_:String = null;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(this.PART_CODE,GameItem) as GameItem;
         if(_loc2_ != null)
         {
            _loc3_ = "titanlab_request_plating";
            ViralsManager.instance.sendFeedWithLotsOfFriction(_loc3_,{"resource":_loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME)});
         }
      }
      
      private function onBuyClicked(param1:MouseEvent) : void
      {
         var _loc2_:PartsBuildingItem = ZGlobal.gameSettings.getItemByCode(this.PART_CODE,PartsBuildingItem) as PartsBuildingItem;
         ZGlobal.player.buyGameItem(_loc2_);
         this.updateNumberOfConsumableParts(this.panel);
         this.updateNumberOfConsumableParts(this.screen.consumablePanel_mc);
      }
      
      private function onCloseConsumablePanel(param1:MouseEvent) : void
      {
         this.consumablePanelVisible = false;
      }
      
      private function onInventoryUpdated(param1:WorldEvent) : void
      {
         this.updateNumberOfConsumableParts(this.panel);
         this.updateNumberOfConsumableParts(this.screen.consumablePanel_mc);
      }
      
      protected function get hasConsumablePanel() : Boolean
      {
         return false;
      }
      
      protected function get allowsCollect() : Boolean
      {
         return true;
      }
   }
}

