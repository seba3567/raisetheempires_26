package core.worlds.strategicWorld
{
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import core.gamemode.battle.Battle;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.GMBattle;
   import core.gamemode.battle.GMBattleReplay;
   import core.gamemode.prebattle.GMPreBattle;
   import core.gameobjects.ConversationItemWrapper;
   import core.gameobjects.Fleet;
   import core.gameobjects.IslandGroupItem;
   import core.gameobjects.IslandItem;
   import core.gameobjects.LetterItemWrapper;
   import core.gameobjects.RewardHelper;
   import core.gameobjects.SpeechItemWrapper;
   import dispatchers.StrategicDispatcher;
   import displays.popups.ConversationPopup;
   import displays.popups.LetterPopup;
   import displays.popups.SpeechPopup;
   import flash.geom.Point;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class StrategicMap
   {
      
      public static const IN_PROGRESS:int = 1 << 0;
      
      public static const IN_REPLAY:int = 1 << 1;
      
      public static const PAUSED:int = 1 << 2;
      
      private var m_code:String = null;
      
      private var m_fleets:Array = null;
      
      private var m_currentIslandItem:IslandItem = null;
      
      private var m_progressIsland:int = 0;
      
      private var m_replayIsland:int = 0;
      
      private var m_lastIsland:int = 0;
      
      private var m_lastIslandStatus:int = 0;
      
      private var m_celebrationIsland:int = -1;
      
      private var m_status:int = 0;
      
      public function StrategicMap(param1:String)
      {
         super();
         this.m_code = param1;
      }
      
      public function loadFromData(param1:Object) : void
      {
         this.m_fleets = param1.fleets;
         this.m_progressIsland = (param1.status & 0xFFF00000) >> 20;
         this.m_replayIsland = (param1.status & 0x0FFF00) >> 8;
         this.m_status = param1.status & 0xFF;
      }
      
      public function get code() : String
      {
         return this.m_code;
      }
      
      public function start(param1:IslandItem, param2:String, param3:String) : void
      {
         this.m_status |= IN_PROGRESS;
         this.m_status &= ~PAUSED;
         this.m_currentIslandItem = param1;
         this.m_fleets = [param2,param3];
         ZGlobal.player.campaign.calculateMasteryScalar();
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.BATTLE_COMPLETE,this.onBattleComplete,false,0,true);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_PAUSE,this.onBattlePaused,false,0,true);
         var _loc4_:Fleet = Fleet.getFleet(param2);
         if(this.inReplay)
         {
            GameModeManager.instance.addGameMode(new GMBattleReplay(_loc4_,Fleet.getFleet(param3)));
         }
         else
         {
            GameModeManager.instance.addGameMode(new GMBattle(_loc4_,Fleet.getFleet(param3)));
         }
         if(GMPreBattle.ENABLED)
         {
            GMPreBattle.ACTIVE = _loc4_.units.length == 0;
            if(GMPreBattle.ACTIVE)
            {
               GameModeManager.instance.addGameMode(new GMPreBattle(_loc4_,Fleet.getFleet(param3),param1.maxUnits),false);
            }
         }
      }
      
      public function haltProgress(param1:int) : void
      {
         if((this.m_status & PAUSED) != 0)
         {
            this.battleComplete(param1);
         }
      }
      
      public function showStartingConversation() : void
      {
         var _loc1_:IslandGroupItem = null;
         var _loc2_:ConversationItemWrapper = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(!this.inProgress && this.m_progressIsland == 0)
         {
            if(!ZGlobal.player.campaign.isMapLocked(this.m_code))
            {
               _loc1_ = ZGlobal.gameSettings.getItemByCode(this.m_code,IslandGroupItem) as IslandGroupItem;
               _loc2_ = new ConversationItemWrapper(_loc1_);
               _loc3_ = _loc2_.startingConversation;
               _loc4_ = _loc2_.conversationVersion;
               if(Boolean(_loc3_) && !ZGlobal.player.hasSeenConversation(_loc3_))
               {
                  PopupManager.instance.push(new ConversationPopup(_loc3_,null,_loc4_));
               }
            }
         }
      }
      
      public function showStartingLetter() : void
      {
         var _loc1_:IslandGroupItem = null;
         var _loc2_:LetterItemWrapper = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(!this.inProgress && this.m_progressIsland == 0)
         {
            if(!ZGlobal.player.campaign.isMapLocked(this.m_code))
            {
               _loc1_ = ZGlobal.gameSettings.getItemByCode(this.m_code,IslandGroupItem) as IslandGroupItem;
               _loc2_ = new LetterItemWrapper(_loc1_);
               _loc3_ = _loc2_.startingLetter;
               _loc4_ = _loc2_.letterVersion;
               if(Boolean(_loc3_) && !ZGlobal.player.hasSeenDialog("letter",_loc3_))
               {
                  PopupManager.instance.push(new LetterPopup(_loc3_,null,_loc4_));
               }
            }
         }
      }
      
      public function showStartingSpeech() : void
      {
         var _loc1_:IslandGroupItem = null;
         var _loc2_:SpeechItemWrapper = null;
         var _loc3_:String = null;
         if(!this.inProgress && this.m_progressIsland == 0)
         {
            if(!ZGlobal.player.campaign.isMapLocked(this.m_code))
            {
               _loc1_ = ZGlobal.gameSettings.getItemByCode(this.m_code,IslandGroupItem) as IslandGroupItem;
               _loc2_ = new SpeechItemWrapper(_loc1_);
               _loc3_ = _loc2_.startingSpeech;
               if(Boolean(_loc3_) && !ZGlobal.player.hasSeenSpeech(_loc3_))
               {
                  PopupManager.instance.push(new SpeechPopup(_loc3_),0,true,false);
               }
            }
         }
      }
      
      public function replay(param1:IslandItem) : void
      {
         if(null != param1)
         {
            this.m_status |= IN_REPLAY;
            this.m_replayIsland = param1.index;
         }
         else
         {
            this.m_status &= ~IN_REPLAY;
            this.m_replayIsland = 0;
         }
      }
      
      public function get progressIsland() : int
      {
         return this.m_progressIsland;
      }
      
      public function get lastIsland() : int
      {
         return this.m_lastIsland;
      }
      
      public function get celebrationIsland() : int
      {
         return this.m_celebrationIsland;
      }
      
      public function set celebrationIsland(param1:int) : void
      {
         this.m_celebrationIsland = param1;
      }
      
      public function get replayIsland() : int
      {
         return this.m_replayIsland;
      }
      
      public function get currentIslandItem() : IslandItem
      {
         return this.m_currentIslandItem;
      }
      
      public function get inProgress() : Boolean
      {
         return (this.m_status & IN_PROGRESS) != 0;
      }
      
      public function get inReplay() : Boolean
      {
         return (this.m_status & IN_REPLAY) != 0;
      }
      
      public function get fleets() : Array
      {
         return this.m_fleets;
      }
      
      public function get numUnits() : int
      {
         var _loc1_:IslandGroupItem = ZGlobal.gameSettings.getItemByCode(this.m_code,IslandGroupItem) as IslandGroupItem;
         return _loc1_.getMaxUnits(this.island);
      }
      
      public function get numAllies() : int
      {
         var _loc1_:IslandGroupItem = ZGlobal.gameSettings.getItemByCode(this.m_code,IslandGroupItem) as IslandGroupItem;
         return Math.min(_loc1_.getNumAllies(this.island),5);
      }
      
      public function get numIslands() : int
      {
         var _loc1_:IslandGroupItem = ZGlobal.gameSettings.getItemByCode(this.m_code,IslandGroupItem) as IslandGroupItem;
         return _loc1_.numIslands;
      }
      
      public function get playerType() : String
      {
         var _loc1_:IslandGroupItem = ZGlobal.gameSettings.getItemByCode(this.m_code,IslandGroupItem) as IslandGroupItem;
         return _loc1_.getPlayerType(this.island);
      }
      
      public function get villain() : String
      {
         var _loc1_:IslandGroupItem = ZGlobal.gameSettings.getItemByCode(this.m_code,IslandGroupItem) as IslandGroupItem;
         return _loc1_.villain;
      }
      
      public function get title() : String
      {
         var _loc1_:IslandGroupItem = ZGlobal.gameSettings.getItemByCode(this.m_code,IslandGroupItem) as IslandGroupItem;
         return ZGameUtils.ZlocT("Campaign",_loc1_.title);
      }
      
      public function getUnlocks(param1:int) : Array
      {
         var _loc2_:Array = new Array();
         var _loc3_:IslandGroupItem = ZGlobal.gameSettings.getItemByCode(this.m_code,IslandGroupItem) as IslandGroupItem;
         var _loc4_:Object = _loc3_.getNextIsland(param1);
         _loc2_.push(_loc4_.island);
         return _loc2_;
      }
      
      public function getPosition(param1:int) : Point
      {
         var _loc2_:IslandGroupItem = ZGlobal.gameSettings.getItemByCode(this.m_code,IslandGroupItem) as IslandGroupItem;
         return _loc2_.getPosition(param1);
      }
      
      public function getName(param1:int) : String
      {
         var _loc2_:IslandGroupItem = ZGlobal.gameSettings.getItemByCode(this.m_code,IslandGroupItem) as IslandGroupItem;
         return _loc2_.getName(param1);
      }
      
      public function getItem(param1:int) : IslandItem
      {
         var _loc2_:IslandGroupItem = ZGlobal.gameSettings.getItemByCode(this.m_code,IslandGroupItem) as IslandGroupItem;
         return _loc2_.getItem(param1,this.m_code);
      }
      
      private function get island() : int
      {
         if(this.inReplay)
         {
            return this.m_replayIsland;
         }
         return this.m_progressIsland;
      }
      
      private function removeListeners() : void
      {
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.BATTLE_COMPLETE,this.onBattleComplete);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_PAUSE,this.onBattlePaused);
      }
      
      private function onBattlePaused(param1:WorldEvent) : void
      {
         this.removeListeners();
         this.m_status |= PAUSED;
      }
      
      private function onBattleComplete(param1:WorldEvent) : void
      {
         this.battleComplete(param1.eventData as int);
      }
      
      private function battleComplete(param1:int) : void
      {
         var _loc2_:IslandGroupItem = null;
         var _loc3_:Object = null;
         this.removeListeners();
         if(param1 == Battle.BATTLE_RESULT_WON)
         {
            this.m_currentIslandItem.giveRewards(!this.inReplay);
            if(!this.inReplay)
            {
               _loc2_ = ZGlobal.gameSettings.getItemByCode(this.m_code,IslandGroupItem) as IslandGroupItem;
               StrategicDispatcher.instance.dispatchEvent(new WorldEvent(StrategicDispatcher.CAMPAIGN_BATTLE_WON,{
                  "leaderboardId":_loc2_.leaderboardId,
                  "index":this.m_currentIslandItem.globalIndex
               }));
               _loc3_ = _loc2_.getNextIsland(this.m_progressIsland);
               this.m_lastIsland = this.m_progressIsland;
               this.m_lastIslandStatus = this.m_status;
               if(ZGlobal.player.campaign.getPreviousMastery(this.m_progressIsland) == 0)
               {
                  this.m_celebrationIsland = this.m_progressIsland;
                  if(_loc3_.island == _loc2_.numIslands)
                  {
                     ZGlobal.player.campaign.celebrationMap = this.m_code;
                  }
               }
               this.m_progressIsland = _loc3_.island;
               ZGlobal.player.campaign.nextMap = _loc3_.map;
            }
            else if(ZGlobal.player.campaign.getIslandMastery(this.m_code) > ZGlobal.player.campaign.getPreviousIslandMastery(this.m_code))
            {
               this.m_celebrationIsland = this.m_progressIsland;
               ZGlobal.player.campaign.celebrationMap = this.m_code;
            }
         }
         this.m_status &= ~IN_PROGRESS;
         this.m_status &= ~PAUSED;
         if(this.inReplay)
         {
            this.m_lastIsland = this.m_replayIsland;
            this.m_lastIslandStatus = this.m_status;
            this.replay(null);
         }
      }
      
      public function getTextObject(param1:Object, param2:Boolean, param3:IslandItem, param4:int = 2) : void
      {
         var _loc5_:XML = null;
         var _loc8_:int = 0;
         var _loc9_:XML = null;
         var _loc10_:RewardHelper = null;
         var _loc11_:int = 0;
         var _loc12_:String = null;
         var _loc13_:RewardHelper = null;
         if(param3 == null)
         {
            _loc5_ = this.m_currentIslandItem.xml;
         }
         else
         {
            _loc5_ = param3.xml;
         }
         param1.rewardText = new Array();
         param1.rewardIcons = new Array();
         param1.rewardPairs = new Array();
         var _loc6_:Boolean = (this.m_lastIslandStatus & IN_REPLAY) == 0;
         var _loc7_:Number = ZGlobal.player.campaign.getRewardMultiplier(!_loc6_);
         if(_loc7_ > 0)
         {
            _loc8_ = ZGlobal.gameSettings.getInt("combatReplayRewardMinimum",100);
            for each(_loc9_ in _loc5_.reward)
            {
               _loc10_ = new RewardHelper(_loc9_);
               if(!_loc10_.isItem || _loc6_)
               {
                  _loc10_.multiplier = _loc7_;
                  _loc10_.multiplierMinimum = _loc8_;
                  _loc10_.buildUI(param1,param4);
               }
            }
            if(_loc6_)
            {
               _loc11_ = ZGlobal.gameSettings.getInt("combatBondRewardsPerBattle",3);
               _loc12_ = ZGlobal.gameSettings.getString("combatBondRewardType","xk01");
               _loc13_ = new RewardHelper(null);
               _loc13_.init("item",_loc11_,_loc12_);
               _loc13_.buildUI(param1,param4);
            }
         }
      }
   }
}

