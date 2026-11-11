package displays.screens
{
   import Engine.Managers.TransactionManager;
   import ZLocalization.LocaleFormatter;
   import ZLocalization.LocalizationObjectToken;
   import com.greensock.TweenLite;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.entities.components.behaviors.states.BuildingPartsDialogState;
   import core.gamemode.GMObjectPlace;
   import core.gamemode.GameModeManager;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.DecorationItem;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsBuildingItem;
   import core.gameobjects.UnitItem;
   import core.gameobjects.expansionitem.ExpansionItem;
   import core.managers.ExpansionPriceExperimentManager;
   import core.managers.ExperimentsManager;
   import core.managers.FlamingUnitManager;
   import core.managers.LEUnitDiscountManager;
   import core.managers.PriceTestManager;
   import core.managers.TierSurfacingManager;
   import core.managers.WhiteUnitManager;
   import core.managers.WorldObjectManager;
   import core.managers.WorldResourceManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.decorationsManager.DecorationsManager;
   import core.managers.promoManager.PromoManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.unitClassManager.UnitClassManager;
   import core.managers.warehouseManager.WarehouseUnitManager;
   import core.managers.worldUnitManager.WorldUnitManager;
   import core.player.Player;
   import core.resource.ResourceInfo;
   import core.ui.Style;
   import core.ui.Tooltip;
   import core.ui.UI;
   import core.ui.ZGameButton;
   import dispatchers.ExperienceDispatcher;
   import dispatchers.ResourceDispatcher;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.RequirementsPopup;
   import displays.popups.RequirementsPopupInfoPopCap;
   import displays.popups.genericPopup.GenericPopup1B;
   import displays.popups.obtainRequirement.ObtainMultiRequirementsPopup;
   import displays.popups.promo.PromoData;
   import displays.screens.mechBattleSetup.MechBattleSetup;
   import displays.screens.partsGather.BuildingPartsGather;
   import entity.GameDataComponent;
   import events.ExperienceUpdatedEvent;
   import events.MarketEvent;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import sound.ButtonSound;
   import transactions.TFinishBuildable;
   import utils.BitArray;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zgame.libs.GS_Store.StoreWindow;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class Store extends CategoryDialog
   {
      
      public static const TOOLTIP_POSITION:Point = new Point(48,5);
      
      protected static var m_storedTab:int = 0;
      
      private static const NUM_SLOTS:int = 8;
      
      public static const UNLOCK_LOCKED:String = "locked";
      
      public static const UNLOCK_LEVEL:String = "level";
      
      public static const UNLOCK_NEIGHBOR:String = "neighbor";
      
      public static const UNLOCK_MASTERY:String = "mastery";
      
      public static const UNLOCK_LEVEL_AND_NEIGHBOR:String = "level_and_neighbor";
      
      public static const UNLOCK_LEVEL_OR_NEIGHBOR:String = "level_or_neighbor";
      
      public static const TAB_CONSUMABLES:int = 1;
      
      public static const TAB_EXPANSION_LABEL:String = "Expansions";
      
      public static const TAB_RESOURCES_LABEL:String = "Resources";
      
      public static const TAB_INDUSTRY_LABEL:String = "Industry";
      
      public static const TAB_POWERUP_LABEL:String = "Power-Ups!";
      
      public static const TAB_UNITS_LABEL:String = "Units";
      
      public static const TAB_NEW_ITEMS_LABEL:String = "New";
      
      public static const TAB_DECORATIONS_LABEL:String = "Decorations";
      
      public static const TAB_HOUSES_LABEL:String = "Houses";
      
      protected static var m_pageHistory:Object = {};
      
      private static const CARDTYPE_NORMAL:int = 0;
      
      private static const CARDTYPE_LIGHTNINGDEAL:int = 1;
      
      private static const CARDTYPE_BUILDMENU_PROXY:int = 2;
      
      private static const CARDTYPE_MECHLEUNITS:int = 3;
      
      private static const ICON_MC_X:Array = [28,15,28,28];
      
      private static const STRENGTH_MC_X:Array = [115.4,100,115.4,115.4];
      
      private static const STRENGTH_MC_Y:Array = [29.9,81,29.9,29.9];
      
      private static const CLASSICON_VISIBILITY:Array = [false,true,false,true];
      
      private static const LD_TIMER_STRING_VISIBILITY:Array = [false,true,false,false];
      
      private static const LD_CLAIM_MC_VISIBILITY:Array = [false,true,false,false];
      
      private static const LD_CLAIMBAR_WIDTH:int = 140;
      
      private static const EXT_STRENGTH_MC_WIDTH:Number = 1;
      
      private var m_confirmationItem:GameItem = null;
      
      private var m_persistPostPurchase:Boolean = false;
      
      private var m_newUnits:Array = null;
      
      private var m_buyContract:Boolean = false;
      
      private var m_expansion_gdc:GameDataComponent = null;
      
      private var m_LDTimer:Timer;
      
      private var m_LDTimerTextFields:Dictionary = new Dictionary();
      
      protected var m_categoryImageLoaders:Array = [];
      
      private var m_LDCards:Array = [];
      
      private var ldCardHeightAdjusted:Boolean = false;
      
      private var strength_mc_width:Number;
      
      private var m_theaterSortOrder:Number = 0;
      
      private var m_sortOrder:Array = new Array();
      
      private var m_newShop:Boolean;
      
      private var m_strengthTable:Object = new Object();
      
      private var m_shopVariant:int = ExperimentsManager.instance.getExperimentVariant("empires_shop_improvements");
      
      private var m_advExpUnit:int = ExperimentsManager.instance.getExperimentVariant("empires_support_units_advanced");
      
      private var m_count:int = 0;
      
      public function Store(param1:Object)
      {
         var _loc4_:Dictionary = null;
         var _loc5_:IEntity = null;
         var _loc2_:StoreWindow = new StoreWindow();
         m_categoryWindow = _loc2_.storeDialog_mc;
         m_window = m_categoryWindow.selectionDialog_mc as MovieClip;
         super(null);
         this.contentWidth = m_categoryWindow.panel_mc.width;
         m_initData = param1;
         var _loc3_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_EXPANSION_CREW_MASTER);
         if(_loc3_ == ZGlobal.EXPERIMENT_EXPANSION_CREW_ENABLED)
         {
            _loc4_ = WorldObjectManager.instance.getObjectsBySubType("expansion","crewExpansion");
            for each(_loc5_ in _loc4_)
            {
               if(_loc5_)
               {
                  this.m_expansion_gdc = GameDataComponent.getGameDataComponent(_loc5_);
               }
            }
         }
         this.m_LDTimer = new Timer(1000);
      }
      
      override protected function getCategories() : XMLList
      {
         return ZGlobal.gameSettings.getBuildCategories();
      }
      
      private function itemBuyableFromStore(param1:XML) : Boolean
      {
         if(Boolean(param1.@buyable) && param1.@buyable == true)
         {
            return true;
         }
         if(ZGlobal.player.isLightingDealItem(param1.@code))
         {
            return true;
         }
         return false;
      }
      
      private function itemHiddenFromStore(param1:XML) : Boolean
      {
         if(Boolean(param1.@hideFromStore) && param1.@hideFromStore == true)
         {
            return true;
         }
         return false;
      }
      
      private function itemDisplayInStore(param1:XML) : Boolean
      {
         if(Boolean(param1.@displayInStore) && param1.@displayInStore == true)
         {
            return true;
         }
         return false;
      }
      
      private function itemPlaceable(param1:XML) : Boolean
      {
         if(Boolean(param1.@placeable) && param1.@placeable == true)
         {
            return true;
         }
         return false;
      }
      
      override protected function addItems(param1:XML) : void
      {
         var _loc5_:XML = null;
         var _loc6_:Array = null;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         var _loc9_:XML = null;
         var _loc10_:Boolean = false;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:GameItem = null;
         var _loc15_:String = null;
         var _loc16_:Array = null;
         var _loc17_:String = null;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:GameItem = null;
         var _loc21_:int = 0;
         var _loc22_:UnitItem = null;
         var _loc23_:Object = null;
         var _loc24_:Array = null;
         var _loc25_:int = 0;
         var _loc2_:XMLList = param1.types.type;
         this.m_newShop = false;
         this.m_count = 0;
         var _loc3_:Array = [];
         var _loc4_:Object = new Object();
         for each(_loc5_ in _loc2_)
         {
            _loc6_ = _loc5_.@subtypes.split(";");
            for each(_loc7_ in _loc6_)
            {
               _loc8_ = ZGlobal.gameSettings.getArrayOfItemXMLByType(_loc5_.@name,_loc7_);
               for each(_loc9_ in _loc8_)
               {
                  if(this.itemBuyableFromStore(_loc9_) || this.itemDisplayInStore(_loc9_))
                  {
                     _loc10_ = true;
                     if(!this.itemBuyableFromStore(_loc9_) && this.itemDisplayInStore(_loc9_))
                     {
                        _loc11_ = WorldObjectManager.instance.getNumberObjectsWithCode(_loc9_.@code);
                        _loc12_ = WorldObjectManager.instance.getNumberBuiltObjectsWithCode(_loc9_.@code);
                        _loc13_ = 0;
                        if(ZGameTimeUtil.instance.getDateStatus(null,_loc9_) == ZGameTimeUtil.DATE_STATUS_ACTIVE)
                        {
                           _loc13_ = ZGlobal.player.getNumberOfInventoryItems(_loc9_.@code);
                        }
                        if(_loc12_ > 0 || _loc13_ == 0 && _loc11_ == 0)
                        {
                           _loc10_ = false;
                        }
                     }
                     if(this.itemBuyableFromStore(_loc9_))
                     {
                        if(_loc9_.@setBonusItem != undefined && _loc9_.@setBonusItem == "true")
                        {
                           _loc14_ = ZGlobal.gameSettings.getItemByCode(_loc9_.@code.toString(),GameItem) as GameItem;
                           if(_loc14_.contractLocked && !ZGlobal.player.hasPurchasedContract(_loc9_.@code.toString()))
                           {
                              continue;
                           }
                        }
                        if(Boolean(_loc9_.@code) && _loc9_.@code == "BB22")
                        {
                           if(!WorldObjectManager.instance.getNumberBuiltObjectsWithCode("BB20") && !WorldObjectManager.instance.getNumberBuiltObjectsWithCode("BB19") && !WorldObjectManager.instance.getNumberBuiltObjectsWithCode("BB21"))
                           {
                              continue;
                           }
                        }
                        if(_loc9_.unit != undefined)
                        {
                           _loc15_ = _loc9_.unit.@type;
                           _loc16_ = _loc15_.split(",");
                           if(_loc16_.indexOf("mastery") >= 0)
                           {
                              continue;
                           }
                           if(_loc16_.indexOf(UnitItem.MEGA_UNIT) >= 0 && _loc9_.@newItem.toString() != "true")
                           {
                              if(!MechBattleSetup.ENABLED)
                              {
                                 continue;
                              }
                           }
                        }
                        if(Boolean(_loc9_.@limit) && Boolean(_loc9_.@limitHide) && _loc9_.@limitHide == true)
                        {
                           _loc17_ = _loc9_.@code.toString();
                           _loc18_ = ZGlobal.player.inventory[_loc17_] ? int(ZGlobal.player.inventory[_loc17_]) : 0;
                           _loc19_ = WorldObjectManager.instance.getNumberObjectsWithCode(_loc17_);
                           if(_loc18_ + _loc19_ >= _loc9_.@limit)
                           {
                              _loc10_ = false;
                           }
                        }
                        if(this.itemHiddenFromStore(_loc9_))
                        {
                           _loc10_ = false;
                        }
                     }
                     if(_loc10_ && ExperimentsManager.instance.validateItem(_loc9_))
                     {
                        _loc20_ = null;
                        if(_loc9_.@subtype == GameItem.SUBTYPE_EXPANSION || _loc9_.@subtype == GameItem.SUBTYPE_CREW_EXPANSION || _loc9_.@subtype == GameItem.SUBTYPE_CASH_EXPANSION)
                        {
                           _loc20_ = ZGlobal.gameSettings.getItemByCode(_loc9_.@code,ExpansionItem) as ExpansionItem;
                        }
                        else
                        {
                           _loc20_ = ZGlobal.gameSettings.getItemByCode(_loc9_.@code,ZGlobal.gameSettings.getItemClass(_loc9_.@type,_loc9_.@subtype)) as GameItem;
                        }
                        if(_loc20_.type == GameItem.TYPE_BUILDMENUPROXY)
                        {
                           if(Boolean(this.getStarterPackSurfacingInfo(_loc20_)) && Boolean(_loc20_.subType == "starterpack") && PromoManager.instance.starterPackSurfacingEnabled)
                           {
                              _loc3_.push(_loc20_);
                           }
                        }
                        else if(param1.types.@newItem.toString() == "true")
                        {
                           if(_loc9_.@newItem.toString() == "true")
                           {
                              _loc21_ = ZGameTimeUtil.instance.getDateStatus(null,_loc9_);
                              if((_loc21_ == ZGameTimeUtil.DATE_STATUS_NONE || _loc21_ == ZGameTimeUtil.DATE_STATUS_ACTIVE) && this.m_shopVariant < 3)
                              {
                                 this.addGameItemToStore(_loc20_);
                              }
                              else
                              {
                                 if(_loc21_ == ZGameTimeUtil.DATE_STATUS_EARLY)
                                 {
                                    continue;
                                 }
                                 _loc22_ = ZGlobal.gameSettings.getItemByCode(_loc20_.code,UnitItem) as UnitItem;
                                 if(_loc20_.xml.unit == undefined)
                                 {
                                    continue;
                                 }
                                 if(_loc4_[_loc22_.unitClass] == undefined)
                                 {
                                    _loc4_[_loc22_.unitClass] = new Object();
                                 }
                                 if(_loc4_[_loc22_.unitClass][_loc22_.tier] == undefined)
                                 {
                                    _loc4_[_loc22_.unitClass][_loc22_.tier] = new Array();
                                 }
                                 _loc4_[_loc22_.unitClass][_loc22_.tier].push(_loc20_);
                              }
                           }
                        }
                        else
                        {
                           this.addGameItemToStore(_loc20_);
                        }
                     }
                  }
               }
            }
         }
         if(this.m_shopVariant > 2 && param1.types.@newItem.toString() == "true")
         {
            this.m_newShop = true;
            for each(_loc23_ in _loc4_)
            {
               for each(_loc24_ in _loc23_)
               {
                  _loc24_.sort(ZGameUtils.sortStrongest);
                  _loc25_ = 0;
                  while(_loc25_ < _loc24_.length && _loc25_ < 2)
                  {
                     this.addGameItemToStore(_loc24_[_loc25_]);
                     _loc25_++;
                  }
               }
            }
         }
         if(param1.@label != undefined && param1.@label.toString() == TAB_NEW_ITEMS_LABEL)
         {
            this.sortNewItems();
         }
         else if(param1.@label != undefined && param1.@label.toString() == TAB_UNITS_LABEL)
         {
            this.sortUnitData();
         }
         else if(param1.@label != undefined && param1.@label.toString() == TAB_DECORATIONS_LABEL)
         {
            this.sortDecorationData();
         }
         else if(param1.@label != undefined && param1.@label.toString() == TAB_HOUSES_LABEL)
         {
            this.sortHouseData();
         }
         else if(param1.@label != undefined && param1.@label.toString() == TAB_POWERUP_LABEL)
         {
            this.sortPowerupData();
         }
         m_data = _loc3_.concat(m_data);
      }
      
      private function get revEnhancedSorting() : Boolean
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_STORE_SORTING_REV_ENHANCED);
         return _loc1_ == ExperimentsManager.VARIANT_STORE_SORTING_REV_ENHANCED;
      }
      
      private function sortHouseData() : void
      {
         var _loc4_:GameItem = null;
         var _loc5_:Object = null;
         if(!this.revEnhancedSorting)
         {
            return;
         }
         var _loc1_:Array = [];
         var _loc2_:Array = [];
         var _loc3_:Array = [];
         for each(_loc4_ in m_data)
         {
            _loc5_ = this.shouldDisplayFirst(_loc4_);
            if(_loc5_.display)
            {
               if(_loc5_.first)
               {
                  _loc1_.push(_loc4_);
               }
               else if(_loc4_.usesCash())
               {
                  _loc2_.push(_loc4_);
               }
               else
               {
                  _loc3_.push(_loc4_);
               }
            }
         }
         _loc2_.sort(ZGameUtils.sortEPCostAscending);
         _loc2_.reverse();
         m_data = _loc1_.concat(_loc2_.concat(_loc3_));
      }
      
      private function sortPowerupData() : void
      {
         var _loc3_:GameItem = null;
         var _loc4_:Boolean = false;
         var _loc5_:Object = null;
         var _loc6_:BitArray = null;
         var _loc1_:Array = [];
         var _loc2_:Array = [];
         for each(_loc3_ in m_data)
         {
            _loc4_ = _loc3_.usesCash() && !_loc3_.directPay;
            _loc5_ = {"forCashPurchase":_loc4_};
            _loc6_ = ZGlobal.player.checkGate(_loc3_,_loc5_);
            if(_loc6_.anyBitSet())
            {
               _loc2_.push(_loc3_);
            }
            else
            {
               _loc1_.push(_loc3_);
            }
         }
         _loc1_.sort(this.powerUpSortLogic);
         m_data = _loc1_.concat(_loc2_);
      }
      
      private function powerUpSortLogic(param1:GameItem, param2:GameItem) : Number
      {
         var _loc3_:ConsumableItem = ZGlobal.gameSettings.getItemByCode(param1.code,ConsumableItem) as ConsumableItem;
         var _loc4_:ConsumableItem = ZGlobal.gameSettings.getItemByCode(param2.code,ConsumableItem) as ConsumableItem;
         if(_loc3_.version > _loc4_.version)
         {
            return -1;
         }
         if(_loc3_.version < _loc4_.version)
         {
            return 1;
         }
         if(_loc3_.cash > _loc4_.cash)
         {
            return -1;
         }
         return 1;
      }
      
      private function sortByDescendingEPFirst(param1:Array) : Array
      {
         var _loc4_:GameItem = null;
         var _loc2_:Array = [];
         var _loc3_:Array = [];
         for each(_loc4_ in param1)
         {
            if(_loc4_.usesCash())
            {
               _loc2_.push(_loc4_);
            }
            else
            {
               _loc3_.push(_loc4_);
            }
         }
         _loc2_.sort(ZGameUtils.sortEPCostAscending);
         _loc2_.reverse();
         return _loc2_.concat(_loc3_);
      }
      
      private function sortDecorationData() : void
      {
         var _loc4_:GameItem = null;
         var _loc1_:Array = new Array();
         var _loc2_:Array = new Array();
         var _loc3_:Array = new Array();
         for each(_loc4_ in m_data)
         {
            if(ZGameTimeUtil.instance.isLimitedEdition(_loc4_.xml))
            {
               _loc1_.push(_loc4_);
            }
            else if(_loc4_.isDecorationSource)
            {
               _loc2_.push(_loc4_);
            }
            else
            {
               _loc3_.push(_loc4_);
            }
         }
         _loc1_.sort(ZGameUtils.sortLENewest);
         _loc2_.sort(DecorationsManager.sortMeaningfulDecorations);
         if(this.revEnhancedSorting)
         {
            _loc1_ = this.sortByDescendingEPFirst(_loc1_);
            _loc2_ = this.sortByDescendingEPFirst(_loc2_);
         }
         m_data = _loc1_.concat(_loc2_).concat(_loc3_);
      }
      
      private function sortUnitData() : void
      {
         var _loc5_:int = 0;
         var _loc7_:GameItem = null;
         var _loc1_:Array = new Array();
         var _loc2_:Array = new Array();
         var _loc3_:Array = new Array();
         var _loc4_:int = int(m_data.length);
         while(_loc5_ < _loc4_)
         {
            _loc7_ = m_data[_loc5_] as GameItem;
            if(_loc7_)
            {
               if(ZGameTimeUtil.instance.isLimitedEdition(_loc7_.xml) && !this.isLevelLocked(_loc7_))
               {
                  _loc1_.push(_loc7_);
               }
               else if(this.isLocked(_loc7_))
               {
                  _loc2_.push(_loc7_);
               }
               else
               {
                  _loc3_.push(_loc7_);
               }
            }
            _loc5_++;
         }
         _loc1_.sort(ZGameUtils.sortStrongest);
         _loc2_.sort(ZGameUtils.sortRequiredLevel);
         _loc3_.sort(ZGameUtils.sortStrongest);
         m_data = [];
         var _loc6_:Array = _loc1_.concat(_loc3_);
         m_data = _loc6_.concat(_loc2_);
      }
      
      private function sortNewItems() : void
      {
         switch(this.m_shopVariant)
         {
            case 0:
            case 1:
            case 2:
            case 3:
               this.sortNewItemsVanilla();
               break;
            case 4:
               this.sortNewItemsFixedTheaters();
               break;
            case 5:
               this.sortNewItemsRandomShuffle();
               break;
            case 6:
               this.sortNewItemsSmartSurfacingA();
               break;
            case 7:
               this.sortNewItemsSmartSurfacingB();
         }
      }
      
      private function sortNewItemsSmartSurfacingB() : void
      {
         var _loc2_:String = null;
         var _loc3_:Dictionary = null;
         var _loc4_:Dictionary = null;
         var _loc5_:Array = null;
         var _loc6_:Array = null;
         var _loc7_:Array = null;
         var _loc8_:Array = null;
         var _loc9_:Date = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc13_:UnitItem = null;
         var _loc14_:int = 0;
         var _loc15_:UnitItem = null;
         var _loc16_:GameItem = null;
         var _loc17_:GameItem = null;
         var _loc1_:Array = ZGlobal.player.getUnlockedUnits();
         for each(_loc2_ in _loc1_)
         {
            _loc13_ = ZGlobal.gameSettings.getItemByCode(_loc2_,UnitItem) as UnitItem;
            _loc14_ = _loc13_.setName.search("LightningDeal");
            if(_loc14_ == -1)
            {
               _loc15_ = _loc13_;
               if(this.m_strengthTable[_loc13_.unitClass] != undefined)
               {
                  if(this.m_strengthTable[_loc13_.unitClass] < _loc13_.getStrength(null))
                  {
                     this.m_strengthTable[_loc13_.unitClass] = _loc13_.getStrength(null);
                  }
               }
               else
               {
                  this.m_strengthTable[_loc13_.unitClass] = _loc13_.getStrength(null);
               }
            }
         }
         _loc3_ = WorldUnitManager.instance.availableUnits;
         for(_loc2_ in _loc3_)
         {
            _loc15_ = _loc13_ = ZGlobal.gameSettings.getItemByCode(_loc2_,UnitItem) as UnitItem;
            if(this.m_strengthTable[_loc13_.unitClass] != undefined)
            {
               if(this.m_strengthTable[_loc13_.unitClass] < _loc13_.getStrength(null))
               {
                  this.m_strengthTable[_loc13_.unitClass] = _loc13_.getStrength(null);
               }
            }
            else
            {
               this.m_strengthTable[_loc13_.unitClass] = _loc13_.getStrength(null);
            }
         }
         _loc4_ = ZGlobal.player.inventory;
         for(_loc2_ in _loc4_)
         {
            _loc16_ = ZGlobal.gameSettings.getItemByCode(_loc2_,GameItem) as GameItem;
            if(_loc16_.xml.unit != undefined)
            {
               _loc15_ = _loc13_ = ZGlobal.gameSettings.getItemByCode(_loc2_,UnitItem) as UnitItem;
               if(this.m_strengthTable[_loc13_.unitClass] != undefined)
               {
                  if(this.m_strengthTable[_loc13_.unitClass] < _loc13_.getStrength(null))
                  {
                     this.m_strengthTable[_loc13_.unitClass] = _loc13_.getStrength(null);
                  }
               }
               else
               {
                  this.m_strengthTable[_loc13_.unitClass] = _loc13_.getStrength(null);
               }
            }
         }
         _loc5_ = new Array();
         _loc6_ = new Array();
         _loc7_ = new Array();
         _loc8_ = new Array();
         _loc9_ = new Date();
         _loc10_ = int(m_data.length);
         while(_loc11_ < _loc10_)
         {
            _loc17_ = m_data[_loc11_] as GameItem;
            if(_loc17_)
            {
               if(_loc17_.xml.@sortFirst != undefined && _loc17_.xml.@sortFirst.toString() == "true")
               {
                  _loc5_.push(_loc17_);
               }
               else if(this.isLocked(_loc17_))
               {
                  _loc7_.push(_loc17_);
               }
               else
               {
                  _loc8_.push(_loc17_);
               }
            }
            _loc11_++;
         }
         _loc7_.sort(this.sortSmartLocked);
         _loc8_.sort(this.sortSmartBUnlocked);
         _loc5_.sort(this.sortSmartBUnlocked);
         m_data = [];
         var _loc12_:Array = _loc5_.concat(_loc8_);
         m_data = _loc12_.concat(_loc7_);
      }
      
      private function sortNewItemsSmartSurfacingA() : void
      {
         var _loc2_:String = null;
         var _loc3_:Dictionary = null;
         var _loc4_:Dictionary = null;
         var _loc5_:Array = null;
         var _loc6_:Array = null;
         var _loc7_:Array = null;
         var _loc8_:Array = null;
         var _loc9_:Date = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc13_:UnitItem = null;
         var _loc14_:GameItem = null;
         var _loc15_:int = 0;
         var _loc16_:UnitItem = null;
         var _loc17_:GameItem = null;
         var _loc18_:GameItem = null;
         var _loc1_:Array = ZGlobal.player.getUnlockedUnits();
         for each(_loc2_ in _loc1_)
         {
            _loc13_ = ZGlobal.gameSettings.getItemByCode(_loc2_,UnitItem) as UnitItem;
            _loc14_ = ZGlobal.gameSettings.getItemByCode(_loc2_,GameItem) as GameItem;
            _loc15_ = _loc13_.setName.search("LightningDeal");
            if(_loc15_ == -1)
            {
               if(_loc14_.buyable)
               {
                  _loc16_ = _loc13_;
                  if(this.m_strengthTable[_loc13_.unitClass] != undefined)
                  {
                     if(this.m_strengthTable[_loc13_.unitClass] < _loc13_.getStrength(null))
                     {
                        this.m_strengthTable[_loc13_.unitClass] = _loc13_.getStrength(null);
                     }
                  }
                  else
                  {
                     this.m_strengthTable[_loc13_.unitClass] = _loc13_.getStrength(null);
                  }
               }
            }
         }
         _loc3_ = WorldUnitManager.instance.availableUnits;
         for(_loc2_ in _loc3_)
         {
            _loc16_ = _loc13_ = ZGlobal.gameSettings.getItemByCode(_loc2_,UnitItem) as UnitItem;
            if(this.m_strengthTable[_loc13_.unitClass] != undefined)
            {
               if(this.m_strengthTable[_loc13_.unitClass] < _loc13_.getStrength(null))
               {
                  this.m_strengthTable[_loc13_.unitClass] = _loc13_.getStrength(null);
               }
            }
            else
            {
               this.m_strengthTable[_loc13_.unitClass] = _loc13_.getStrength(null);
            }
         }
         _loc4_ = ZGlobal.player.inventory;
         for(_loc2_ in _loc4_)
         {
            _loc17_ = ZGlobal.gameSettings.getItemByCode(_loc2_,GameItem) as GameItem;
            if(!(!_loc17_ || _loc17_.xml.unit == undefined))
            {
               _loc16_ = _loc13_ = ZGlobal.gameSettings.getItemByCode(_loc2_,UnitItem) as UnitItem;
               if(this.m_strengthTable[_loc13_.unitClass] != undefined)
               {
                  if(this.m_strengthTable[_loc13_.unitClass] < _loc13_.getStrength(null))
                  {
                     this.m_strengthTable[_loc13_.unitClass] = _loc13_.getStrength(null);
                  }
               }
               else
               {
                  this.m_strengthTable[_loc13_.unitClass] = _loc13_.getStrength(null);
               }
            }
         }
         _loc5_ = new Array();
         _loc6_ = new Array();
         _loc7_ = new Array();
         _loc8_ = new Array();
         _loc9_ = new Date();
         _loc10_ = int(m_data.length);
         while(_loc11_ < _loc10_)
         {
            _loc18_ = m_data[_loc11_] as GameItem;
            if(_loc18_)
            {
               if(_loc18_.xml.@sortFirst != undefined && _loc18_.xml.@sortFirst.toString() == "true")
               {
                  _loc5_.push(_loc18_);
               }
               else if(this.isLocked(_loc18_))
               {
                  _loc7_.push(_loc18_);
               }
               else
               {
                  _loc8_.push(_loc18_);
               }
            }
            _loc11_++;
         }
         _loc7_.sort(this.sortSmartLocked);
         _loc8_.sort(this.sortSmartAUnlocked);
         _loc5_.sort(this.sortSmartBUnlocked);
         m_data = [];
         var _loc12_:Array = _loc5_.concat(_loc8_);
         m_data = _loc12_.concat(_loc7_);
      }
      
      private function sortNewItemsRandomShuffle() : void
      {
         var _loc8_:int = 0;
         var _loc10_:GameItem = null;
         var _loc1_:Array = new Array();
         var _loc2_:Array = new Array();
         var _loc3_:Array = new Array();
         var _loc4_:Array = new Array();
         var _loc5_:Date = new Date();
         var _loc6_:Number = _loc5_.date + ZGlobal.player.timeWarpSeconds / (24 * 60 * 60);
         this.m_theaterSortOrder = _loc6_ % 6;
         switch(this.m_theaterSortOrder)
         {
            case 1:
               this.m_sortOrder = ["army","air","navy"];
               break;
            case 0:
               this.m_sortOrder = ["army","navy","air"];
               break;
            case 2:
               this.m_sortOrder = ["air","army","navy"];
               break;
            case 3:
               this.m_sortOrder = ["air","navy","army"];
               break;
            case 4:
               this.m_sortOrder = ["navy","air","army"];
               break;
            case 5:
               this.m_sortOrder = ["navy","army","air"];
         }
         var _loc7_:int = int(m_data.length);
         while(_loc8_ < _loc7_)
         {
            _loc10_ = m_data[_loc8_] as GameItem;
            if(_loc10_)
            {
               if(_loc10_.xml.@sortFirst != undefined && _loc10_.xml.@sortFirst.toString() == "true")
               {
                  _loc1_.push(_loc10_);
               }
               else if(this.isLocked(_loc10_))
               {
                  _loc3_.push(_loc10_);
               }
               else
               {
                  _loc4_.push(_loc10_);
               }
            }
            _loc8_++;
         }
         _loc3_.sort(this.sortTheaterLocked);
         _loc4_.sort(this.sortTheaterUnlocked);
         _loc1_.sort(this.sortSmartBUnlocked);
         m_data = [];
         var _loc9_:Array = _loc1_.concat(_loc4_);
         m_data = _loc9_.concat(_loc3_);
      }
      
      private function sortNewItemsFixedTheaters() : void
      {
         var _loc6_:int = 0;
         var _loc8_:GameItem = null;
         var _loc1_:Array = new Array();
         var _loc2_:Array = new Array();
         var _loc3_:Array = new Array();
         var _loc4_:Array = new Array();
         this.m_sortOrder = ["army","air","navy"];
         var _loc5_:int = int(m_data.length);
         while(_loc6_ < _loc5_)
         {
            _loc8_ = m_data[_loc6_] as GameItem;
            if(_loc8_)
            {
               if(_loc8_.xml.@sortFirst != undefined && _loc8_.xml.@sortFirst.toString() == "true")
               {
                  _loc1_.push(_loc8_);
               }
               else if(this.isLocked(_loc8_))
               {
                  _loc3_.push(_loc8_);
               }
               else
               {
                  _loc4_.push(_loc8_);
               }
            }
            _loc6_++;
         }
         _loc3_.sort(this.sortTheaterLocked);
         _loc4_.sort(this.sortTheaterUnlocked);
         _loc1_.sort(this.sortSmartBUnlocked);
         m_data = [];
         var _loc7_:Array = _loc1_.concat(_loc4_);
         m_data = _loc7_.concat(_loc3_);
      }
      
      private function sortNewItemsVanilla() : void
      {
         var _loc6_:int = 0;
         var _loc9_:GameItem = null;
         var _loc1_:Array = new Array();
         var _loc2_:Array = new Array();
         var _loc3_:Array = new Array();
         var _loc4_:Array = new Array();
         var _loc5_:int = int(m_data.length);
         while(_loc6_ < _loc5_)
         {
            _loc9_ = m_data[_loc6_] as GameItem;
            if(_loc9_)
            {
               if(_loc9_.xml.@sortFirst != undefined && _loc9_.xml.@sortFirst.toString() == "true")
               {
                  _loc1_.push(_loc9_);
               }
               else if(ZGameTimeUtil.instance.isLimitedEdition(_loc9_.xml) && !this.isLevelLocked(_loc9_))
               {
                  _loc2_.push(_loc9_);
               }
               else if(this.isLocked(_loc9_))
               {
                  _loc3_.push(_loc9_);
               }
               else
               {
                  _loc4_.push(_loc9_);
               }
            }
            _loc6_++;
         }
         _loc2_.sort(this.sortLE);
         _loc4_.sort(ZGameUtils.sortStrongest);
         _loc3_.sort(ZGameUtils.sortRequiredLevel);
         _loc1_.sort(this.sortSmartBUnlocked);
         m_data = [];
         var _loc7_:Array = _loc1_.concat(_loc2_);
         var _loc8_:Array = _loc7_.concat(_loc4_);
         m_data = _loc8_.concat(_loc3_);
      }
      
      private function sortSmartLocked(param1:GameItem, param2:GameItem) : int
      {
         var _loc3_:int = this.sortTierIncreasing(param1,param2);
         if(_loc3_ == 0)
         {
            return ZGameUtils.sortStrongest(param1,param2);
         }
         return _loc3_;
      }
      
      private function sortSmartBUnlocked(param1:GameItem, param2:GameItem) : int
      {
         var _loc4_:int = 0;
         var _loc3_:int = this.sortTierDecreasing(param1,param2);
         if(_loc3_ == 0)
         {
            _loc4_ = this.sortClassDec(param1,param2);
            if(_loc4_ == 0)
            {
               return ZGameUtils.sortStrongest(param1,param2);
            }
            return _loc4_;
         }
         return _loc3_;
      }
      
      private function sortSmartAUnlocked(param1:GameItem, param2:GameItem) : int
      {
         var _loc4_:int = 0;
         var _loc3_:int = this.sortTierDecreasing(param1,param2);
         if(_loc3_ == 0)
         {
            _loc4_ = this.sortClassInc(param1,param2);
            if(_loc4_ == 0)
            {
               return ZGameUtils.sortStrongest(param1,param2);
            }
            return _loc4_;
         }
         return _loc3_;
      }
      
      private function sortTheaterUnlocked(param1:GameItem, param2:GameItem) : int
      {
         var _loc4_:int = 0;
         var _loc3_:int = this.sortTierDecreasing(param1,param2);
         if(_loc3_ == 0)
         {
            _loc4_ = this.sortTheater(param1,param2);
            if(_loc4_ == 0)
            {
               return ZGameUtils.sortStrongest(param1,param2);
            }
            return _loc4_;
         }
         return _loc3_;
      }
      
      private function sortTheaterLocked(param1:GameItem, param2:GameItem) : int
      {
         var _loc4_:int = 0;
         var _loc3_:int = this.sortTierIncreasing(param1,param2);
         if(_loc3_ == 0)
         {
            _loc4_ = this.sortTheater(param1,param2);
            if(_loc4_ == 0)
            {
               return ZGameUtils.sortWeakest(param1,param2);
            }
            return _loc4_;
         }
         return _loc3_;
      }
      
      private function sortClassDec(param1:GameItem, param2:GameItem) : int
      {
         var _loc3_:UnitItem = ZGlobal.gameSettings.getItemByCode(param1.code,UnitItem) as UnitItem;
         var _loc4_:UnitItem = ZGlobal.gameSettings.getItemByCode(param2.code,UnitItem) as UnitItem;
         if(this.m_strengthTable[_loc3_.unitClass] == undefined || this.m_strengthTable[_loc3_.unitClass] < this.m_strengthTable[_loc4_.unitClass])
         {
            return 1;
         }
         if(this.m_strengthTable[_loc4_.unitClass] == undefined || this.m_strengthTable[_loc3_.unitClass] > this.m_strengthTable[_loc4_.unitClass])
         {
            return -1;
         }
         return 0;
      }
      
      private function sortClassInc(param1:GameItem, param2:GameItem) : int
      {
         var _loc3_:UnitItem = ZGlobal.gameSettings.getItemByCode(param1.code,UnitItem) as UnitItem;
         var _loc4_:UnitItem = ZGlobal.gameSettings.getItemByCode(param2.code,UnitItem) as UnitItem;
         if(this.m_strengthTable[_loc3_.unitClass] == undefined || this.m_strengthTable[_loc3_.unitClass] < this.m_strengthTable[_loc4_.unitClass])
         {
            return -1;
         }
         if(this.m_strengthTable[_loc4_.unitClass] == undefined || this.m_strengthTable[_loc3_.unitClass] > this.m_strengthTable[_loc4_.unitClass])
         {
            return 1;
         }
         return 0;
      }
      
      private function sortTheater(param1:GameItem, param2:GameItem) : int
      {
         var _loc3_:UnitItem = ZGlobal.gameSettings.getItemByCode(param1.code,UnitItem) as UnitItem;
         var _loc4_:UnitItem = ZGlobal.gameSettings.getItemByCode(param2.code,UnitItem) as UnitItem;
         var _loc5_:Array = this.m_sortOrder;
         if(_loc3_.subType == _loc4_.subType)
         {
            return 0;
         }
         if(_loc3_.subType == _loc5_[0] || _loc3_.subType == _loc5_[1] && _loc4_.subType == _loc5_[2])
         {
            return -1;
         }
         return 1;
      }
      
      private function sortLE(param1:GameItem, param2:GameItem) : int
      {
         var _loc3_:int = ZGameUtils.sortLENewest(param1,param2);
         if(_loc3_ == 0)
         {
            _loc3_ = this.sortUnitsDecos(param1,param2);
            if(_loc3_ == 0)
            {
               _loc3_ = ZGameUtils.sortStrongest(param1,param2);
            }
         }
         return _loc3_;
      }
      
      private function sortFirst(param1:GameItem, param2:GameItem) : int
      {
         if(param1.xml.@sortFirst.toString() == param2.xml.@sortFirst.toString())
         {
            return 0;
         }
         if(param1.xml.@sortFirst.toString() == "true")
         {
            return -1;
         }
         return 1;
      }
      
      private function sortTierDecreasing(param1:GameItem, param2:GameItem) : int
      {
         if(param1.xml.unit.@tier == param2.xml.unit.@tier)
         {
            return 0;
         }
         if(param1.xml.unit.@tier > param2.xml.unit.@tier)
         {
            return -1;
         }
         return 1;
      }
      
      private function sortTierIncreasing(param1:GameItem, param2:GameItem) : int
      {
         if(param1.xml.unit.@tier == param2.xml.unit.@tier)
         {
            return 0;
         }
         if(param1.xml.unit.@tier > param2.xml.unit.@tier)
         {
            return 1;
         }
         return -1;
      }
      
      private function isItemLocked(param1:GameItem) : Boolean
      {
         var _loc2_:UnitItem = ZGlobal.gameSettings.getItemByCode(param1.code,UnitItem) as UnitItem;
         var _loc3_:Boolean = true;
         if(!_loc2_.isRequriedBuildingActive && _loc2_.hasType(UnitItem.MEGA_UNIT))
         {
            _loc3_ = false;
         }
         if(!this.isLevelLocked(param1) && !this.isQuestLocked(param1) && _loc3_)
         {
            return false;
         }
         return true;
      }
      
      private function isLocked(param1:GameItem) : Boolean
      {
         var _loc2_:BitArray = ZGlobal.player.checkGate(param1);
         _loc2_.resetBit(Player.GATE_FAILURE_CONTRACT_LOCKED);
         _loc2_.resetBit(Player.GATE_FAILURE_TITAN_LAB);
         if(_loc2_.isBitSet(Player.GATE_FAILURE_LEVEL) && ZGlobal.player.isItemUnlocked(param1.code))
         {
            _loc2_.resetBit(Player.GATE_FAILURE_LEVEL);
            _loc2_.resetBit(Player.GATE_FAILURE_CAMPAIGN);
         }
         if(this.m_shopVariant > 2)
         {
            _loc2_.resetBit(Player.GATE_FAILURE_DATE);
         }
         if(_loc2_.anyBitSet())
         {
            return true;
         }
         return false;
      }
      
      private function sortUnitsDecos(param1:GameItem, param2:GameItem) : int
      {
         if(param1.subType == param2.subType)
         {
            return 0;
         }
         if(param1.subType == "army" || param1.subType == "navy" || param1.subType == "air")
         {
            return -1;
         }
         return 1;
      }
      
      private function sortSubType(param1:GameItem, param2:GameItem) : int
      {
         if(param1.subType == param2.subType)
         {
            return 0;
         }
         if(param1.subType == "army")
         {
            return -1;
         }
         if(param1.subType == "navy")
         {
            if(param2.subType == "army")
            {
               return 1;
            }
            return -1;
         }
         return 1;
      }
      
      private function excludeGameItem(param1:GameItem) : Boolean
      {
         var _loc2_:ResourceInfo = null;
         var _loc3_:int = 0;
         if(param1.type == "resource" && param1.subType == "commodity")
         {
            _loc2_ = WorldResourceManager.instance.getResourceInfoByType(param1.resourceType);
            if(Boolean(_loc2_) && Boolean(_loc2_.isRare) && !param1.usesCash())
            {
               _loc3_ = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_RAREOREPURCHASE_DISABLED);
               if(_loc3_ == ExperimentsManager.VARIANT_EXCLUDE_RAREOREPURCHASE)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      private function addGameItemToStore(param1:GameItem) : void
      {
         var _loc2_:Object = this.shouldDisplayFirst(param1);
         if(_loc2_.display)
         {
            if(_loc2_.first)
            {
               m_data.splice(0,0,param1);
            }
            else if(!this.excludeGameItem(param1))
            {
               m_data.push(param1);
            }
         }
      }
      
      override protected function dispatchCategoryHighlightEvent(param1:int) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.UI_HIGHLIGHT_STORE_TAB,{
            "ui":m_categoryWindow["tab" + param1],
            "index":param1
         }));
      }
      
      override protected function dispatchCategoryClickEvent(param1:int) : void
      {
         this.resetPageHistory();
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.UI_STORE_TAB_CLICK,{"index":param1.toString()}));
      }
      
      override protected function onLtArrowClick(param1:MouseEvent) : void
      {
         this.stopNewUnitTimer(true);
         this.unregisterLDTimer();
         this.unregisterLDItemCountChanged();
         super.onLtArrowClick(param1);
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_STORE_VIEW,{
            "category":m_storedTab,
            "page":m_tileSet
         }));
         this.savePageHistory();
      }
      
      override protected function onRtArrowClick(param1:MouseEvent) : void
      {
         this.stopNewUnitTimer(true);
         this.unregisterLDTimer();
         this.unregisterLDItemCountChanged();
         super.onRtArrowClick(param1);
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_STORE_VIEW,{
            "category":m_storedTab,
            "page":m_tileSet
         }));
         this.savePageHistory();
      }
      
      private function clearCategoryImageLoaders() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_categoryImageLoaders)
         {
            _loc1_.destroy();
         }
         this.m_categoryImageLoaders = [];
      }
      
      override protected function showCategory(param1:int) : void
      {
         var _loc2_:Boolean = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REMEMBER_LAST_BUILD_MENU_PAGE) == ExperimentsManager.VARIANT_VALUE_REMEMBER_LAST_BUILD_MENU_PAGE_ON;
         this.stopNewUnitTimer(true);
         removeTiles();
         m_categoryIndex = param1;
         if(_loc2_)
         {
            m_tileSet = this.getPageHistory(param1);
         }
         else
         {
            m_tileSet = 0;
         }
         m_data = new Array();
         this.clearCategoryImageLoaders();
         var _loc3_:XML = m_categoryButtons[param1].xml;
         addItemsToCategories(param1,_loc3_);
         addAllComponents(0);
         if(Boolean(m_initData) && m_initData.hasOwnProperty("focusGameItemCode"))
         {
            gotoTileSetFromGameItemCode(m_initData.focusGameItemCode);
         }
         else
         {
            setCurrentTileSet(m_tileSet);
         }
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_STORE_VIEW,{
            "category":param1,
            "page":m_tileSet
         }));
      }
      
      override protected function getStoredTab() : int
      {
         return m_storedTab;
      }
      
      override protected function setStoredTab(param1:int) : void
      {
         m_storedTab = param1;
         super.setStoredTab(param1);
      }
      
      private function onPlayerUpdated(param1:Event) : void
      {
         this.refreshLayout();
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         TextFieldUtil.processTextField(m_categoryWindow.title_mc,ZGameUtils.ZlocT("Dialogs","StoreTitle"));
         UIDispatcher.instance.addEventListener(ObtainMultiRequirementsPopup.EVENT_PURCHASE_ITEM,this.onBuyItemEvent,false,0,true);
         ExperienceDispatcher.instance.addEventListener(ExperienceUpdatedEvent.LEVEL,this.onPlayerUpdated,false,0,true);
         UIDispatcher.instance.addEventListener(Player.INVENTORY_UPDATED,this.onPlayerUpdated,false,0,true);
         UIDispatcher.instance.addEventListener(MarketEvent.MARKET_EXPANSION_CREW_UNLOCK,this.onCrewExpansionBuy,false,0,true);
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_EXPANSION_CREW_MASTER);
         if(_loc1_ == ZGlobal.EXPERIMENT_EXPANSION_CREW_ENABLED)
         {
            this.m_expansion_gdc.owner.eventDispatcher.addEventListener(GameDataComponent.CREW_UPDATED,this.onCrewUpdated);
         }
         this.setResourceListeners(true);
         m_tiles = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < NUM_SLOTS)
         {
            addTile(m_categoryWindow.selectionDialog_mc["card_mc_" + _loc2_]);
            _loc2_++;
         }
         initCategoryButtons();
         m_buttonSounds.addButton(m_categoryWindow.exit_bt,ButtonSound.DEFAULT);
      }
      
      protected function setResourceListeners(param1:Boolean) : void
      {
         var _loc2_:ResourceInfo = null;
         for each(_loc2_ in WorldResourceManager.instance.resourceInfo)
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
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         this.stopNewUnitTimer(true);
         UIDispatcher.instance.removeEventListener(ObtainMultiRequirementsPopup.EVENT_PURCHASE_ITEM,this.onBuyItemEvent);
         ExperienceDispatcher.instance.removeEventListener(ExperienceUpdatedEvent.LEVEL,this.onPlayerUpdated);
         UIDispatcher.instance.removeEventListener(Player.INVENTORY_UPDATED,this.onPlayerUpdated);
         UIDispatcher.instance.removeEventListener(MarketEvent.MARKET_EXPANSION_CREW_UNLOCK,this.onCrewExpansionBuy);
         this.setResourceListeners(false);
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_EXPANSION_CREW_MASTER);
         if(_loc1_ == ZGlobal.EXPERIMENT_EXPANSION_CREW_ENABLED)
         {
            this.m_expansion_gdc.owner.eventDispatcher.removeEventListener(GameDataComponent.CREW_UPDATED,this.onCrewUpdated);
         }
         m_tiles = null;
         m_categoryButtons = null;
         this.unregisterLDTimer();
         this.unregisterLDItemCountChanged();
         this.m_LDTimer = null;
         this.clearCategoryImageLoaders();
      }
      
      private function onCrewUpdated(param1:Event) : void
      {
         refreshLayout();
      }
      
      private function setUpNewUnit(param1:GameItem, param2:MovieClip) : void
      {
         this.updateNewUnitCard(param1,param2,true);
      }
      
      private function updateNewUnitCard(param1:GameItem, param2:MovieClip, param3:Boolean) : void
      {
         var _loc4_:Object = new Object();
         var _loc5_:int = ZGameTimeUtil.instance.getDateStatus(_loc4_,param1.xml);
         var _loc6_:Boolean = false;
         if(this.m_shopVariant < 7)
         {
            switch(_loc5_)
            {
               case ZGameTimeUtil.DATE_STATUS_EARLY:
                  _loc6_ = true;
                  TextFieldUtil.processTextField(param2.daysLeft_tf,ZGameUtils.ZlocT("Main","ReadyMessage",{"time":_loc4_.string}));
                  break;
               case ZGameTimeUtil.DATE_STATUS_ACTIVE:
                  _loc6_ = true;
                  TextFieldUtil.compactTextField(param2.daysLeft_tf,ZGameUtils.ZlocT("Dialogs","LimitedEditionCountdown",{"time":_loc4_.string}),{
                     "maxLines":1,
                     "minScale":0.8
                  });
                  break;
               case ZGameTimeUtil.DATE_STATUS_LATE:
                  if(param1.contractLocked && ZGlobal.player.hasPurchasedContract(param1.code))
                  {
                     _loc6_ = true;
                  }
            }
         }
         _loc6_ &&= this.m_shopVariant < 7;
         if(_loc6_)
         {
            if(param3)
            {
               if(!this.m_newUnits)
               {
                  this.m_newUnits = new Array();
               }
               this.m_newUnits.push({
                  "gameItem":param1,
                  "card":param2
               });
               this.startNewUnitTimer();
            }
            TextFieldUtil.processTextField(param2.limited_tf,ZGameUtils.ZlocT("Dialogs","LimitedEditionBanner"));
         }
         if(param1.contractLocked)
         {
            if(ZGlobal.player.hasPurchasedContract(param1.code))
            {
               param2.daysLeft_tf.visible = false;
            }
            else
            {
               param2.daysLeft_tf.visible = _loc6_;
            }
         }
         else
         {
            param2.daysLeft_tf.visible = _loc6_;
         }
         param2.limitedCard_mc.visible = _loc6_ || param1.isNewItem();
         param2.limited_tf.visible = _loc6_;
         if(param1.isAdvExpUnit == "true")
         {
            param2.limitedCard_mc.visible = false;
            param2.limited_tf.visible = false;
            param2.daysLeft_tf.visible = false;
         }
      }
      
      private function stopNewUnitTimer(param1:Boolean) : void
      {
         Zlab.processManager.removeScheduledObject(this);
         if(param1)
         {
            this.m_newUnits = null;
         }
      }
      
      private function startNewUnitTimer() : void
      {
         this.stopNewUnitTimer(false);
         Zlab.processManager.schedule(1000,this,this.onUpdateNewUnitCards);
      }
      
      private function onUpdateNewUnitCards() : void
      {
         var _loc1_:Object = null;
         this.stopNewUnitTimer(false);
         for each(_loc1_ in this.m_newUnits)
         {
            this.updateNewUnitCard(_loc1_.gameItem,_loc1_.card,false);
         }
         this.startNewUnitTimer();
      }
      
      private function getExpansionCount() : int
      {
         var _loc1_:String = ZGlobal.gameSettings.getString("startingExpansionIndexes");
         var _loc2_:Array = _loc1_.split(",");
         var _loc3_:uint = _loc2_.length;
         return uint(ZGlobal.player.expansions.numBitsSet() - _loc3_);
      }
      
      private function get crewableExpansionsCapped() : Boolean
      {
         var _loc1_:String = ZGlobal.gameSettings.getString("crewableExpansionsPurchasedLimits","9999,9999,9999,20,30,40");
         var _loc2_:int = ExperimentsManager.instance.getExperimentValue("empire_expansion_crew_cap",_loc1_.split(","),20);
         var _loc3_:int = this.getExpansionCount();
         return _loc3_ >= _loc2_;
      }
      
      private function get crewableExpansionGated() : Boolean
      {
         var _loc1_:ExpansionItem = ZGlobal.gameSettings.getItemByCode(ExpansionItem.CREWABLE_EXPANSION_ID,ExpansionItem) as ExpansionItem;
         var _loc2_:BitArray = ZGlobal.player.checkGate(_loc1_);
         return _loc2_.anyBitSet();
      }
      
      private function get canUseCrewableExpansion() : Boolean
      {
         if(this.crewableExpansionsCapped)
         {
            return false;
         }
         if(this.crewableExpansionGated)
         {
            return false;
         }
         return true;
      }
      
      private function crewExpansionReady() : Boolean
      {
         var _loc1_:int = ExpansionPriceExperimentManager.instance.getFilledCrewExpansionCount();
         var _loc2_:int = int(ExpansionPriceExperimentManager.instance.getExpansionData(this.getExpansionCount(),"crewRequired"));
         return _loc2_ == _loc1_ ? true : false;
      }
      
      private function initLightningDealCard(param1:MovieClip, param2:GameItem) : void
      {
         var _loc6_:Boolean = false;
         var _loc7_:UnitItem = null;
         var _loc8_:String = null;
         var _loc3_:int = ZGlobal.player.lightningDealFractionClaimed;
         var _loc4_:String = ZGlobal.player.getFriendlyClaimProgressString(_loc3_);
         TextFieldUtil.processTextField(param1.ld_claim_mc.cliam_tf,_loc4_);
         var _loc5_:int = LD_CLAIMBAR_WIDTH * _loc3_ / 100;
         param1.ld_claim_mc.loadingBar_mc.width = _loc5_;
         this.registerForLDRemainingTimer(param2.code,param1.ld_timer_tf);
         this.updateLDTimeRemaining();
         if(param1.class_icon.visible)
         {
            _loc7_ = ZGlobal.gameSettings.getItemByCode(param2.code,UnitItem) as UnitItem;
            if(_loc7_)
            {
               _loc8_ = UnitClassManager.instance.getSmIconURLForUnit(_loc7_);
               if(_loc8_)
               {
                  ImageLoaderFactory.CreateImageLoader(_loc8_,param1.class_icon);
                  _loc6_ = true;
               }
            }
            if(!_loc6_)
            {
               param1.class_icon.visible = false;
            }
            if(this.isLevelLocked(param2) && !this.ldCardHeightAdjusted)
            {
               this.ldCardHeightAdjusted = true;
               param1.locked_mc.y += 12;
               param1.ld_claim_mc.y += 12;
               param1.levelInfo_tf.x -= 10;
               param1.levelInfo_tf.y += 10;
            }
         }
         PromoManager.instance.addEventListener(PromoManager.LIGHTNINGDEAL_ITEMCOUNT_UPDATED,this.onLDItemCountUpdated,false,0,true);
         this.m_LDCards.push(param1);
      }
      
      private function getPackageOfferings(param1:GameItem, param2:XML) : Object
      {
         var _loc3_:Object = {};
         if(param2.@unitCode != undefined)
         {
            _loc3_.itemCode = param2.@unitCode.toString();
         }
         if(param2.@energy != undefined)
         {
            _loc3_.energy = int(param2.@energy);
         }
         if(param2.@ep != undefined)
         {
            _loc3_.cash = int(param2.@ep);
         }
         if(param2.@cost != undefined)
         {
            _loc3_.cost = int(param2.@cost);
         }
         var _loc4_:Array = WorldResourceManager.instance.resourceInfo;
         return _loc3_;
      }
      
      private function buildFeedbackEntryInfo(param1:XML, param2:String, param3:String, param4:int = 0) : Object
      {
         var _loc5_:int = 0;
         if(param4)
         {
            return {
               "url":param3,
               "amount":param4
            };
         }
         if(param1.attribute(param2) != undefined)
         {
            _loc5_ = int(param1.attribute(param2));
            return {
               "url":param3,
               "amount":_loc5_
            };
         }
         return null;
      }
      
      private function buildFeedbackInfo(param1:XML) : Array
      {
         var _loc4_:ResourceInfo = null;
         var _loc5_:String = null;
         var _loc6_:GameItem = null;
         var _loc2_:Array = [];
         if(param1.@unitCode != undefined)
         {
            _loc5_ = param1.@unitCode.toString();
            _loc6_ = ZGlobal.gameSettings.getItemByCode(_loc5_,GameItem) as GameItem;
            if(_loc6_)
            {
               _loc2_.push(this.buildFeedbackEntryInfo(param1,"unitCode",ZGlobal.gameSettings.getImageByName(_loc6_.name,"icon"),1));
            }
         }
         _loc2_.push(this.buildFeedbackEntryInfo(param1,"ep",ZGlobal.getAssetURL(ZGlobal.gameSettings.getString("epIconPath",null))));
         _loc2_.push(this.buildFeedbackEntryInfo(param1,"energy",ZGlobal.getAssetURL(ZGlobal.gameSettings.getString("energyIconPath",null))));
         var _loc3_:Array = WorldResourceManager.instance.resourceInfo;
         for each(_loc4_ in _loc3_)
         {
            if(param1.attribute(_loc4_.type) != undefined)
            {
               _loc2_.push(this.buildFeedbackEntryInfo(param1,_loc4_.type,ZGlobal.getAssetURL(_loc4_.mediumIcon)));
            }
         }
         return _loc2_;
      }
      
      private function initStarterPackFeedback(param1:MovieClip, param2:Array) : void
      {
         var _loc5_:int = 0;
         var _loc6_:ImageLoader = null;
         var _loc3_:Array = [param1.starterPackUI_mc.icon0,param1.starterPackUI_mc.icon1,param1.starterPackUI_mc.icon2,param1.starterPackUI_mc.icon3];
         var _loc4_:Array = [null,param1.starterPackUI_mc.value_tf1,param1.starterPackUI_mc.value_tf2,param1.starterPackUI_mc.value_tf3];
         while(!(_loc5_ >= param2.length || _loc5_ >= _loc3_.length || _loc5_ >= _loc4_.length))
         {
            if(_loc4_[_loc5_])
            {
               TextFieldUtil.processSingleLineTextField(_loc4_[_loc5_],param2[_loc5_].amount);
            }
            _loc6_ = ImageLoaderFactory.CreateImageLoader(param2[_loc5_].url,_loc3_[_loc5_]);
            if(_loc6_)
            {
               _loc6_.smooth = true;
               this.m_categoryImageLoaders.push(_loc6_);
            }
            _loc5_++;
         }
         while(_loc5_ < _loc3_.length)
         {
            _loc3_[_loc5_].visible = false;
            _loc4_[_loc5_].visible = false;
            _loc5_++;
         }
      }
      
      private function initStarterPackCard(param1:MovieClip, param2:GameItem) : void
      {
         param1.starterPackUI_mc.visible = true;
         var _loc3_:XML = this.getStarterPackSurfacingInfo(param2);
         var _loc4_:Array = this.buildFeedbackInfo(_loc3_);
         this.initStarterPackFeedback(param1,_loc4_);
      }
      
      private function getStarterPackSurfacingInfo(param1:GameItem) : XML
      {
         var _loc2_:String = param1.starterPackPaymentCode;
         return PromoManager.instance.getStarterPackPaymentFromCodeName(_loc2_);
      }
      
      private function initTile(param1:MovieClip, param2:GameItem, param3:int) : void
      {
         param1.icon.x = ICON_MC_X[param3];
         if(param2.code == "UD20")
         {
            param1.strength_mc.x = STRENGTH_MC_X[0];
            param1.strength_mc.y = STRENGTH_MC_Y[0];
         }
         else
         {
            param1.strength_mc.x = STRENGTH_MC_X[param3];
            param1.strength_mc.y = STRENGTH_MC_Y[param3];
         }
         param1.class_icon.visible = CLASSICON_VISIBILITY[param3] && param2.isUnit;
         param1.ld_timer_tf.visible = LD_TIMER_STRING_VISIBILITY[param3];
         param1.ld_claim_mc.visible = LD_CLAIM_MC_VISIBILITY[param3];
         param1.starterPackUI_mc.visible = false;
         var _loc4_:UnitItem = ZGlobal.gameSettings.getItemByCode(param2.code,UnitItem) as UnitItem;
         if(param3 == CARDTYPE_LIGHTNINGDEAL)
         {
            this.initLightningDealCard(param1,param2);
         }
         else if(param3 == CARDTYPE_BUILDMENU_PROXY)
         {
            if(param2.subType == GameItem.SUBTYPE_BUILDMENU_PROXY_STARTERPACK)
            {
               this.initStarterPackCard(param1,param2);
            }
         }
         else if(param3 == CARDTYPE_MECHLEUNITS)
         {
            this.initMechLeUnitCard(param1,_loc4_);
         }
      }
      
      private function initMechLeUnitCard(param1:MovieClip, param2:UnitItem) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:String = null;
         if(param1.class_icon.visible)
         {
            if(param2)
            {
               _loc4_ = UnitItem.MECH_ICON_PATH;
               if(_loc4_)
               {
                  ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc4_),param1.class_icon);
                  _loc3_ = true;
               }
            }
         }
         if(!_loc3_)
         {
            param1.class_icon.visible = false;
         }
      }
      
      private function updateLDTimeRemaining() : void
      {
         var _loc2_:TextField = null;
         var _loc1_:String = ZGlobal.player.lightingDealTimeRemainingString;
         for each(_loc2_ in this.m_LDTimerTextFields)
         {
            TextFieldUtil.processTextField(_loc2_,_loc1_);
         }
      }
      
      private function unregisterLDTimer() : void
      {
         this.m_LDTimerTextFields = new Dictionary();
         this.m_LDTimer.removeEventListener(TimerEvent.TIMER,this.onLDTimer);
         this.m_LDTimer.stop();
      }
      
      private function unregisterLDItemCountChanged() : void
      {
         PromoManager.instance.removeEventListener(PromoManager.LIGHTNINGDEAL_ITEMCOUNT_UPDATED,this.onLDItemCountUpdated);
         this.m_LDCards = [];
      }
      
      private function registerForLDRemainingTimer(param1:String, param2:TextField) : void
      {
         this.m_LDTimerTextFields[param1] = param2;
         this.m_LDTimer.addEventListener(TimerEvent.TIMER,this.onLDTimer,false,0,true);
         this.m_LDTimer.start();
      }
      
      private function onLDTimer(param1:TimerEvent = null) : void
      {
         this.updateLDTimeRemaining();
      }
      
      private function onLDItemCountUpdated(param1:WorldEvent) : void
      {
         var _loc2_:MovieClip = null;
         for each(_loc2_ in this.m_LDCards)
         {
            this.updateLDClaimFeedback(_loc2_);
         }
      }
      
      private function postInitTile(param1:MovieClip, param2:GameItem, param3:int) : void
      {
         param1.starterCard_mc.visible = false;
         param1.icon.visible = true;
         if(param3 == CARDTYPE_LIGHTNINGDEAL)
         {
            param1.card_mc_decco.visible = false;
            param1.limitedCard_mc_gray.visible = false;
            param1.limitedCard_mc.visible = false;
            param1.card_mc_default.visible = false;
            param1.lightningCard_mc.visible = true;
            param1.count_mc3.visible = false;
            param1.count_mc2.visible = false;
            param1.count_mc.visible = false;
         }
         else if(param3 == CARDTYPE_BUILDMENU_PROXY)
         {
            param1.card_mc_decco.visible = false;
            param1.limitedCard_mc_gray.visible = false;
            param1.limitedCard_mc.visible = false;
            param1.card_mc_default.visible = false;
            param1.lightningCard_mc.visible = true;
            param1.starterCard_mc.visible = true;
            param1.icon.visible = false;
            param1.count_mc3.visible = false;
            param1.count_mc2.visible = false;
            param1.count_mc.visible = false;
         }
      }
      
      override protected function addComponent(param1:int, param2:int = 0) : void
      {
         var _loc5_:int = 0;
         var _loc6_:Array = null;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc9_:Boolean = false;
         var _loc10_:Object = null;
         var _loc11_:BitArray = null;
         var _loc12_:UnitItem = null;
         var _loc13_:Dictionary = null;
         var _loc14_:Dictionary = null;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:Boolean = false;
         var _loc19_:Object = null;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:GameItem = null;
         var _loc23_:LocalizationObjectToken = null;
         var _loc24_:LocalizationObjectToken = null;
         var _loc25_:Object = null;
         var _loc26_:int = 0;
         var _loc27_:GameItem = null;
         var _loc28_:LocalizationObjectToken = null;
         var _loc29_:Object = null;
         var _loc30_:Number = NaN;
         var _loc31_:String = null;
         var _loc32_:ZGameButton = null;
         var _loc33_:Loader = null;
         var _loc34_:int = 0;
         var _loc35_:int = 0;
         var _loc36_:Boolean = false;
         var _loc37_:TextFormat = null;
         var _loc38_:Array = null;
         var _loc39_:int = 0;
         var _loc40_:Boolean = false;
         var _loc41_:Boolean = false;
         var _loc42_:Boolean = false;
         var _loc43_:Boolean = false;
         var _loc44_:Boolean = false;
         var _loc45_:int = 0;
         var _loc46_:Dictionary = null;
         var _loc47_:String = null;
         var _loc48_:Boolean = false;
         var _loc49_:GameItem = null;
         var _loc50_:Boolean = false;
         var _loc51_:String = null;
         var _loc52_:Number = NaN;
         var _loc53_:String = null;
         var _loc54_:Array = null;
         var _loc55_:Number = NaN;
         var _loc56_:int = 0;
         var _loc57_:String = null;
         var _loc58_:BitArray = null;
         var _loc59_:String = null;
         var _loc60_:int = 0;
         var _loc61_:int = 0;
         var _loc62_:int = 0;
         var _loc63_:String = null;
         var _loc64_:Dictionary = null;
         var _loc65_:Object = null;
         var _loc66_:BuildingPartsGather = null;
         var _loc67_:int = 0;
         var _loc68_:GameDataComponent = null;
         var _loc69_:DecorationItem = null;
         var _loc70_:Boolean = false;
         var _loc3_:GameItem = m_data[param2 + param1] as GameItem;
         var _loc4_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_EXPANSION_CREW_MASTER);
         m_tiles[param1].itemCard_mc.count_mc_decco.visible = false;
         m_tiles[param1].itemCard_mc.card_mc_decco.visible = false;
         m_tiles[param1].itemCard_mc.label_tf_0.visible = false;
         m_tiles[param1].itemCard_mc.label_tf_1.visible = false;
         if(m_tiles[param1].itemCard_mc.tierRating_mc)
         {
            Tooltip.unsubscribe(m_tiles[param1].itemCard_mc.tierRating_mc);
            m_tiles[param1].itemCard_mc.tierRating_mc.visible = false;
         }
         if(m_tiles[param1].itemCard_mc.doubleXP_mc)
         {
            Tooltip.unsubscribe(m_tiles[param1].itemCard_mc.doubleXP_mc);
            m_tiles[param1].itemCard_mc.doubleXP_mc.visible = false;
         }
         if(Boolean(m_tiles[param1].itemCard_mc.flame_mc) && Boolean(m_tiles[param1].itemCard_mc.flameRollover_mc))
         {
            Tooltip.unsubscribe(m_tiles[param1].itemCard_mc.flameRollover_mc);
            m_tiles[param1].itemCard_mc.flame_mc.visible = false;
            m_tiles[param1].itemCard_mc.flameRollover_mc.visible = false;
         }
         if(m_tiles[param1].itemCard_mc.blackmarket_tf)
         {
            m_tiles[param1].itemCard_mc.blackmarket_tf.visible = false;
         }
         if(Boolean(m_tiles[param1].itemCard_mc.whiteSabre_mc) && Boolean(m_tiles[param1].itemCard_mc.flameRollover_mc))
         {
            Tooltip.unsubscribe(m_tiles[param1].itemCard_mc.flameRollover_mc);
            m_tiles[param1].itemCard_mc.whiteSabre_mc.visible = false;
            m_tiles[param1].itemCard_mc.flameRollover_mc.visible = false;
         }
         if(m_tiles[param1].itemCard_mc.lightning_mc)
         {
            m_tiles[param1].itemCard_mc.lightning_mc.visible = false;
         }
         if(Boolean(m_tiles) && Boolean(_loc3_))
         {
            _loc5_ = this.getCardType(_loc3_);
            this.initTile(m_tiles[param1].itemCard_mc,_loc3_,_loc5_);
            m_tiles[param1].visible = true;
            m_tiles[param1].itemCard_mc.highlightSelect.visible = false;
            m_tiles[param1].itemCard_mc.cost_tf.mouseEnabled = false;
            m_tiles[param1].itemCard_mc.limitedCard_mc_gray.visible = false;
            m_tiles[param1].itemCard_mc.count_mc3.visible = false;
            _loc6_ = [m_tiles[param1].itemCard_mc.resourceIcon_mc_0,m_tiles[param1].itemCard_mc.resourceIcon_mc_1,m_tiles[param1].itemCard_mc.resourceIcon_mc_2];
            _loc7_ = [m_tiles[param1].itemCard_mc.resource_tf_0,m_tiles[param1].itemCard_mc.resource_tf_1,m_tiles[param1].itemCard_mc.resource_tf_2];
            _loc8_ = int(_loc7_.length);
            m_tiles[param1].itemCard_mc.buy_bt2.visible = false;
            m_tiles[param1].itemCard_mc.itemName_tf.mouseEnabled = false;
            TextFieldUtil.processTextField(m_tiles[param1].itemCard_mc.itemName_tf,m_data[param2 + param1].getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            m_tiles[param1].itemCard_mc.underlay_mc.visible = m_tiles[param1].itemCard_mc.itemName_tf.numLines > 1;
            m_tiles[param1].itemCard_mc.cost_tf.visible = false;
            m_tiles[param1].itemCard_mc.discount_tf.visible = false;
            m_tiles[param1].itemCard_mc.discount_mc.visible = false;
            if(_loc3_.xml.unit != undefined)
            {
               _loc12_ = ZGlobal.gameSettings.getItemByCode(_loc3_.code,UnitItem) as UnitItem;
               _loc13_ = WorldUnitManager.instance.availableUnits;
               _loc14_ = WarehouseUnitManager.instance.getAvailableUnits();
               _loc15_ = ZGlobal.player.inventory[_loc12_.code] ? int(ZGlobal.player.inventory[_loc12_.code]) : 0;
               _loc16_ = _loc13_[_loc12_.code] ? int(_loc13_[_loc12_.code]) : 0;
               _loc17_ = _loc14_[_loc12_.code] ? int(_loc14_[_loc12_.code]) : 0;
               _loc18_ = true;
               _loc19_ = new Object();
               _loc20_ = ZGameTimeUtil.instance.getDateStatus(_loc19_,_loc3_.xml);
               if(_loc20_ == ZGameTimeUtil.DATE_STATUS_EARLY || _loc20_ == ZGameTimeUtil.DATE_STATUS_ACTIVE || this.m_shopVariant > 2 && _loc20_ == ZGameTimeUtil.DATE_STATUS_LATE)
               {
                  TextFieldUtil.processTextField(m_tiles[param1].itemCard_mc.count_mc2.count_tf,(_loc15_ + _loc16_ + _loc17_).toString());
                  m_tiles[param1].itemCard_mc.count_mc2.visible = true;
                  m_tiles[param1].itemCard_mc.count_mc.visible = false;
                  if(!_loc12_.isRequriedBuildingActive && _loc12_.hasType(UnitItem.MEGA_UNIT))
                  {
                     _loc18_ = false;
                  }
                  if(_loc3_.contractLocked && _loc3_.canBuyContract() && !this.isLevelLocked(_loc3_) && _loc18_)
                  {
                     _loc22_ = _loc3_.builtFromStructure;
                     _loc32_ = new ZGameButton(m_tiles[param1].itemCard_mc.buy_bt2,this.onBuyContractClick);
                     _loc32_.text = ZGameUtils.ZlocT("Dialogs","UnlockForAmount",{"amount":_loc3_.contractCost});
                     if(_loc22_)
                     {
                        _loc23_ = _loc3_.getSentenceNameLocalizationObject("singular,indefinite",true);
                        _loc24_ = _loc22_.getSentenceNameLocalizationObject("singular,definite",true);
                        if(Boolean(_loc23_) && Boolean(_loc24_))
                        {
                           _loc25_ = {
                              "item":_loc23_,
                              "building":_loc24_
                           };
                           _loc32_.addTooltip(ZGameUtils.ZlocT("Dialogs","BuyContractButtonTooltip",_loc25_));
                           m_unlockContractButtons[param1] = _loc32_;
                           m_unlockContractButtons[param1].sounds = ButtonSound.ROLLOVER_ONLY;
                        }
                     }
                     m_tiles[param1].itemCard_mc.buy_bt2.visible = true;
                  }
                  if(!this.isLevelLocked(_loc3_) && !this.isQuestLocked(_loc3_) && _loc18_)
                  {
                     _loc32_ = new ZGameButton(m_tiles[param1].itemCard_mc.buy_bt,this.onBuyClick);
                     _loc32_.text = ZGameUtils.ZlocT("Dialogs","BuyForAmount",{"amount":_loc3_.cash});
                     m_tiles[param1].itemCard_mc.buy_bt.visible = true;
                     m_tiles[param1].itemCard_mc.green_bt.visible = false;
                     m_buildButtons[param1] = _loc32_;
                  }
               }
               else
               {
                  TextFieldUtil.processTextField(m_tiles[param1].itemCard_mc.count_mc.count_tf,(_loc15_ + _loc16_ + _loc17_).toString());
                  m_tiles[param1].itemCard_mc.count_mc.visible = true;
                  m_tiles[param1].itemCard_mc.count_mc2.visible = false;
               }
               _loc21_ = _loc12_.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(_loc12_.code));
               TextFieldUtil.processTextField(m_tiles[param1].itemCard_mc.strength_mc.strength_tf,String(_loc21_));
               if(!this.strength_mc_width)
               {
                  this.strength_mc_width = m_tiles[param1].itemCard_mc.strength_mc.width;
               }
               this.resizeStrengthText(m_tiles[param1].itemCard_mc.strength_mc,_loc21_);
               m_tiles[param1].itemCard_mc.strength_mc.visible = true;
               if(Boolean(m_tiles[param1].itemCard_mc.tierRating_mc) && this.tierSurfacingEnabled)
               {
                  _loc26_ = (ZGlobal.gameSettings.getItemByCode(_loc12_.code,UnitItem) as UnitItem).tier;
                  TextFieldUtil.compactTextField(m_tiles[param1].itemCard_mc.tierRating_mc.tier_tf,String(_loc26_));
                  m_tiles[param1].itemCard_mc.tierRating_mc.visible = true;
                  _loc27_ = _loc3_.builtFromStructure;
                  if(_loc27_)
                  {
                     _loc28_ = _loc27_.getSentenceNameLocalizationObject("singular,definite",true);
                     if(Boolean(_loc27_) && Boolean(_loc28_))
                     {
                        _loc29_ = {"building":_loc28_};
                        Tooltip.subscribe(m_tiles[param1].itemCard_mc.tierRating_mc,ZGameUtils.ZlocT("Tooltips","TierToolTipNew",_loc29_));
                     }
                  }
               }
               if(Boolean(m_tiles[param1].itemCard_mc.doubleXP_mc) && Boolean(this.tierSurfacingEnabled) && _loc12_.isBlueDevil)
               {
                  m_tiles[param1].itemCard_mc.doubleXP_mc.visible = true;
                  Tooltip.subscribe(m_tiles[param1].itemCard_mc.doubleXP_mc,ZGameUtils.ZlocT("Tooltips","doubleXPToolTip"));
               }
               if(Boolean(m_tiles[param1].itemCard_mc.flame_mc && m_tiles[param1].itemCard_mc.flameRollover_mc) && Boolean(FlamingUnitManager.instance.flamingUnitsEnabled) && _loc12_.isFlamingUnit)
               {
                  m_tiles[param1].itemCard_mc.limitedCard_mc.visible = false;
                  m_tiles[param1].itemCard_mc.limitedCard_mc_gray.visible = true;
                  m_tiles[param1].itemCard_mc.flame_mc.visible = true;
                  m_tiles[param1].itemCard_mc.flameRollover_mc.visible = true;
                  Tooltip.subscribe(m_tiles[param1].itemCard_mc.flameRollover_mc,ZGameUtils.ZlocT("Tooltips","flamingToolTip"));
               }
               if(Boolean(m_tiles[param1].itemCard_mc.lightning_mc) && Boolean(_loc3_.isWhiteUnit) && WhiteUnitManager.instance.whiteUnitsEnabled)
               {
                  m_tiles[param1].itemCard_mc.lightning_mc.visible = true;
               }
               if(Boolean(m_tiles[param1].itemCard_mc.whiteSabre_mc) && Boolean(WhiteUnitManager.instance.whiteUnitsEnabled) && _loc12_.isWhiteUnit)
               {
                  m_tiles[param1].itemCard_mc.limitedCard_mc.visible = false;
                  m_tiles[param1].itemCard_mc.limitedCard_mc_gray.visible = true;
                  m_tiles[param1].itemCard_mc.whiteSabre_mc.visible = true;
                  m_tiles[param1].itemCard_mc.flameRollover_mc.visible = true;
                  Tooltip.subscribe(m_tiles[param1].itemCard_mc.flameRollover_mc,ZGameUtils.ZlocT("Tooltips","whiteSaberToolTip"));
               }
               if(LEUnitDiscountManager.instance.isLEDiscountExpEnabled() && LEUnitDiscountManager.instance.isOverrideLEItem(_loc12_.code))
               {
                  _loc30_ = Math.floor(LEUnitDiscountManager.instance.getLEOverrideDiscount(_loc12_.code) * 100);
                  if(_loc30_ > 0)
                  {
                     if(LEUnitDiscountManager.instance.leDiscountVariant == 3)
                     {
                        TextFieldUtil.compactTextField(m_tiles[param1].itemCard_mc.discount_tf,ZGameUtils.ZlocT("Dialogs","PercentOffExclaim",{"amount":_loc30_}));
                     }
                     else
                     {
                        TextFieldUtil.compactTextField(m_tiles[param1].itemCard_mc.discount_tf,ZGameUtils.ZlocT("Promo","promo_RepeatPackHUD_textSale"));
                     }
                     m_tiles[param1].itemCard_mc.discount_tf.visible = true;
                  }
                  else
                  {
                     m_tiles[param1].itemCard_mc.discount_tf.visible = false;
                  }
               }
            }
            else
            {
               m_tiles[param1].itemCard_mc.strength_mc.visible = false;
               m_tiles[param1].itemCard_mc.count_mc.visible = false;
               m_tiles[param1].itemCard_mc.count_mc2.visible = false;
               if(m_tiles[param1].itemCard_mc.tierRating_mc)
               {
                  m_tiles[param1].itemCard_mc.tierRating_mc.visible = false;
               }
               if(m_tiles[param1].itemCard_mc.doubleXP_mc)
               {
                  m_tiles[param1].itemCard_mc.doubleXP_mc.visible = false;
               }
               if(Boolean(m_tiles[param1].itemCard_mc.flame_mc) && Boolean(m_tiles[param1].itemCard_mc.flameRollover_mc))
               {
                  m_tiles[param1].itemCard_mc.flame_mc.visible = false;
                  m_tiles[param1].itemCard_mc.flameRollover_mc.visible = false;
               }
               if(Boolean(m_tiles[param1].itemCard_mc.whiteSabre_mc) && Boolean(m_tiles[param1].itemCard_mc.flameRollover_mc))
               {
                  m_tiles[param1].itemCard_mc.whiteSabre_mc.visible = false;
                  m_tiles[param1].itemCard_mc.flameRollover_mc.visible = false;
               }
               if(m_tiles[param1].itemCard_mc.lightning_mc)
               {
                  m_tiles[param1].itemCard_mc.lightning_mc.visible = false;
               }
               if(Boolean(m_tiles[param1].itemCard_mc.blackmarket_tf) && this.isBlackMarket(_loc3_))
               {
                  m_tiles[param1].itemCard_mc.blackmarket_tf.visible = true;
                  TextFieldUtil.compactTextField(m_tiles[param1].itemCard_mc.blackmarket_tf,WorldObjectManager.instance.getNumberBuiltObjectsWithCode("R99") + " / " + _loc3_.limit);
               }
               m_tiles[param1].itemCard_mc.discount_tf.visible = false;
            }
            _loc33_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc3_.name,"icon"),m_tiles[param1].itemCard_mc.icon);
            m_iconLoaders.push(_loc33_);
            _loc9_ = _loc3_.usesCash() && !_loc3_.directPay;
            _loc10_ = {"forCashPurchase":_loc9_};
            _loc11_ = ZGlobal.player.checkGate(_loc3_,_loc10_);
            if(this.isItemUnlockEligible(_loc3_))
            {
               this.blurCard(m_tiles[param1]);
               _loc32_ = new ZGameButton(m_tiles[param1].itemCard_mc.buy_bt,this.onBuyClick);
               _loc32_.text = ZGameUtils.ZlocT("Dialogs","UnlockForAmount",{"amount":_loc3_.unlockCost});
               _loc32_.addTooltip(ZGameUtils.ZlocT("Dialogs","StoreUnitUnlockTooltip"));
               m_tiles[param1].itemCard_mc.buy_bt.visible = true;
               m_tiles[param1].itemCard_mc.green_bt.visible = false;
               m_tiles[param1].itemCard_mc.levelInfo_tf.visible = true;
               _loc31_ = _loc3_.getGateFailureString(_loc11_);
               TextFieldUtil.processTextField(m_tiles[param1].itemCard_mc.levelInfo_tf,_loc31_ ? _loc31_ : "");
               m_tiles[param1].itemCard_mc.locked_mc.visible = true;
               m_tiles[param1].itemCard_mc.locked_mc.locked_tf.visible = false;
               m_buildButtons[param1] = _loc32_;
               m_buildButtons[param1].buttonValue = param1.toString();
               m_buildButtons[param1].sounds = ButtonSound.ROLLOVER_ONLY;
            }
            else if(!_loc11_.anyBitSet() || this.shouldDisplayItem(_loc3_))
            {
               m_tiles[param1].itemCard_mc.useHandCursor = false;
               _loc32_ = null;
               TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.UI_ELEMENT,{
                  "ui":m_tiles[param1].itemCard_mc,
                  "item":_loc3_
               }));
               m_tiles[param1].itemCard_mc.locked_mc.visible = false;
               m_tiles[param1].itemCard_mc.levelInfo_tf.visible = false;
               TextFieldUtil.processTextField(m_tiles[param1].itemCard_mc.cost_tf,ZGameUtils.ZlocT("Dialogs","StoreCostHeader"));
               m_tiles[param1].itemCard_mc.icon.filters = [];
               _loc34_ = 0;
               if(_loc3_.type == GameItem.TYPE_BUILDMENUPROXY)
               {
                  _loc32_ = new ZGameButton(m_tiles[param1].itemCard_mc.green_bt,this.onBuyStarterPack);
                  _loc32_.buttonObject = _loc3_;
                  _loc32_.text = ZGameUtils.ZlocT("Promo","promo_MoneyCost",{"cost":this.getStarterPackProxyCost(_loc3_)});
                  m_tiles[param1].itemCard_mc.buy_bt.visible = false;
                  m_tiles[param1].itemCard_mc.build_bt.visible = false;
                  m_tiles[param1].itemCard_mc.green_bt.visible = true;
                  m_buildButtons[param1] = _loc32_;
                  _loc35_ = int(this.getStarterPackItemStrength(_loc3_));
                  if(_loc35_)
                  {
                     m_tiles[param1].itemCard_mc.strength_mc.visible = true;
                     TextFieldUtil.processTextField(m_tiles[param1].itemCard_mc.strength_mc.strength_tf,String(_loc35_));
                  }
               }
               else if(!_loc3_.usesCash() && !_loc3_.directPay)
               {
                  _loc32_ = new ZGameButton(m_tiles[param1].itemCard_mc.build_bt,this.onBuyClick);
                  _loc36_ = _loc3_.type == "resource" && _loc3_.subType == "resource";
                  _loc32_.text = ZGameUtils.ZlocT("Dialogs",_loc36_ ? "BuildButton_Cash" : "BuildButton_Resource");
                  m_tiles[param1].itemCard_mc.build_bt.visible = true;
                  m_tiles[param1].itemCard_mc.buy_bt.visible = false;
                  m_tiles[param1].itemCard_mc.green_bt.visible = false;
                  _loc37_ = null;
                  _loc38_ = _loc3_.resourceCosts;
                  _loc39_ = int(_loc38_.length);
                  _loc40_ = true;
                  _loc41_ = true;
                  if(_loc3_.isExpansionItem)
                  {
                     _loc42_ = this.getExpansionCount() >= ExpansionPriceExperimentManager.MAX_EXPANSIONS;
                     _loc43_ = (_loc3_ as ExpansionItem).isCrewableExpansion() && !this.canUseCrewableExpansion;
                     if(_loc42_ || _loc43_)
                     {
                        _loc41_ = false;
                     }
                     else
                     {
                        _loc44_ = _loc4_ == ZGlobal.EXPERIMENT_EXPANSION_CREW_ENABLED && this.crewExpansionReady() && this.canUseCrewableExpansion;
                        if(_loc44_)
                        {
                           _loc41_ = false;
                        }
                     }
                  }
                  if(_loc41_)
                  {
                     _loc45_ = 0;
                     while(_loc45_ < _loc39_)
                     {
                        if(_loc34_ < _loc8_ && Math.abs(_loc38_[_loc45_].type) != 0)
                        {
                           TextFieldUtil.processTextField(_loc7_[_loc34_],String(Math.abs(_loc3_.resourceCosts[_loc45_].amount)));
                           _loc33_ = ImageLoaderFactory.CreateImageLoader(WorldResourceManager.instance.getResourceImageURLByType(_loc38_[_loc45_].type,WorldResourceManager.XTRA_SMALL_ICON),_loc6_[_loc34_]);
                           m_iconLoaders.push(_loc33_);
                           _loc7_[_loc34_].visible = true;
                           _loc7_[_loc34_].mouseEnabled = false;
                           _loc48_ = ZGlobal.player.hasResource(_loc38_[_loc45_]);
                           _loc40_ &&= _loc48_;
                           TextFieldUtil.setTextFieldColor(_loc7_[_loc34_],!_loc48_ ? Style.COLOR_UNSUFFICIENT_RESOURCES : 16777215);
                        }
                        _loc34_++;
                        _loc45_++;
                     }
                     _loc46_ = _loc3_.itemCosts;
                     for(_loc47_ in _loc46_)
                     {
                        if(_loc34_ < _loc8_)
                        {
                           _loc49_ = ZGlobal.gameSettings.getItemByCode(_loc47_,GameItem) as GameItem;
                           _loc33_ = ImageLoaderFactory.CreateImageLoader(_loc49_.getCachedImage("icon").url,_loc6_[_loc34_]);
                           TextFieldUtil.processTextField(_loc7_[_loc34_],_loc46_[_loc47_]);
                           _loc7_[_loc34_].visible = true;
                           _loc7_[_loc34_].mouseEnabled = false;
                           _loc50_ = ZGlobal.player.getNumberOfInventoryItems(_loc47_) >= _loc46_[_loc47_];
                           _loc40_ &&= _loc50_;
                           TextFieldUtil.setTextFieldColor(_loc7_[_loc34_],!_loc50_ ? Style.COLOR_UNSUFFICIENT_FUNDS : 0);
                        }
                        _loc34_++;
                     }
                  }
                  if(_loc3_.isExpansionItem && _loc4_ == ZGlobal.EXPERIMENT_EXPANSION_CREW_ENABLED)
                  {
                     if((_loc3_ as ExpansionItem).isCrewableExpansion())
                     {
                        _loc32_ = new ZGameButton(m_tiles[param1].itemCard_mc.green_bt,this.onCrewClick);
                        if(this.crewExpansionReady())
                        {
                           _loc32_.text = ZGameUtils.ZlocT("Dialogs","CrewedExpansionHireButtonComplete");
                        }
                        else
                        {
                           _loc32_.text = ZGameUtils.ZlocT("Dialogs","CrewedExpansionHireButton");
                        }
                        _loc32_.addTooltip(ZGameUtils.ZlocT("Dialogs","CrewedExpansionHireButtonTooltip"));
                        m_tiles[param1].itemCard_mc.build_bt.visible = false;
                        m_tiles[param1].itemCard_mc.buy_bt.visible = false;
                        m_tiles[param1].itemCard_mc.green_bt.visible = true;
                     }
                     else if(this.crewExpansionReady() && this.canUseCrewableExpansion)
                     {
                        this.blurCard(m_tiles[param1]);
                        m_tiles[param1].itemCard_mc.buy_bt.visible = false;
                        m_tiles[param1].itemCard_mc.build_bt.visible = false;
                        m_tiles[param1].itemCard_mc.green_bt.visible = false;
                        m_tiles[param1].itemCard_mc.locked_mc.visible = true;
                        m_tiles[param1].itemCard_mc.locked_mc.locked_tf.visible = false;
                        m_tiles[param1].itemCard_mc.levelInfo_tf.visible = false;
                        m_tiles[param1].itemCard_mc.icon.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
                        TextFieldUtil.processTextField(m_tiles[param1].itemCard_mc.levelInfo_tf,ZGameUtils.ZlocT("Dialogs","CrewedExpansionLockedButtonTooltip"));
                        m_tiles[param1].itemCard_mc.levelInfo_tf.visible = true;
                        _loc32_.callback = null;
                     }
                     if(_loc3_.isExpansionItem)
                     {
                        if(this.getExpansionCount() >= ExpansionPriceExperimentManager.MAX_EXPANSIONS)
                        {
                           _loc51_ = "CrewedExpansionLockedAllExpansions";
                        }
                        else if((_loc3_ as ExpansionItem).isCrewableExpansion() && this.crewableExpansionsCapped)
                        {
                           _loc51_ = "Expansion_CrewableCardCapReached";
                        }
                        if(_loc51_)
                        {
                           this.blurCard(m_tiles[param1]);
                           m_tiles[param1].itemCard_mc.green_bt.visible = false;
                           _loc32_.callback = null;
                           m_tiles[param1].itemCard_mc.icon.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
                           m_tiles[param1].itemCard_mc.locked_mc.visible = true;
                           m_tiles[param1].itemCard_mc.locked_mc.locked_tf.visible = false;
                           TextFieldUtil.processTextField(m_tiles[param1].itemCard_mc.levelInfo_tf,ZGameUtils.ZlocT("Dialogs",_loc51_));
                           m_tiles[param1].itemCard_mc.levelInfo_tf.visible = true;
                        }
                     }
                  }
               }
               else if(_loc3_.directPay)
               {
                  _loc52_ = _loc3_.directPayPrice;
                  _loc53_ = LocaleFormatter.formatNumber(_loc52_);
                  _loc54_ = _loc53_.split(".");
                  if(Boolean(_loc54_[1]) && _loc54_[1].length == 1)
                  {
                     _loc54_[1] += "0";
                     _loc53_ = _loc54_[0] + "." + _loc54_[1];
                  }
                  _loc53_ += " USD";
                  _loc32_ = new ZGameButton(m_tiles[param1].itemCard_mc.green_bt,this.onDirectPayClick);
                  _loc32_.text = ZGameUtils.ZlocT("Dialogs","BuyForAmount",{"amount":_loc53_});
                  m_tiles[param1].directPayZGameButton = _loc32_;
                  m_tiles[param1].itemCard_mc.build_bt.visible = false;
                  m_tiles[param1].itemCard_mc.buy_bt.visible = false;
                  m_tiles[param1].itemCard_mc.green_bt.visible = true;
                  m_tiles[param1].itemCard_mc.cost_tf.text = "";
               }
               else
               {
                  _loc32_ = new ZGameButton(m_tiles[param1].itemCard_mc.buy_bt,this.onBuyClick);
                  _loc32_.text = ZGameUtils.ZlocT("Dialogs","BuyForAmount",{"amount":_loc3_.cash});
                  m_tiles[param1].itemCard_mc.buy_bt.visible = true;
                  m_tiles[param1].itemCard_mc.build_bt.visible = false;
                  m_tiles[param1].itemCard_mc.green_bt.visible = false;
                  m_tiles[param1].itemCard_mc.cost_tf.text = "";
                  if(_loc3_.xml.unit != undefined && !ZGameTimeUtil.instance.isLimitedEdition(_loc3_.xml))
                  {
                     _loc55_ = PriceTestManager.instance.costMultiplierByType("unitsalediscount");
                     if(_loc55_ < 1)
                     {
                        _loc56_ = (1 - _loc55_) * 100;
                        TextFieldUtil.processTextField(m_tiles[param1].itemCard_mc.discount_tf,ZGameUtils.ZlocT("Dialogs","PercentOffExclaim",{"amount":_loc56_}));
                        m_tiles[param1].itemCard_mc.discount_tf.visible = true;
                     }
                  }
                  else if(_loc3_.cash < _loc3_.xmlCash)
                  {
                     if(_loc3_.type == "consumable" && _loc3_.subType == "energy")
                     {
                        TextFieldUtil.compactTextField(m_tiles[param1].itemCard_mc.discount_mc.percent_tf,ZGameUtils.ZlocT("Dialogs","BoldSale"),{
                           "maxLines":1,
                           "minScale":0.5,
                           "onFail":"return"
                        });
                        m_tiles[param1].itemCard_mc.discount_mc.visible = true;
                     }
                  }
                  if(_loc4_ == ZGlobal.EXPERIMENT_EXPANSION_CREW_ENABLED && _loc3_.isExpansionItem)
                  {
                     if((_loc3_ as ExpansionItem).isCashExpansion() && this.crewExpansionReady())
                     {
                        if(this.canUseCrewableExpansion)
                        {
                           this.blurCard(m_tiles[param1]);
                           m_tiles[param1].itemCard_mc.buy_bt.visible = false;
                           m_tiles[param1].itemCard_mc.build_bt.visible = false;
                           m_tiles[param1].itemCard_mc.green_bt.visible = false;
                           m_tiles[param1].itemCard_mc.locked_mc.visible = true;
                           m_tiles[param1].itemCard_mc.locked_mc.locked_tf.visible = false;
                           m_tiles[param1].itemCard_mc.levelInfo_tf.visible = false;
                           m_tiles[param1].itemCard_mc.icon.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
                           TextFieldUtil.processTextField(m_tiles[param1].itemCard_mc.levelInfo_tf,ZGameUtils.ZlocT("Dialogs","CrewedExpansionLockedButtonTooltip"));
                           m_tiles[param1].itemCard_mc.levelInfo_tf.visible = true;
                           _loc32_.removeTooltip();
                           _loc32_.callback = null;
                        }
                     }
                     else if(_loc3_.isExpansionItem)
                     {
                        if(this.getExpansionCount() >= ExpansionPriceExperimentManager.MAX_EXPANSIONS)
                        {
                           _loc57_ = "CrewedExpansionLockedAllExpansions";
                        }
                        else if((_loc3_ as ExpansionItem).isCrewableExpansion() && this.crewableExpansionsCapped)
                        {
                           _loc57_ = "Expansion_CrewableCardCapReached";
                        }
                        if(_loc57_)
                        {
                           TextFieldUtil.processTextField(m_tiles[param1].itemCard_mc.levelInfo_tf,ZGameUtils.ZlocT("Dialogs",_loc57_));
                           this.blurCard(m_tiles[param1]);
                           m_tiles[param1].itemCard_mc.green_bt.visible = false;
                           _loc32_.callback = null;
                           m_tiles[param1].itemCard_mc.icon.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
                           m_tiles[param1].itemCard_mc.locked_mc.visible = true;
                           m_tiles[param1].itemCard_mc.locked_mc.locked_tf.visible = false;
                           m_tiles[param1].itemCard_mc.levelInfo_tf.visible = true;
                        }
                     }
                  }
               }
               m_buildButtons[param1] = _loc32_;
               m_buildButtons[param1].buttonValue = param1.toString();
               m_buildButtons[param1].sounds = ButtonSound.ROLLOVER_ONLY;
               while(_loc34_ < _loc8_)
               {
                  _loc7_[_loc34_].visible = false;
                  _loc6_[_loc34_].unload();
                  _loc34_++;
               }
            }
            else
            {
               this.blurCard(m_tiles[param1]);
               _loc58_ = ZGlobal.player.checkGate(_loc3_);
               if(ZGlobal.player.isItemUnlocked(_loc3_.code))
               {
                  _loc58_.resetBit(Player.GATE_FAILURE_LEVEL);
                  _loc58_.resetBit(Player.GATE_FAILURE_QUEST);
               }
               if(_loc3_.isExpansionItem && (_loc3_ as ExpansionItem).isCrewableExpansion() && _loc4_ == ZGlobal.EXPERIMENT_EXPANSION_CREW_ENABLED && (this.getExpansionCount() >= ExpansionPriceExperimentManager.MAX_EXPANSIONS || this.crewableExpansionsCapped))
               {
                  if(this.getExpansionCount() >= ExpansionPriceExperimentManager.MAX_EXPANSIONS)
                  {
                     TextFieldUtil.processTextField(m_tiles[param1].itemCard_mc.levelInfo_tf,ZGameUtils.ZlocT("Dialogs","CrewedExpansionLockedAllExpansions"));
                  }
                  else if(this.crewableExpansionsCapped)
                  {
                     TextFieldUtil.processTextField(m_tiles[param1].itemCard_mc.levelInfo_tf,ZGameUtils.ZlocT("Dialogs","Expansion_CrewableCardCapReached"));
                  }
               }
               else
               {
                  _loc59_ = _loc3_.getGateFailureString(_loc58_);
                  TextFieldUtil.processTextField(m_tiles[param1].itemCard_mc.levelInfo_tf,_loc59_ ? _loc59_ : "");
               }
               m_tiles[param1].itemCard_mc.locked_mc.visible = true;
               m_tiles[param1].itemCard_mc.locked_mc.locked_tf.visible = false;
               m_tiles[param1].itemCard_mc.levelInfo_tf.visible = true;
               if(!this.itemBuyableFromStore(_loc3_.xml) && this.itemDisplayInStore(_loc3_.xml) && _loc3_.placeable)
               {
                  _loc60_ = 0;
                  if(ZGameTimeUtil.instance.getDateStatus(null,_loc3_.xml) == ZGameTimeUtil.DATE_STATUS_ACTIVE)
                  {
                     _loc60_ = ZGlobal.player.getNumberOfInventoryItems(_loc3_.code);
                  }
                  _loc61_ = WorldObjectManager.instance.getNumberObjectsWithCode(_loc3_.code);
                  _loc62_ = WorldObjectManager.instance.getNumberBuiltObjectsWithCode(_loc3_.code);
                  if(_loc61_ == 0 && _loc62_ == 0 && _loc60_ > 0)
                  {
                     _loc32_ = new ZGameButton(m_tiles[param1].itemCard_mc.build_bt,this.onPlaceClick);
                     _loc32_.text = ZGameUtils.ZlocT("MessageOfTheDay","motd_Button_PlaceNowExclaim");
                     m_tiles[param1].itemCard_mc.build_bt.visible = true;
                     m_tiles[param1].addEventListener(MouseEvent.CLICK,this.onPlaceClick,false,0,true);
                     m_tiles[param1].itemCard_mc.buy_bt.visible = false;
                     m_tiles[param1].itemCard_mc.green_bt.visible = false;
                     m_tiles[param1].itemCard_mc.locked_mc.visible = false;
                     m_tiles[param1].itemCard_mc.locked_mc.locked_tf.visible = false;
                     m_tiles[param1].itemCard_mc.levelInfo_tf.visible = false;
                  }
                  else if(_loc61_ == 1 && _loc62_ == 0)
                  {
                     _loc63_ = _loc3_.code;
                     _loc64_ = WorldObjectManager.instance.getObjectsBySubType(_loc3_.type,_loc3_.subType);
                     for each(_loc65_ in _loc64_)
                     {
                        _loc68_ = GameDataComponent(_loc65_.lookupComponentByType(GameDataComponent));
                        if((Boolean(_loc68_)) && _loc68_.gameData.code == _loc63_)
                        {
                           break;
                        }
                     }
                     _loc66_ = new BuildingPartsGather(new EventDispatcher(),_loc3_.code,null,_loc65_ as IEntity);
                     _loc67_ = _loc66_.getRemainingBuildingPartsAmount(_loc3_.code);
                     if(_loc67_ > 0)
                     {
                        _loc32_ = new ZGameButton(m_tiles[param1].itemCard_mc.buy_bt,this.onFinishClick);
                        _loc32_.text = ZGameUtils.ZlocT("Dialogs","SpeedupFinishButtonText",{"amount":_loc67_});
                        m_tiles[param1].itemCard_mc.build_bt.visible = false;
                        m_tiles[param1].addEventListener(MouseEvent.CLICK,this.onFinishClick,false,0,true);
                        m_tiles[param1].itemCard_mc.buy_bt.visible = true;
                        m_tiles[param1].itemCard_mc.green_bt.visible = false;
                        m_tiles[param1].itemCard_mc.locked_mc.visible = false;
                        m_tiles[param1].itemCard_mc.locked_mc.locked_tf.visible = false;
                        m_tiles[param1].itemCard_mc.levelInfo_tf.visible = false;
                     }
                     else
                     {
                        _loc32_ = new ZGameButton(m_tiles[param1].itemCard_mc.build_bt,this.showPartsDialog);
                        _loc32_.text = ZGameUtils.ZlocT("Dialogs","FinishNowButtonText");
                        m_tiles[param1].itemCard_mc.build_bt.visible = true;
                        m_tiles[param1].addEventListener(MouseEvent.CLICK,this.showPartsDialog,false,0,true);
                        m_tiles[param1].itemCard_mc.buy_bt.visible = false;
                        m_tiles[param1].itemCard_mc.green_bt.visible = false;
                        m_tiles[param1].itemCard_mc.locked_mc.visible = false;
                        m_tiles[param1].itemCard_mc.locked_mc.locked_tf.visible = false;
                        m_tiles[param1].itemCard_mc.levelInfo_tf.visible = false;
                     }
                  }
               }
               if(m_tiles[param1].itemCard_mc.strength_mc.visible == true)
               {
                  m_tiles[param1].itemCard_mc.strength_mc.visible = false;
               }
               if(m_tiles[param1].itemCard_mc.tierRating_mc)
               {
                  if(m_tiles[param1].itemCard_mc.tierRating_mc.visible == true)
                  {
                     m_tiles[param1].itemCard_mc.tierRating_mc.visible = false;
                  }
               }
               if(m_tiles[param1].itemCard_mc.doubleXP_mc)
               {
                  if(m_tiles[param1].itemCard_mc.doubleXP_mc.visible == true)
                  {
                     m_tiles[param1].itemCard_mc.doubleXP_mc.visible = false;
                  }
               }
               if(Boolean(m_tiles[param1].itemCard_mc.flame_mc) && Boolean(m_tiles[param1].itemCard_mc.flameRollover_mc))
               {
                  if(m_tiles[param1].itemCard_mc.flame_mc.visible == true)
                  {
                     m_tiles[param1].itemCard_mc.flame_mc.visible = false;
                  }
                  if(m_tiles[param1].itemCard_mc.flameRollover_mc.visible == true)
                  {
                     m_tiles[param1].itemCard_mc.flameRollover_mc.visible = false;
                  }
               }
               if(m_tiles[param1].itemCard_mc.lightning_mc)
               {
                  if(m_tiles[param1].itemCard_mc.lightning_mc.visible == true)
                  {
                     m_tiles[param1].itemCard_mc.lightning_mc.visible = false;
                  }
               }
               if(m_tiles[param1].itemCard_mc.whiteSabre_mc)
               {
                  if(m_tiles[param1].itemCard_mc.whiteSabre_mc.visible == true)
                  {
                     m_tiles[param1].itemCard_mc.whiteSabre_mc.visible = false;
                  }
                  if(m_tiles[param1].itemCard_mc.flameRollover_mc.visible == true)
                  {
                     m_tiles[param1].itemCard_mc.flameRollover_mc.visible = false;
                  }
               }
               if(m_tiles[param1].itemCard_mc.discount_tf.visible == true)
               {
                  m_tiles[param1].itemCard_mc.discount_tf.visible = false;
               }
               if(_loc3_.contractLocked)
               {
                  TextFieldUtil.processTextField(m_tiles[param1].itemCard_mc.count_mc3.count_tf,(_loc15_ + _loc16_ + _loc17_).toString());
                  if(!this.isLevelLocked(_loc3_) && _loc18_)
                  {
                     m_tiles[param1].itemCard_mc.buy_bt.visible = true;
                     m_tiles[param1].itemCard_mc.green_bt.visible = false;
                     m_tiles[param1].itemCard_mc.strength_mc.visible = true;
                     if(Boolean(m_tiles[param1].itemCard_mc.tierRating_mc) && this.tierSurfacingEnabled)
                     {
                        m_tiles[param1].itemCard_mc.tierRating_mc.visible = true;
                     }
                     if(Boolean(m_tiles[param1].itemCard_mc.doubleXP_mc) && Boolean(this.tierSurfacingEnabled) && _loc3_.isBlueDevil)
                     {
                        m_tiles[param1].itemCard_mc.doubleXP_mc.visible = true;
                     }
                     if(Boolean(m_tiles[param1].itemCard_mc.flame_mc && m_tiles[param1].itemCard_mc.flameRollover_mc) && Boolean(FlamingUnitManager.instance.flamingUnitsEnabled) && _loc3_.isFlamingUnit)
                     {
                        m_tiles[param1].itemCard_mc.limitedCard_mc.visible = false;
                        m_tiles[param1].itemCard_mc.limitedCard_mc_gray.visible = true;
                        m_tiles[param1].itemCard_mc.flame_mc.visible = true;
                        m_tiles[param1].itemCard_mc.flameRollover_mc.visible = true;
                     }
                     if(Boolean(m_tiles[param1].itemCard_mc.lightning_mc) && Boolean(_loc3_.isWhiteUnit) && WhiteUnitManager.instance.whiteUnitsEnabled)
                     {
                        m_tiles[param1].itemCard_mc.lightning_mc.visible = true;
                     }
                     if(Boolean(m_tiles[param1].itemCard_mc.whiteSabre_mc) && Boolean(WhiteUnitManager.instance.whiteUnitsEnabled) && _loc3_.isWhiteUnit)
                     {
                        m_tiles[param1].itemCard_mc.limitedCard_mc.visible = false;
                        m_tiles[param1].itemCard_mc.limitedCard_mc_gray.visible = true;
                        m_tiles[param1].itemCard_mc.whiteSabre_mc.visible = true;
                        m_tiles[param1].itemCard_mc.flameRollover_mc.visible = true;
                     }
                     if(LEUnitDiscountManager.instance.isLEDiscountExpEnabled() && LEUnitDiscountManager.instance.isOverrideLEItem(_loc12_.code) && _loc30_ > 0)
                     {
                        m_tiles[param1].itemCard_mc.discount_tf.visible = true;
                     }
                  }
                  else
                  {
                     m_tiles[param1].itemCard_mc.icon.filters = [];
                     m_tiles[param1].itemCard_mc.limitedCard_mc_gray.visible = true;
                     m_tiles[param1].itemCard_mc.count_mc3.visible = true;
                     m_tiles[param1].itemCard_mc.discount_tf.visible = false;
                  }
                  if(ZGlobal.player.hasPurchasedContract(_loc3_.code) || _loc3_.canBuyContract() && !this.isLevelLocked(_loc3_) && _loc18_)
                  {
                     m_tiles[param1].itemCard_mc.locked_mc.visible = false;
                     m_tiles[param1].itemCard_mc.icon.filters = [];
                  }
                  else
                  {
                     m_tiles[param1].itemCard_mc.icon.filters = [];
                     m_tiles[param1].itemCard_mc.limitedCard_mc_gray.visible = true;
                     m_tiles[param1].itemCard_mc.count_mc3.visible = true;
                  }
               }
            }
            if(!m_tiles[param1].itemCard_mc.limitedCard_mc_gray.visible)
            {
               if(_loc3_.isDecorationSource && DecorationsManager.instance.enabled)
               {
                  m_tiles[param1].itemCard_mc.card_mc_decco.visible = true;
                  _loc69_ = ZGlobal.gameSettings.getItemByCode(_loc3_.code,DecorationItem) as DecorationItem;
                  DecorationsManager.instance.initDecoUICardBackground(_loc69_,m_tiles[param1].itemCard_mc.card_mc_decco);
                  m_tiles[param1].itemCard_mc.card_mc_default.visible = false;
               }
               else
               {
                  m_tiles[param1].itemCard_mc.card_mc_default.visible = true;
               }
            }
            this.setUpNewUnit(m_data[param2 + param1],m_tiles[param1].itemCard_mc);
            m_tiles[param1].addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
            m_tiles[param1].addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
            if(_loc3_.type == GameItem.TYPE_BUILDMENUPROXY)
            {
               this.setCardClickCallback(m_tiles[param1],this.onBuyStarterPack);
            }
            else if(_loc3_.directPay)
            {
               this.setCardClickCallback(m_tiles[param1],this.onDirectPayClick);
            }
            else
            {
               this.setCardClickCallback(m_tiles[param1],this.onBuyClick);
               if(_loc3_.isExpansionItem && _loc4_ == ZGlobal.EXPERIMENT_EXPANSION_CREW_ENABLED)
               {
                  _loc70_ = (_loc3_ as ExpansionItem).isCrewableExpansion() && !this.canUseCrewableExpansion;
                  if((_loc70_) || this.getExpansionCount() >= ExpansionPriceExperimentManager.MAX_EXPANSIONS)
                  {
                     this.clearCardClickListeners(m_tiles[param1]);
                  }
                  else if((_loc3_ as ExpansionItem).isCrewableExpansion())
                  {
                     this.setCardClickCallback(m_tiles[param1],this.onCrewClick);
                  }
                  else if(this.crewExpansionReady())
                  {
                     this.clearCardClickListeners(m_tiles[param1]);
                  }
               }
            }
            this.postInitTile(m_tiles[param1].itemCard_mc,_loc3_,_loc5_);
            if(ZGlobal.player.isLightningDealSoldOutItem(_loc3_.code))
            {
               m_tiles[param1].itemCard_mc.buttonMode = false;
               if(m_buildButtons[param1])
               {
                  m_buildButtons[param1].disable();
                  m_buildButtons[param1].hide();
               }
            }
            else
            {
               m_tiles[param1].itemCard_mc.buttonMode = true;
            }
         }
      }
      
      private function resizeStrengthText(param1:MovieClip, param2:int) : void
      {
         if(param2 >= 1000)
         {
            param1.strengthBack_mc.width = this.strength_mc_width + EXT_STRENGTH_MC_WIDTH;
         }
         else
         {
            param1.strengthBack_mc.width = this.strength_mc_width;
         }
      }
      
      private function clearCardClickListeners(param1:MovieClip) : void
      {
         param1.removeEventListener(MouseEvent.CLICK,this.onDirectPayClick);
         param1.removeEventListener(MouseEvent.CLICK,this.onBuyStarterPack);
         param1.removeEventListener(MouseEvent.CLICK,this.onBuyClick);
         param1.removeEventListener(MouseEvent.CLICK,this.onCrewClick);
         param1.removeEventListener(MouseEvent.CLICK,this.onPlaceClick);
         param1.removeEventListener(MouseEvent.CLICK,this.onFinishClick);
      }
      
      private function setCardClickCallback(param1:MovieClip, param2:Function) : void
      {
         this.clearCardClickListeners(param1);
         if(param2 != null)
         {
            param1.addEventListener(MouseEvent.CLICK,param2,false,0,true);
         }
      }
      
      private function blurCard(param1:MovieClip) : void
      {
         var _loc2_:Array = [param1.itemCard_mc.resourceIcon_mc_0,param1.itemCard_mc.resourceIcon_mc_1,param1.itemCard_mc.resourceIcon_mc_2];
         var _loc3_:Array = [param1.itemCard_mc.resource_tf_0,param1.itemCard_mc.resource_tf_1,param1.itemCard_mc.resource_tf_2];
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc3_[_loc4_].visible = false;
            _loc2_[_loc4_].unload();
            _loc4_++;
         }
         param1.itemCard_mc.cost_tf.text = "";
         param1.itemCard_mc.locked_mc.visible = false;
         param1.itemCard_mc.levelInfo_tf.visible = false;
         param1.itemCard_mc.build_bt.visible = false;
         param1.itemCard_mc.buy_bt.visible = false;
         param1.itemCard_mc.green_bt.visible = false;
         param1.itemCard_mc.icon.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
      }
      
      private function isItemUnlockEligible(param1:GameItem) : Boolean
      {
         var _loc2_:BitArray = ZGlobal.player.checkGate(param1);
         var _loc3_:Boolean = _loc2_.isBitSet(Player.GATE_FAILURE_LEVEL);
         var _loc4_:Boolean = _loc2_.isBitSet(Player.GATE_FAILURE_QUEST);
         _loc2_.resetBit(Player.GATE_FAILURE_LEVEL);
         _loc2_.resetBit(Player.GATE_FAILURE_QUEST);
         _loc2_.resetBit(Player.GATE_FAILURE_CAMPAIGN);
         return (_loc3_ || _loc4_) && !_loc2_.anyBitSet() && param1.unlockCost > 0 && !ZGlobal.player.isItemUnlocked(param1.code);
      }
      
      private function isLevelLocked(param1:GameItem) : Boolean
      {
         var _loc2_:BitArray = ZGlobal.player.checkGate(param1);
         var _loc3_:Boolean = _loc2_.isBitSet(Player.GATE_FAILURE_LEVEL);
         _loc2_.resetBit(Player.GATE_FAILURE_LEVEL);
         return _loc3_;
      }
      
      private function isQuestLocked(param1:GameItem) : Boolean
      {
         var _loc2_:BitArray = ZGlobal.player.checkGate(param1);
         var _loc3_:Boolean = _loc2_.isBitSet(Player.GATE_FAILURE_QUEST);
         _loc2_.resetBit(Player.GATE_FAILURE_QUEST);
         return _loc3_;
      }
      
      private function shouldDisplayItem(param1:GameItem) : Boolean
      {
         var _loc3_:UnitItem = null;
         var _loc2_:BitArray = ZGlobal.player.checkGate(param1);
         if(_loc2_.isBitSet(Player.GATE_FAILURE_QUEST))
         {
            _loc3_ = ZGlobal.gameSettings.getItemByCode(param1.code,UnitItem) as UnitItem;
            if(Boolean(_loc3_) && _loc3_.hasUnitItemSubtype())
            {
               if(_loc3_.hasType(UnitItem.VILLAIN))
               {
                  return false;
               }
            }
         }
         _loc2_.resetBit(Player.GATE_FAILURE_LEVEL);
         _loc2_.resetBit(Player.GATE_FAILURE_QUEST);
         _loc2_.resetBit(Player.GATE_FAILURE_CAMPAIGN);
         return ZGlobal.player.isItemUnlocked(param1.code) && !_loc2_.anyBitSet();
      }
      
      private function itemIsNotUnlocked(param1:GameItem) : Boolean
      {
         var _loc2_:BitArray = ZGlobal.player.checkGate(param1);
         return (_loc2_.isBitSet(Player.GATE_FAILURE_LEVEL) || _loc2_.isBitSet(Player.GATE_FAILURE_QUEST)) && !ZGlobal.player.isItemUnlocked(param1.code);
      }
      
      override protected function preRemoveTiles() : void
      {
         var _loc1_:int = 0;
         if(m_iconLoaders != null)
         {
            _loc1_ = 0;
            while(_loc1_ < m_iconLoaders.length)
            {
               m_iconLoaders[_loc1_].destroy();
               _loc1_++;
            }
            m_iconLoaders = new Array();
         }
      }
      
      override protected function postRemoveTiles(param1:int) : void
      {
         m_tiles[param1].itemCard_mc.icon.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         m_tiles[param1].itemCard_mc.icon.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.clearCardClickListeners(m_tiles[param1]);
         super.postRemoveTiles(param1);
      }
      
      override protected function getNumSlots() : int
      {
         return NUM_SLOTS;
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         var _loc3_:String = null;
         var _loc5_:UnitItem = null;
         param1.currentTarget.itemCard_mc.highlightSelect.visible = true;
         var _loc2_:int = this.getIndexFromEvent(param1);
         var _loc4_:GameItem = m_data[_loc2_];
         if(_loc4_)
         {
            _loc3_ = _loc4_.tooltipType;
         }
         if(_loc3_ != GameItem.NO_TOOLTIP)
         {
            if(_loc3_ == GameItem.UNIT_TOOLTIP || _loc3_ == GameItem.SUPPORT_UNIT_TOOLTIP || _loc3_ == GameItem.TITAN_TOOLTIP)
            {
               _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc4_.code,UnitItem) as UnitItem;
               m_tooltip = new ItemTooltip(_loc3_,_loc5_,ItemTooltip.SOURCE_STORE);
            }
            else
            {
               m_tooltip = new ItemTooltip(_loc3_,_loc4_,ItemTooltip.SOURCE_STORE);
            }
            m_categoryWindow.selectionDialog_mc.addChild(m_tooltip);
            m_tooltip.x = param1.currentTarget.x + param1.currentTarget.width * 0.5;
            m_tooltip.y = param1.currentTarget.y;
            m_tooltip.alpha = 0;
            TweenLite.to(m_tooltip,0.5,{"alpha":1});
         }
      }
      
      protected function onRollOut(param1:MouseEvent) : void
      {
         param1.currentTarget.itemCard_mc.highlightSelect.visible = false;
         if(Boolean(m_tooltip) && Boolean(m_categoryWindow.selectionDialog_mc.contains(m_tooltip)))
         {
            m_categoryWindow.selectionDialog_mc.removeChild(m_tooltip);
            m_tooltip.destroy();
         }
         m_tooltip = null;
      }
      
      private function onBuyContractClick(param1:MouseEvent) : void
      {
         this.m_buyContract = true;
         this.onBuyClick(param1);
      }
      
      private function onBuyStarterPack(param1:MouseEvent) : void
      {
         var _loc2_:int = indexOfTileContaining(param1.target as DisplayObject);
         var _loc3_:int = _loc2_ + m_tileSet * NUM_SLOTS;
         var _loc4_:GameItem = m_data[_loc3_];
         var _loc5_:String = _loc4_.starterPackPaymentCode;
         PromoManager.instance.buyBuildMenuStarterPack(_loc5_);
         onCloseClick(param1);
      }
      
      private function onBuyClick(param1:MouseEvent) : void
      {
         if(Boolean(m_initData) && Boolean(m_initData.motd))
         {
            TutorialManager.instance.removeArrows();
         }
         var _loc2_:int = indexOfTileContaining(param1.target as DisplayObject);
         if(m_buildButtons[_loc2_] == null)
         {
            this.handleDisabledCardClick(param1);
            return;
         }
         var _loc3_:int = _loc2_ + m_tileSet * NUM_SLOTS;
         var _loc4_:GameItem = m_data[_loc3_];
         if((Boolean(_loc4_)) && ZGlobal.player.isLightningDealSoldOutItem(_loc4_.code))
         {
            return;
         }
         this.doBuyItem(_loc4_,param1);
      }
      
      private function onCrewClick(param1:MouseEvent) : void
      {
         var _loc2_:int = indexOfTileContaining(param1.target as DisplayObject);
         if(m_buildButtons[_loc2_] == null)
         {
            this.handleDisabledCardClick(param1);
            return;
         }
         var _loc3_:int = _loc2_ + m_tileSet * NUM_SLOTS;
         var _loc4_:GameItem = m_data[_loc3_];
         onCloseClick(param1);
         UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_EXPANSION_CASH_UNLOCK,0,_loc4_.name,MarketEvent.SOURCE_STORE));
      }
      
      private function showPartsDialog(param1:MouseEvent) : void
      {
         var _loc2_:int = indexOfTileContaining(param1.target as DisplayObject);
         var _loc3_:int = _loc2_ + m_tileSet * NUM_SLOTS;
         var _loc4_:GameItem = m_data[_loc3_];
         onCloseClick(null);
         UIDispatcher.instance.dispatchEvent(new WorldEvent(BuildingPartsDialogState.SHOW_BUILDING_PART_DIALOG + _loc4_.code));
      }
      
      private function onPlaceClick(param1:MouseEvent) : void
      {
         var _loc2_:int = indexOfTileContaining(param1.target as DisplayObject);
         var _loc3_:int = _loc2_ + m_tileSet * NUM_SLOTS;
         var _loc4_:GameItem = m_data[_loc3_];
         if(_loc4_.placeable)
         {
            GameModeManager.instance.addGameMode(new GMObjectPlace(_loc4_.name,MarketEvent.SOURCE_INVENTORY,true));
            onCloseClick(param1);
         }
      }
      
      private function onFinishClick(param1:MouseEvent) : void
      {
         var _loc7_:Object = null;
         var _loc8_:BuildingPartsGather = null;
         var _loc9_:Object = null;
         var _loc10_:int = 0;
         var _loc11_:GameDataComponent = null;
         var _loc12_:String = null;
         var _loc13_:Object = null;
         var _loc14_:String = null;
         var _loc15_:GenericPopup2B = null;
         var _loc16_:IEntity = null;
         var _loc17_:BuildingFSMComponent = null;
         var _loc2_:int = indexOfTileContaining(param1.target as DisplayObject);
         var _loc3_:int = _loc2_ + m_tileSet * NUM_SLOTS;
         var _loc4_:GameItem = m_data[_loc3_];
         var _loc5_:String = _loc4_.code;
         var _loc6_:Dictionary = WorldObjectManager.instance.getObjectsBySubType(_loc4_.type,_loc4_.subType);
         for each(_loc7_ in _loc6_)
         {
            _loc11_ = GameDataComponent(_loc7_.lookupComponentByType(GameDataComponent));
            if((Boolean(_loc11_)) && _loc11_.gameData.code == _loc5_)
            {
               break;
            }
         }
         _loc8_ = new BuildingPartsGather(new EventDispatcher(),_loc4_.code,null,_loc7_ as IEntity);
         _loc9_ = _loc8_.getRemainingPartsData(ZGlobal.gameSettings.getItemByCode(_loc5_,PartsBuildingItem) as PartsBuildingItem);
         _loc10_ = int(_loc9_.cash);
         if(ZGlobal.player.canBuyCash(_loc10_,true))
         {
            if(ZGlobal.gameSettings.showConfirmationPopup(_loc10_))
            {
               _loc12_ = ZGameUtils.ZlocT("Dialogs","BuildingPartConfirmPartBuyTitle");
               _loc13_ = ZGameUtils.CashTokenReplacements(_loc10_);
               _loc14_ = ZGameUtils.ZlocT("Dialogs","BuildingPartConfirmAllPartsBuyMessage",_loc13_);
               _loc15_ = GenericPopup2B.NewYesNo(_loc14_,_loc12_,this.finishForCashConfirmed);
               _loc15_.userData = {
                  "partItems":_loc9_.remaining,
                  "bpg":_loc8_,
                  "entity":_loc7_ as IEntity,
                  "item":_loc4_
               };
               PopupManager.instance.push(_loc15_);
            }
            else
            {
               _loc8_.buyAllParts(_loc9_.remaining,false);
               _loc16_ = _loc7_ as IEntity;
               TransactionManager.addTransaction(new TFinishBuildable(_loc16_));
               _loc17_ = _loc16_.lookupComponentByType(BuildingFSMComponent) as BuildingFSMComponent;
               if(_loc17_)
               {
                  _loc17_.stateMachine.setCurrentState((_loc17_.stateMachine as BehaviorStateMachine).builtState);
                  WorldObjectManager.instance.addObjectToBuiltDictionary(_loc4_.code);
               }
            }
            return;
         }
         onCloseClick(param1);
      }
      
      private function finishForCashConfirmed(param1:GenericPopupEvent) : void
      {
         var _loc2_:IEntity = null;
         var _loc3_:GameItem = null;
         var _loc4_:BuildingFSMComponent = null;
         if(param1.button == GenericPopup.YES)
         {
            param1.userData.bpg.buyAllParts(param1.userData.partItems,false);
            _loc2_ = param1.userData.entity as IEntity;
            _loc3_ = param1.userData.item as GameItem;
            TransactionManager.addTransaction(new TFinishBuildable(_loc2_));
            _loc4_ = _loc2_.lookupComponentByType(BuildingFSMComponent) as BuildingFSMComponent;
            if(_loc4_)
            {
               _loc4_.stateMachine.setCurrentState((_loc4_.stateMachine as BehaviorStateMachine).builtState);
               WorldObjectManager.instance.addObjectToBuiltDictionary(_loc3_.code);
            }
         }
      }
      
      private function onCrewExpansionBuy(param1:MarketEvent) : void
      {
         if(param1.referenceItem.code == ExpansionItem.CREWABLE_EXPANSION_ID)
         {
            refreshLayout();
            this.onPostPurchase();
         }
      }
      
      private function onDirectPayClick(param1:MouseEvent) : void
      {
         if(Boolean(m_initData) && Boolean(m_initData.motd))
         {
            TutorialManager.instance.removeArrows();
         }
         var _loc2_:int = indexOfTileContaining(param1.target as DisplayObject);
         if(m_buildButtons[_loc2_] == null)
         {
            this.handleDisabledCardClick(param1);
            return;
         }
         var _loc3_:int = _loc2_ + m_tileSet * NUM_SLOTS;
         var _loc4_:GameItem = m_data[_loc3_];
         m_tiles[_loc2_].removeEventListener(MouseEvent.CLICK,this.onDirectPayClick);
         m_tiles[_loc2_].itemCard_mc.icon.removeEventListener(MouseEvent.CLICK,this.onDirectPayClick);
         m_tiles[_loc2_].directPayZGameButton.disable();
         PromoManager.instance.addEventListener(PromoManager.EVENT_IN_APP_PURCHASE_COMPLETE,this.onPlayerUpdated);
         this.doDirectPayItem(_loc4_,param1);
      }
      
      private function doBuyItem(param1:GameItem, param2:MouseEvent = null) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:Object = null;
         var _loc8_:LocalizationObjectToken = null;
         var _loc9_:String = null;
         var _loc10_:Array = null;
         if(param1)
         {
            _loc3_ = this.isItemUnlockEligible(param1);
            _loc5_ = 0;
            if(_loc3_)
            {
               _loc5_ = param1.unlockCost;
            }
            else if(this.m_buyContract && param1.contractLocked && param1.canBuyContract())
            {
               _loc5_ = param1.contractCost;
            }
            else
            {
               _loc5_ = param1.cash;
            }
            if(param1.usesCash() || _loc5_ > 0)
            {
               _loc4_ = ZGlobal.player.canBuyCash(_loc5_,true);
            }
            else
            {
               _loc4_ = ZGlobal.player.canBuy(param1,true);
            }
            if(_loc4_)
            {
               if(!this.tryBuyPlayerEnergies(param1))
               {
                  _loc4_ = false;
               }
            }
            if(_loc4_ && (param1.usesCash() || this.itemIsNotUnlocked(param1) || param1.contractLocked && param1.canBuyContract()))
            {
               if(ZGlobal.gameSettings.showConfirmationPopup(_loc5_))
               {
                  this.m_confirmationItem = param1;
                  _loc7_ = ZGameUtils.CashTokenReplacements(_loc5_);
                  _loc8_ = this.m_confirmationItem.getSentenceNameLocalizationObject("singular",true);
                  if(_loc8_)
                  {
                     _loc7_.item = _loc8_;
                     if(_loc3_)
                     {
                        _loc6_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashUnlockMessage_Object",_loc7_);
                     }
                     else if(this.m_buyContract && param1.contractLocked && param1.canBuyContract())
                     {
                        _loc6_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashUnlockContractMessage_Object",_loc7_);
                     }
                     else
                     {
                        _loc6_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseMessage_Object",_loc7_);
                     }
                  }
                  else
                  {
                     _loc7_.item = this.m_confirmationItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
                     if(_loc3_)
                     {
                        _loc6_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashUnlockMessage",_loc7_);
                     }
                     else if(this.m_buyContract && param1.contractLocked && param1.canBuyContract())
                     {
                        _loc6_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashUnlockContractMessage",_loc7_);
                     }
                     else
                     {
                        _loc6_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseMessage",_loc7_);
                     }
                  }
                  _loc9_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle");
                  _loc10_ = new Array("EmpirePointsConfirm","","","");
                  PopupManager.instance.push(GenericPopup2B.NewYesNo(_loc6_,_loc9_,this.onCashBuyPopupClose,_loc10_));
                  return;
               }
            }
            if(_loc4_ == true)
            {
               this.buyItem(param1);
               this.onPostPurchase(param2);
            }
            else
            {
               this.m_buyContract = false;
            }
         }
      }
      
      private function doDirectPayItem(param1:GameItem, param2:MouseEvent = null) : void
      {
         var _loc3_:String = param1.directPayCode;
         var _loc4_:PromoData = new PromoData();
         var _loc5_:String = param1.directPayPhylum;
         _loc4_.popup = null;
         _loc4_.trackingConfirmPromoKingdom = null;
         _loc4_.shareFeedFunction = null;
         _loc4_.shareFeedParams = null;
         _loc4_.congratsPopup = param1.directPayCongratsPopup;
         PromoManager.instance.dispatchEvent(new WorldEvent(PromoManager.EVENT_DIALOG_ACCEPT,{
            "packageType":_loc3_,
            "phylum":_loc5_,
            "promoData":_loc4_
         }));
      }
      
      private function tryBuyPlayerEnergies(param1:GameItem) : Boolean
      {
         var _loc4_:GenericPopup = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(!ZGlobal.player.canAddItemToInventory(param1))
         {
            if(param1.energyYield > 0)
            {
               _loc2_ = "NoAcceptEnergy_Title";
               _loc3_ = "NoAcceptEnergy_Message";
            }
            else if(param1.manaYield > 0)
            {
               _loc2_ = "NoAcceptMana_Title";
               _loc3_ = "NoAcceptMana_Message";
            }
         }
         if(_loc2_)
         {
            _loc4_ = new GenericPopup1B(ZGameUtils.ZlocT("Dialogs",_loc3_),ZGameUtils.ZlocT("Dialogs",_loc2_),GenericPopup.TYPE_OK,null);
            _loc4_.setAdvisorMood(GenericPopup.MOOD_DEFAULT);
            PopupManager.instance.push(_loc4_);
            return false;
         }
         return true;
      }
      
      private function onPostPurchase(param1:MouseEvent = null) : void
      {
         if(this.m_persistPostPurchase)
         {
            refreshLayout();
            UI.instance.setupForItemPurchase();
         }
         else
         {
            onCloseClick(param1);
         }
      }
      
      private function onBuyItemEvent(param1:WorldEvent) : void
      {
         var _loc2_:GameItem = param1.eventData as GameItem;
         this.doBuyItem(_loc2_);
      }
      
      private function handleDisabledCardClick(param1:MouseEvent) : void
      {
         var _loc5_:BitArray = null;
         var _loc2_:int = indexOfTileContaining(param1.target as DisplayObject);
         var _loc3_:int = _loc2_ + m_tileSet * NUM_SLOTS;
         var _loc4_:GameItem = m_data[_loc3_];
         if(_loc4_)
         {
            _loc5_ = ZGlobal.player.checkGate(_loc4_);
            if(_loc5_.isBitSet(Player.GATE_FAILURE_EXCEEDS_POPULATION))
            {
               PopupManager.instance.push(new RequirementsPopup(new RequirementsPopupInfoPopCap()));
            }
         }
      }
      
      private function buyItem(param1:GameItem) : void
      {
         var _loc2_:Object = null;
         if(this.itemIsNotUnlocked(param1) && param1.canBeUnlocked())
         {
            this.m_persistPostPurchase = true;
            UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_UNLOCK,0,param1.name,MarketEvent.SOURCE_STORE));
         }
         else if(this.m_buyContract && param1.contractLocked && param1.canBuyContract())
         {
            this.m_persistPostPurchase = false;
            UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_UNLOCK_CONTRACT,0,param1.name,MarketEvent.SOURCE_STORE));
         }
         else
         {
            this.m_persistPostPurchase = false;
            _loc2_ = null;
            _loc2_ = new Object();
            _loc2_.screen = "build_menu";
            if(m_initData)
            {
               _loc2_.genus = m_initData.genus;
            }
            switch(param1.type)
            {
               case GameItem.TYPE_EXPANSION:
                  UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY,MarketEvent.EXPAND_ISLAND,param1.code,MarketEvent.SOURCE_STORE));
                  break;
               case GameItem.TYPE_BUILDING:
                  UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY,MarketEvent.BUILDING,param1.name,MarketEvent.SOURCE_STORE,_loc2_));
                  break;
               case GameItem.TYPE_ROAD:
                  UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY,MarketEvent.ROADS,param1.name,MarketEvent.SOURCE_STORE));
                  break;
               case GameItem.TYPE_CONSUMABLE:
                  UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY,MarketEvent.CONSUMABLE,param1.name,MarketEvent.SOURCE_STORE,_loc2_,ZGlobal.gameSettings.getItemClass(param1.type,param1.subType)));
                  break;
               case GameItem.TYPE_BUILDABLE:
                  UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY,MarketEvent.BUILDABLE,param1.name,MarketEvent.SOURCE_STORE,_loc2_));
                  break;
               case GameItem.TYPE_RESOURCE:
                  UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY,MarketEvent.RESOURCE,param1.name,MarketEvent.SOURCE_STORE,_loc2_));
            }
         }
         this.m_buyContract = false;
      }
      
      protected function onCashBuyPopupClose(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            this.buyItem(this.m_confirmationItem);
            this.m_confirmationItem = null;
            this.onPostPurchase();
         }
         this.m_buyContract = false;
      }
      
      private function getIndexFromEvent(param1:MouseEvent) : int
      {
         var _loc4_:String = null;
         var _loc2_:int = 0;
         if(param1 != null)
         {
            _loc4_ = String(param1.currentTarget.name).replace(/card_mc_/,"");
            _loc2_ = int(_loc4_);
         }
         return int(_loc2_ + m_tileSet * NUM_SLOTS);
      }
      
      protected function getPageHistory(param1:int) : int
      {
         var _loc2_:Boolean = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REMEMBER_LAST_BUILD_MENU_PAGE) == ExperimentsManager.VARIANT_VALUE_REMEMBER_LAST_BUILD_MENU_PAGE_ON;
         var _loc3_:int = 0;
         if(_loc2_ && Boolean(m_pageHistory["page_" + param1]))
         {
            _loc3_ = int(m_pageHistory["page_" + param1]);
         }
         return _loc3_;
      }
      
      protected function savePageHistory() : void
      {
         var _loc1_:Boolean = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REMEMBER_LAST_BUILD_MENU_PAGE) == ExperimentsManager.VARIANT_VALUE_REMEMBER_LAST_BUILD_MENU_PAGE_ON;
         if(_loc1_)
         {
            m_pageHistory["page_" + m_categoryIndex] = m_tileSet;
         }
         else
         {
            m_pageHistory["page_" + m_categoryIndex] = 0;
         }
      }
      
      protected function resetPageHistory() : void
      {
         var _loc1_:* = undefined;
         for(_loc1_ in m_pageHistory)
         {
            m_pageHistory[_loc1_] = 0;
         }
      }
      
      private function getCardType(param1:GameItem) : int
      {
         var _loc2_:UnitItem = ZGlobal.gameSettings.getItemByCode(param1.code,UnitItem) as UnitItem;
         if(ZGlobal.player.isLightingDealItem(param1.code))
         {
            return CARDTYPE_LIGHTNINGDEAL;
         }
         if(param1.type == GameItem.TYPE_BUILDMENUPROXY)
         {
            return CARDTYPE_BUILDMENU_PROXY;
         }
         if(_loc2_.hasType(UnitItem.MEGA_UNIT))
         {
            return CARDTYPE_MECHLEUNITS;
         }
         return CARDTYPE_NORMAL;
      }
      
      private function shouldDisplayFirst(param1:GameItem) : Object
      {
         ++this.m_count;
         var _loc2_:int = ZGameTimeUtil.instance.getDateStatus(null,param1.xml);
         if(this.m_shopVariant > 2 && this.m_newShop)
         {
            return {
               "display":true,
               "first":false
            };
         }
         if(_loc2_ != ZGameTimeUtil.DATE_STATUS_NONE)
         {
            if(_loc2_ == ZGameTimeUtil.DATE_STATUS_ACTIVE)
            {
               return {
                  "display":true,
                  "first":true
               };
            }
            if(param1.contractLocked && ZGlobal.player.hasPurchasedContract(param1.code))
            {
               return {
                  "display":true,
                  "first":true
               };
            }
            return {
               "display":false,
               "first":true
            };
         }
         return {
            "display":true,
            "first":false
         };
      }
      
      private function getStarterPackItemStrength(param1:GameItem) : uint
      {
         var _loc3_:GameItem = null;
         var _loc2_:XML = this.getStarterPackSurfacingInfo(param1);
         if(_loc2_.@unitCode != undefined)
         {
            _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc2_.@unitCode.toString(),GameItem) as GameItem;
            if(Boolean(_loc3_) && _loc3_.xml.unit != undefined)
            {
               _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc2_.@unitCode.toString(),UnitItem) as UnitItem;
               return (_loc3_ as UnitItem).getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(_loc3_.code));
            }
         }
         return 0;
      }
      
      private function getStarterPackProxyCost(param1:GameItem) : int
      {
         var _loc2_:XML = this.getStarterPackSurfacingInfo(param1);
         if(_loc2_.@cost != undefined)
         {
            return int(_loc2_.@cost);
         }
         return 0;
      }
      
      private function updateLDClaimFeedback(param1:MovieClip) : void
      {
         var _loc2_:int = ZGlobal.player.lightningDealFractionClaimed;
         var _loc3_:String = ZGlobal.player.getFriendlyClaimProgressString(_loc2_);
         TextFieldUtil.processTextField(param1.ld_claim_mc.cliam_tf,_loc3_);
         var _loc4_:int = LD_CLAIMBAR_WIDTH * _loc2_ / 100;
         param1.ld_claim_mc.loadingBar_mc.width = _loc4_;
      }
      
      private function get tierSurfacingEnabled() : Boolean
      {
         if(!TierSurfacingManager.instance.tierSurfacingEnabled)
         {
            return false;
         }
         return true;
      }
      
      private function isBlackMarket(param1:GameItem) : Boolean
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_BLACKMARKET_MASTER) == ExperimentsManager.EXPERIMENT_BLACKMARKET_ENABLED_VARIANT && param1.className == "BlackMarket")
         {
            return true;
         }
         return false;
      }
   }
}

