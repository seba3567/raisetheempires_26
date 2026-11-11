package core.gameobjects
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gamemode.battle.Battle;
   import core.managers.ExperimentsManager;
   import core.managers.campaignManager.CampaignManager;
   import core.worlds.strategicWorld.StrategicMap;
   import dispatchers.StrategicDispatcher;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import transactions.TSetCurrentCampaign;
   import utils.ThreeBitArray;
   import utils.ZGameUtils;
   
   public class PlayerCampaign
   {
      
      public const MAX_MASTERY_TIER:uint = 2;
      
      private var m_maps:Dictionary = null;
      
      private var m_currentMap:String = null;
      
      private var m_mastery:Dictionary = null;
      
      private var m_previousMastery:Dictionary = null;
      
      private var m_lockedUnits:Array = null;
      
      private var m_unlockedUnits:Array = null;
      
      private var m_nextMap:String = null;
      
      private var m_celebrationMap:String = null;
      
      private var m_currentMasteryScalar:Number = 1;
      
      private var m_rematch:Boolean = false;
      
      private var m_currentCampaign:String = null;
      
      public function PlayerCampaign(param1:Object)
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:ThreeBitArray = null;
         super();
         this.m_nextMap = ZGlobal.gameSettings.campaignfirstMap;
         this.currentCampaignName = param1.current;
         this.m_maps = new Dictionary();
         for(_loc2_ in param1.active)
         {
            this.loadMap(_loc2_);
            this.m_maps[_loc2_].loadFromData(param1.active[_loc2_]);
         }
         this.m_mastery = new Dictionary();
         this.m_previousMastery = new Dictionary();
         for(_loc3_ in param1.mastery)
         {
            _loc4_ = new ThreeBitArray(param1.mastery[_loc3_]);
            this.m_mastery[_loc3_] = _loc4_.asArray;
            this.m_previousMastery[_loc3_] = _loc4_.asArray;
         }
         this.setupLockedUnits();
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.CONTINUE_PROGRESS,this.onContinueProgress);
      }
      
      public function set currentMapName(param1:String) : void
      {
         this.m_currentMap = param1;
         this.m_currentMasteryScalar = 1;
      }
      
      public function get currentMapName() : String
      {
         return this.m_currentMap;
      }
      
      public function get mapInProgress() : StrategicMap
      {
         return this.mapInProgressForCampaign(this.currentCampaignName);
      }
      
      public function get allMapsInProgress() : Array
      {
         var _loc3_:String = null;
         var _loc4_:StrategicMap = null;
         var _loc1_:Array = new Array();
         var _loc2_:Array = CampaignManager.instance.campaignNamesArray;
         for each(_loc3_ in _loc2_)
         {
            if(CampaignManager.instance.isEligibleCampaign(_loc3_))
            {
               _loc4_ = this.mapInProgressForCampaign(_loc3_);
               if(_loc4_)
               {
                  _loc1_.push(_loc4_);
               }
            }
         }
         return _loc1_;
      }
      
      public function mapInProgressForCampaign(param1:String) : StrategicMap
      {
         var _loc3_:XML = null;
         var _loc4_:StrategicMap = null;
         var _loc2_:Array = CampaignManager.instance.getChaptersArray(param1);
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = this.m_maps[String(_loc3_.@code)];
            if((Boolean(_loc4_)) && _loc4_.inProgress)
            {
               return _loc4_;
            }
         }
         return null;
      }
      
      public function mapContainingFleet(param1:Fleet) : StrategicMap
      {
         var _loc2_:StrategicMap = null;
         for each(_loc2_ in this.m_maps)
         {
            if(Boolean(_loc2_.fleets) && Boolean(_loc2_.fleets.length > 1) && (param1.name == _loc2_.fleets[0] || param1.name == _loc2_.fleets[1]))
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function set nextMap(param1:String) : void
      {
         this.m_nextMap = param1;
      }
      
      public function get nextMap() : String
      {
         var _loc1_:String = this.m_nextMap;
         this.m_nextMap = null;
         return _loc1_ ? _loc1_ : this.m_currentMap;
      }
      
      public function getActiveMaps() : Dictionary
      {
         return this.m_maps;
      }
      
      public function set celebrationMap(param1:String) : void
      {
         this.m_celebrationMap = param1;
      }
      
      public function get celebrationMap() : String
      {
         return this.m_celebrationMap;
      }
      
      public function get newMapAvailable() : Boolean
      {
         if(null != this.mapInProgress)
         {
            return false;
         }
         var _loc1_:String = this.activeMap;
         var _loc2_:StrategicMap = this.getMap(_loc1_);
         if(_loc2_.progressIsland != 0)
         {
            return false;
         }
         var _loc3_:IslandGroupItem = ZGlobal.gameSettings.getItemByCode(_loc1_,IslandGroupItem) as IslandGroupItem;
         if(_loc3_.questLocked || _loc3_.uilocked)
         {
            return false;
         }
         return true;
      }
      
      public function get activeMap() : String
      {
         var _loc4_:StrategicMap = null;
         var _loc5_:Boolean = false;
         var _loc6_:IslandGroupItem = null;
         var _loc1_:String = this.getFirstMapOfCampaign(this.currentCampaignName);
         var _loc2_:String = _loc1_;
         var _loc3_:Boolean = false;
         while(true)
         {
            _loc4_ = this.getMap(_loc1_);
            _loc5_ = _loc4_.progressIsland >= _loc4_.numIslands;
            if(_loc4_.inProgress)
            {
               break;
            }
            if(_loc3_)
            {
               if(!_loc5_)
               {
                  return _loc1_;
               }
            }
            _loc3_ = _loc5_;
            _loc6_ = ZGlobal.gameSettings.getItemByCode(_loc1_,IslandGroupItem) as IslandGroupItem;
            _loc1_ = _loc6_.unlocks;
            if(!_loc1_)
            {
               return _loc2_;
            }
         }
         return _loc1_;
      }
      
      public function get leadMap() : String
      {
         var _loc4_:StrategicMap = null;
         var _loc5_:Boolean = false;
         var _loc6_:IslandGroupItem = null;
         var _loc7_:String = null;
         var _loc1_:String = ZGlobal.gameSettings.campaignfirstMap;
         var _loc2_:String = _loc1_;
         var _loc3_:Boolean = false;
         while(true)
         {
            _loc4_ = this.getMap(_loc1_);
            _loc5_ = _loc4_.progressIsland >= _loc4_.numIslands;
            if(_loc3_)
            {
               if(!_loc5_)
               {
                  break;
               }
            }
            _loc3_ = _loc5_;
            _loc6_ = ZGlobal.gameSettings.getItemByCode(_loc1_,IslandGroupItem) as IslandGroupItem;
            _loc7_ = _loc6_.unlocks;
            if(!_loc7_ && _loc5_)
            {
               return _loc1_;
            }
            _loc1_ = _loc7_;
            if(!_loc1_)
            {
               return _loc2_;
            }
         }
         return _loc1_;
      }
      
      public function get currentMap() : StrategicMap
      {
         return this.getMap(this.m_currentMap);
      }
      
      public function get justCompletedMap() : Boolean
      {
         var _loc1_:StrategicMap = null;
         if(this.m_currentMap)
         {
            _loc1_ = this.currentMap;
            if(Boolean(_loc1_) && _loc1_.progressIsland == _loc1_.numIslands)
            {
               if(this.getPreviousMastery(_loc1_.lastIsland) == 0)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function set rematch(param1:Boolean) : void
      {
         this.m_rematch = param1;
      }
      
      public function get rematch() : Boolean
      {
         return this.m_rematch;
      }
      
      public function getMap(param1:String) : StrategicMap
      {
         this.loadMap(param1);
         return this.m_maps[param1];
      }
      
      public function getIslandMastery(param1:String) : int
      {
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:IslandGroupItem = ZGlobal.gameSettings.getItemByCode(param1,IslandGroupItem) as IslandGroupItem;
         var _loc4_:int = _loc3_.numIslands;
         if(null != this.m_mastery)
         {
            if(null != this.m_mastery[param1])
            {
               _loc5_ = new Array(0,0,0,0);
               _loc6_ = 0;
               _loc7_ = 0;
               while(_loc7_ < _loc4_)
               {
                  _loc6_ = int(this.m_mastery[param1][_loc7_]);
                  ++_loc5_[_loc6_];
                  _loc7_++;
               }
               if(_loc5_[3] == _loc4_)
               {
                  _loc2_ = 3;
               }
               else if(_loc5_[2] == _loc4_ || _loc5_[2] + _loc5_[3] == _loc4_)
               {
                  _loc2_ = 2;
               }
               else if(_loc5_[1] == _loc4_ || _loc5_[1] + _loc5_[2] + _loc5_[3] == _loc4_)
               {
                  _loc2_ = 1;
               }
            }
         }
         return _loc2_;
      }
      
      public function getPreviousIslandMastery(param1:String) : int
      {
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:IslandGroupItem = ZGlobal.gameSettings.getItemByCode(param1,IslandGroupItem) as IslandGroupItem;
         var _loc4_:int = _loc3_.numIslands;
         if(null != this.m_previousMastery)
         {
            if(null != this.m_previousMastery[param1])
            {
               _loc5_ = new Array(0,0,0,0);
               _loc6_ = 0;
               _loc7_ = 0;
               while(_loc7_ < _loc4_)
               {
                  _loc6_ = int(this.m_previousMastery[param1][_loc7_]);
                  ++_loc5_[_loc6_];
                  _loc7_++;
               }
               if(_loc5_[3] == _loc4_)
               {
                  _loc2_ = 3;
               }
               else if(_loc5_[2] == _loc4_ || _loc5_[2] + _loc5_[3] == _loc4_)
               {
                  _loc2_ = 2;
               }
               else if(_loc5_[1] == _loc4_ || _loc5_[1] + _loc5_[2] + _loc5_[3] == _loc4_)
               {
                  _loc2_ = 1;
               }
            }
         }
         return _loc2_;
      }
      
      public function getMastery(param1:int) : int
      {
         return this.getGenericMastery(param1,this.m_mastery);
      }
      
      public function getCappedMastery(param1:int) : int
      {
         var _loc2_:uint = uint(this.getGenericMastery(param1,this.m_mastery));
         if(_loc2_ > this.MAX_MASTERY_TIER)
         {
            _loc2_ = this.MAX_MASTERY_TIER + 1;
         }
         return _loc2_;
      }
      
      public function setMastery(param1:int, param2:int) : void
      {
         var _loc5_:int = 0;
         var _loc3_:int = this.getMastery(param1);
         this.setGenericMastery(param1,param2,this.m_mastery);
         var _loc4_:int = 0;
         for each(_loc5_ in this.m_mastery[this.m_currentMap])
         {
            this.setGenericMastery(_loc4_,_loc5_,this.m_previousMastery);
            _loc4_++;
         }
         this.m_previousMastery[this.m_currentMap][param1] = _loc3_;
      }
      
      public function getPreviousMastery(param1:int) : int
      {
         return this.getGenericMastery(param1,this.m_previousMastery);
      }
      
      public function get currentMasteryScalar() : Number
      {
         return this.m_currentMasteryScalar;
      }
      
      public function calculateMasteryScalar() : void
      {
         var _loc1_:StrategicMap = null;
         var _loc2_:int = 0;
         var _loc3_:* = 0;
         var _loc4_:int = 0;
         this.m_currentMasteryScalar = 1;
         if(this.currentMapName)
         {
            _loc1_ = this.currentMap;
            if(Boolean(_loc1_) && Boolean(_loc1_.inReplay) && Boolean(_loc1_.currentIslandItem))
            {
               _loc3_ = this.getMastery(_loc1_.currentIslandItem.index);
               while(_loc3_ > 0)
               {
                  this.m_currentMasteryScalar *= 0.5;
                  _loc3_--;
               }
               if(this.m_currentMasteryScalar < 0.2)
               {
                  this.m_currentMasteryScalar = 0;
               }
            }
            _loc2_ = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPAIGN_MASTERY);
            if(_loc2_ == ZGlobal.EXPERIMENT_CAMPAIGN_MASTERY_ENABLED)
            {
               _loc4_ = this.getMastery(_loc1_.currentIslandItem.index);
               this.m_currentMasteryScalar = ZGlobal.gameSettings.getCampaignMasteryScalar(_loc4_);
            }
         }
      }
      
      public function getRewardMultiplier(param1:Boolean) : Number
      {
         var _loc3_:StrategicMap = null;
         var _loc4_:IslandGroupItem = null;
         var _loc5_:IslandGroupItem = null;
         var _loc6_:IslandItem = null;
         var _loc7_:IslandItem = null;
         var _loc8_:Number = NaN;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc2_:StrategicMap = this.currentMap;
         if(param1 || _loc2_.inReplay)
         {
            _loc3_ = this.getMap(this.leadMap);
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_.code,IslandGroupItem) as IslandGroupItem;
            _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc2_.code,IslandGroupItem) as IslandGroupItem;
            _loc6_ = _loc4_.getIslandItem(_loc3_.progressIsland);
            if(!_loc6_)
            {
               _loc6_ = _loc4_.getIslandItem(_loc4_.numIslands - 1);
            }
            _loc7_ = _loc2_.currentIslandItem;
            if(_loc3_.code != _loc2_.code || _loc6_.index != _loc7_.index)
            {
               _loc8_ = ZGlobal.gameSettings.getInt("combatReplayRewardSpan",10);
               _loc9_ = _loc7_.globalIndex;
               _loc10_ = _loc6_.globalIndex;
               _loc11_ = _loc10_ - _loc9_;
               _loc11_ = _loc8_ - Math.min(_loc11_,_loc8_);
               return _loc11_ > 0 ? _loc11_ * (1 / _loc8_) : 0.01;
            }
         }
         return 1;
      }
      
      public function isUnitLocked(param1:String) : Boolean
      {
         return this.m_lockedUnits.indexOf(param1) >= 0;
      }
      
      public function couldUnitBeLocked(param1:String) : Boolean
      {
         return this.m_lockedUnits.indexOf(param1) >= 0 || this.m_unlockedUnits.indexOf(param1) >= 0;
      }
      
      private function setupLockedUnits() : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:uint = 0;
         var _loc5_:String = null;
         var _loc6_:StrategicMap = null;
         this.m_lockedUnits = new Array();
         this.m_unlockedUnits = new Array();
         var _loc1_:XMLList = ZGlobal.gameSettings.getXML().unitUnlocks;
         for each(_loc2_ in _loc1_.unlock)
         {
            _loc3_ = _loc2_.@code;
            _loc4_ = parseInt(_loc2_.@index);
            _loc5_ = _loc2_.@unit;
            _loc6_ = this.getMap(_loc3_);
            if(_loc4_ >= _loc6_.progressIsland)
            {
               this.m_lockedUnits.push(_loc5_);
            }
            else
            {
               this.m_unlockedUnits.push(_loc5_);
            }
         }
      }
      
      private function loadMap(param1:String) : void
      {
         var _loc2_:StrategicMap = null;
         if(null == this.m_maps[param1])
         {
            _loc2_ = new StrategicMap(param1);
            if(_loc2_)
            {
               this.m_maps[param1] = _loc2_;
            }
         }
      }
      
      private function getGenericMastery(param1:int, param2:Dictionary) : int
      {
         if(null != param2)
         {
            if(null != param2[this.m_currentMap])
            {
               return param2[this.m_currentMap][param1];
            }
         }
         return 0;
      }
      
      private function setGenericMastery(param1:int, param2:int, param3:Dictionary) : void
      {
         if(null == param3[this.m_currentMap])
         {
            param3[this.m_currentMap] = new Array();
         }
         if(null == param3[this.m_currentMap][param1] || param2 > param3[this.m_currentMap][param1])
         {
            param3[this.m_currentMap][param1] = param2;
         }
      }
      
      public function isMapLocked(param1:String) : Boolean
      {
         var _loc2_:StrategicMap = this.getKey(param1);
         if(null != _loc2_)
         {
            if(_loc2_.progressIsland < _loc2_.numIslands)
            {
               return true;
            }
         }
         var _loc3_:IslandGroupItem = ZGlobal.gameSettings.getItemByCode(param1,IslandGroupItem) as IslandGroupItem;
         if(null != _loc3_)
         {
            return _loc3_.locked;
         }
         return false;
      }
      
      public function isAvailableInCampaign(param1:String) : Boolean
      {
         var _loc2_:IslandGroupItem = ZGlobal.gameSettings.getItemByCode(param1,IslandGroupItem) as IslandGroupItem;
         if(null != _loc2_)
         {
            return _loc2_.uilocked;
         }
         return false;
      }
      
      public function getKey(param1:String, param2:uint = 10000) : StrategicMap
      {
         var _loc5_:XML = null;
         var _loc6_:String = null;
         var _loc3_:Array = ZGlobal.gameSettings.getArrayOfItemXMLByType("IslandGroup");
         var _loc4_:* = 0;
         for each(_loc5_ in _loc3_)
         {
            _loc6_ = _loc5_.@unlocks.toString();
            if(_loc6_ == param1)
            {
               return this.getMap(_loc5_.@code.toString());
            }
            if(++_loc4_ > param2)
            {
               break;
            }
         }
         return null;
      }
      
      public function isHomeIslandGroup(param1:String) : Boolean
      {
         var _loc2_:IslandGroupItem = null;
         if(this.getKey(param1) == null)
         {
            _loc2_ = ZGlobal.gameSettings.getItemByCode(param1,IslandGroupItem) as IslandGroupItem;
            if(_loc2_)
            {
               return !_loc2_.ignorehome;
            }
         }
         return false;
      }
      
      public function getWinDescText(param1:String, param2:int) : String
      {
         return ZGameUtils.ZlocT("Campaign","map_" + param1 + "_" + this.m_maps[param1].getName(param2) + "_win_desc");
      }
      
      public function getWinTitleText(param1:String, param2:int) : String
      {
         return ZGameUtils.ZlocT("Campaign","map_" + param1 + "_" + this.m_maps[param1].getName(param2) + "_win_title");
      }
      
      public function getWinAvatarClipIndex(param1:String, param2:int) : int
      {
         var _loc4_:IslandItem = null;
         var _loc3_:StrategicMap = this.getMap(param1);
         if(_loc3_ != null)
         {
            _loc4_ = _loc3_.getItem(param2);
            if(_loc4_ != null)
            {
               return _loc4_.winAvatarIndex;
            }
         }
         return 0;
      }
      
      public function calculateMasteryScore(param1:Dictionary) : int
      {
         var _loc2_:int = this.getMastery(this.currentMap.currentIslandItem.index);
         var _loc3_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPAIGN_MASTERY);
         if(_loc3_ == ZGlobal.EXPERIMENT_CAMPAIGN_MASTERY_ENABLED)
         {
            return Math.min(3,_loc2_ + 1);
         }
         return Math.min(3,_loc2_ + 1);
      }
      
      public function setBattleResult(param1:int) : void
      {
         var _loc2_:StrategicMap = this.currentMap;
         if(_loc2_)
         {
            _loc2_.haltProgress(param1);
         }
      }
      
      public function battleComplete(param1:Fleet, param2:int) : void
      {
         if(param2 != Battle.BATTLE_RESULT_RETREAT)
         {
            if(Boolean(param1) && param1.getStrengthPercentage() != 0)
            {
               this.unlockUnit();
               this.setMastery(this.currentMap.currentIslandItem.index,this.calculateMasteryScore(param1.lost));
            }
         }
      }
      
      public function set currentCampaignName(param1:String) : void
      {
         if(this.m_currentCampaign != param1)
         {
            TransactionManager.addTransaction(new TSetCurrentCampaign(param1));
         }
         this.m_currentCampaign = param1;
      }
      
      public function get currentCampaignName() : String
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPV2_ENABLED) != ExperimentsManager.EXPERIMENT_CAMPV2_ENABLED_VARIANT_ENABLED)
         {
            return CampaignManager.instance.defaultCampaignName();
         }
         return this.m_currentCampaign;
      }
      
      public function get currentCampaignMapAsset() : String
      {
         var _loc1_:XML = CampaignManager.instance.getCampaignDefinition(this.currentCampaignName);
         if(_loc1_)
         {
            return _loc1_.@artAsset;
         }
         return null;
      }
      
      public function getFirstMapOfCampaign(param1:String) : String
      {
         var _loc2_:XML = CampaignManager.instance.getCampaignDefinition(param1);
         if(_loc2_)
         {
            return _loc2_.@startChapter;
         }
         return null;
      }
      
      public function setPrevCampaign() : void
      {
         var _loc1_:String = CampaignManager.instance.prevEligibleCampaign(this.currentCampaignName);
         if(_loc1_)
         {
            this.currentCampaignName = _loc1_;
         }
      }
      
      public function setNextCampaign() : void
      {
         var _loc1_:String = CampaignManager.instance.nextEligibleCampaign(this.currentCampaignName);
         if(_loc1_)
         {
            this.currentCampaignName = _loc1_;
         }
      }
      
      private function unlockUnit() : void
      {
         var _loc2_:int = 0;
         var _loc1_:String = this.currentMap.currentIslandItem.unit;
         if(_loc1_)
         {
            if(this.getPreviousMastery(this.currentMap.currentIslandItem.index) == 0)
            {
               _loc2_ = this.m_lockedUnits.indexOf(_loc1_);
               if(_loc2_ >= 0)
               {
                  this.m_lockedUnits.splice(_loc2_,1);
               }
               this.m_unlockedUnits.push(_loc1_);
            }
         }
      }
      
      private function onContinueProgress(param1:Event) : void
      {
         var _loc2_:StrategicMap = this.mapInProgress;
         this.m_currentMap = _loc2_.code;
         var _loc3_:IslandItem = _loc2_.getItem(_loc2_.inReplay ? _loc2_.replayIsland : _loc2_.progressIsland);
         _loc2_.start(_loc3_,_loc2_.fleets[0],_loc2_.fleets[1]);
      }
      
      public function get isMasteryEnabled() : Boolean
      {
         var _loc1_:XML = CampaignManager.instance.getCampaignDefinition(this.currentCampaignName);
         var _loc2_:Boolean = true;
         if(_loc1_)
         {
            if(_loc1_.@mastery.toString().length > 0)
            {
               _loc2_ = _loc1_.@mastery as Boolean;
            }
         }
         return _loc2_;
      }
   }
}

