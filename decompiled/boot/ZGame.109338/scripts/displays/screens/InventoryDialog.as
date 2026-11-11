package displays.screens
{
   import Engine.Managers.TransactionManager;
   import com.greensock.TweenLite;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.entities.components.WorldUnitComponent;
   import core.gameobjects.DecorationItem;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.EspionageHQManager;
   import core.managers.ExperimentsManager;
   import core.managers.InventoryList;
   import core.managers.TierSurfacingManager;
   import core.managers.WorldObjectManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.decorationsManager.DecorationsManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.unitClassManager.UnitClass;
   import core.managers.unitClassManager.UnitClassManager;
   import core.managers.warehouseManager.WarehouseUnitManager;
   import core.managers.worldUnitManager.WorldUnitManager;
   import core.ui.Tooltip;
   import core.ui.UI;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.genericPopup.GenericPopup1B;
   import entity.GameDataComponent;
   import events.MarketEvent;
   import fl.containers.UILoader;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import sound.ButtonSound;
   import transactions.TRemoveExpiredInventory;
   import transactions.TRemoveExtraInventoryBuilding;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zgame.assets.displays.screens.GS_InventoryDialog.InventoryWindow;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class InventoryDialog extends CategoryDialog
   {
      
      public static const TOOLTIP_POSITION:Point = new Point(48,5);
      
      protected static var m_storedTab:int = -1;
      
      private static const NUM_SLOTS:int = 8;
      
      private static const DETAILS_MARGIN:int = 30;
      
      private var m_clips:Array = new Array();
      
      public function InventoryDialog(param1:String = "")
      {
         m_categoryWindow = new InventoryWindow();
         m_window = m_categoryWindow.slots_mc;
         TextFieldUtil.processTextField(m_categoryWindow.title_mc,ZGameUtils.ZlocT("Dialogs","InventoryTitle"));
         super(null);
      }
      
      public static function getTabLabelString(param1:GameItem) : String
      {
         var _loc4_:XML = null;
         var _loc5_:XMLList = null;
         var _loc2_:XMLList = ZGlobal.gameSettings.getInventoryCategories();
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length())
         {
            _loc4_ = _loc2_[_loc3_];
            _loc5_ = _loc4_.types.type;
            if(matchesCategory(_loc5_,param1))
            {
               return ZGameUtils.ZlocT("Dialogs",_loc4_.@displayKey);
            }
            _loc3_++;
         }
         return null;
      }
      
      private static function matchesCategory(param1:XMLList, param2:Object) : Boolean
      {
         var _loc3_:XML = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         for each(_loc3_ in param1)
         {
            if(_loc3_.@subtypes.toString().length > 0)
            {
               _loc4_ = _loc3_.@subtypes.split(";");
               for each(_loc5_ in _loc4_)
               {
                  if(param2.subType == _loc5_)
                  {
                     if(!ignoreUnitType(_loc3_,param2))
                     {
                        return true;
                     }
                  }
                  else if(hasUnitType(_loc3_,param2))
                  {
                     return true;
                  }
               }
            }
            else if(_loc3_.@name == param2.type)
            {
               return true;
            }
         }
         return false;
      }
      
      private static function ignoreUnitType(param1:XML, param2:Object) : Boolean
      {
         if(param2 is UnitItem && param1.@ignoreUnitTypes != undefined)
         {
            if((param2 as UnitItem).hasType(param1.@ignoreUnitTypes))
            {
               return true;
            }
         }
         return false;
      }
      
      private static function hasUnitType(param1:XML, param2:Object) : Boolean
      {
         if(param2 is UnitItem && param1.@unitTypes != undefined)
         {
            if((param2 as UnitItem).hasType(param1.@unitTypes))
            {
               return true;
            }
         }
         return false;
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.INVENTORY_CLOSED));
            TutorialManager.instance.removeEventListener(TutorialManager.UI_HIGHLIGHT_ITEM,this.onArrow);
         }
      }
      
      override protected function getCategories() : XMLList
      {
         return ZGlobal.gameSettings.getInventoryCategories();
      }
      
      private function initStoredTab() : void
      {
         var _loc1_:uint = 0;
         var _loc2_:CategoryDialogTab = null;
         var _loc3_:XML = null;
         var _loc4_:XMLList = null;
         var _loc5_:String = null;
         var _loc6_:GameItem = null;
         if(m_storedTab < 0)
         {
            m_storedTab = 0;
            _loc1_ = 0;
            loop0:
            for each(_loc2_ in m_categoryButtons)
            {
               _loc3_ = _loc2_.xml;
               _loc4_ = _loc3_.types.type;
               for(_loc5_ in ZGlobal.player.inventory)
               {
                  if(ZGlobal.player.getNumberOfInventoryItems(_loc5_) > 0)
                  {
                     if(!(ZGlobal.player.getNumberOfInventoryItems(_loc5_) == 1 && EspionageHQManager.instance.stolenUnit == _loc5_ && !EspionageHQManager.instance.isUnitInBattle))
                     {
                        _loc6_ = ZGlobal.gameSettings.getItemByCode(_loc5_,GameItem) as GameItem;
                        if((Boolean(_loc6_)) && matchesCategory(_loc4_,_loc6_))
                        {
                           m_storedTab = _loc1_;
                           break loop0;
                        }
                     }
                  }
               }
               _loc1_++;
            }
         }
      }
      
      private function isUnitCategory(param1:XMLList) : Boolean
      {
         var _loc2_:XML = null;
         for each(_loc2_ in param1)
         {
            if(_loc2_.@name == "Buildable" && _loc2_.@subtypes != "decoration")
            {
               return true;
            }
         }
         return false;
      }
      
      override protected function addItems(param1:XML) : void
      {
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:GameItem = null;
         var _loc8_:Dictionary = null;
         var _loc9_:Object = null;
         var _loc10_:GameDataComponent = null;
         var _loc11_:WorldUnitComponent = null;
         var _loc12_:Object = null;
         var _loc13_:* = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:XML = null;
         var _loc17_:int = 0;
         var _loc2_:Array = InventoryList.instance.items;
         var _loc3_:XMLList = param1.types.type;
         var _loc4_:Boolean = this.isUnitCategory(_loc3_);
         for each(_loc5_ in _loc2_)
         {
            _loc6_ = 0;
            _loc7_ = ZGlobal.gameSettings.getItemByCode(_loc5_,GameItem) as GameItem;
            if((Boolean(_loc7_)) && _loc7_.isUnit())
            {
               _loc8_ = WorldObjectManager.instance.getObjectsBySubType(_loc7_.type,_loc7_.subType);
               for each(_loc9_ in _loc8_)
               {
                  _loc10_ = GameDataComponent(_loc9_.lookupComponentByType(GameDataComponent));
                  if((Boolean(_loc10_)) && _loc10_.gameData.code == _loc5_)
                  {
                     _loc11_ = _loc9_.lookupComponentByType(WorldUnitComponent) as WorldUnitComponent;
                     if((Boolean(_loc11_)) && _loc11_.type == WorldUnitManager.UNIT_UNCLAIMED)
                     {
                        _loc6_ += 1;
                     }
                  }
               }
            }
            if(ZGlobal.player.inventory[_loc5_] > 0 || WorldUnitManager.instance.numUnits(_loc5_) - _loc6_ > 0 || WarehouseUnitManager.instance.numUnits(_loc5_) > 0)
            {
               _loc12_ = _loc4_ ? ZGlobal.gameSettings.getItemByCode(_loc5_,UnitItem) as UnitItem : ZGlobal.gameSettings.getItemByCode(_loc5_,GameItem) as GameItem;
               if(ExperimentsManager.instance.getExperimentVariant("empire_remove_extra_building") == 2 || ExperimentsManager.instance.getExperimentVariant("empire_remove_extra_building") == 4)
               {
                  if(Boolean(_loc12_.limit) && _loc12_.limit > 0)
                  {
                     _loc13_ = ZGlobal.player.inventory[_loc5_] ? int(ZGlobal.player.inventory[_loc5_]) : 0;
                     _loc14_ = WorldObjectManager.instance.getNumberObjectsWithCode(_loc5_);
                     _loc15_ = 0;
                     while(_loc13_ + _loc14_ >= _loc12_.limit && _loc13_ > 0)
                     {
                        ZGlobal.player.removeInventoryItem(_loc5_,1);
                        _loc13_--;
                        _loc15_++;
                     }
                     if(_loc15_ > 0)
                     {
                        TransactionManager.addTransaction(new TRemoveExtraInventoryBuilding(_loc5_,_loc15_));
                     }
                  }
               }
               if(matchesCategory(_loc3_,_loc12_))
               {
                  _loc16_ = _loc12_.xml as XML;
                  if(_loc16_.requiredDate != undefined && _loc16_.requiredDate.@removeFromInventory != undefined && _loc16_.requiredDate.@removeFromInventory == true)
                  {
                     _loc17_ = ZGameTimeUtil.instance.getDateStatus(null,_loc16_);
                     if(_loc17_ != ZGameTimeUtil.DATE_STATUS_ACTIVE)
                     {
                        ZGlobal.player.removeInventoryItem(_loc5_);
                        TransactionManager.addTransaction(new TRemoveExpiredInventory(_loc5_));
                        continue;
                     }
                  }
                  if(ExperimentsManager.instance.validateItem(_loc12_.xml) && !(ZGlobal.player.getNumberOfInventoryItems(_loc5_) == 1 && EspionageHQManager.instance.stolenUnit == _loc5_ && !EspionageHQManager.instance.isUnitInBattle))
                  {
                     m_data.push(_loc12_);
                  }
               }
            }
         }
      }
      
      override protected function preRemoveTiles() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < m_iconLoaders.length)
         {
            m_iconLoaders[_loc1_].destroy();
            _loc1_++;
         }
         m_iconLoaders = new Array();
      }
      
      override protected function initDialog() : void
      {
         var _loc2_:MovieClip = null;
         super.initDialog();
         var _loc1_:Array = [m_window.card_mc_0,m_window.card_mc_1,m_window.card_mc_2,m_window.card_mc_3,m_window.card_mc_4,m_window.card_mc_5,m_window.card_mc_6,m_window.card_mc_7];
         for each(_loc2_ in _loc1_)
         {
            addTile(_loc2_);
         }
         initCategoryButtons();
         this.initStoredTab();
         m_buttonSounds.addButton(m_categoryWindow.exit_bt,ButtonSound.DEFAULT);
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.addEventListener(TutorialManager.UI_HIGHLIGHT_ITEM,this.onArrow,false,0,true);
         }
      }
      
      override protected function addComponent(param1:int, param2:int = 0) : void
      {
         var _loc4_:MovieClip = null;
         var _loc5_:MovieClip = null;
         var _loc6_:Object = null;
         var _loc7_:Boolean = false;
         var _loc8_:UnitItem = null;
         var _loc9_:String = null;
         var _loc10_:Array = null;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:DecorationItem = null;
         var _loc14_:UnitClass = null;
         var _loc15_:ImageLoader = null;
         var _loc3_:GameItem = m_data[param2 + param1];
         if(Boolean(m_tiles) && _loc3_ != null)
         {
            _loc4_ = m_tiles[param1];
            _loc5_ = _loc4_.itemCard_mc;
            _loc4_.visible = true;
            _loc5_.visible = true;
            _loc5_.buttonMode = true;
            _loc5_.useHandCursor = true;
            _loc5_.highlightSelect.visible = false;
            _loc5_.count_mc_decco.visible = false;
            _loc5_.card_mc_decco.visible = false;
            _loc5_.label_tf_0.visible = false;
            _loc5_.label_tf_1.visible = false;
            Tooltip.unsubscribe(_loc5_.inventory_units_mc);
            Tooltip.unsubscribe(_loc5_.island_units_mc);
            _loc6_ = new Object();
            _loc6_.itemCode = _loc3_.code;
            _loc6_.clip = _loc5_;
            this.m_clips.push(_loc6_);
            _loc7_ = _loc3_.xml.unit.toString().length > 0;
            _loc8_ = null;
            if(_loc5_.tierRating_mc)
            {
               _loc5_.tierRating_mc.visible = false;
            }
            if(_loc7_)
            {
               _loc8_ = m_data[param2 + param1] as UnitItem;
               _loc11_ = _loc8_.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(_loc8_.code));
               TextFieldUtil.processTextField(_loc5_.strength_mc.value_tf,_loc11_.toString());
               if(m_tiles[param1].itemCard_mc.tierRating_mc)
               {
                  m_tiles[param1].itemCard_mc.tierRating_mc.visible = false;
               }
               this.resizeStrengthText(_loc5_.strength_mc,_loc11_);
               _loc5_.strength_mc.visible = true;
               if(Boolean(_loc5_.tierRating_mc) && TierSurfacingManager.instance.tierSurfacingEnabled)
               {
                  _loc12_ = (ZGlobal.gameSettings.getItemByCode(_loc8_.code,UnitItem) as UnitItem).tier;
                  TextFieldUtil.compactTextField(_loc5_.tierRating_mc.tier_tf,String(_loc12_));
                  _loc5_.tierRating_mc.visible = true;
               }
               TextFieldUtil.processTextField(_loc5_.useInCombat_tf,ZGameUtils.ZlocT("Dialogs","InventoryUnitsPlaced"));
               Tooltip.subscribe(_loc5_.inventory_units_mc,ZGameUtils.ZlocT("Dialogs","InventoryInventoryIconTooltip"));
               Tooltip.subscribe(_loc5_.island_units_mc,ZGameUtils.ZlocT("Dialogs","InventoryWorldIconTooltip"));
            }
            else
            {
               _loc5_.strength_mc.visible = false;
               if(_loc5_.tierRating_mc)
               {
                  _loc5_.tierRating_mc.visible = false;
               }
            }
            if(_loc3_.subType == GameItem.TYPE_CONSUMABLE)
            {
               _loc5_.select_bt.visible = false;
               _loc5_.useInCombat_tf.visible = true;
               TextFieldUtil.processTextField(_loc5_.useInCombat_tf,ZGameUtils.ZlocT("Dialogs","UseInCombat"));
            }
            else if(_loc3_.subType == GameItem.TYPE_EXPANSION)
            {
               _loc5_.select_bt.visible = false;
               _loc5_.useInCombat_tf.visible = true;
               TextFieldUtil.processTextField(_loc5_.useInCombat_tf,ZGameUtils.ZlocT("Dialogs","UseForExpansions"));
            }
            else if(_loc3_.subType == GameItem.TYPE_GLOBALPVP_SLOTTOKEN)
            {
               _loc5_.select_bt.visible = false;
               _loc5_.useInCombat_tf.visible = true;
               TextFieldUtil.processTextField(_loc5_.useInCombat_tf,ZGameUtils.ZlocT("Dialogs","UseForGlobalPVPExpansions"));
            }
            else if(_loc3_.subType == GameItem.SUBTYPE_UNITPART)
            {
               _loc5_.select_bt.visible = false;
               _loc5_.useInCombat_tf.visible = true;
               TextFieldUtil.processTextField(_loc5_.useInCombat_tf,ZGameUtils.ZlocT("Dialogs","UseInResearch"));
               if(_loc3_.code == "SC01")
               {
                  TextFieldUtil.processTextField(_loc5_.useInCombat_tf,ZGameUtils.ZlocT("Items","scrap_inventoryText"));
               }
            }
            else if(_loc3_.subType == GameItem.SUBTYPE_QUESTPART || _loc3_.subType == GameItem.SUBTYPE_DRONEPART || _loc3_.subType == GameItem.SUBTYPE_FARMCAMPPART || _loc3_.subType == GameItem.SUBTYPE_VOLCANOPOWERPART || _loc3_.subType == GameItem.SUBTYPE_AMITYLIGHTHOUSEPART || _loc3_.subType == GameItem.SUBTYPE_MECHPART || _loc3_.subType == GameItem.SUBTYPE_VRTRAININGSIMULATORPART)
            {
               _loc5_.select_bt.visible = false;
               _loc5_.useInCombat_tf.visible = false;
            }
            else if(_loc3_.subType == GameItem.SUBTYPE_BUILDINGPART || _loc3_.subType == GameItem.SUBTYPE_SUPPORTBUILDINGPART)
            {
               _loc5_.select_bt.visible = false;
               _loc5_.useInCombat_tf.visible = true;
               TextFieldUtil.processTextField(_loc5_.useInCombat_tf,ZGameUtils.ZlocT("Dialogs","UseInConstruction"));
            }
            else if(_loc3_.subType == GameItem.SUBTYPE_DEFENSEPART)
            {
               _loc5_.select_bt.visible = false;
               _loc5_.useInCombat_tf.visible = true;
               TextFieldUtil.processTextField(_loc5_.useInCombat_tf,ZGameUtils.ZlocT("Dialogs","UseInDefenseTower"));
            }
            else if(_loc3_.subType == GameItem.SUBTYPE_POWERUPPART)
            {
               _loc5_.select_bt.visible = false;
               _loc5_.useInCombat_tf.visible = true;
               TextFieldUtil.processTextField(_loc5_.useInCombat_tf,ZGameUtils.ZlocT("Dialogs","UseInPowerupFactory"));
            }
            else if(_loc3_.subType == GameItem.SUBTYPE_VILLAINTOKEN)
            {
               _loc5_.select_bt.visible = false;
               _loc5_.useInCombat_tf.visible = true;
               TextFieldUtil.compactTextField(_loc5_.useInCombat_tf,ZGameUtils.ZlocT("Dialogs","UseInMasteryFactory"));
            }
            else if(_loc3_.type == GameItem.TYPE_MECHPART)
            {
               _loc5_.select_bt.visible = false;
               _loc5_.useInCombat_tf.visible = true;
               TextFieldUtil.compactTextField(_loc5_.useInCombat_tf,ZGameUtils.ZlocT("Dialogs","UseMechParts"));
            }
            else if(_loc3_ is UnitItem && (_loc3_ as UnitItem).hasType(UnitItem.MEGA_UNIT))
            {
               _loc5_.select_bt.visible = false;
               _loc5_.useInCombat_tf.visible = true;
               TextFieldUtil.processTextField(_loc5_.useInCombat_tf,ZGameUtils.ZlocT("Dialogs","UseInCombat"));
            }
            else if(!this.isInvalidEnergyItem(_loc3_,_loc5_))
            {
               _loc5_.select_bt.visible = true;
               _loc5_.useInCombat_tf.visible = false;
               m_buildButtons[param1] = new ZGameButton(_loc5_.select_bt,this.onUseClick);
               m_buildButtons[param1].buttonValue = param1.toString();
               m_buildButtons[param1].text = ZGameUtils.ZlocT("Dialogs","SelectButton");
               m_buildButtons[param1].sounds = ButtonSound.ROLLOVER_ONLY;
               _loc4_.addEventListener(MouseEvent.CLICK,this.onUseClick,false,0,true);
            }
            if(_loc3_.isDecorationSource && DecorationsManager.instance.enabled)
            {
               _loc5_.card_mc_decco.visible = true;
               _loc13_ = ZGlobal.gameSettings.getItemByCode(_loc3_.code,DecorationItem) as DecorationItem;
               DecorationsManager.instance.initDecoUICardBackground(_loc13_,_loc5_.card_mc_decco);
               _loc5_.bg_mc.visbible = false;
            }
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.UI_ELEMENT,{
               "ui":_loc5_,
               "item":_loc3_
            }));
            TextFieldUtil.processTextField(_loc5_.itemName_tf,GameItem(_loc3_).getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            _loc5_.underlay_mc.visible = _loc5_.itemName_tf.numLines > 1;
            this.updateTile(param1,_loc3_);
            _loc9_ = ZGlobal.gameSettings.getImageByName(GameItem(_loc3_).name,"icon");
            if(null != _loc9_)
            {
               m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(_loc9_,_loc7_ ? _loc5_.icon_unit : _loc5_.icon));
            }
            _loc5_.icon_unit.visible = _loc7_;
            _loc5_.icon.visible = !_loc7_;
            if(_loc7_)
            {
               _loc14_ = UnitClassManager.instance.unitClassForUnit(_loc8_);
               if(_loc14_)
               {
                  _loc15_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc14_.getIconURL()),_loc5_.class_icon);
                  _loc15_.smooth = true;
                  m_iconLoaders.push(_loc15_);
               }
            }
            _loc10_ = new Array(_loc5_.itemName_tf,_loc5_.quantity_mc.value_tf,_loc5_.count_mc_decco.value_tf,_loc5_.strength_mc.value_tf,_loc5_.useInCombat_tf,_loc5_.inventory_units_mc.value_tf,_loc5_.island_units_mc.value_tf,_loc5_.tierRating_mc.tier_tf);
            if(_loc5_.tierRating_mc)
            {
               _loc10_.push(_loc5_.tierRating_mc.tier_tf);
            }
            TextFieldUtil.setMouseEnabled(_loc10_,false);
            _loc4_.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
            _loc4_.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
         }
         else
         {
            m_tiles[param1].visible = false;
         }
      }
      
      private function resizeStrengthText(param1:MovieClip, param2:int) : void
      {
         var _loc3_:TextFormat = null;
         if(param2 >= 1000)
         {
            _loc3_ = new TextFormat();
            _loc3_.size = 12;
            param1.value_tf.setTextFormat(_loc3_);
         }
      }
      
      private function isInvalidEnergyItem(param1:GameItem, param2:MovieClip) : Boolean
      {
         var _loc3_:int = 0;
         if(param1.subType == GameItem.TYPE_MANA)
         {
            _loc3_ = ZGlobal.gameSettings.getInt("manaStartingLevel",20);
            if(ZGlobal.player.level < _loc3_)
            {
               param2.select_bt.visible = false;
               param2.useInCombat_tf.visible = true;
               TextFieldUtil.processTextField(param2.useInCombat_tf,ZGameUtils.ZlocT("Dialogs","LevelRequired",{"num":_loc3_}));
               return true;
            }
         }
         return false;
      }
      
      override protected function getStoredTab() : int
      {
         return m_storedTab;
      }
      
      override protected function setStoredTab(param1:int) : void
      {
         m_storedTab = param1;
      }
      
      override protected function showCategory(param1:int) : void
      {
         super.showCategory(param1);
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_INVENTORY_VIEW,{
            "category":param1,
            "page":m_tileSet
         }));
      }
      
      protected function onRollOver(param1:MouseEvent) : void
      {
         this.updateRollOverState(param1.currentTarget);
      }
      
      private function updateRollOverState(param1:Object) : void
      {
         var _loc3_:String = null;
         param1.itemCard_mc.highlightSelect.visible = true;
         var _loc2_:GameItem = this.getItemFromEvent(param1);
         if(_loc2_)
         {
            _loc3_ = _loc2_.tooltipType;
         }
         if(_loc3_ != GameItem.NO_TOOLTIP)
         {
            m_tooltip = new ItemTooltip(_loc3_,_loc2_,ItemTooltip.SOURCE_INVENTORY);
            m_categoryWindow.slots_mc.addChild(m_tooltip);
            m_tooltip.x = param1.x + param1.width * 0.5;
            m_tooltip.y = param1.y;
            m_tooltip.alpha = 0;
            TweenLite.to(m_tooltip,0.5,{"alpha":1});
         }
      }
      
      protected function onRollOut(param1:MouseEvent) : void
      {
         param1.currentTarget.itemCard_mc.highlightSelect.visible = false;
         if(Boolean(m_tooltip) && Boolean(m_categoryWindow.slots_mc.contains(m_tooltip)))
         {
            m_categoryWindow.slots_mc.removeChild(m_tooltip);
            m_tooltip.destroy();
         }
         m_tooltip = null;
      }
      
      override protected function getNumSlots() : int
      {
         return NUM_SLOTS;
      }
      
      override protected function postRemoveTiles(param1:int) : void
      {
         m_tiles[param1].removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         m_tiles[param1].removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         m_tiles[param1].removeEventListener(MouseEvent.CLICK,this.onUseClick);
         super.postRemoveTiles(param1);
      }
      
      private function onUseClick(param1:MouseEvent) : void
      {
         var _loc2_:int = indexOfTileContaining(param1.target as DisplayObject) + m_tileSet * NUM_SLOTS;
         var _loc3_:GameItem = m_data[_loc2_];
         if(Boolean(_loc3_) && ZGlobal.player.inventory[_loc3_.code] > 0)
         {
            if(_loc3_.placeable)
            {
               UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_USE,MarketEvent.BUILDABLE,_loc3_.name,MarketEvent.SOURCE_INVENTORY));
               onCloseClick(param1);
            }
            else if(_loc3_.energyYield > 0 || _loc3_.manaYield > 0 || _loc3_.ammoYield > 0)
            {
               this.useEnergyItem(_loc2_,_loc3_);
            }
         }
      }
      
      private function useEnergyItem(param1:int, param2:GameItem) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:GenericPopup = null;
         var _loc6_:int = 0;
         if(param2.energyYield > 0 && !ZGlobal.player.m_energy.canAcceptEnergy(param2.energyYield) || param2.ammoYield > 0 && !ZGlobal.player.m_ammo.canAcceptAmmo(param2.ammoYield) || param2.manaYield > 0 && !ZGlobal.player.mana.allowGive(param2.manaYield))
         {
            _loc3_ = param2.energyYield ? "NoAcceptEnergy_Message" : "NoAcceptMana_Message";
            _loc3_ = param2.ammoYield ? "NoAcceptAmmo_Message" : _loc3_;
            _loc4_ = param2.energyYield ? "NoAcceptEnergy_Title" : "NoAcceptMana_Title";
            _loc4_ = param2.ammoYield ? "NoAcceptAmmo_Title" : _loc4_;
            _loc5_ = new GenericPopup1B(ZGameUtils.ZlocT("Dialogs",_loc3_),ZGameUtils.ZlocT("Dialogs",_loc4_),GenericPopup.TYPE_OK,null);
            _loc5_.setAdvisorMood(GenericPopup.MOOD_DEFAULT);
            PopupManager.instance.push(_loc5_);
         }
         else
         {
            UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_USE,MarketEvent.CONSUMABLE,param2.name,MarketEvent.SOURCE_INVENTORY));
            _loc6_ = int(ZGlobal.player.inventory[param2.code]);
            if(_loc6_ > 0)
            {
               this.updateTile(param1,param2);
            }
            else
            {
               this.showCategory(m_categoryIndex);
               if(param1 < m_data.length)
               {
                  this.updateRollOverState(m_tiles[param1]);
               }
            }
            UI.instance.setupForItemPlacement();
         }
      }
      
      private function updateTile(param1:int, param2:GameItem) : void
      {
         var _loc10_:Dictionary = null;
         var _loc11_:Object = null;
         var _loc12_:GameDataComponent = null;
         var _loc13_:WorldUnitComponent = null;
         var _loc14_:TextField = null;
         var _loc15_:DecorationItem = null;
         var _loc3_:int = param1 % NUM_SLOTS;
         var _loc4_:MovieClip = m_tiles[_loc3_].itemCard_mc;
         var _loc5_:int = param2.inventoryCap;
         var _loc6_:Boolean = param2.xml.unit.toString().length > 0;
         var _loc7_:Dictionary = WorldUnitManager.instance.availableUnits;
         var _loc8_:* = ZGlobal.player.inventory[param2.code] ? int(ZGlobal.player.inventory[param2.code]) : 0;
         if(_loc8_ > 0 && EspionageHQManager.instance.stolenUnit == param2.code && !EspionageHQManager.instance.isUnitInBattle)
         {
            _loc8_--;
         }
         var _loc9_:int = WorldUnitManager.instance.numUnits(param2.code);
         param2 = ZGlobal.gameSettings.getItemByCode(param2.code,GameItem) as GameItem;
         if(param2)
         {
            _loc10_ = WorldObjectManager.instance.getObjectsBySubType(param2.type,param2.subType);
            for each(_loc11_ in _loc10_)
            {
               _loc12_ = GameDataComponent(_loc11_.lookupComponentByType(GameDataComponent));
               if((Boolean(_loc12_)) && _loc12_.gameData.code == param2.code)
               {
                  _loc13_ = _loc11_.lookupComponentByType(WorldUnitComponent) as WorldUnitComponent;
                  if((Boolean(_loc13_)) && _loc13_.type == WorldUnitManager.UNIT_UNCLAIMED)
                  {
                     _loc9_--;
                  }
               }
            }
         }
         _loc9_ += WarehouseUnitManager.instance.numUnits(param2.code);
         if(_loc5_ > 0)
         {
            TextFieldUtil.processTextField(_loc4_.quantity_mc.value_tf,ZGameUtils.ZlocT("Main","Inventory_ratio",{
               "count":_loc8_.toString(),
               "total":_loc5_
            }));
            _loc4_.quantity_mc.visible = true;
            _loc4_.inventory_units_mc.visible = false;
            _loc4_.island_units_mc.visible = false;
         }
         else if(_loc6_)
         {
            TextFieldUtil.processTextField(_loc4_.inventory_units_mc.value_tf,_loc8_.toString());
            TextFieldUtil.processTextField(_loc4_.island_units_mc.value_tf,_loc9_.toString());
            _loc4_.quantity_mc.visible = false;
            _loc4_.inventory_units_mc.visible = true;
            _loc4_.island_units_mc.visible = true;
            if(_loc8_ == 0 || param2.notPlaceable)
            {
               _loc4_.useInCombat_tf.visible = true;
               _loc4_.select_bt.visible = false;
            }
            else
            {
               _loc4_.useInCombat_tf.visible = false;
               _loc4_.select_bt.visible = true;
            }
         }
         else
         {
            _loc14_ = _loc4_.quantity_mc.value_tf;
            if(param2.isDecorationSource && DecorationsManager.instance.enabled)
            {
               _loc4_.count_mc_decco.visible = true;
               _loc4_.quantity_mc.visible = false;
               _loc14_ = _loc4_.count_mc_decco.value_tf;
               _loc15_ = ZGlobal.gameSettings.getItemByCode(param2.code,DecorationItem) as DecorationItem;
               DecorationsManager.instance.initDecoUICardCountBackground(_loc15_,_loc4_.count_mc_decco);
            }
            else
            {
               _loc4_.quantity_mc.visible = true;
            }
            TextFieldUtil.processTextField(_loc14_,_loc8_.toString());
            _loc4_.inventory_units_mc.visible = false;
            _loc4_.island_units_mc.visible = false;
         }
      }
      
      private function getItemFromEvent(param1:Object) : GameItem
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         if(param1 != null)
         {
            _loc2_ = String(param1.name).replace(/card_mc_/,"");
            _loc3_ = int(_loc2_);
         }
         var _loc4_:int = _loc3_ + m_tileSet * NUM_SLOTS;
         return GameItem.createItemFromCode(m_data[_loc4_].code,ZGlobal.gameSettings.getItems());
      }
      
      private function onArrow(param1:WorldEvent) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.m_clips.length)
         {
            if(this.m_clips[_loc2_].itemCode == param1.eventData as String)
            {
               TutorialManager.instance.addArrowToUIElement(this.m_clips[_loc2_].clip,true,true);
            }
            _loc2_++;
         }
      }
      
      override protected function onLtArrowClick(param1:MouseEvent) : void
      {
         super.onLtArrowClick(param1);
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_INVENTORY_VIEW,{
            "category":this.getStoredTab(),
            "page":m_tileSet
         }));
      }
      
      override protected function onRtArrowClick(param1:MouseEvent) : void
      {
         super.onRtArrowClick(param1);
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_INVENTORY_VIEW,{
            "category":this.getStoredTab(),
            "page":m_tileSet
         }));
      }
   }
}

