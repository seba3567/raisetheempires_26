package displays.screens.partsGather
{
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsItem;
   import core.gameobjects.PartsPowerupItem;
   import core.managers.ExperimentsManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import displays.screens.powerupFactoryScreens.PowerupSelectionScreen;
   import displays.screens.requests.RequestAskPartsDialog;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class PowerupPartsGather extends PartsGather
   {
      
      private var m_backButton:ZGameButton = null;
      
      public function PowerupPartsGather(param1:EventDispatcher, param2:String, param3:IEntity)
      {
         super(param1,param2,param3);
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:IEntity) : void
      {
         WindowManager.instance.push(new PowerupPartsGather(param1,param2,param3));
      }
      
      override protected function get assetUrl() : String
      {
         return "assets/displays/screens/PU_UnitPartsGather.swf";
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         super.onLoadComplete(param1);
         m_partsWindow.back_bt.visible = true;
         m_partsWindow.unitCard_mc.upgrades_mc.visible = true;
         this.m_backButton = new ZGameButton(m_partsWindow.back_bt,this.onBackClick);
         this.m_backButton.text = ZGameUtils.ZlocT("Dialogs","BuildingPartsBack");
         var _loc2_:Array = [m_partsWindow.unitCard_mc.upgrades_mc.icon0,m_partsWindow.unitCard_mc.upgrades_mc.icon1,m_partsWindow.unitCard_mc.upgrades_mc.icon2,m_partsWindow.unitCard_mc.upgrades_mc.icon3,m_partsWindow.unitCard_mc.upgrades_mc.icon4];
         _loc3_ = {"item":m_partsItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME)};
         _loc4_ = ZGameUtils.ZlocT("Dialogs","PowerupPartsTitle",_loc3_);
         TextFieldUtil.processTextField(m_partsWindow.title_tf,_loc4_);
         m_buttonSounds.addButton(this.m_backButton.m_overlay,ButtonSound.DEFAULT);
      }
      
      override protected function getPartsItem(param1:String) : PartsItem
      {
         return ZGlobal.gameSettings.getItemByCode(param1,PartsPowerupItem) as PartsPowerupItem;
      }
      
      override protected function setDescriptionText() : void
      {
         if(!canFinish())
         {
            TextFieldUtil.compactTextField(m_partsWindow.description_tf,ZGameUtils.ZlocT("Dialogs","PowerupPartsSubtitle"));
         }
         else
         {
            TextFieldUtil.compactTextField(m_partsWindow.description_tf,ZGameUtils.ZlocT("Dialogs","PowerupPartsSubtitleComplete"));
         }
      }
      
      override protected function completePartsItem() : void
      {
         m_eventDispatcher.dispatchEvent(new WorldEvent(PowerupSelectionScreen.FINISH_POWERUP,{"unitItem":m_partsItem}));
         closeWindow(null);
      }
      
      override protected function onAskClick(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc2_:Object = getSlotInfoFromEvent(param1);
         var _loc3_:GameItem = _loc2_.data.partItem;
         if(_loc3_ != null)
         {
            _loc4_ = ZGlobal.getResearchPartsExperimentVariantByType(m_partsItem.subType);
            if(_loc2_.slotIndex == m_slotData.length - 1 || _loc2_.slotIndex == 0)
            {
               ViralsManager.instance.sendFeedWithLotsOfFriction("ask_for_parts_powerup",{
                  "itemCode":_loc3_.code,
                  "powerupName":m_partsItem.name,
                  "ITEMTOKitem":m_partsItem.name + "|",
                  "ITEMTOKreward":_loc3_.name + "|"
               },null);
            }
            else if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_MASTER) == ExperimentsManager.VARIANT_VALUE_REQUEST2_MASTER_ON)
            {
               PopupManager.instance.push(new RequestAskPartsDialog(_loc3_.name,m_partsItem.name));
            }
            else
            {
               _loc5_ = "building_parts.php?part=" + _loc3_.name + "&unit=" + m_partsItem.name + "&requestType=powerup_part";
               ZGlobal.navigateImmediatelyTo(_loc5_);
            }
         }
      }
      
      override protected function sendStatsEvent(param1:Boolean) : void
      {
         if(param1)
         {
            ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
               "counter":"dialog",
               "kingdom":"powerup_factory",
               "phylum":"buy_all"
            }));
         }
      }
      
      private function onBackClick(param1:MouseEvent) : void
      {
         closeWindow(param1);
         PowerupSelectionScreen.display(m_eventDispatcher,m_partsItem.subType,m_entity);
      }
      
      override protected function deinitDialog() : void
      {
         if(this.m_backButton != null)
         {
            this.m_backButton.dispose();
            this.m_backButton = null;
         }
         super.deinitDialog();
      }
   }
}

