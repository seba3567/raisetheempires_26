package displays.screens.contractScreen
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsItem;
   import core.managers.PVPManager;
   import core.ui.UI;
   import core.ui.ZGameButton;
   import core.ui.ZGameBuyButton;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.ItemTooltip;
   import displays.screens.gridScreen.GridSlot;
   import events.MarketEvent;
   import events.ProgressBarEvent;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class MissionContractSlot extends GridSlot
   {
      
      public static const DEPLOY_MISSION:String = "deploy";
      
      public static const BUILD_MISSION:String = "build";
      
      public static const FINISH_MISSION:String = "finishmission";
      
      public static const UNLOCK_MISSION:String = "buymission";
      
      private static const NUM_SLOTS:int = 4;
      
      protected var m_deployBtn:ZGameButton;
      
      protected var m_buildBtn:ZGameButton;
      
      protected var m_unlockBtn:ZGameBuyButton;
      
      protected var m_progressBuilding:IEntity = null;
      
      protected var m_powerupItem:PartsItem = null;
      
      protected var m_iconLoaders:Array = null;
      
      public function MissionContractSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:PartsItem, param7:Number, param8:Boolean)
      {
         super(param1,param2,param3);
         this.m_powerupItem = param6;
         slot.x = param4 * (sizerWidth * param7);
         slot.y = param5 * (sizerHeight * param7);
         this.filloutStats();
      }
      
      override protected function get className() : String
      {
         return "UnitCard";
      }
      
      override public function getData() : Object
      {
         return this.m_powerupItem;
      }
      
      override public function fillOutTooltip() : ItemTooltip
      {
         return new ItemTooltip(GameItem.CONSUMABLE_TOOLTIP,this.m_powerupItem,ItemTooltip.SOURCE_NONE);
      }
      
      override public function get tooltipAnchorPositionY() : Number
      {
         return 0;
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         if(Boolean(this.m_buildBtn) && this.m_buildBtn.enabled)
         {
            this.onBuildClicked(param1);
         }
      }
      
      protected function filloutStats() : void
      {
         slot.unitCard_mc.icon.filters = [];
         slot.unitCard_mc.gotoAndStop("powerup");
         slot.unitCard_mc.bg_mc_plan.visible = false;
         slot.unitCard_mc.bg_mc_locked.visible = false;
         slot.unitCard_mc.bg_mc_soon.visible = false;
         slot.unitCard_mc.bg_mc_sf_ready.visible = false;
         slot.unitCard_mc.highlightSelect_mc.visible = false;
         slot.unitCard_mc.soon_tf.visible = false;
         slot.unitCard_mc.locked_tf.visible = false;
         this.m_buildBtn = new ZGameButton(slot.unitCard_mc.build_bt,this.onBuildClicked);
         this.m_buildBtn.text = ZGameUtils.ZlocT("Dialogs","MissionSelectionBuildButtonText");
         m_buttonSounds.addButton(this.m_buildBtn.m_overlay,ButtonSound.DEFAULT);
         this.m_unlockBtn = new ZGameBuyButton(slot.unitCard_mc.buy_bt,this.generateUnlockButtonData(this.m_powerupItem),this.onUnlockClicked);
         this.m_unlockBtn.text = ZGameUtils.ZlocT("Dialogs","MissionCardUnlockForAmount",{"amount":this.m_powerupItem.contractCost});
         m_buttonSounds.addButton(this.m_unlockBtn.m_overlay,ButtonSound.DEFAULT);
         this.m_deployBtn = new ZGameButton(slot.unitCard_mc.deploy_bt,this.onDeployClicked);
         this.m_deployBtn.text = ZGameUtils.ZlocT("Dialogs","MissionSelectionDeployButtonText");
         m_buttonSounds.addButton(this.m_deployBtn.m_overlay,ButtonSound.DEFAULT);
         var _loc1_:int = ZGlobal.player.getNumberOfInventoryItems(this.m_powerupItem.code);
         var _loc2_:int = this.getRequiredMissionCount();
         var _loc3_:int = this.getRequiredMissionsDeployed();
         if(_loc2_ <= _loc3_ && !ZGlobal.player.hasPurchasedContract(this.m_powerupItem.code))
         {
            ZGlobal.player.unlockContract(this.m_powerupItem,true,false,true);
         }
         if(!ZGlobal.player.hasPurchasedContract(this.m_powerupItem.code))
         {
            slot.unitCard_mc.gotoAndStop("locked");
            this.m_buildBtn.hide();
            this.m_unlockBtn.show();
            this.m_deployBtn.show();
            this.m_deployBtn.disable(true);
            slot.unitCard_mc.locked_tf.visible = true;
            TextFieldUtil.processTextField(slot.unitCard_mc.locked_tf,ZGameUtils.ZlocT("Dialogs","MissionPartsUnlockRequirements",{"num":_loc2_}));
            slot.unitCard_mc.locked_tf.mouseEnabled = false;
            slot.unitCard_mc.icon.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
            slot.unitCard_mc.bg_mc_locked.visible = true;
            TextFieldUtil.processTextField(slot.unitCard_mc.header_tf,ZGameUtils.ZlocT("Dialogs","MissionCardUnlock"));
            slot.unitCard_mc.count_mc.visible = false;
         }
         else if(_loc1_ == 0)
         {
            this.m_buildBtn.show();
            this.m_unlockBtn.hide();
            this.m_deployBtn.show();
            this.m_deployBtn.disable(true);
            slot.unitCard_mc.bg_mc_plan.visible = true;
            TextFieldUtil.processTextField(slot.unitCard_mc.header_tf,ZGameUtils.ZlocT("Dialogs","MissionCardPlan"));
            slot.unitCard_mc.count_mc.visible = false;
         }
         else
         {
            this.m_buildBtn.show();
            this.m_unlockBtn.hide();
            this.m_deployBtn.show();
            if(PVPManager.instance.numOccupiedInvaders > 0)
            {
               this.m_deployBtn.enable();
            }
            else
            {
               this.m_deployBtn.disable(true);
            }
            slot.unitCard_mc.bg_mc_sf_ready.visible = true;
            TextFieldUtil.processTextField(slot.unitCard_mc.header_tf,ZGameUtils.ZlocT("Dialogs","MissionCardReady"));
            slot.unitCard_mc.count_mc.visible = true;
            TextFieldUtil.processTextField(slot.unitCard_mc.count_mc.count_tf,_loc1_.toString());
         }
         this.m_iconLoaders = new Array();
         this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(this.m_powerupItem.name,"icon"),slot.unitCard_mc.icon));
         TextFieldUtil.processTextField(slot.unitCard_mc.itemName_tf,this.m_powerupItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         slot.unitCard_mc.itemName_tf.mouseEnabled = false;
         if(slot.unitCard_mc.currentLabel == "inProgress")
         {
            slot.unitCard_mc.upgrades_mc.visible = false;
         }
      }
      
      private function getRequiredMissionCount() : int
      {
         var _loc1_:int = 0;
         var _loc2_:XML = this.m_powerupItem.xml;
         if(_loc2_.requiredConsumableUsed != undefined && _loc2_.requiredConsumableUsed.length() > 0)
         {
            _loc1_ = int(_loc2_.requiredConsumableUsed[0].@count);
         }
         return _loc1_;
      }
      
      private function getRequiredMissionsDeployed() : int
      {
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc1_:int = 0;
         var _loc2_:XML = this.m_powerupItem.xml;
         if(_loc2_.requiredConsumableUsed != undefined && _loc2_.requiredConsumableUsed.length() > 0)
         {
            _loc3_ = _loc2_.requiredConsumableUsed[0].@codes;
            _loc4_ = _loc3_.split(",");
            for(_loc5_ in _loc4_)
            {
               _loc1_ += ZGlobal.player.getConsumableUsedByCode(_loc4_[_loc5_]);
            }
         }
         return _loc1_;
      }
      
      protected function onProgress(param1:ProgressBarEvent) : void
      {
         TextFieldUtil.processTextField(slot.unitCard_mc.countdown_tf,param1.timeRemaining);
      }
      
      protected function onProgressComplete(param1:ProgressBarEvent) : void
      {
         slot.unitCard_mc.buy_bt.visible = false;
         TextFieldUtil.processTextField(slot.unitCard_mc.countdown_tf,ZGameUtils.ZlocT("Dialogs","ResearchReady_Line"));
         this.m_progressBuilding.eventDispatcher.removeEventListener(ProgressBarEvent.UPDATE_PROGRESS,this.onProgress);
         this.m_progressBuilding.eventDispatcher.removeEventListener(ProgressBarEvent.STOP_PROGRESS_BAR,this.onProgressComplete);
      }
      
      private function onUnlockClicked(param1:MouseEvent) : void
      {
         if(ZGlobal.player.canBuyCash(this.m_powerupItem.contractCost,true,"",false))
         {
            UI.instance.setupForItemPurchase();
            UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_UNLOCK_CONTRACT,0,this.m_powerupItem.name,MarketEvent.SOURCE_STORE));
            UIDispatcher.instance.dispatchEvent(new WorldEvent(UNLOCK_MISSION,{"unitItem":this.m_powerupItem}));
            this.filloutStats();
         }
      }
      
      private function onBuildClicked(param1:MouseEvent) : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(BUILD_MISSION,this));
      }
      
      private function onDeployClicked(param1:MouseEvent) : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(DEPLOY_MISSION,{"unitItem":this.m_powerupItem}));
      }
      
      override public function dispose() : void
      {
         var _loc1_:ImageLoader = null;
         if(this.m_progressBuilding)
         {
            this.m_progressBuilding.eventDispatcher.removeEventListener(ProgressBarEvent.UPDATE_PROGRESS,this.onProgress);
         }
         if(this.m_unlockBtn)
         {
            this.m_unlockBtn.dispose();
         }
         if(this.m_deployBtn)
         {
            this.m_deployBtn.dispose();
         }
         if(this.m_buildBtn)
         {
            this.m_buildBtn.dispose();
         }
         if(this.m_iconLoaders != null)
         {
            for each(_loc1_ in this.m_iconLoaders)
            {
               _loc1_.destroy();
            }
            this.m_iconLoaders = null;
         }
         super.dispose();
      }
      
      private function generateUnlockButtonData(param1:GameItem) : Object
      {
         var _loc2_:uint = uint(param1.contractCost);
         var _loc3_:Object = new Object();
         _loc3_.cash = _loc2_;
         _loc3_.confirmationData = new Object();
         _loc3_.confirmationData.title = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle");
         var _loc4_:Object = ZGameUtils.CashTokenReplacements(_loc2_);
         _loc4_.item = param1.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
         _loc3_.confirmationData.message = ZGameUtils.ZlocT("Dialogs","MechLabConfirmUnlockMessage",_loc4_);
         return _loc3_;
      }
   }
}

