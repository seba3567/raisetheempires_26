package displays.screens.powerupFactoryScreens
{
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsItem;
   import core.gameobjects.PartsPowerupItem;
   import core.managers.WorldObjectManager;
   import core.player.Player;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.ImageLoaderFactory;
   import displays.screens.ItemTooltip;
   import displays.screens.gridScreen.GridSlot;
   import entity.GameDataComponent;
   import events.ProgressBarEvent;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.utils.Dictionary;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class PowerupSlot extends GridSlot
   {
      
      public static const BUILD_POWERUP:String = "build";
      
      public static const FINISH_POWERUP:String = "finishpowerup";
      
      public static const BUY_POWERUP:String = "buypowerup";
      
      private static const NUM_SLOTS:int = 4;
      
      protected var m_buildBtn:ZGameButton;
      
      protected var m_buyBtn:ZGameButton;
      
      protected var m_finishNowBtn:ZGameButton;
      
      protected var m_progressBuilding:IEntity = null;
      
      protected var m_powerupItem:PartsPowerupItem = null;
      
      protected var m_iconLoaders:Array = null;
      
      public function PowerupSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:PartsPowerupItem, param7:Number, param8:Boolean)
      {
         super(param1,param2,param3);
         this.m_powerupItem = param6;
         slot.unitCard_mc.bg_mc_le.visible = false;
         slot.unitCard_mc.bg_mc.visible = false;
         slot.unitCard_mc.bg_mc_powerup_tier3.visible = param8;
         slot.unitCard_mc.bg_mc_powerup.visible = !param8;
         slot.unitCard_mc.bg_mc_locked.visible = false;
         slot.unitCard_mc.underlay_mc.visible = false;
         slot.x = param4 * (sizerWidth * param7);
         slot.y = param5 * (sizerHeight * param7);
         slot.unitCard_mc.highlightSelect_mc.visible = false;
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
         if(Boolean(this.m_buildBtn) && Boolean(this.m_buildBtn.enabled) || Boolean(this.m_finishNowBtn) && Boolean(this.m_finishNowBtn.enabled))
         {
            this.onBuildClicked(param1);
         }
      }
      
      private function checkRemainingParts() : Boolean
      {
         var _loc1_:PartsItem = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:GameItem = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(this.m_powerupItem)
         {
            _loc1_ = ZGlobal.gameSettings.getItemByCode(this.m_powerupItem.code,PartsItem) as PartsItem;
            _loc2_ = Math.min(this.m_powerupItem.numParts,NUM_SLOTS);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc4_ = this.m_powerupItem.getPartCodeForIndex(_loc3_);
               _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc4_,GameItem) as GameItem;
               if(_loc5_)
               {
                  _loc6_ = ZGlobal.player.getNumberOfInventoryItems(_loc4_);
                  _loc7_ = this.m_powerupItem.getPartCountForIndex(_loc3_);
                  if(_loc7_ > _loc6_)
                  {
                     return true;
                  }
               }
               _loc3_++;
            }
         }
         return false;
      }
      
      protected function filloutStats() : void
      {
         var _loc2_:IEntity = null;
         var _loc3_:GameDataComponent = null;
         var _loc4_:BuildingFSMComponent = null;
         var _loc1_:Dictionary = WorldObjectManager.instance.getObjectsBySubType("building","military");
         for each(_loc2_ in _loc1_)
         {
            if(_loc2_)
            {
               _loc3_ = GameDataComponent(_loc2_.lookupComponentByType(GameDataComponent));
               _loc4_ = BuildingFSMComponent(_loc2_.lookupComponentByType(BuildingFSMComponent));
            }
         }
         slot.unitCard_mc.icon.filters = [];
         slot.unitCard_mc.upgradeStatus_tf.visible = false;
         slot.unitCard_mc.upgradeStatus_tf.mouseEnabled = false;
         slot.unitCard_mc.tierRating_mc.visible = false;
         slot.unitCard_mc.discount_tf.visible = false;
         slot.unitCard_mc.doubleXP_mc.visible = false;
         slot.unitCard_mc.gotoAndStop("powerup");
         if(ZGlobal.player.checkGate(this.m_powerupItem).isBitSet(Player.GATE_FAILURE_LEVEL))
         {
            slot.unitCard_mc.gotoAndStop("locked");
            slot.unitCard_mc.unlock_bt.visible = false;
            slot.unitCard_mc.buy_bt.visible = false;
            slot.unitCard_mc.tooltip.visible = false;
            TextFieldUtil.processTextField(slot.unitCard_mc.locked_tf,ZGameUtils.ZlocT("Dialogs","LevelRequired",{"num":this.m_powerupItem.requiredLevel}));
            slot.unitCard_mc.locked_tf.mouseEnabled = false;
            slot.unitCard_mc.locked_mc.visible = true;
            slot.unitCard_mc.icon.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
            slot.unitCard_mc.bg_mc_powerup_tier3.visible = false;
            slot.unitCard_mc.bg_mc_powerup.visible = false;
            slot.unitCard_mc.bg_mc_locked.visible = true;
         }
         else if(!this.checkRemainingParts())
         {
            slot.unitCard_mc.build_bt.visible = false;
            this.m_finishNowBtn = new ZGameButton(slot.unitCard_mc.finishNow_bt,this.onBuildClicked);
            this.m_finishNowBtn.text = ZGameUtils.ZlocT("Dialogs","PowerupSelectionFinishButtonText");
            slot.unitCard_mc.cashIcon_mc.visible = false;
            slot.unitCard_mc.finishNow_bt.visible = true;
            m_buttonSounds.addButton(this.m_finishNowBtn.m_overlay,ButtonSound.DEFAULT);
            this.m_finishNowBtn.enable();
         }
         else
         {
            this.m_buildBtn = new ZGameButton(slot.unitCard_mc.build_bt,this.onBuildClicked);
            this.m_buildBtn.text = ZGameUtils.ZlocT("Dialogs","PowerupSelectionBuildButtonText");
            this.m_buildBtn.enable();
            m_buttonSounds.addButton(this.m_buildBtn.m_overlay,ButtonSound.DEFAULT);
            this.m_buyBtn = new ZGameButton(slot.unitCard_mc.finishNow_bt,this.onBuyClicked);
            this.m_buyBtn.text = ZGameUtils.ZlocT("Dialogs","BuyForAmount",{"amount":this.m_powerupItem.cash});
            slot.unitCard_mc.cashIcon_mc.visible = true;
            slot.unitCard_mc.finishNow_bt.visible = true;
            m_buttonSounds.addButton(this.m_buyBtn.m_overlay,ButtonSound.DEFAULT);
         }
         this.m_iconLoaders = new Array();
         this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(this.m_powerupItem.name,"icon"),slot.unitCard_mc.icon));
         TextFieldUtil.processTextField(slot.unitCard_mc.itemName_tf,this.m_powerupItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         slot.unitCard_mc.itemName_tf.mouseEnabled = false;
         if(slot.unitCard_mc.currentLabel == "inProgress")
         {
            slot.unitCard_mc.upgrades_mc.visible = false;
            slot.unitCard_mc.tooltip.visible = false;
         }
      }
      
      protected function onProgress(param1:ProgressBarEvent) : void
      {
         TextFieldUtil.processTextField(slot.unitCard_mc.countdown_tf,param1.timeRemaining);
      }
      
      protected function onProgressComplete(param1:ProgressBarEvent) : void
      {
         slot.unitCard_mc.upgradeStatus_tf.visible = false;
         slot.unitCard_mc.finishNow_bt.visible = false;
         TextFieldUtil.processTextField(slot.unitCard_mc.countdown_tf,ZGameUtils.ZlocT("Dialogs","ResearchReady_Line"));
         this.m_progressBuilding.eventDispatcher.removeEventListener(ProgressBarEvent.UPDATE_PROGRESS,this.onProgress);
         this.m_progressBuilding.eventDispatcher.removeEventListener(ProgressBarEvent.STOP_PROGRESS_BAR,this.onProgressComplete);
      }
      
      private function onBuyClicked(param1:MouseEvent) : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(BUY_POWERUP,{"unitItem":this.m_powerupItem}));
      }
      
      private function onBuildClicked(param1:MouseEvent) : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(BUILD_POWERUP,this));
      }
      
      override public function dispose() : void
      {
         if(this.m_progressBuilding)
         {
            this.m_progressBuilding.eventDispatcher.removeEventListener(ProgressBarEvent.UPDATE_PROGRESS,this.onProgress);
         }
         if(this.m_buyBtn)
         {
            this.m_buyBtn.dispose();
         }
         if(this.m_buildBtn)
         {
            this.m_buildBtn.dispose();
         }
         if(this.m_finishNowBtn)
         {
            this.m_finishNowBtn.dispose();
         }
         super.dispose();
      }
   }
}

