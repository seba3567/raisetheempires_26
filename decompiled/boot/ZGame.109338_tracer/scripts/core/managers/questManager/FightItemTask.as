package core.managers.questManager
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gamemode.battle.Battle;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.GMBattle;
   import core.gameobjects.BaddieItem;
   import core.gameobjects.Fleet;
   import core.gameobjects.UnitItem;
   import core.gameobjects.fleet.FleetComposition;
   import core.gameobjects.questPower.QuestPower;
   import core.managers.WorldUpgradeManager;
   import core.managers.tutorialManager.TutorialManager;
   import transactions.TBeginQuestBattle;
   import transactions.TSpawnFleet;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   
   public class FightItemTask extends ZGameTask
   {
      
      public function FightItemTask(param1:int, param2:XML, param3:String, param4:Number)
      {
         super(param1,param2,param3,param4);
         if(param2.@item.toString().length == 0)
         {
            Logger.error(this,"FightItemTask","type: \'fight\' does not have recognised subtype (item)");
         }
      }
      
      public function get regenerateOnRetreat() : Boolean
      {
         return m_xml.@regenerateOnRetreat.toString() == "true";
      }
      
      public function get isPVE() : Boolean
      {
         return m_xml.@isPVE.toString() == "true";
      }
      
      public function get winPopupUsesFirstVictory() : Boolean
      {
         return m_xml.@winPopupUsesFirstVictory.toString() == "true";
      }
      
      public function get episodeDialog() : String
      {
         return m_xml.@showEpisodeDialog.toString();
      }
      
      public function get defaultSelectSlot() : String
      {
         return m_xml.@defaultSelectSlot.toString();
      }
      
      override public function get fleetComposition() : Array
      {
         var _loc1_:FleetComposition = new FleetComposition(m_xml);
         return _loc1_.units;
      }
      
      override public function get hasCombatSetup() : Boolean
      {
         return m_xml.combat != undefined;
      }
      
      override public function get combatSetup() : Object
      {
         var _loc1_:Object = new Object();
         _loc1_.maxUnits = parseInt(m_xml.combat.@maxUnits);
         _loc1_.numAllies = parseInt(m_xml.combat.@numAllies);
         _loc1_.playerType = m_xml.combat.@playerType.toString();
         return _loc1_;
      }
      
      override public function get combatAllies() : Array
      {
         return ZGameUtils.callFunctionFromXml(m_xml.fight.@allies);
      }
      
      public function get percentageRetreat() : Number
      {
         return m_xml.fight.@percentageRetreat;
      }
      
      override public function start() : void
      {
         if(m_xml.@immediate.toString() == "1")
         {
            if(m_xml.@showEpisodeDialog.toString().length > 0)
            {
               GMBattle.createStaticBattleFromQuest(null,fleetName,m_xml.@showEpisodeDialog.toString());
            }
            else
            {
               GMBattle.createStaticBattleFromQuest({
                  "id":m_questName,
                  "index":m_taskIndex
               },fleetName);
            }
         }
      }
      
      override protected function onSetActive(param1:Boolean) : void
      {
         var _loc2_:Fleet = null;
         super.onSetActive(param1);
         if(param1)
         {
            _loc2_ = Fleet.getFleet(fleetName);
            if(!_loc2_)
            {
               _loc2_ = this.createBaddies();
            }
            if(!_loc2_.battleTarget)
            {
               this.createMissingPlayerFleet(_loc2_);
            }
            BattleDispatcher.instance.addEventListener(BattleDispatcher.QUEST_BATTLE_STARTED,this.onBattleStart);
            BattleDispatcher.instance.addEventListener(BattleDispatcher.PLAYER_FLEET_DESTROYED,this.onPlayerFleetDestroyed);
         }
         else
         {
            BattleDispatcher.instance.removeEventListener(BattleDispatcher.QUEST_BATTLE_STARTED,this.onBattleStart);
            BattleDispatcher.instance.removeEventListener(BattleDispatcher.PLAYER_FLEET_DESTROYED,this.onPlayerFleetDestroyed);
         }
      }
      
      private function onBattleStart(param1:WorldEvent) : void
      {
         if(fleetName == param1.eventData)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_START));
         }
      }
      
      private function onPlayerFleetDestroyed(param1:WorldEvent) : void
      {
         var _loc3_:Fleet = null;
         var _loc2_:String = fleetName;
         if(_loc2_ == param1.eventData)
         {
            _loc3_ = Fleet.getFleet(_loc2_);
            this.createMissingPlayerFleet(_loc3_);
         }
      }
      
      private function createMissingPlayerFleet(param1:Fleet) : void
      {
         var _loc2_:String = param1.type;
         if(this.combatSetup.playerType)
         {
            _loc2_ = this.combatSetup.playerType;
         }
         var _loc3_:Fleet = this.createPlayerFleet(_loc2_,param1.name);
         Fleet.linkFleets(_loc3_,param1);
         TransactionManager.addTransaction(new TBeginQuestBattle(questName,param1.name));
      }
      
      private function createPlayerFleet(param1:String, param2:String) : Fleet
      {
         var _loc5_:UnitItem = null;
         var _loc6_:String = null;
         var _loc3_:Fleet = null;
         var _loc4_:Array = this.fleetComposition;
         if(null != _loc4_ && _loc4_.length > 0)
         {
            _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc4_[0],UnitItem) as UnitItem;
            _loc3_ = ZGlobal.player.fleets.createFleet(_loc5_.subType,true);
            _loc3_.setStatus(Fleet.FREE);
            for each(_loc6_ in _loc4_)
            {
               _loc3_.addUpgrades(_loc6_,WorldUpgradeManager.instance.getUpgradesByCode(_loc6_));
               _loc3_.addUnit(_loc6_);
            }
         }
         else
         {
            _loc3_ = ZGlobal.player.fleets.createFleet(param1,true);
         }
         if(ZGlobal.player.questTrees.isQuestTreeQuest(questName))
         {
            _loc3_.setStatus(Fleet.QUESTTREE);
            this.addQuestPowers(_loc3_);
         }
         _loc3_.battleTarget = param2;
         return _loc3_;
      }
      
      private function addQuestPowers(param1:Fleet) : void
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc2_:String = m_xml.fight.powers;
         if(_loc2_)
         {
            _loc3_ = _loc2_.split(",");
            _loc4_ = 0;
            for each(_loc5_ in _loc3_)
            {
               _loc6_ = QuestPower.POWER_TAG + _loc4_ + "_" + _loc5_;
               param1.addAlly(_loc6_);
               ZGlobal.player.allies.addAlly(_loc6_);
               _loc4_++;
            }
         }
      }
      
      override public function buyCompletion() : void
      {
         if(!m_complete)
         {
            ZGlobal.player.fleets.fightItemTaskComplete(this.fleetName,Battle.BATTLE_RESULT_NONE);
         }
      }
      
      private function createBaddies() : Fleet
      {
         var _loc1_:String = m_xml.@item.toString();
         var _loc2_:BaddieItem = ZGlobal.gameSettings.getItemByCode(_loc1_,BaddieItem) as BaddieItem;
         var _loc3_:Array = _loc2_.items;
         var _loc4_:String = "";
         var _loc5_:UnitItem = ZGlobal.gameSettings.getItemByCode(_loc3_[0].code,UnitItem) as UnitItem;
         _loc4_ = _loc5_.subType;
         var _loc6_:Fleet = ZGlobal.player.fleets.createFleet(_loc4_,false);
         _loc6_.name = fleetName;
         _loc6_.setStatus(Fleet.QUEST);
         if(_loc5_.hasType(UnitItem.MEGA_UNIT) || this.regenerateOnRetreat)
         {
            _loc6_.setStatus(Fleet.RESTORE_ON_RETREAT);
         }
         _loc2_.addUnitsToFleet(_loc6_,_loc3_);
         if(this.combatSetup.playerType)
         {
            _loc4_ = this.combatSetup.playerType;
         }
         var _loc7_:Fleet = this.createPlayerFleet(_loc4_,_loc6_.name);
         _loc6_.battleTarget = _loc7_.name;
         TransactionManager.addTransaction(new TSpawnFleet(questName,_loc6_.name));
         m_cachedNeed = 1;
         return _loc6_;
      }
   }
}

