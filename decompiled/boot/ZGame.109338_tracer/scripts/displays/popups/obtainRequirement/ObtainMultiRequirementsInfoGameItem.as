package displays.popups.obtainRequirement
{
   import core.ZGlobal;
   import core.gameobjects.EnergyRefillItem;
   import core.gameobjects.GameItem;
   import core.player.PlayerResources;
   import flash.utils.Dictionary;
   
   public class ObtainMultiRequirementsInfoGameItem
   {
      
      private var m_item:GameItem;
      
      private var m_lacking:Array = null;
      
      private var m_overrideCost:int = 0;
      
      private var m_buyItem:GameItem = null;
      
      public function ObtainMultiRequirementsInfoGameItem(param1:GameItem)
      {
         super();
         this.m_item = param1;
         this.calculateShortages();
      }
      
      public function get item() : GameItem
      {
         return this.m_item;
      }
      
      public function get numRequirements() : int
      {
         return this.m_lacking.length;
      }
      
      public function get overrideCost() : int
      {
         return this.m_overrideCost;
      }
      
      public function set overrideCost(param1:int) : void
      {
         this.m_overrideCost = param1;
      }
      
      public function isResourceRequirement(param1:int) : Boolean
      {
         if(param1 < this.numRequirements)
         {
            return this.m_lacking[param1].type != null;
         }
         return false;
      }
      
      public function requirement(param1:int) : Object
      {
         if(param1 < this.numRequirements)
         {
            return this.m_lacking[param1];
         }
         return null;
      }
      
      public function requirementType(param1:int) : String
      {
         if(param1 < this.numRequirements)
         {
            return String(this.m_lacking[param1].type);
         }
         return null;
      }
      
      public function requirementQuantity(param1:int) : int
      {
         if(param1 < this.numRequirements)
         {
            return int(this.m_lacking[param1].shortage);
         }
         return 0;
      }
      
      public function buyItem(param1:int) : GameItem
      {
         return GameItem(this.m_lacking[param1].buyItem);
      }
      
      public function requirementItem(param1:int) : GameItem
      {
         if(param1 < this.numRequirements)
         {
            return GameItem(this.m_lacking[param1].item);
         }
         return null;
      }
      
      public function requirementCost(param1:int) : int
      {
         var _loc3_:int = 0;
         var _loc4_:GameItem = null;
         var _loc2_:int = 0;
         if(this.requirementType(param1) == "energy")
         {
            _loc4_ = this.buyItem(param1);
            if(_loc4_.code == EnergyRefillItem.ITEM_CODE)
            {
               return ZGlobal.player.m_energy.energyMax - ZGlobal.player.m_energy.energy;
            }
            return _loc4_.xml.cost.@cash;
         }
         _loc3_ = this.requirementQuantity(param1);
         if(this.isResourceRequirement(param1))
         {
            _loc2_ = ZGlobal.player.resourceCashCost(this.requirementType(param1),_loc3_);
         }
         else
         {
            _loc2_ = this.requirementItem(param1).cash * _loc3_;
         }
         return _loc2_;
      }
      
      public function get cashCostTotal() : int
      {
         if(this.m_overrideCost > 0)
         {
            return this.m_overrideCost;
         }
         return this.calculatedCost;
      }
      
      public function get calculatedCost() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.numRequirements)
         {
            _loc1_ += this.requirementCost(_loc2_);
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function removeRequirement(param1:int) : void
      {
         if(this.m_lacking.length > param1)
         {
            this.m_lacking.splice(param1,1);
         }
      }
      
      private function calculateShortages() : void
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:GameItem = null;
         var _loc9_:int = 0;
         var _loc10_:GameItem = null;
         this.m_lacking = new Array();
         var _loc1_:PlayerResources = ZGlobal.player.resources;
         var _loc2_:Array = this.m_item.resourceCosts;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc6_ = _loc2_[_loc3_].type;
            _loc7_ = -_loc1_.resourceAmounts[_loc6_] - _loc2_[_loc3_].amount;
            if(_loc7_ > 0)
            {
               if(_loc6_ == "energy")
               {
                  _loc8_ = ZGlobal.player.energyItem(_loc7_,false);
                  this.m_buyItem = ZGlobal.player.energyItem(_loc7_,true);
                  this.m_lacking.push({
                     "type":_loc6_,
                     "item":_loc8_,
                     "buyItem":this.m_buyItem,
                     "shortage":_loc7_
                  });
               }
               else
               {
                  _loc8_ = ZGlobal.player.resourceItem(_loc6_,_loc6_ == ZGlobal.player.rareResourceName);
                  this.m_lacking.push({
                     "type":_loc6_,
                     "item":_loc8_,
                     "shortage":_loc7_
                  });
               }
            }
            _loc3_++;
         }
         var _loc4_:Dictionary = this.m_item.itemCosts;
         for(_loc5_ in _loc4_)
         {
            _loc9_ = _loc4_[_loc5_] - ZGlobal.player.getNumberOfInventoryItems(_loc5_);
            if(_loc9_ > 0)
            {
               _loc10_ = ZGlobal.gameSettings.getItemByCode(_loc5_,GameItem) as GameItem;
               this.m_lacking.push({
                  "type":null,
                  "item":_loc10_,
                  "shortage":_loc9_
               });
            }
         }
      }
   }
}

