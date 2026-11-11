package core.managers.prisoncamp
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.managers.WorldObjectManager;
   import flash.events.EventDispatcher;
   import utils.ZGameRandom;
   
   public class PrisonCampManager extends EventDispatcher
   {
      
      public static const instance:PrisonCampManager = new PrisonCampManager();
      
      public static const BUILDING_CODE:String = "BB23";
      
      public static const MULTIPLIER_15_FLOAT:Number = 1.5;
      
      public static const MULTIPLIER_20_FLOAT:Number = 2;
      
      private var m_invasions:Array;
      
      public function PrisonCampManager()
      {
         super();
      }
      
      public function getInfo() : Array
      {
         return this.m_invasions;
      }
      
      public function setInfo(param1:Object) : void
      {
         this.m_invasions = param1 as Array;
      }
      
      public function clearInfo() : void
      {
         this.m_invasions = null;
      }
      
      public function getAvailableCP() : uint
      {
         var _loc1_:uint = 0;
         var _loc2_:Object = null;
         if(this.m_invasions)
         {
            for each(_loc2_ in this.m_invasions)
            {
               _loc1_ += _loc2_.cp;
            }
         }
         return uint(_loc1_ + ZGlobal.player.staticCP);
      }
      
      public function getPotentialXPMultiplier() : Number
      {
         var _loc1_:uint = this.getAvailableCP();
         var _loc2_:Object = this.getXPBuffThresholds();
         if(Boolean(_loc2_.buff1CP) && _loc1_ >= _loc2_.buff1CP)
         {
            return MULTIPLIER_20_FLOAT;
         }
         if(Boolean(_loc2_.buff0CP) && _loc1_ >= _loc2_.buff0CP)
         {
            return MULTIPLIER_15_FLOAT;
         }
         return 1;
      }
      
      public function getXPBuffThresholds() : Object
      {
         var variant:int = 0;
         var thresholds:XMLList = null;
         var level:int = 0;
         var xml:XML = null;
         variant = ExperimentsManager.instance.getExperimentVariant("empire_prisoncamp_threshold");
         thresholds = ZGlobal.gameSettings.getXML().prisonCampXPBuffThresholds.threshold.(@variant == variant);
         if(thresholds)
         {
            level = ZGlobal.player.level;
            for each(xml in thresholds)
            {
               if(level >= int(xml.@minLevel))
               {
                  return {
                     "buff0CP":int(xml.@buff0CP),
                     "buff1CP":int(xml.@buff1CP)
                  };
               }
            }
         }
         return {
            "buff0CP":99999,
            "buff1CP":99999
         };
      }
      
      public function applyXPMultiplier(param1:int, param2:Object) : int
      {
         var _loc6_:Number = NaN;
         if(param1 <= 0)
         {
            return param1;
         }
         var _loc3_:Number = ZGlobal.player.xpMultiplier;
         var _loc4_:Number = Math.floor(_loc3_);
         var _loc5_:Number = Math.ceil(_loc3_);
         if(_loc3_ == _loc4_)
         {
            return _loc3_ * param1;
         }
         if(param2 is ZGameRandom)
         {
            _loc6_ = (param2 as ZGameRandom).float();
         }
         else
         {
            _loc6_ = param2 as Number;
         }
         var _loc7_:Number = _loc3_ - _loc4_;
         if(_loc6_ < _loc7_)
         {
            return int(_loc5_ * param1);
         }
         return int(_loc4_ * param1);
      }
      
      public function isPrisonCampBuilt() : Boolean
      {
         return WorldObjectManager.instance.getNumberBuiltObjectsWithCode(BUILDING_CODE) == 1;
      }
      
      public function isHomePrisonCampBuilt() : Boolean
      {
         return WorldObjectManager.instance.getNumberHomeBuiltObjectsWithCode(BUILDING_CODE) == 1;
      }
   }
}

