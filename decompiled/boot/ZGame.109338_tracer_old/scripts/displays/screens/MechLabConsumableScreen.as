package displays.screens
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsBuildingItem;
   import core.managers.ExperimentsManager;
   import core.managers.MechLabDailyRewardManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import core.ui.ZGameBuyButton;
   import dispatchers.MessageDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.displays.popups.IWindow;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.WindowManager;
   
   public class MechLabConsumableScreen extends MechLabScreen
   {
      
      public static const FINISHED:String = "finished";
      
      private var m_eventDispatcher:EventDispatcher = null;
      
      private var m_entity:IEntity = null;
      
      private var m_partsDetailLoader:ImageLoader = null;
      
      private var m_fightButton:ZGameButton = null;
      
      private var m_askButton:ZGameButton = null;
      
      private var m_buyButton:ZGameBuyButton = null;
      
      private var m_finishButton:ZGameButton = null;
      
      private var m_imageLoaders:Array = [];
      
      private var m_disposeFunc:Function;
      
      private const PART_CODE:String = "B289";
      
      public function MechLabConsumableScreen(param1:EventDispatcher, param2:IEntity, param3:String = "assets/displays/screens/MechLabMain.swf")
      {
         this.m_eventDispatcher = param1;
         this.m_entity = param2;
         super(param1,param2,ZGlobal.getAssetURL(param3));
      }
      
      public static function display(param1:EventDispatcher, param2:IEntity) : IWindow
      {
         var _loc3_:IWindow = null;
         _loc3_ = new MechLabConsumableScreen(param1,param2);
         WindowManager.instance.push(_loc3_);
         return _loc3_;
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         var _loc1_:Boolean = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MECH_LAB_DAILY_REWARD) != 3;
         this.initCommonAssets();
         if(_loc1_)
         {
            this.initPreviewMode();
         }
         else
         {
            this.initDailyRewardMode();
         }
      }
      
      override protected function initUI() : void
      {
         screen.partsPanel_mc.visible = false;
         screen.badges_mc.visible = false;
         screen.complete_mc.visible = false;
         screen.comingSoon_mc.visible = false;
         screen.finish_bt.visible = false;
         screen.activationPanel_mc.visible = false;
         screen.mech2_mc.visible = false;
         screen.buildPanel_mc.visible = false;
         screen.mech_mc.visible = true;
         screen.consumablePanel_mc.visible = true;
         screen.consumablePanel_mc.back_bt.visible = false;
         screen.consumablePanel_mc.titanPlates_mc.visible = false;
      }
      
      private function initCommonAssets() : void
      {
         screen.leftPanel_mc.visible = true;
         screen.leftPanel_mc.screenDesc_mc.visible = false;
         screen.badges_mc.visible = false;
         screen.finish_bt.visible = false;
         screen.frame_mc.mouseEnabled = false;
         screen.complete_mc.visible = true;
         TextFieldUtil.processTextField(screen.complete_mc.complete_tf,ZGameUtils.ZlocT("Dialogs","MechLabResearchComplete"));
      }
      
      private function initPreviewMode() : void
      {
         this.m_disposeFunc = this.disposePreviewMode;
         TextFieldUtil.processTextField(screen.screenTitle_tf,ZGameUtils.ZlocT("Dialogs","MechLabConsumableTitle"));
         TextFieldUtil.processTextField(screen.comingSoon_mc.desc_tf,ZGameUtils.ZlocT("Dialogs","MechLabComingSoonBody"));
         screen.consumablePanel_mc.visible = false;
         screen.comingSoon_mc.visible = true;
         screen.partsPanel_mc.visible = false;
         TextFieldUtil.processTextField(screen.comingSoon_mc.title_tf,ZGameUtils.ZlocT("Dialogs","MechLabComingSoonHeader"));
         this.showMechBuilt();
      }
      
      private function disposePreviewMode() : void
      {
      }
      
      private function initDailyRewardMode() : void
      {
         this.m_disposeFunc = this.disposeDailyRewardMode;
         MessageDispatcher.instance.addEventListener(MessageDispatcher.ITEM_GIFT,this.onItemGift,false,0,true);
         TextFieldUtil.processTextField(screen.screenTitle_tf,ZGameUtils.ZlocT("Dialogs","MechLabConsumableTitle"));
         TextFieldUtil.processTextField(screen.consumablePanel_mc.desc_tf,ZGameUtils.ZlocT("Dialogs","MechLabConsumableDescription"));
         screen.consumablePanel_mc.visible = true;
         screen.comingSoon_mc.visible = false;
         screen.partsPanel_mc.visible = false;
         this.showMechBuilt();
         this.initButtons();
         this.initBonusIcons();
      }
      
      private function disposeDailyRewardMode() : void
      {
         this.m_askButton.dispose();
         this.m_askButton = null;
         this.m_buyButton.dispose();
         this.m_buyButton = null;
         MessageDispatcher.instance.removeEventListener(MessageDispatcher.ITEM_GIFT,this.onItemGift);
      }
      
      private function onItemGift(param1:WorldEvent) : void
      {
         if(param1.eventData.code == this.PART_CODE)
         {
            this.refreshPartCount();
         }
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_imageLoaders)
         {
            _loc1_.destroy();
         }
         this.m_imageLoaders = null;
         this.m_disposeFunc();
         super.deinitDialog();
      }
      
      private function showMechBuilt() : void
      {
         var _loc5_:MovieClip = null;
         var _loc1_:int = 7;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ <= _loc1_)
         {
            MovieClip(screen.badges_mc["mechItemBadge0" + _loc2_ + "_mc"]).visible = false;
            _loc2_++;
         }
         var _loc3_:Array = ["mechItemLegLeft_mc","mechItemArmLeft_mc","mechItemHead_mc","mechItemHeadGun_mc","mechItemBody_mc","mechItemBack_mc","mechItemArmRight_mc","mechItemFootLeft_mc","mechItemFootRight_mc","mechItemLegRight_mc"];
         var _loc4_:MovieClip = screen.mech_mc;
         _loc2_ = 0;
         while(_loc2_ < _loc3_.length)
         {
            _loc5_ = _loc4_[_loc3_[_loc2_]];
            _loc5_.visible = false;
            _loc2_++;
         }
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
         var _loc3_:MovieClip = screen.consumablePanel_mc;
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
         this.m_askButton = new ZGameButton(screen.consumablePanel_mc.ask_bt,this.onAskClicked);
         this.m_buyButton = new ZGameBuyButton(screen.consumablePanel_mc.buy_bt,this.generateBuyButtonData(),this.onBuyClicked);
         var _loc2_:String = _loc1_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
         this.m_askButton.text = ZGameUtils.ZlocT("Dialogs","MechLabPartDetailButtonAsk",{"item":_loc2_});
         var _loc3_:Object = ZGameUtils.CashTokenReplacements(_loc1_.cash);
         _loc3_.item = _loc2_;
         this.m_buyButton.text = ZGameUtils.ZlocT("Dialogs","MechLabPartDetailButtonBuy",_loc3_);
      }
      
      private function onAskClicked(param1:MouseEvent) : void
      {
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(this.PART_CODE,GameItem) as GameItem;
         if(_loc2_ != null)
         {
            ViralsManager.instance.sendFeedWithLotsOfFriction("ask_for_parts_titan_plating",{
               "itemCode":_loc2_.code,
               "mechlabPartName":_loc2_.name,
               "powerupName":null,
               "ITEMTOKitem":m_partsItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME) + "|",
               "ITEMTOKreward":_loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME) + "|"
            },null);
         }
      }
      
      private function onBuyClicked(param1:MouseEvent) : void
      {
         var _loc2_:PartsBuildingItem = ZGlobal.gameSettings.getItemByCode(this.PART_CODE,PartsBuildingItem) as PartsBuildingItem;
         ZGlobal.player.buyGameItem(_loc2_);
         this.refreshPartCount();
      }
      
      private function refreshPartCount() : void
      {
         TextFieldUtil.processTextField(screen.consumablePanel_mc.total_tf,"" + ZGlobal.player.getNumberOfInventoryItems(this.PART_CODE));
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
      
      override protected function get currentActivationStage() : uint
      {
         return 2;
      }
   }
}

