package core.gameobjects
{
   import core.ZGlobal;
   import core.gameobjects.fleet.FleetComposition;
   import core.managers.ExperimentsManager;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import zlabs.debug.Logger;
   import zlabs.utils.StringUtils;
   
   public class IslandItem extends GameItem
   {
      
      public static const ADVISOR_TYPE:String = "a";
      
      private var m_map:String = null;
      
      private var m_unitStrengthMods:Dictionary = null;
      
      public function IslandItem(param1:XML, param2:String)
      {
         super(param1);
         this.m_map = param2;
      }
      
      public function get playerType() : String
      {
         return xml.@playerType.toString();
      }
      
      public function set playerType(param1:String) : void
      {
         xml.@playerType = param1;
      }
      
      public function get winType() : String
      {
         return xml.@win.toString();
      }
      
      public function get endMovie() : String
      {
         return xml.@movie.toString();
      }
      
      public function get showBonus() : String
      {
         return xml.@showBonus.toString();
      }
      
      public function get suppressCCPopup() : Boolean
      {
         var _loc1_:String = xml.@suppressCCPopup.toString();
         return _loc1_ == "true";
      }
      
      public function get numAllies() : int
      {
         var _loc1_:int = ExperimentsManager.instance.allyGateIncrease();
         var _loc2_:String = xml.@numAllies.toString();
         if(_loc2_.length > 0)
         {
            return parseInt(_loc2_) + _loc1_;
         }
         return 1 + _loc1_;
      }
      
      public function set numAllies(param1:int) : void
      {
         xml.@numAllies = param1;
      }
      
      public function get maxUnits() : int
      {
         var _loc1_:int = Fleet.MAX_UNITS;
         var _loc2_:String = xml.@maxUnits.toString();
         if(_loc2_.length > 0)
         {
            return parseInt(_loc2_);
         }
         return Fleet.MAX_UNITS;
      }
      
      public function set maxUnits(param1:int) : void
      {
         xml.@maxUnits = param1;
      }
      
      public function get unlocks() : String
      {
         return m_xml.@unlocks;
      }
      
      public function set unlocks(param1:String) : void
      {
         m_xml.@unlocks = param1;
      }
      
      public function get map() : String
      {
         return this.m_map;
      }
      
      public function get index() : int
      {
         return m_xml.@index;
      }
      
      public function get globalIndex() : int
      {
         return m_xml.@globalIslandIndex;
      }
      
      public function get mc() : String
      {
         return m_xml.art.@mc;
      }
      
      public function set mc(param1:String) : void
      {
         m_xml.art.@mc = param1;
      }
      
      public function get unit() : String
      {
         return m_xml.@unit;
      }
      
      public function set index(param1:int) : void
      {
         m_xml.@index = param1;
         m_xml.@name = "island" + (param1 < 10 ? "0" : "") + (param1 + 1);
      }
      
      public function get position() : Point
      {
         return StringUtils.parsePoint(m_xml.art.@pos.toString());
      }
      
      public function setPosition(param1:int, param2:int) : void
      {
         m_xml.art.@pos = param1 + "," + param2;
      }
      
      public function get fleetType() : String
      {
         var _loc2_:GameItem = null;
         var _loc1_:Array = this.getUnits();
         if(_loc1_.length > 0)
         {
            _loc2_ = ZGlobal.gameSettings.getItemByCode(_loc1_[0],GameItem) as GameItem;
            return _loc2_.subType;
         }
         return "";
      }
      
      public function getUnits() : Array
      {
         var _loc4_:int = 0;
         var _loc5_:Array = null;
         var _loc1_:FleetComposition = new FleetComposition(m_xml);
         var _loc2_:Array = _loc1_.units;
         var _loc3_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPAIGN_MASTERY);
         if(_loc3_ == ZGlobal.EXPERIMENT_CAMPAIGN_MASTERY_ENABLED)
         {
            _loc4_ = ZGlobal.player.campaign.getMastery(this.index);
            if(_loc4_ > ZGlobal.player.campaign.MAX_MASTERY_TIER)
            {
               _loc4_ = int(ZGlobal.player.campaign.MAX_MASTERY_TIER);
            }
            if(_loc4_ > 0)
            {
               _loc5_ = this.getMasteryUnits(_loc2_,_loc4_);
               if(_loc5_.length > 0)
               {
                  _loc2_ = _loc5_;
               }
            }
         }
         return _loc2_;
      }
      
      public function get winAvatarIndex() : int
      {
         return m_xml.@winAvatarIndex;
      }
      
      public function get allowedConsumables() : Array
      {
         var _loc1_:String = m_xml.@allowedConsumables.toString();
         if(_loc1_.length > 0)
         {
            return _loc1_.split(",");
         }
         return null;
      }
      
      public function strengthMultiplier(param1:String) : Number
      {
         if(null == this.m_unitStrengthMods)
         {
            this.populateStrengthMultipliers();
         }
         var _loc2_:Number = 1;
         if(null != this.m_unitStrengthMods[param1])
         {
            _loc2_ = Number(this.m_unitStrengthMods[param1]);
         }
         return _loc2_;
      }
      
      public function getMaximumTierForUnitType(param1:String, param2:String, param3:Boolean) : int
      {
         var _loc6_:XML = null;
         var _loc7_:UnitItem = null;
         var _loc8_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:XMLList = ZGlobal.gameSettings.getItemsByType("Buildable",param1);
         for each(_loc6_ in _loc5_)
         {
            _loc7_ = new UnitItem(_loc6_);
            if(!(param3 && _loc7_.hasType(UnitItem.VILLAIN)))
            {
               if(Boolean(_loc7_.unitClass) && _loc7_.unitClass == param2)
               {
                  _loc8_ = _loc7_.tier;
                  if(_loc8_ > _loc4_)
                  {
                     _loc4_ = _loc8_;
                  }
               }
            }
         }
         return _loc4_;
      }
      
      private function getTieredUnits(param1:XMLList, param2:String, param3:int) : Array
      {
         var _loc5_:XML = null;
         var _loc6_:UnitItem = null;
         var _loc4_:Array = new Array();
         for each(_loc5_ in param1)
         {
            _loc6_ = new UnitItem(_loc5_);
            if(_loc6_.tier == param3 && param2 == _loc6_.unitClass && !_loc6_.hasType(UnitItem.VILLAIN) && !_loc6_.hasType(UnitItem.MEGA_UNIT))
            {
               _loc4_.push(_loc6_.code);
            }
         }
         return _loc4_;
      }
      
      private function getMasteryUnits(param1:Array, param2:int) : Array
      {
         var _loc6_:String = null;
         var _loc7_:UnitItem = null;
         var _loc8_:* = 0;
         var _loc9_:Boolean = false;
         var _loc10_:int = 0;
         var _loc11_:XMLList = null;
         var _loc12_:Array = null;
         var _loc3_:Array = new Array();
         var _loc4_:int = 0;
         var _loc5_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPAIGN_MASTERY_UNIT_TIER);
         if(_loc5_ == ZGlobal.EXPERIMENT_CAMPAIGN_MASTERY_UNIT_TIER_HARD_VARIANT)
         {
            _loc4_ = 1;
         }
         for each(_loc6_ in param1)
         {
            _loc7_ = ZGlobal.gameSettings.getItemByCode(_loc6_,UnitItem) as UnitItem;
            _loc8_ = int(_loc7_.tier + param2 + _loc4_);
            _loc9_ = true;
            _loc10_ = this.getMaximumTierForUnitType(_loc7_.subType,_loc7_.unitClass,_loc9_);
            if(_loc8_ > _loc10_)
            {
               _loc8_ = _loc10_;
            }
            _loc11_ = ZGlobal.gameSettings.getItemsByType("Buildable",_loc7_.subType);
            _loc12_ = null;
            do
            {
               _loc12_ = this.getTieredUnits(_loc11_,_loc7_.unitClass,_loc8_);
               _loc8_--;
            }
            while(_loc12_.length == 0);
            if(_loc12_.length > 0)
            {
               _loc12_.sort();
               _loc3_.push(_loc12_[0]);
            }
         }
         return _loc3_;
      }
      
      public function createFleet() : Fleet
      {
         var _loc5_:String = null;
         var _loc1_:Array = this.getUnits();
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(_loc1_[0],GameItem) as GameItem;
         if(null == _loc2_)
         {
            Logger.error(this,"createFleet","no such unit with code " + _loc1_[0]);
         }
         else if(_loc1_.length > Fleet.MAX_UNITS)
         {
            _loc5_ = "Too many (" + _loc1_.length + ") units for island " + this.index + ", " + this.m_map;
            Logger.error(this,"createFleet",_loc5_);
            throw new Error(_loc5_);
         }
         var _loc3_:Fleet = ZGlobal.player.fleets.createFleet(_loc2_.subType,false);
         _loc3_.setStatus(Fleet.CAMPAIGN);
         var _loc4_:int = 0;
         while(_loc4_ < _loc1_.length)
         {
            _loc3_.addUnit(_loc1_[_loc4_]);
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function getFleetInventory() : Array
      {
         var _loc2_:XML = null;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:* = 0;
         var _loc1_:Array = null;
         if(xml.fleetInventory.length() > 0)
         {
            _loc1_ = new Array();
            for each(_loc2_ in xml.fleetInventory)
            {
               _loc3_ = 0;
               while(_loc3_ < _loc2_.attributes().length())
               {
                  _loc4_ = _loc2_.attributes()[_loc3_].name().toString();
                  _loc5_ = int(_loc2_.attributes()[_loc3_]);
                  while(_loc5_ > 0)
                  {
                     _loc1_.push(_loc4_);
                     _loc5_--;
                  }
                  _loc3_++;
               }
            }
         }
         return _loc1_;
      }
      
      public function giveRewards(param1:Boolean) : void
      {
         var _loc3_:int = 0;
         var _loc4_:XML = null;
         var _loc5_:RewardHelper = null;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:RewardHelper = null;
         var _loc2_:Number = ZGlobal.player.campaign.getRewardMultiplier(false);
         if(_loc2_ > 0)
         {
            _loc3_ = ZGlobal.gameSettings.getInt("combatReplayRewardMinimum",100);
            for each(_loc4_ in m_xml.reward)
            {
               _loc5_ = new RewardHelper(_loc4_);
               if(!_loc5_.isItem || param1)
               {
                  _loc5_.multiplier = _loc2_;
                  _loc5_.multiplierMinimum = _loc3_;
                  _loc5_.execute();
               }
            }
            if(param1)
            {
               _loc6_ = ZGlobal.gameSettings.getInt("combatBondRewardsPerBattle",3);
               _loc7_ = ZGlobal.gameSettings.getString("combatBondRewardType","xk01");
               _loc8_ = new RewardHelper(null);
               _loc8_.init("item",_loc6_,_loc7_);
               _loc8_.execute();
            }
         }
      }
      
      private function populateStrengthMultipliers() : void
      {
         var _loc1_:XML = null;
         var _loc2_:String = null;
         this.m_unitStrengthMods = new Dictionary();
         for each(_loc1_ in m_xml.strength)
         {
            _loc2_ = _loc1_.@code.toString();
            if(_loc2_.length > 0)
            {
               this.m_unitStrengthMods[_loc2_] = parseFloat(_loc1_.@mult);
            }
         }
      }
   }
}

