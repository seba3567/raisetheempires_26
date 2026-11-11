package displays.screens.researchScreens
{
   import ZLocalization.LocalizationObjectToken;
   import core.ZGlobal;
   import core.entities.components.DecorationTargetComponent;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.gameobjects.UpgradeItem;
   import core.managers.ExperimentsManager;
   import core.managers.WorldResourceManager;
   import core.managers.WorldUpgradeManager;
   import core.resource.ResourceInfo;
   import core.ui.UIManager;
   import core.ui.ZGameButton;
   import core.ui.menuitem.PlayerStatsUIItem;
   import dispatchers.ResearchDispatcher;
   import dispatchers.ResourceDispatcher;
   import dispatchers.UIDispatcher;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.ItemTooltip;
   import events.ResearchUpdatedEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import sound.SoundEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   import zlabs.utils.StringUtils;
   
   public class ResearchUpgradeScreen extends ZGamePopUp
   {
      
      public static const UPGRADE_SELECTED:String = "upgradeselected";
      
      private static const ID:String = "ResearchUpgradeScreen";
      
      protected var m_entity:IEntity = null;
      
      protected var m_eventDispatcher:EventDispatcher = null;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      protected var m_unitItem:UnitItem;
      
      protected var m_resource:SWFResource = null;
      
      protected var m_upgradeSlots:Array = null;
      
      private var m_backButton:ZGameButton = null;
      
      protected var m_upgradeCards:Array = new Array();
      
      protected var m_upgradesDisplay:UpgradesDisplay = null;
      
      protected var m_iconLoaders:Array = new Array();
      
      private var m_itemTooltip:ItemTooltip = null;
      
      public function ResearchUpgradeScreen(param1:EventDispatcher, param2:IEntity, param3:UnitItem)
      {
         this.m_unitItem = param3;
         this.m_eventDispatcher = param1;
         this.m_entity = param2;
         super(ZGlobal.getAssetURL(this.assetURL));
      }
      
      public static function display(param1:EventDispatcher, param2:IEntity, param3:UnitItem) : void
      {
         WindowManager.instance.push(new ResearchUpgradeScreen(param1,param2,param3));
      }
      
      private function get assetURL() : String
      {
         if(this.m_unitItem.hasType(UnitItem.MEGA_UNIT))
         {
            return "assets/displays/screens/Titan_ResearchUpgradeScreen.swf";
         }
         return "assets/displays/screens/ResearchUpgradeScreen.swf";
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var _loc6_:Object = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         this.m_resource = param1;
         var _loc2_:Class = param1.getAssetClass("UpgradeScreen");
         m_window = new _loc2_();
         initDialog();
         m_window["exit_bt"].addEventListener(MouseEvent.CLICK,this.onExitClicked,false,0,true);
         UIDispatcher.instance.addEventListener(UpgradeSlot.SELECTED,this.onUpgradeSelected,false,0,true);
         this.setResourceListeners(true);
         this.m_backButton = new ZGameButton(m_window["back_bt"],this.onBackClick);
         this.m_backButton.text = ZGameUtils.ZlocT("Dialogs","BuildingPartsBack");
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(m_window["exit_bt"],ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_backButton.m_overlay,ButtonSound.DEFAULT);
         addChild(m_window);
         m_origOffsetX = m_window.x;
         m_origOffsetY = m_window.y;
         this.contentWidth = m_window["panel_mc"].width;
         this.contentHeight = m_window["panel_mc"].height;
         centerWithinStage(Zlab.mainStage);
         this.fillOutUpgrades();
         TextFieldUtil.processTextField(m_window["unitCard_mc"].itemName_tf,this.m_unitItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(this.m_unitItem.name,"icon"),m_window["unitCard_mc"].icon));
         var _loc3_:int = WorldUpgradeManager.instance.getNumRemainingUpgrades(this.m_unitItem.code);
         var _loc4_:String = this.m_unitItem.researchTemplate;
         var _loc5_:XMLList = WorldUpgradeManager.instance.getResearchTemplate(_loc4_);
         TextFieldUtil.processTextField(m_window["unitCard_mc"].upgrades_tf,ZGameUtils.ZlocT("Dialogs","RemainingUpgrades_Line",{
            "num":_loc3_,
            "total":_loc5_.upgrade.length()
         }));
         var _loc9_:LocalizationObjectToken = this.m_unitItem.getSentenceNameLocalizationObject("plural",false);
         if(_loc9_)
         {
            _loc6_ = {
               "item":_loc9_,
               "secondItem":_loc9_
            };
            _loc7_ = ZGameUtils.ZlocT("Dialogs","ResearchUpgradeScreenTitle_Object",_loc6_);
            _loc7_ = StringUtils.upperCaseFirstChar(_loc7_);
            _loc8_ = ZGameUtils.ZlocT("Dialogs","ResearchUpgradeScreenDescription_Object",_loc6_);
         }
         else
         {
            _loc6_ = {"item":this.m_unitItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME)};
            _loc7_ = ZGameUtils.ZlocT("Dialogs","ResearchUpgradeScreenTitle",_loc6_);
            _loc8_ = ZGameUtils.ZlocT("Dialogs","ResearchUpgradeScreenDescription",_loc6_);
         }
         TextFieldUtil.compactTextField(m_window["title_tf"],_loc7_);
         TextFieldUtil.compactTextField(m_window["title_tf_2"],ZGameUtils.ZlocT("Dialogs","ResearchUpgradeScreenInstructions"));
         TextFieldUtil.compactTextField(m_window["popupBox_tf"],_loc8_);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(true);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(WindowManager.instance.container,0);
      }
      
      protected function setResourceListeners(param1:Boolean) : void
      {
         var _loc2_:ResourceInfo = null;
         for each(_loc2_ in WorldResourceManager.instance.resourceInfo)
         {
            if(_loc2_.type != "coins")
            {
               if(param1)
               {
                  ResourceDispatcher.instance.addEventListener(_loc2_.type,this.onPlayerUpdated,false,0,true);
               }
               else
               {
                  ResourceDispatcher.instance.removeEventListener(_loc2_.type,this.onPlayerUpdated);
               }
            }
         }
      }
      
      protected function onExitClicked(param1:MouseEvent) : void
      {
         this.close();
      }
      
      protected function onPlayerUpdated(param1:Event) : void
      {
         this.dispose();
         this.fillOutUpgrades();
      }
      
      protected function onUpgradeSelected(param1:WorldEvent) : void
      {
         var _loc5_:GenericPopup2B = null;
         var _loc2_:Object = UpgradeSlot(param1.eventData).getData();
         var _loc3_:UpgradeItem = UpgradeItem(_loc2_.referenceItem);
         var _loc4_:int = _loc3_.cash;
         if(_loc4_ != 0 && ZGlobal.player.canBuyCash(_loc4_,true) || _loc4_ == 0 && ZGlobal.player.canBuy(_loc3_))
         {
            if(ZGlobal.gameSettings.showConfirmationPopup(_loc4_))
            {
               _loc5_ = GenericPopup2B.NewYesNo(ZGameUtils.ZlocT("Dialogs","ResearchUpgradeBuyConfirmMsg",ZGameUtils.CashTokenReplacements(_loc4_)),null,this.onBuyConfirmed);
               _loc5_.userData = param1.eventData;
               PopupManager.instance.push(_loc5_,0,false);
            }
            else
            {
               this.buyUpgrade(param1.eventData);
            }
         }
      }
      
      private function buyUpgrade(param1:Object) : void
      {
         this.close();
         var _loc2_:Object = UpgradeSlot(param1).getData();
         this.m_eventDispatcher.dispatchEvent(new WorldEvent(UPGRADE_SELECTED,_loc2_));
         SoundEvent.getSoundEvent("StartResearch").play();
      }
      
      private function onBuyConfirmed(param1:GenericPopupEvent) : void
      {
         param1.stopImmediatePropagation();
         param1.stopPropagation();
         if(param1.button == GenericPopup.YES)
         {
            this.buyUpgrade(param1.userData);
         }
      }
      
      protected function onConfirmClicked(param1:MouseEvent) : void
      {
      }
      
      protected function fillOutUpgrades() : void
      {
         var _loc9_:MovieClip = null;
         var _loc1_:String = this.m_unitItem.researchTemplate;
         var _loc2_:XMLList = WorldUpgradeManager.instance.getResearchTemplate(_loc1_);
         var _loc3_:Number = WorldUpgradeManager.instance.getTotalUpgrades(this.m_unitItem.code);
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_RESEARCH_SHIELD_UPGRADE) == ExperimentsManager.VARIANT_RESEARCH_SHIELD_UPGRADE_ON && WorldUpgradeManager.instance.isTechResearch(_loc1_))
         {
            m_window["card_mc_4"].visible = false;
            this.m_upgradeCards = [m_window["card_mc_0"],m_window["card_mc_1"],m_window["card_mc_2"],m_window["card_mc_3"],m_window["card_mc_5"],m_window["card_mc_6"]];
         }
         else
         {
            if(m_window.hasOwnProperty("card_mc_5") && m_window.hasOwnProperty("card_mc_6") && m_window.hasOwnProperty("starburst_mc"))
            {
               m_window["card_mc_5"].visible = false;
               m_window["card_mc_6"].visible = false;
               m_window["starburst_mc"].visible = false;
            }
            this.m_upgradeCards = [m_window["card_mc_0"],m_window["card_mc_1"],m_window["card_mc_2"],m_window["card_mc_3"],m_window["card_mc_4"]];
         }
         var _loc4_:Array = [m_window["unitCard_mc"].upgrades_mc.icon0,m_window["unitCard_mc"].upgrades_mc.icon1,m_window["unitCard_mc"].upgrades_mc.icon2,m_window["unitCard_mc"].upgrades_mc.icon3,m_window["unitCard_mc"].upgrades_mc.icon4];
         this.m_upgradesDisplay = new UpgradesDisplay(_loc4_,m_window["unitCard_mc"].upgrades_mc,m_window["unitCard_mc"].tooltip,m_window,this.m_unitItem,WorldUpgradeManager.instance.getUpgradesByCode(this.m_unitItem.code));
         var _loc5_:Array = [null,m_window["ind_arrow_mc_0"],null,m_window["ind_arrow_mc_1"],m_window["ind_arrow_mc_2"],null];
         var _loc6_:Dictionary = DecorationTargetComponent.getDiscountForObject(this.m_entity);
         var _loc7_:Array = DecorationTargetComponent.getDecoEffectsForTarget(this.m_entity);
         this.m_upgradeSlots = new Array();
         var _loc8_:int = 0;
         while(_loc8_ < _loc3_)
         {
            _loc9_ = _loc8_ < _loc5_.length ? _loc5_[_loc8_] : null;
            this.m_upgradeSlots.push(new UpgradeSlot(this.m_upgradeCards[_loc8_],_loc2_.upgrade[_loc8_],this.m_unitItem,_loc9_,_loc6_,_loc7_,this.m_entity));
            this.m_upgradeCards[_loc8_].addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
            this.m_upgradeCards[_loc8_].addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
            _loc8_++;
         }
      }
      
      private function onResearchUpdated(param1:ResearchUpdatedEvent) : void
      {
         this.onPlayerUpdated(null);
      }
      
      protected function onRollOver(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.m_upgradeCards.length)
         {
            if(param1.target == this.m_upgradeCards[_loc2_])
            {
               break;
            }
            _loc2_++;
         }
         this.m_itemTooltip = this.m_upgradeSlots[_loc2_].fillOutTooltip();
         m_window.addChild(this.m_itemTooltip);
         this.m_itemTooltip.x = param1.target.x + m_window.x + param1.target.hit_mc.width * 0.5 - 1;
         this.m_itemTooltip.y = param1.target.y + m_window.y;
         this.m_itemTooltip.mouseEnabled = false;
         this.m_itemTooltip.mouseChildren = false;
      }
      
      protected function onRollOut(param1:MouseEvent) : void
      {
         if(Boolean(this.m_itemTooltip) && m_window.contains(this.m_itemTooltip))
         {
            m_window.removeChild(this.m_itemTooltip);
            this.m_itemTooltip.destroy();
         }
         this.m_itemTooltip = null;
      }
      
      protected function onBackClick(param1:MouseEvent) : void
      {
         this.close(param1);
         if(this.m_unitItem.hasType(UnitItem.MEGA_UNIT))
         {
            MegaResearchUnitSelectionScreen.display(this.m_eventDispatcher,this.m_unitItem.subType,this.m_entity);
         }
         else
         {
            ResearchUnitSelectionScreen.display(this.m_eventDispatcher,this.m_unitItem.subType,this.m_entity);
         }
      }
      
      override protected function close(param1:Event = null) : void
      {
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(false);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(UIManager.instance.uiDisplay,0);
         m_window["exit_bt"].removeEventListener(MouseEvent.CLICK,this.onExitClicked);
         UIDispatcher.instance.removeEventListener(UpgradeSlot.SELECTED,this.onUpgradeSelected);
         ResearchDispatcher.instance.removeEventListener(ResearchUpdatedEvent.UPGRADE_ADDED,this.onResearchUpdated);
         this.setResourceListeners(false);
         this.dispose();
         super.close();
      }
      
      public function dispose() : void
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
         var _loc1_:int = 0;
         while(_loc1_ < this.m_upgradeCards.length)
         {
            if(this.m_upgradeSlots[_loc1_])
            {
               this.m_upgradeSlots[_loc1_].dispose();
            }
            this.m_upgradeSlots[_loc1_] = null;
            this.m_upgradeCards[_loc1_].removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
            this.m_upgradeCards[_loc1_].removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this.m_iconLoaders.length)
         {
            if(this.m_iconLoaders[_loc1_])
            {
               this.m_iconLoaders[_loc1_].destroy();
            }
            _loc1_++;
         }
      }
   }
}

