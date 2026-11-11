package displays.screens.pickConsumableScreen
{
   import core.ZGlobal;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.Fleet;
   import core.gameobjects.GameItem;
   import core.gameobjects.IslandItem;
   import core.managers.ExperimentsManager;
   import core.managers.InventoryList;
   import core.managers.tutorialManager.TutorialManager;
   import core.player.Player;
   import core.worlds.strategicWorld.StrategicMap;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import utils.BitArray;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class CombatConsumablesGrid extends ConsumablesGrid
   {
      
      public function CombatConsumablesGrid(param1:MovieClip, param2:SWFResource, param3:EventDispatcher)
      {
         super(param1,param2,param3,null,1,null);
      }
      
      override protected function init(param1:MovieClip, param2:SWFResource) : void
      {
         setDimensions(6,1);
         this.load(param1,param2);
      }
      
      override protected function load(param1:MovieClip, param2:SWFResource) : void
      {
         super.load(param1,param2);
         screen.arrowRtSingle_bt.addEventListener(MouseEvent.CLICK,this.onSingleRightClick,false,0,true);
         screen.arrowLtSingle_bt.addEventListener(MouseEvent.CLICK,this.onSingleLeftClick,false,0,true);
         buttonSounds.addButton(screen.arrowRtSingle_bt,ButtonSound.DEFAULT);
         buttonSounds.addButton(screen.arrowLtSingle_bt,ButtonSound.DEFAULT);
      }
      
      override protected function close() : void
      {
         screen.arrowRtSingle_bt.removeEventListener(MouseEvent.CLICK,this.onSingleRightClick);
         screen.arrowLtSingle_bt.removeEventListener(MouseEvent.CLICK,this.onSingleLeftClick);
         super.close();
      }
      
      override protected function createItemList() : void
      {
         if(this.addItemsFromCurrentCampaignFleet())
         {
            return;
         }
         this.addItems(InventoryList.instance.items);
      }
      
      private function addItemsFromCurrentCampaignFleet() : Boolean
      {
         var _loc1_:StrategicMap = null;
         var _loc2_:Fleet = null;
         if(ZGlobal.player.campaign.currentMapName)
         {
            _loc1_ = ZGlobal.player.campaign.mapInProgress;
            if(_loc1_)
            {
               _loc2_ = Fleet.getFleet(_loc1_.fleets[0]);
               if(Boolean(_loc2_) && Boolean(_loc2_.inventory) && _loc2_.inventory.length > 0)
               {
                  this.addItems(_loc2_.inventory,1);
                  return true;
               }
            }
         }
         return false;
      }
      
      private function addItems(param1:Array, param2:int = -1) : void
      {
         var _loc10_:String = null;
         var _loc11_:ConsumableItem = null;
         var _loc12_:Boolean = false;
         var _loc13_:int = 0;
         var _loc14_:BitArray = null;
         var _loc3_:Array = new Array();
         var _loc4_:Array = new Array();
         var _loc5_:IslandItem = ZGlobal.player.campaign.currentMap.currentIslandItem;
         var _loc6_:Array = _loc5_ ? _loc5_.allowedConsumables : null;
         var _loc7_:Object = {"forCashPurchase":true};
         var _loc8_:int = 0;
         while(_loc8_ < param1.length)
         {
            _loc10_ = param1[_loc8_];
            _loc11_ = ZGlobal.gameSettings.getItemByCode(_loc10_,ConsumableItem) as ConsumableItem;
            _loc12_ = !_loc6_ || _loc6_.indexOf(_loc11_.code) >= 0;
            if((_loc12_) && _loc11_.type == m_type && _loc11_.subType == GameItem.TYPE_CONSUMABLE && !TutorialManager.instance.isLocked(_loc11_.code) && _loc11_.experimentAllowed)
            {
               _loc13_ = param2;
               if(_loc13_ < 0)
               {
                  _loc13_ = ZGlobal.player.getNumberOfInventoryItems(_loc10_);
               }
               if(_loc13_)
               {
                  this.addConsumableWithAmount(_loc11_,_loc13_);
               }
               else if(_loc11_.usesCash() && _loc11_.buyable)
               {
                  _loc14_ = ZGlobal.player.checkGate(_loc11_,_loc7_);
                  if(!_loc14_.isBitSet(Player.GATE_FAILURE_DATE))
                  {
                     if(!_loc14_.isBitSet(Player.GATE_FAILURE_LEVEL))
                     {
                        _loc3_.push(new StackedConsumableInfo(_loc11_));
                     }
                     else
                     {
                        _loc4_.push(new StackedConsumableInfo(_loc11_));
                     }
                  }
               }
            }
            _loc8_++;
         }
         if(ExperimentsManager.instance.getExperimentVariant("empire_new_consumable_sort") == 2)
         {
            m_consumables.sort(this.sortLogic);
            _loc3_.sort(this.sortLogic);
            _loc4_.sort(this.sortLogic);
         }
         var _loc9_:int = 0;
         while(_loc9_ < _loc3_.length)
         {
            m_consumables.push(_loc3_[_loc9_]);
            _loc9_++;
         }
         _loc9_ = 0;
         while(_loc9_ < _loc4_.length)
         {
            m_consumables.push(_loc4_[_loc9_]);
            _loc9_++;
         }
      }
      
      private function sortLogic(param1:StackedConsumableInfo, param2:StackedConsumableInfo) : Number
      {
         if(param1.consumable.version > param2.consumable.version)
         {
            return -1;
         }
         if(param1.consumable.version < param2.consumable.version)
         {
            return 1;
         }
         if(param1.cash > param2.cash)
         {
            return -1;
         }
         return 1;
      }
      
      override protected function resetAnchorPosition() : void
      {
         setAnchor(m_screen.origin_mc.x,m_screen.origin_mc.y);
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         var _loc6_:StackedConsumableInfo = m_consumables[param5] as StackedConsumableInfo;
         if(_loc6_.quantity)
         {
            return new StackedConsumableSlot(param1,param2,screen,param3,param4,_loc6_,param5,this.getMultFactor());
         }
         return new PremiumConsumableSlotV2(param1,param2,screen,param3,param4,_loc6_.consumable,param5,this.getMultFactor());
      }
      
      override protected function getMultFactor() : Number
      {
         return 1;
      }
      
      override protected function addHeader() : void
      {
      }
      
      override protected function onCardClicked(param1:WorldEvent) : void
      {
         m_eventDispatcher.dispatchEvent(new WorldEvent(param1.type,param1.eventData));
      }
      
      private function findStackedConsumable(param1:String) : StackedConsumableInfo
      {
         var _loc2_:StackedConsumableInfo = null;
         for each(_loc2_ in m_consumables)
         {
            if(_loc2_.consumable.code == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function addConsumableWithAmount(param1:ConsumableItem, param2:int) : void
      {
         var _loc3_:String = param1.code;
         var _loc4_:StackedConsumableInfo = this.findStackedConsumable(_loc3_);
         if(_loc4_ == null)
         {
            _loc4_ = new StackedConsumableInfo(param1);
            m_consumables.push(_loc4_);
         }
         _loc4_.incrementQuantity(param2);
      }
      
      private function onSingleRightClick(param1:MouseEvent) : void
      {
         slide(-1);
      }
      
      private function onSingleLeftClick(param1:MouseEvent) : void
      {
         slide(1);
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
   }
}

