package core.managers.leaderboardManager
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.player.Player;
   import displays.screens.leaderboard.BarDisplay;
   import displays.screens.leaderboard.Campaign2BarDisplay;
   import displays.screens.leaderboard.CampaignBarDisplay;
   import displays.screens.leaderboard.CriticalHitsBarDisplay;
   import displays.screens.leaderboard.DamageBarDisplay;
   import displays.screens.leaderboard.ElementZConsumedBarDisplay;
   import displays.screens.leaderboard.ExpansionsBarDisplay;
   import displays.screens.leaderboard.GlobalPVPDamageBarDisplay;
   import displays.screens.leaderboard.HonorBarDisplay;
   import displays.screens.leaderboard.InfamyBarDisplay;
   import displays.screens.leaderboard.NeighborTendsBarDisplay;
   import displays.screens.leaderboard.PowerUpAddictBarDisplay;
   import displays.screens.leaderboard.ResearchUpgradesBarDisplay;
   import displays.screens.leaderboard.ResourceBarDisplay;
   import displays.screens.leaderboard.SurvivalBarDisplay;
   import displays.screens.leaderboard.SurvivalDamageDashBarDisplay;
   import displays.screens.leaderboard.UnitsKilledBarDisplay;
   import displays.screens.leaderboard.VillainTokensBarDisplay;
   import displays.screens.leaderboard.WhiteKnightRepelsBarDisplay;
   import displays.screens.leaderboard.XpBarDisplay;
   import utils.ZGameTimeUtil;
   import zlabs.events.WorldEvent;
   
   public class Leaderboard
   {
      
      public static const TYPE_CAMPAIGN:String = "campaign";
      
      public static const TYPE_CAMPAIGN2:String = "campaign2";
      
      public static const TYPE_SURVIVAL:String = "survival";
      
      public static const TYPE_SURVIVAL2:String = "survival2";
      
      public static const TYPE_SURVIVAL3:String = "survival3";
      
      public static const TYPE_SURVIVAL4:String = "eliteSurvival";
      
      public static const TYPE_SURVIVAL5:String = "eliteSurvival_enhancements";
      
      public static const TYPE_DAMAGE:String = "damage";
      
      public static const TYPE_GPVP_DAMAGE:String = "gpvpdamage";
      
      public static const TYPE_SURVIVAL_DAMAGE:String = "survivalDamage";
      
      public static const TYPE_RESOURCE:String = "resource";
      
      public static const TYPE_HONOR:String = "honor";
      
      public static const TYPE_INFAMY:String = "infamy";
      
      public static const TYPE_XP:String = "xp";
      
      public static const TYPE_UNITS_KILLED:String = "unitsKilled";
      
      public static const TYPE_CRITICAL_HITS:String = "criticalHits";
      
      public static const TYPE_EXPANSIONS:String = "expansions";
      
      public static const TYPE_GLANCING_BLOWS:String = "glancingBlows";
      
      public static const TYPE_NEIGHBOR_TENDS:String = "neighborTends";
      
      public static const TYPE_RESEARCH_UPGRADES:String = "researchUpgrades";
      
      public static const TYPE_ELEMENT_Z_CONSUMED:String = "elementZConsumed";
      
      public static const TYPE_WHITE_KNIGHT_REPELS:String = "whiteKnightRepels";
      
      public static const TYPE_POWER_UP_ADDICT:String = "powerUpAddict";
      
      public static const TYPE_VILLAIN_TOKENS:String = "campaignMastery";
      
      public static const TYPE_DOMINATION_SCORE_GAINED:String = "dominationScoreGained";
      
      public static const MAX_REWARDS:int = 4;
      
      public static const MIN_INCLUSION_LEVEL:uint = 6;
      
      public static const PLACEMENT_REWARD_INDEX:uint = 3;
      
      public var id:String = null;
      
      public var type:String = null;
      
      public var xml:XML = null;
      
      public var results:Array = null;
      
      public var completedRewards:Array = [false,false,false,false];
      
      public var numEntries:int = 0;
      
      public function Leaderboard()
      {
         super();
      }
      
      public function get tabIcon() : String
      {
         if(this.xml.@tabIcon.toString())
         {
            return this.xml.@tabIcon.toString();
         }
         return null;
      }
      
      public function ranking(param1:String) : uint
      {
         var _loc3_:Object = null;
         var _loc2_:int = this.getIndex(param1);
         if(_loc2_ >= 0)
         {
            _loc3_ = this.results[_loc2_];
            return _loc3_.localRank;
         }
         return 0;
      }
      
      public function entry(param1:String) : Object
      {
         var _loc3_:Object = null;
         var _loc2_:int = this.getIndex(param1);
         if(_loc2_ >= 0)
         {
            return this.results[_loc2_];
         }
         return null;
      }
      
      public function get barDisplay() : BarDisplay
      {
         if(this.type == TYPE_CAMPAIGN)
         {
            return new CampaignBarDisplay();
         }
         if(this.type == TYPE_CAMPAIGN2)
         {
            return new Campaign2BarDisplay();
         }
         if(this.type == TYPE_SURVIVAL)
         {
            return new SurvivalBarDisplay();
         }
         if(this.type == TYPE_SURVIVAL2)
         {
            return new SurvivalBarDisplay();
         }
         if(this.type == TYPE_SURVIVAL3)
         {
            return new SurvivalBarDisplay();
         }
         if(this.type == TYPE_DAMAGE)
         {
            return new DamageBarDisplay();
         }
         if(this.type == TYPE_GPVP_DAMAGE)
         {
            return new GlobalPVPDamageBarDisplay();
         }
         if(this.type == TYPE_SURVIVAL_DAMAGE)
         {
            return new SurvivalDamageDashBarDisplay();
         }
         if(this.type == TYPE_RESOURCE)
         {
            return new ResourceBarDisplay(this);
         }
         if(this.type == TYPE_HONOR)
         {
            return new HonorBarDisplay();
         }
         if(this.type == TYPE_INFAMY)
         {
            return new InfamyBarDisplay();
         }
         if(this.type == TYPE_XP)
         {
            return new XpBarDisplay();
         }
         if(this.type == TYPE_UNITS_KILLED)
         {
            return new UnitsKilledBarDisplay();
         }
         if(this.type == TYPE_CRITICAL_HITS)
         {
            return new CriticalHitsBarDisplay();
         }
         if(this.type == TYPE_EXPANSIONS)
         {
            return new ExpansionsBarDisplay();
         }
         if(this.type != TYPE_GLANCING_BLOWS)
         {
            if(this.type == TYPE_NEIGHBOR_TENDS)
            {
               return new NeighborTendsBarDisplay();
            }
            if(this.type == TYPE_RESEARCH_UPGRADES)
            {
               return new ResearchUpgradesBarDisplay();
            }
            if(this.type == TYPE_ELEMENT_Z_CONSUMED)
            {
               return new ElementZConsumedBarDisplay();
            }
            if(this.type == TYPE_WHITE_KNIGHT_REPELS)
            {
               return new WhiteKnightRepelsBarDisplay();
            }
            if(this.type == TYPE_POWER_UP_ADDICT)
            {
               return new PowerUpAddictBarDisplay();
            }
            if(this.type == TYPE_VILLAIN_TOKENS)
            {
               return new VillainTokensBarDisplay();
            }
         }
         return new BarDisplay();
      }
      
      public function getDateState() : int
      {
         return ZGameTimeUtil.instance.getDateStatus(null,this.xml);
      }
      
      public function get active() : Boolean
      {
         var _loc1_:int = this.getDateState();
         return _loc1_ == ZGameTimeUtil.DATE_STATUS_NONE || _loc1_ == ZGameTimeUtil.DATE_STATUS_ACTIVE;
      }
      
      public function isVisible(param1:Boolean) : Boolean
      {
         var _loc2_:int = this.getDateState();
         if(_loc2_ == ZGameTimeUtil.DATE_STATUS_EARLY)
         {
            return false;
         }
         if(_loc2_ == ZGameTimeUtil.DATE_STATUS_LATE)
         {
            if(!param1 || this.getValue(ZGlobal.player.uid) <= 0)
            {
               return false;
            }
         }
         if(!this.checkGate())
         {
            return false;
         }
         return true;
      }
      
      public function getPlacementRewards() : Array
      {
         var _loc1_:Array = null;
         if(this.xml.placementRewards != undefined)
         {
            _loc1_ = this.xml.placementRewards.toString().split(",");
         }
         return _loc1_;
      }
      
      public function getPlacementVirals() : Array
      {
         var _loc1_:Array = null;
         if(this.xml.placementVirals != undefined)
         {
            _loc1_ = this.xml.placementVirals.toString().split(",");
         }
         return _loc1_;
      }
      
      public function matchesMetric(param1:String) : Boolean
      {
         var _loc2_:Array = null;
         if(this.xml.metric)
         {
            _loc2_ = this.xml.metric.toString().split(",");
            return _loc2_.indexOf(param1) >= 0;
         }
         return true;
      }
      
      public function get numParticipationRewards() : uint
      {
         if(this.xml.participation != undefined)
         {
            return this.xml.participation.reward.length();
         }
         return 0;
      }
      
      public function getValue(param1:String) : int
      {
         var _loc3_:Object = null;
         var _loc2_:int = this.getIndex(param1);
         if(_loc2_ >= 0)
         {
            _loc3_ = this.results[_loc2_];
            return _loc3_.value;
         }
         return 0;
      }
      
      public function setValue(param1:int, param2:String) : void
      {
         var _loc4_:Object = null;
         var _loc3_:int = this.getIndex(param2);
         if(_loc3_ >= 0)
         {
            _loc4_ = this.results[_loc3_];
            _loc4_.value = param1;
            this.moveUp(_loc3_,_loc4_);
         }
      }
      
      public function updateValue(param1:int, param2:String) : void
      {
         var _loc4_:Object = null;
         var _loc3_:int = this.getIndex(param2);
         if(_loc3_ >= 0)
         {
            _loc4_ = this.results[_loc3_];
            _loc4_.value += param1;
            this.moveUp(_loc3_,_loc4_);
         }
      }
      
      public function addResults(param1:Array, param2:Boolean = false) : void
      {
         var _loc5_:XML = null;
         var _loc6_:* = 0;
         var _loc7_:int = 0;
         var _loc8_:uint = 0;
         var _loc9_:XML = null;
         var _loc10_:int = 0;
         var _loc11_:Object = null;
         var _loc12_:Player = null;
         var _loc13_:int = 0;
         var _loc14_:String = null;
         var _loc15_:Object = null;
         this.results = new Array();
         var _loc3_:Array = new Array();
         var _loc4_:Array = this.getAllPlayers();
         for each(_loc5_ in this.xml.participation.reward)
         {
            _loc3_.splice(0,0,_loc5_);
         }
         _loc6_ = int(_loc3_.length - 1);
         _loc7_ = int(param1.length);
         this.numEntries = _loc7_;
         _loc8_ = 0;
         _loc9_ = null;
         _loc10_ = 0;
         while(_loc8_ < _loc7_)
         {
            _loc11_ = param1[_loc8_];
            _loc9_ = this.isNextItemReward(_loc3_,_loc11_);
            if(_loc9_ != null)
            {
               this.addRewardAsEntry(_loc9_,_loc6_--);
            }
            else
            {
               _loc12_ = ZGlobal.player.findFriendById(_loc11_.zid);
               if(this.isPlayerValid(_loc12_))
               {
                  _loc13_ = _loc4_.indexOf(_loc12_.uid);
                  _loc4_.splice(_loc13_,1);
                  if(_loc11_.zid == ZGlobal.player.uid || param2 || _loc11_.value > 0)
                  {
                     this.results.push(_loc11_);
                     _loc11_.player = _loc12_;
                     _loc11_.localRank = ++_loc10_;
                  }
               }
               _loc8_++;
            }
         }
         while(_loc3_.length > 0)
         {
            this.addRewardAsEntry(this.isNextItemReward(_loc3_,null),_loc6_--);
         }
         while(_loc4_.length)
         {
            _loc14_ = _loc4_.pop();
            _loc15_ = new Object();
            _loc15_.player = ZGlobal.player.findFriendById(_loc14_);
            if(this.isPlayerValid(_loc15_.player) && param2 || _loc14_ == ZGlobal.player.uid)
            {
               _loc15_.zid = _loc14_;
               _loc15_.value = 0;
               _loc15_.localRank = ++_loc10_;
               this.results.push(_loc15_);
            }
         }
      }
      
      public function get rewardToCollect() : Boolean
      {
         if(this.anyParticipationRewardToCollect)
         {
            return true;
         }
         return false;
      }
      
      public function get isInteresting() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         if(!this.completedRewards[PLACEMENT_REWARD_INDEX])
         {
            _loc1_ = this.getDateState();
            if(_loc1_ == ZGameTimeUtil.DATE_STATUS_LATE)
            {
               _loc2_ = this.entry(ZGlobal.player.uid);
               if(Boolean(_loc2_) && Boolean(_loc2_.value > 0) && _loc2_.localRank < 4)
               {
                  return true;
               }
            }
         }
         return this.anyParticipationRewardToCollect;
      }
      
      public function allPossibleRewardsCollected(param1:int) : Boolean
      {
         if(param1 > 0 && !this.completedRewards[PLACEMENT_REWARD_INDEX])
         {
            return false;
         }
         return !this.anyParticipationRewardToCollect;
      }
      
      private function isPlayerValid(param1:Player) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         if(param1.uid == Player.FAKE_PLAYER_ID)
         {
            return false;
         }
         if(param1.uid == Player.SURVIVAL_MODE_ALY_ID || param1.uid == Player.MW2_XPROMO_ALLY_ID)
         {
            return false;
         }
         return true;
      }
      
      private function get anyParticipationRewardToCollect() : Boolean
      {
         var _loc3_:XML = null;
         var _loc1_:int = 0;
         var _loc2_:int = this.getValue(ZGlobal.player.uid);
         for each(_loc3_ in this.xml.participation.reward)
         {
            if(_loc2_ < _loc3_.@value)
            {
               break;
            }
            if(!this.completedRewards[_loc1_])
            {
               return true;
            }
            _loc1_++;
         }
         return false;
      }
      
      private function getAllPlayers() : Array
      {
         var _loc2_:String = null;
         var _loc1_:Array = [ZGlobal.player.uid];
         for(_loc2_ in ZGlobal.player.neighbors)
         {
            _loc1_.push(_loc2_);
         }
         return _loc1_;
      }
      
      private function addRewardAsEntry(param1:XML, param2:int) : void
      {
         this.results.push({
            "reward":param1,
            "value":parseInt(param1.@value),
            "rewardIndex":param2
         });
      }
      
      private function moveUp(param1:int, param2:Object) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Boolean = false;
         var _loc3_:int = param1;
         while(param1 > 0)
         {
            _loc4_ = this.results[param1 - 1];
            if(param2.value < _loc4_.value)
            {
               break;
            }
            param1--;
         }
         if(_loc3_ != param1)
         {
            this.results.splice(_loc3_,1);
            this.results.splice(param1,0,param2);
            this.reorderRanks();
            _loc5_ = false;
            if(param1 + 1 < this.results.length)
            {
               _loc5_ = Boolean(this.results[param1 + 1].hasOwnProperty("player"));
            }
            if(this.checkGate())
            {
               LeaderboardManager.instance.dispatchEvent(new WorldEvent(LeaderboardManager.LEADERBOARD_PLACE_CHANGED,{
                  "leaderboard":this,
                  "index":param1,
                  "passedPlayer":_loc5_
               }));
            }
         }
      }
      
      private function reorderRanks() : void
      {
         var _loc2_:Object = null;
         var _loc1_:uint = 0;
         for each(_loc2_ in this.results)
         {
            if(_loc2_.player)
            {
               _loc2_.localRank = ++_loc1_;
            }
         }
      }
      
      private function isNextItemReward(param1:Array, param2:Object) : XML
      {
         var _loc5_:XML = null;
         var _loc3_:int = param2 ? int(param2.value) : 0;
         var _loc4_:int = 0;
         for each(_loc5_ in param1)
         {
            if(_loc5_.@value > _loc3_)
            {
               param1.splice(_loc4_,1);
               return _loc5_;
            }
            _loc4_++;
         }
         return null;
      }
      
      public function checkGate() : Boolean
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         if(this.xml.requiredQuest != undefined)
         {
            if(!ZGlobal.player.didCompleteQuest(this.xml.requiredQuest))
            {
               return false;
            }
         }
         if(this.xml.requiredLevel != undefined)
         {
            if(ZGlobal.player.level < int(this.xml.requiredLevel))
            {
               return false;
            }
         }
         if(this.xml.requiredExperiment.@name != undefined)
         {
            if(this.xml.requiredExperiment.@variants != undefined)
            {
               _loc1_ = this.xml.requiredExperiment.@variants.split(",");
               _loc2_ = ExperimentsManager.instance.getExperimentVariant(this.xml.requiredExperiment.@name);
               if(_loc1_.indexOf(_loc2_.toString()) == -1)
               {
                  return false;
               }
            }
         }
         return true;
      }
      
      public function getIndex(param1:String) : int
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         for each(_loc3_ in this.results)
         {
            if(_loc3_.zid == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public function getNextPlayerId(param1:int, param2:int) : String
      {
         var _loc3_:int = int(this.results.length);
         var _loc4_:int = param1 + param2;
         while(_loc4_ >= 0 && _loc4_ < _loc3_)
         {
            if(this.results[_loc4_].player)
            {
               return this.results[_loc4_].player.uid;
            }
            _loc4_ += param2;
         }
         return null;
      }
      
      public function getNextReward(param1:int, param2:int) : XML
      {
         var _loc3_:int = int(this.results.length);
         var _loc4_:int = param1 + param2;
         while(_loc4_ >= 0 && _loc4_ < _loc3_)
         {
            if(this.results[_loc4_].reward)
            {
               return this.results[_loc4_].reward;
            }
            _loc4_ += param2;
         }
         return null;
      }
   }
}

