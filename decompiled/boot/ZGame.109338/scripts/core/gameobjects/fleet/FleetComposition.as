package core.gameobjects.fleet
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   
   public class FleetComposition
   {
      
      private var m_units:Array = null;
      
      private var m_strengthMults:Array = null;
      
      public function FleetComposition(param1:XML)
      {
         super();
         this.buildFleet(param1);
         this.buildStrengthMultipliers(param1);
      }
      
      public function get units() : Array
      {
         return this.m_units;
      }
      
      public function get strengthMults() : Array
      {
         return this.m_strengthMults;
      }
      
      private function buildFleet(param1:XML) : void
      {
         var _loc2_:XML = null;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:* = 0;
         this.m_units = new Array();
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPAIGN_3) == ExperimentsManager.EXPERIMENT_CAMPAIGN_3_ENABLED_VARIANT)
         {
            if(param1.hasOwnProperty("fleetSet"))
            {
               param1 = this.getDynamicFleets(param1);
            }
         }
         for each(_loc2_ in param1.fleet)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_.attributes().length())
            {
               _loc4_ = _loc2_.attributes()[_loc3_].name().toString();
               _loc5_ = int(_loc2_.attributes()[_loc3_]);
               while(_loc5_ > 0)
               {
                  this.m_units.push(_loc4_);
                  _loc5_--;
               }
               _loc3_++;
            }
         }
      }
      
      private function buildStrengthMultipliers(param1:XML) : void
      {
         var _loc2_:int = 0;
         var _loc3_:XML = null;
         var _loc4_:Number = NaN;
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         this.m_strengthMults = new Array();
         _loc2_ = 0;
         while(_loc2_ < this.m_units.length)
         {
            this.m_strengthMults.push(1);
            _loc2_++;
         }
         for each(_loc3_ in param1.strength)
         {
            if(_loc3_.@mult.toString().length > 0)
            {
               _loc4_ = Math.max(0,Number(_loc3_.@mult));
               _loc5_ = _loc3_.@index.toString();
               if(_loc5_ == "all")
               {
                  _loc2_ = 0;
                  while(_loc2_ < this.m_strengthMults.length)
                  {
                     this.m_strengthMults[_loc2_] = _loc4_;
                     _loc2_++;
                  }
               }
               else
               {
                  _loc6_ = _loc5_.split("-");
                  _loc7_ = 0;
                  _loc8_ = 0;
                  if(_loc6_.length == 2)
                  {
                     _loc7_ = int(_loc6_[0]);
                     _loc8_ = int(_loc6_[1]);
                  }
                  else
                  {
                     _loc7_ = _loc8_ = int(_loc5_);
                  }
                  _loc7_ = Math.min(_loc7_,this.m_strengthMults.length - 1);
                  _loc8_ = Math.min(_loc8_,this.m_strengthMults.length - 1);
                  _loc2_ = _loc7_;
                  while(_loc2_ <= _loc8_)
                  {
                     this.m_strengthMults[_loc2_] = _loc4_;
                     _loc2_++;
                  }
               }
            }
         }
      }
      
      public function getDynamicFleets(param1:XML) : XML
      {
         var _loc3_:XML = null;
         var _loc4_:XML = null;
         var _loc2_:int = ZGlobal.player.level;
         if(param1.fleetSet)
         {
            for each(_loc4_ in param1.fleetSet)
            {
               if(_loc2_ >= _loc4_.@minLevel && _loc2_ <= _loc4_.@maxLevel)
               {
                  _loc3_ = _loc4_;
                  break;
               }
            }
         }
         return _loc3_;
      }
   }
}

