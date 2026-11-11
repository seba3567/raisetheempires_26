package displays.screens.partsGather
{
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsItem;
   import core.gameobjects.PartsLEUnitItem;
   import core.gameobjects.UnitItem;
   import core.managers.ExperimentsManager;
   import core.managers.LEUnitFactoryManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.unitClassManager.UnitClass;
   import core.managers.unitClassManager.UnitClassManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.leUnitFactoryScreens.LEUnitSelectionScreen;
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
   
   public class LEUnitPartsGather extends PartsGather
   {
      
      private var m_backButton:ZGameButton = null;
      
      private var m_leUnitItem:PartsLEUnitItem;
      
      private var m_unit:UnitItem;
      
      private var m_imageLoaders:Array = [];
      
      public function LEUnitPartsGather(param1:EventDispatcher, param2:String, param3:IEntity, param4:PartsLEUnitItem)
      {
         super(param1,param2,param3);
         this.m_leUnitItem = param4;
         this.m_unit = ZGlobal.gameSettings.getItemByCode(this.m_leUnitItem.unitCode,UnitItem) as UnitItem;
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:IEntity, param4:PartsLEUnitItem) : void
      {
         WindowManager.instance.push(new LEUnitPartsGather(param1,param2,param3,param4));
      }
      
      override protected function get assetUrl() : String
      {
         return "assets/displays/screens/LEFactoryPartsGather.swf";
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         m_partsWindow.back_bt.visible = true;
         m_partsWindow.unitCard_mc.upgrades_mc.visible = true;
         this.m_backButton = new ZGameButton(m_partsWindow.back_bt,this.onBackClick);
         this.m_backButton.text = ZGameUtils.ZlocT("Dialogs","BuildingPartsBack");
         var _loc2_:Array = [m_partsWindow.unitCard_mc.upgrades_mc.icon0,m_partsWindow.unitCard_mc.upgrades_mc.icon1,m_partsWindow.unitCard_mc.upgrades_mc.icon2,m_partsWindow.unitCard_mc.upgrades_mc.icon3,m_partsWindow.unitCard_mc.upgrades_mc.icon4];
         m_partsWindow.finish_bt.visible = false;
         TextFieldUtil.compactTextField(m_partsWindow.title_tf,this.m_unit.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         m_buttonSounds.addButton(this.m_backButton.m_overlay,ButtonSound.DEFAULT);
         this.initUnitStats();
      }
      
      override protected function initDialog() : void
      {
         this.contentWidth = m_partsWindow.panel_mc.width;
         this.contentHeight = m_partsWindow.panel_mc.height;
         super.initDialog();
      }
      
      protected function initUnitStats() : void
      {
         var _loc1_:ImageLoader = null;
         var _loc3_:UnitClass = null;
         var _loc4_:Array = null;
         var _loc2_:Boolean = false;
         TextFieldUtil.compactTextField(m_partsWindow.against_tf,ZGameUtils.ZlocT("Dialogs","CombatCardGoodAgainst"));
         _loc4_ = this.m_unit.goodAgainst;
         var _loc5_:int = 0;
         while(_loc5_ < 3)
         {
            _loc3_ = UnitClassManager.instance.unitClassNamed(_loc4_[_loc5_]);
            _loc1_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc2_ ? _loc3_.getIconURL() : _loc3_.getAltIconURL()),m_partsWindow["against" + _loc5_]);
            _loc1_.reverse = _loc2_;
            this.m_imageLoaders.push(_loc1_);
            _loc5_++;
         }
         m_partsWindow.unitStats_mc.visible = true;
         _loc3_ = UnitClassManager.instance.unitClassNamed(this.m_unit.unitClass);
         _loc1_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc3_.getSmIconURL()),m_partsWindow.unitStats_mc.icon_class);
         this.m_imageLoaders.push(_loc1_);
         TextFieldUtil.compactTextField(m_partsWindow.unitStats_mc.strength_tf,String(this.m_unit.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(this.m_unit.code))));
      }
      
      override protected function loadUnitCardIcon() : void
      {
         var _loc1_:String = ZGlobal.gameSettings.getImageByName(this.m_unit.name,"icon");
         itemIconLoader = ImageLoaderFactory.CreateImageLoader(_loc1_,m_partsWindow.icon);
         itemIconLoader.smooth = true;
         m_partsWindow.unitCard_mc.upgrades_mc.visible = false;
         m_partsWindow.unitCard_mc.tooltip.visible = false;
      }
      
      override protected function getPartsItem(param1:String) : PartsItem
      {
         return ZGlobal.gameSettings.getItemByCode(param1,PartsLEUnitItem) as PartsLEUnitItem;
      }
      
      override protected function setDescriptionText() : void
      {
         if(!canFinish())
         {
            TextFieldUtil.compactTextField(m_partsWindow.description_tf,ZGameUtils.ZlocT("Dialogs","LEUnitPartsSubtitle",{"item":this.m_unit.getSentenceNameLocalizationObject()}));
         }
         else
         {
            TextFieldUtil.compactTextField(m_partsWindow.description_tf,ZGameUtils.ZlocT("Dialogs","LEUnitPartsSubtitleComplete",{"item":this.m_unit.getSentenceNameLocalizationObject()}));
         }
      }
      
      override protected function onFinishClick(param1:MouseEvent) : void
      {
         if(canFinish())
         {
            LEUnitFactoryManager.instance.startBuildPlacement(m_slotData,this.m_unit,this.m_leUnitItem,m_entity);
            closeWindow(null);
         }
      }
      
      override protected function onAskClick(param1:MouseEvent) : void
      {
         var _loc4_:String = null;
         var _loc2_:Object = getSlotInfoFromEvent(param1);
         var _loc3_:GameItem = _loc2_.data.partItem;
         if(_loc3_ != null)
         {
            if(_loc2_.slotIndex == m_slotData.length - 1 || _loc2_.slotIndex == 0)
            {
               ViralsManager.instance.sendFeedWithLotsOfFriction("ask_for_parts_leunitfactory",{
                  "itemCode":_loc3_.code,
                  "leUnitName":this.m_leUnitItem.unit.name,
                  "ITEMTOKitem":this.m_leUnitItem.unit.name + "|",
                  "ITEMTOKreward":_loc3_.name + "|"
               },null);
            }
            else if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_MASTER) == ExperimentsManager.VARIANT_VALUE_REQUEST2_MASTER_ON)
            {
               PopupManager.instance.push(new RequestAskPartsDialog(_loc3_.name,this.m_leUnitItem.unit.name));
            }
            else
            {
               _loc4_ = "building_parts.php?part=" + _loc3_.name + "&unit=" + m_partsItem.name + "&requestType=leunitfactory_part";
               ZGlobal.navigateImmediatelyTo(_loc4_);
            }
         }
      }
      
      override protected function sendStatsEvent(param1:Boolean) : void
      {
         if(param1)
         {
            ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
               "counter":"dialog",
               "kingdom":"le_unit_factory",
               "phylum":"buy_all"
            }));
         }
      }
      
      private function onBackClick(param1:MouseEvent) : void
      {
         closeWindow(param1);
         LEUnitSelectionScreen.display(m_eventDispatcher,m_partsItem.subType,m_entity);
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         if(this.m_backButton != null)
         {
            this.m_backButton.dispose();
            this.m_backButton = null;
         }
         for each(_loc1_ in this.m_imageLoaders)
         {
            _loc1_.destroy();
         }
         this.m_imageLoaders = null;
         super.deinitDialog();
      }
   }
}

