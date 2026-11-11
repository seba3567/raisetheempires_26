package displays.screens.partsGather
{
   import Engine.Managers.TransactionManager;
   import ZLocalization.LocalizationObjectToken;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsItem;
   import core.gameobjects.PartsUnitItem;
   import core.gameobjects.UnitItem;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import displays.screens.requests.RequestAskPartsDialog;
   import displays.screens.researchScreens.MegaResearchUnitSelectionScreen;
   import displays.screens.researchScreens.ResearchUnitSelectionScreen;
   import displays.screens.researchScreens.ResearchUpgradeScreen;
   import displays.screens.researchScreens.UpgradesDisplay;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import transactions.TUnitUnlock;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class UnitPartsGather extends PartsGather
   {
      
      private var m_backButton:ZGameButton = null;
      
      private var m_upgradesDisplay:UpgradesDisplay = null;
      
      private var m_researchScreenUnitItem:UnitItem = null;
      
      public function UnitPartsGather(param1:EventDispatcher, param2:String, param3:IEntity, param4:UnitItem)
      {
         this.m_researchScreenUnitItem = param4;
         super(param1,param2,param3);
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:IEntity, param4:UnitItem) : void
      {
         WindowManager.instance.push(new UnitPartsGather(param1,param2,param3,param4));
      }
      
      override protected function get assetUrl() : String
      {
         var _loc1_:UnitItem = ZGlobal.gameSettings.getItemByCode(m_partsItem.code,UnitItem) as UnitItem;
         if(_loc1_.hasType(UnitItem.MEGA_UNIT))
         {
            return "assets/displays/screens/PU_TitanLab_PartsGather.swf";
         }
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
         this.m_upgradesDisplay = new UpgradesDisplay(_loc2_,m_partsWindow.unitCard_mc.upgrades_mc,m_partsWindow.unitCard_mc.tooltip,m_partsWindow,UnitItem(m_partsItem),null);
         var _loc5_:LocalizationObjectToken = m_partsItem.getSentenceNameLocalizationObject("plural",false);
         if(_loc5_)
         {
            _loc3_ = {"item":_loc5_};
            _loc4_ = ZGameUtils.ZlocT("Dialogs","BuildingPartsTitle_Object",_loc3_);
         }
         else
         {
            _loc3_ = {"item":m_partsItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME)};
            _loc4_ = ZGameUtils.ZlocT("Dialogs","BuildingPartsTitle",_loc3_);
         }
         TextFieldUtil.processTextField(m_partsWindow.title_tf,_loc4_);
         m_buttonSounds.addButton(this.m_backButton.m_overlay,ButtonSound.DEFAULT);
      }
      
      override protected function getPartsItem(param1:String) : PartsItem
      {
         return ZGlobal.gameSettings.getItemByCode(param1,PartsUnitItem) as PartsUnitItem;
      }
      
      override protected function setDescriptionText() : void
      {
         if(!canFinish())
         {
            TextFieldUtil.processTextField(m_partsWindow.description_tf,ZGameUtils.ZlocT("Dialogs","BuildingPartsSubtitle"));
         }
         else
         {
            TextFieldUtil.compactTextField(m_partsWindow.description_tf,ZGameUtils.ZlocT("Dialogs","BuildingPartsUnitSubtitleComplete"));
         }
      }
      
      override protected function completePartsItem() : void
      {
         ZGlobal.player.unlockUnit(m_partsItem.code);
         TransactionManager.addTransaction(new TUnitUnlock(m_partsItem.code));
         closeWindow(null);
         if(this.m_researchScreenUnitItem)
         {
            if(this.m_researchScreenUnitItem.hasType(UnitItem.MEGA_UNIT))
            {
               MegaResearchUnitSelectionScreen.display(m_eventDispatcher,m_partsItem.subType,m_entity,this.m_researchScreenUnitItem);
            }
            else
            {
               ResearchUnitSelectionScreen.display(m_eventDispatcher,m_partsItem.subType,m_entity,this.m_researchScreenUnitItem);
            }
         }
         else
         {
            ResearchUpgradeScreen.display(m_eventDispatcher,m_entity,UnitItem(m_partsItem));
         }
      }
      
      override protected function onAskClick(param1:MouseEvent) : void
      {
         var _loc4_:uint = 0;
         var _loc2_:Object = getSlotInfoFromEvent(param1);
         var _loc3_:GameItem = _loc2_.data.partItem;
         if(_loc3_ != null)
         {
            _loc4_ = uint(ZGlobal.getResearchPartsExperimentVariantByType(m_partsItem.subType));
            if(_loc4_ > ZGlobal.EXPERIMENT_RESEARCH_PARTS_VIRAL_VARIANT_3 && _loc2_.slotIndex == m_slotData.length - 1 || Boolean(_loc2_.slotIndex == 0 && UnitItem(m_partsItem)) && Boolean(UnitItem(m_partsItem).hasType(UnitItem.MEGA_UNIT)))
            {
               ViralsManager.instance.sendFeedWithLotsOfFriction("ask_for_parts",{
                  "itemCode":_loc3_.code,
                  "unitName":m_partsItem.name,
                  "ITEMTOKOVERRIDEitemPart":_loc3_.name + "|singular",
                  "ITEMTOKitemParts":_loc3_.name + "|plural"
               },null);
            }
            else
            {
               PopupManager.instance.push(new RequestAskPartsDialog(_loc3_.name,m_partsItem.name));
            }
         }
      }
      
      override protected function sendStatsEvent(param1:Boolean) : void
      {
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_UNIT_PARTS_PURCHASE,{
            "unitItem":m_partsItem,
            "buyAllParts":param1
         }));
      }
      
      private function onBackClick(param1:MouseEvent) : void
      {
         closeWindow(param1);
         if(UnitItem(m_partsItem).hasType(UnitItem.MEGA_UNIT))
         {
            MegaResearchUnitSelectionScreen.display(m_eventDispatcher,m_partsItem.subType,m_entity,this.m_researchScreenUnitItem);
         }
         else
         {
            ResearchUnitSelectionScreen.display(m_eventDispatcher,m_partsItem.subType,m_entity,this.m_researchScreenUnitItem);
         }
      }
      
      override protected function deinitDialog() : void
      {
         if(this.m_upgradesDisplay)
         {
            this.m_upgradesDisplay.dispose();
         }
         if(this.m_backButton != null)
         {
            this.m_backButton.dispose();
            this.m_backButton = null;
         }
         super.deinitDialog();
      }
   }
}

