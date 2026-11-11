package core.gamemode.battle.consumable.suggester
{
   import core.ZGlobal;
   import core.gameobjects.Fleet;
   import core.gameobjects.Unit;
   import core.gameobjects.UnitItem;
   
   public class ConsumableSuggesterUtils
   {
      
      public function ConsumableSuggesterUtils()
      {
         super();
      }
      
      public static function calculateTotalWeight(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return param1 * param2 + param3 * param4;
      }
      
      public static function getAverageStrengthLost(param1:Fleet, param2:Boolean) : Number
      {
         var _loc6_:UnitItem = null;
         var _loc7_:Unit = null;
         var _loc3_:Number = 0;
         var _loc4_:Number = 0;
         var _loc5_:int = 0;
         for each(_loc7_ in param1.units)
         {
            _loc6_ = ZGlobal.gameSettings.getItemByCode(_loc7_.code,UnitItem) as UnitItem;
            if(param2 || _loc6_.getStrength(null) != _loc7_.strength)
            {
               _loc4_ += _loc6_.getStrength(null) - _loc7_.strength;
               _loc5_++;
            }
         }
         if(_loc5_ > 0)
         {
            _loc3_ = _loc4_ / _loc5_;
         }
         return _loc3_;
      }
      
      public static function getAverageTier(param1:Fleet) : Number
      {
         var _loc5_:UnitItem = null;
         var _loc6_:Unit = null;
         var _loc2_:Number = -1;
         var _loc3_:Number = 0;
         var _loc4_:int = 0;
         for each(_loc6_ in param1.units)
         {
            _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc6_.code,UnitItem) as UnitItem;
            _loc3_ += _loc5_.tier;
            _loc4_++;
         }
         if(_loc4_ > 0)
         {
            _loc2_ = _loc3_ / _loc4_;
         }
         return _loc2_;
      }
      
      public static function getFleetCurrentStrength(param1:Fleet) : Number
      {
         var _loc3_:Unit = null;
         var _loc2_:Number = 0;
         for each(_loc3_ in param1.units)
         {
            _loc2_ += _loc3_.strength;
         }
         return _loc2_;
      }
      
      public static function getFleetStartingStrength(param1:Fleet) : Number
      {
         var _loc3_:UnitItem = null;
         var _loc4_:Unit = null;
         var _loc2_:Number = 0;
         for each(_loc4_ in param1.units)
         {
            _loc2_ += (ZGlobal.gameSettings.getItemByCode(_loc4_.code,UnitItem) as UnitItem).getStrength(null);
         }
         return _loc2_;
      }
      
      public static function localFleetHasCounterUnitToRemoteFleet(param1:Fleet, param2:Fleet) : Boolean
      {
         var _loc5_:UnitItem = null;
         var _loc6_:String = null;
         var _loc7_:Unit = null;
         var _loc3_:Boolean = false;
         var _loc4_:Vector.<String> = new Vector.<String>();
         for each(_loc7_ in param1.units)
         {
            _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc7_.code,UnitItem) as UnitItem;
            for each(_loc6_ in _loc5_.goodAgainst)
            {
               if(_loc4_.indexOf(_loc6_) == -1)
               {
                  _loc4_.push(_loc6_);
               }
            }
         }
         for each(_loc7_ in param2.units)
         {
            _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc7_.code,UnitItem) as UnitItem;
            if(_loc4_.indexOf(_loc5_.unitClass) != -1)
            {
               _loc3_ = true;
               break;
            }
         }
         return _loc3_;
      }
      
      public static function fleetCurrentlyUsingConsumable(param1:Fleet, param2:String) : Boolean
      {
         var _loc5_:Object = null;
         var _loc3_:Boolean = false;
         var _loc4_:Array = param1.getConsumables(-1);
         for each(_loc5_ in _loc4_)
         {
            if(_loc5_ != null && _loc5_.code != null && _loc5_.code == param2)
            {
               _loc3_ = true;
            }
         }
         return _loc3_;
      }
      
      public static function fleetCurrentlyUsingArrayOfConsumables(param1:Fleet, param2:Array, param3:Boolean = true) : Boolean
      {
         var _loc6_:String = null;
         var _loc4_:Boolean = param3 ? false : true;
         var _loc5_:Boolean = false;
         var _loc7_:int = 0;
         var _loc8_:* = param2;
         for each(_loc6_ in _loc8_)
         {
            _loc5_ = fleetCurrentlyUsingConsumable(param1,_loc6_);
            if(param3 == true && _loc5_ == true)
            {
               _loc4_ = true;
            }
            else
            {
               param3 == false && _loc5_ == false;
               _loc4_ = false;
            }
         }
         return _loc4_;
      }
      
      public static function getFleetStrengthRemainingFraction(param1:Fleet) : Number
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = getFleetCurrentStrength(param1);
         var _loc4_:Number = getFleetStartingStrength(param1);
         if(_loc3_ != 0)
         {
            _loc2_ = _loc3_ / _loc4_;
         }
         return _loc2_;
      }
      
      public static function getFleetStrengthLostDecimalFraction(param1:Fleet) : Number
      {
         var _loc2_:Number = getFleetStrengthRemainingFraction(param1);
         if(isNaN(_loc2_) == false)
         {
            _loc2_ = 1 - _loc2_;
         }
         return _loc2_;
      }
      
      public static function getfleetDamagedUnitsQuantity(param1:Fleet) : int
      {
         var _loc3_:UnitItem = null;
         var _loc4_:Unit = null;
         var _loc2_:int = 0;
         for each(_loc4_ in param1.units)
         {
            _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc4_.code,UnitItem) as UnitItem;
            if(_loc4_.strength != _loc3_.getStrength(null))
            {
               _loc2_++;
            }
         }
         return _loc2_;
      }
   }
}

