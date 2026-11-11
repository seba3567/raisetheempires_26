package displays.screens.pickUnitsScreen
{
   import core.ZGlobal;
   import core.gamemode.prebattle.PreBattleUI;
   import core.gameobjects.UnitItem;
   import core.managers.EspionageHQManager;
   import core.managers.InventoryList;
   import core.managers.domination.DominationModeManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import core.managers.warehouseManager.WarehouseUnitManager;
   import core.managers.worldUnitManager.WorldUnitManager;
   import dispatchers.UIDispatcher;
   import displays.screens.gridScreen.GridSlot;
   import displays.screens.mechBattleSetup.MechBattleSetup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import sound.ButtonSound;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class StackedUnitsGrid extends UnitsGrid
   {
      
      public static const UNIT_CARD_SELECTED:String = "unitCardSelected";
      
      public static const UNIT_CARD_ADDED:String = "unitCardAdded";
      
      protected var m_dispatcher:EventDispatcher = null;
      
      protected var m_availableUnits:Array = null;
      
      protected var m_ownsValidMechItems:Boolean = false;
      
      public function StackedUnitsGrid(param1:MovieClip, param2:SWFResource, param3:EventDispatcher, param4:String, param5:String, param6:Array, param7:int, param8:Array, param9:int = 0)
      {
         this.m_dispatcher = param3;
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9);
      }
      
      override protected function init(param1:MovieClip, param2:SWFResource) : void
      {
         setDimensions(4,1);
         load(param1,param2);
         buttonSounds.addButton(screen.arrowRtSingle_bt,ButtonSound.DEFAULT);
         buttonSounds.addButton(screen.arrowLtSingle_bt,ButtonSound.DEFAULT);
         UIDispatcher.instance.addEventListener(UnitsPurchaseDialog.UNIT_PURCHASED,this.onUnitPurchased,false,0,true);
         this.startListening();
      }
      
      override public function dispose() : void
      {
         UIDispatcher.instance.removeEventListener(UnitsPurchaseDialog.UNIT_PURCHASED,this.onUnitPurchased);
         this.stopListening();
         super.dispose();
      }
      
      public function startListening() : void
      {
         UIDispatcher.instance.addEventListener(GridSlot.SELECTED,this.onSlotSelected,false,0,true);
         screen.arrowRtSingle_bt.addEventListener(MouseEvent.CLICK,this.onSingleRightClick,false,0,true);
         screen.arrowLtSingle_bt.addEventListener(MouseEvent.CLICK,this.onSingleLeftClick,false,0,true);
      }
      
      public function stopListening() : void
      {
         UIDispatcher.instance.removeEventListener(GridSlot.SELECTED,this.onSlotSelected);
         screen.arrowRtSingle_bt.removeEventListener(MouseEvent.CLICK,this.onSingleRightClick);
         screen.arrowLtSingle_bt.removeEventListener(MouseEvent.CLICK,this.onSingleLeftClick);
      }
      
      override protected function enableLeftButtons(param1:Boolean) : void
      {
         super.enableLeftButtons(param1);
         ZGameUtils.setButtonEnabled(m_screen.arrowLtSingle_bt,this.onSingleLeftClick,param1);
      }
      
      override protected function enableRightButtons(param1:Boolean) : void
      {
         super.enableRightButtons(param1);
         ZGameUtils.setButtonEnabled(m_screen.arrowRtSingle_bt,this.onSingleRightClick,param1);
      }
      
      public function get numUnitsLength() : int
      {
         return super.numCards;
      }
      
      override public function get numCards() : int
      {
         return this.m_availableUnits.length;
      }
      
      public function deductUnit(param1:UnitItem) : void
      {
         var _loc2_:GridSlot = null;
         var _loc3_:StackedUnitsSlot = null;
         for each(_loc2_ in m_cards)
         {
            _loc3_ = _loc2_ as StackedUnitsSlot;
            if(Boolean(_loc3_) && _loc3_.getUnitInfoForSlot().unitItem.code == param1.code)
            {
               if(DominationModeManager.instance.isInSetupFleetEditMode())
               {
                  DominationModeManager.instance.updateSetupFleetStrength(param1.getUpgradedStrength());
               }
               if(_loc3_.updateQuantityUI(-1,param1.code))
               {
                  this.updateCards();
               }
               break;
            }
         }
      }
      
      public function disableStolenCard(param1:UnitItem) : void
      {
         var _loc2_:GridSlot = null;
         var _loc3_:StackedUnitsSlot = null;
         for each(_loc2_ in m_cards)
         {
            _loc3_ = _loc2_ as StackedUnitsSlot;
            if(Boolean(_loc3_) && _loc3_.getUnitInfoForSlot().unitItem.code == param1.code)
            {
               _loc3_.disableStolenUnitUI();
               this.updateCards();
               break;
            }
         }
      }
      
      public function enableStolenCard(param1:UnitItem) : void
      {
         var _loc2_:GridSlot = null;
         var _loc3_:StackedUnitsSlot = null;
         for each(_loc2_ in m_cards)
         {
            _loc3_ = _loc2_ as StackedUnitsSlot;
            if(Boolean(_loc3_) && _loc3_.getUnitInfoForSlot().unitItem.code == param1.code)
            {
               _loc3_.enableStolenUnitUI();
               this.updateCards();
               break;
            }
         }
      }
      
      public function returnUnit(param1:UnitItem, param2:Boolean = false) : void
      {
         var _loc4_:GridSlot = null;
         var _loc5_:Boolean = false;
         var _loc6_:StackedUnitsSlot = null;
         var _loc7_:Boolean = false;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:StackedUnitInfo = null;
         var _loc12_:StackedUnitInfo = null;
         var _loc3_:Boolean = false;
         for each(_loc4_ in m_cards)
         {
            _loc6_ = _loc4_ as StackedUnitsSlot;
            if((Boolean(_loc6_)) && _loc6_.getUnitInfoForSlot().unitItem.code == param1.code)
            {
               _loc6_.updateQuantityUI(1,param1.code);
               _loc3_ = true;
               break;
            }
         }
         if(!_loc3_)
         {
            _loc7_ = false;
            _loc8_ = 0;
            _loc9_ = -1;
            _loc10_ = param1.getUpgradedStrength();
            for each(_loc11_ in m_units)
            {
               if(_loc11_.unitItem.templateFor(param1.code))
               {
                  _loc11_.incrementQuantity(1,param1.code);
                  _loc7_ = true;
                  _loc5_ = true;
                  break;
               }
               if(_loc9_ < 0)
               {
                  if(_loc11_.unitItem.getUpgradedStrength() <= _loc10_)
                  {
                     _loc9_ = _loc8_;
                  }
                  _loc8_++;
               }
            }
            if(!_loc7_ && DominationModeManager.instance.isInSetupFleetEditMode())
            {
               _loc12_ = new StackedUnitInfo(param1);
               _loc12_.incrementQuantity(1,param1.code);
               if(_loc9_ >= 0 && _loc9_ < m_units.length)
               {
                  m_units.splice(_loc9_,0,_loc12_);
               }
               else
               {
                  m_units.push(_loc12_);
               }
               _loc5_ = true;
            }
         }
         if(!_loc3_ || DominationModeManager.instance.isInSetupFleetEditMode() && !param2)
         {
            if(DominationModeManager.instance.isInSetupFleetEditMode() && !param2)
            {
               DominationModeManager.instance.updateSetupFleetStrength(-param1.getUpgradedStrength());
            }
            if(_loc5_)
            {
               this.updateCards();
               this.m_dispatcher.dispatchEvent(new Event(UNIT_CARD_ADDED));
            }
         }
      }
      
      override protected function createItemList() : void
      {
         var _loc5_:UnitItem = null;
         var _loc6_:String = null;
         var _loc7_:UnitItem = null;
         var _loc8_:int = 0;
         var _loc9_:* = 0;
         var _loc10_:int = 0;
         m_units = new Array();
         var _loc1_:Array = InventoryList.instance.itemsByEffectiveness;
         var _loc2_:Dictionary = WorldUnitManager.instance.availableUnits;
         var _loc3_:Dictionary = WarehouseUnitManager.instance.getAvailableUnits();
         if(EspionageHQManager.instance.shouldShowCard())
         {
            _loc5_ = ZGlobal.gameSettings.getItemByCode(EspionageHQManager.instance.stolenUnit,UnitItem) as UnitItem;
            if((Boolean(_loc5_)) && Boolean(_loc5_.type == m_type) && _loc5_.subType == m_subtype)
            {
               this.addUnitWithAmount(_loc5_,0);
            }
         }
         var _loc4_:* = int(_loc1_.length);
         while(_loc4_--)
         {
            _loc6_ = _loc1_[_loc4_];
            _loc7_ = ZGlobal.gameSettings.getItemByCode(_loc6_,UnitItem) as UnitItem;
            if(_loc7_.type == m_type && _loc7_.subType == m_subtype)
            {
               _loc8_ = int(_loc2_[_loc6_]);
               if(_loc8_ > 0)
               {
                  this.addUnitWithAmount(_loc7_,_loc8_);
               }
               _loc9_ = ZGlobal.player.getNumberOfInventoryItems(_loc6_);
               if((DominationModeManager.instance.isInDefenseForceEditMode() || SurvivalModeManager.instance.isInSurvivalBattle()) && EspionageHQManager.instance.stolenUnit == _loc6_ && _loc9_ >= 1)
               {
                  _loc9_--;
               }
               if(_loc9_ > 0)
               {
                  this.addUnitWithAmount(_loc7_,_loc9_);
               }
               _loc10_ = int(_loc3_[_loc6_]);
               if(_loc10_ > 0)
               {
                  this.addUnitWithAmount(_loc7_,_loc10_);
               }
            }
         }
         this.createAvailableItemList();
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         var _loc6_:Boolean = DominationModeManager.instance.isInSetupFleetEditMode();
         var _loc7_:Class = _loc6_ ? StackedUnitsSlotDominationMode : StackedUnitsSlot;
         return new _loc7_(param1,param2,screen,param3,param4,this.m_availableUnits[param5],param5,this.getMultFactor());
      }
      
      override protected function getMultFactor() : Number
      {
         return 1;
      }
      
      override protected function specialCardIsAtFirstSlot() : Boolean
      {
         if(MechBattleSetup.isEnabled())
         {
            return !DominationModeManager.instance.isInDefenseForceEditMode() && this.m_ownsValidMechItems && !PreBattleUI.TITAN_MODE;
         }
         return false;
      }
      
      override protected function hasSpecialCard() : Boolean
      {
         return this.specialCardIsAtFirstSlot();
      }
      
      override protected function createSpecialCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int) : GridSlot
      {
         return new TitanEntrySlot(param1,param2,screen,param3,param4,this.getMultFactor());
      }
      
      override protected function resetAnchorPosition() : void
      {
         setAnchor(screen.fixedAnchor_mc.x,screen.fixedAnchor_mc.y);
      }
      
      override protected function fillOutHeader() : void
      {
      }
      
      override public function updateCards() : void
      {
         this.createAvailableItemList();
         super.updateCards();
      }
      
      private function onSingleRightClick(param1:MouseEvent) : void
      {
         slide(-1);
      }
      
      private function onSingleLeftClick(param1:MouseEvent) : void
      {
         slide(1);
      }
      
      private function createAvailableItemList() : void
      {
         var _loc1_:StackedUnitInfo = null;
         this.m_availableUnits = new Array();
         for each(_loc1_ in m_units)
         {
            if(this.validateItem(_loc1_))
            {
               this.m_availableUnits.push(_loc1_);
            }
         }
      }
      
      private function validateItem(param1:StackedUnitInfo) : Boolean
      {
         if(param1.quantity <= 0)
         {
            return false;
         }
         if(PreBattleUI.TITAN_MODE != param1.unitItem.hasType(UnitItem.MEGA_UNIT))
         {
            return false;
         }
         if(PreBattleUI.TITAN_MODE)
         {
            if(!(PreBattleUI.getPreBattleUI() as PreBattleUI).titanUI.validateItem(param1.unitItem))
            {
               return false;
            }
            if(DominationModeManager.instance.isInDefenseForceEditMode())
            {
               return false;
            }
         }
         return true;
      }
      
      private function findStackedUnit(param1:String) : StackedUnitInfo
      {
         var _loc2_:StackedUnitInfo = null;
         for each(_loc2_ in m_units)
         {
            if(_loc2_.unitItem.code == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function addUnitWithAmount(param1:UnitItem, param2:int) : void
      {
         var _loc3_:String = param1.code;
         var _loc4_:StackedUnitInfo = this.findStackedUnit(_loc3_);
         var _loc5_:Boolean = MechBattleSetup.isEnabled();
         if(_loc4_ == null)
         {
            _loc4_ = new StackedUnitInfo(param1);
            if(_loc5_ && param2 > 0 && param1.hasType(UnitItem.MEGA_UNIT_CONTROLLER))
            {
               this.m_ownsValidMechItems = true;
            }
            m_units.push(_loc4_);
         }
         _loc4_.incrementQuantity(param2,_loc3_);
      }
      
      protected function onSlotSelected(param1:WorldEvent) : void
      {
         var _loc2_:StackedUnitsSlot = StackedUnitsSlot(param1.eventData);
         this.m_dispatcher.dispatchEvent(new WorldEvent(UNIT_CARD_SELECTED,_loc2_.getUnitInfoForSlot()));
      }
      
      protected function onUnitPurchased(param1:WorldEvent) : void
      {
         var _loc3_:StackedUnitInfo = null;
         var _loc4_:GridSlot = null;
         var _loc2_:UnitItem = UnitItem(param1.eventData);
         if(this.findStackedUnit(_loc2_.code))
         {
            this.returnUnit(_loc2_,true);
         }
         else
         {
            this.addUnitWithAmount(_loc2_,1);
            this.createAvailableItemList();
            _loc3_ = new StackedUnitInfo(_loc2_,1);
            if(this.validateItem(_loc3_))
            {
               if(Boolean(m_cards.length != 0) && Boolean(m_cards[0].hasOwnProperty("titanExist")) && m_cards[0].titanExist == 1)
               {
                  _loc4_ = this.createCard(m_resource,m_screen.anchor_mc,m_cards.length,0,m_cards.length - 1);
               }
               else
               {
                  _loc4_ = this.createCard(m_resource,m_screen.anchor_mc,m_cards.length,0,m_cards.length);
               }
               if(_loc4_ != null)
               {
                  this.m_dispatcher.dispatchEvent(new Event(UNIT_CARD_ADDED));
                  _loc4_.slot.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
                  _loc4_.slot.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
                  m_slotWidth = _loc4_.width * this.getMultFactor();
                  m_slotHeight = _loc4_.height * this.getMultFactor();
                  m_cards.push(_loc4_);
                  this.fixArrows(0);
               }
            }
         }
      }
      
      override protected function fixArrows(param1:int) : void
      {
         if(m_clickPosition == 0)
         {
            this.enableLeftButtons(false);
         }
         else
         {
            this.enableLeftButtons(true);
         }
         var _loc2_:int = m_clickPosition * (m_isVerticalGrid ? m_width : m_height);
         if(m_cards.length + _loc2_ > m_width * m_height)
         {
            this.enableRightButtons(true);
         }
         else
         {
            this.enableRightButtons(false);
         }
      }
   }
}

