package core.gamemode.prebattle
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.gamemode.GameMode;
   import core.gamemode.GameModeManager;
   import core.gamemode.battle.BattleDispatcher;
   import core.gameobjects.Fleet;
   import core.managers.ChallengeModeManager;
   import core.managers.QuestSurvivalModeManager;
   import core.managers.deathMatchManager.DeathMatchManager;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import core.player.questTrees.QuestTree;
   import core.ui.menuitem.ContextualBarUIItem;
   import core.ui.menuitem.PlayerStatsUIItem;
   import core.views.ViewManager;
   import core.worlds.battleWorld.BattleRendererComponent;
   import core.worlds.battleWorld.BattleWorld;
   import dispatchers.UIDispatcher;
   import displays.popups.genericPopup.GenericPopup1B;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import transactions.TAddFleet;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class GMPreBattle extends GameMode implements IPreBattle
   {
      
      public static const ENABLED:Boolean = true;
      
      public static var ACTIVE:Boolean = false;
      
      public static var IN_DISABLE_STATE:Boolean = false;
      
      private var m_playerFleet:Fleet = null;
      
      private var m_enemyFleet:Fleet = null;
      
      private var m_maxUnits:int = 0;
      
      private var m_questData:Object = null;
      
      private var m_terrainSelectMode:Boolean = false;
      
      public function GMPreBattle(param1:Fleet, param2:Fleet, param3:int, param4:Boolean = false, param5:Object = null)
      {
         super();
         this.m_playerFleet = param1;
         this.m_enemyFleet = param2;
         this.m_maxUnits = param3;
         this.m_terrainSelectMode = param4;
         this.m_questData = param5;
      }
      
      public function startFight() : void
      {
         if(ChallengeModeManager.instance.isInChallengeBattle())
         {
            ChallengeModeManager.instance.startFight();
         }
         else if(SurvivalModeManager.instance.isInSurvivalBattle())
         {
            SurvivalModeManager.instance.startFight();
         }
         else if(QuestSurvivalModeManager.instance.isInQuestSurvivalBattle())
         {
            QuestSurvivalModeManager.instance.startFight();
         }
         else if(DeathMatchManager.instance.isInDeathMatchBattle())
         {
            DeathMatchManager.instance.startFight();
         }
         else
         {
            TransactionManager.addTransaction(new TAddFleet(this.m_playerFleet.name));
         }
         IN_DISABLE_STATE = true;
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_RECREATE_PLAYER_GROUP,this.m_playerFleet));
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_START,this.m_playerFleet));
         IN_DISABLE_STATE = false;
         GameModeManager.instance.popGameMode();
      }
      
      public function cancelFight() : void
      {
         GameModeManager.instance.popGameMode();
         if(ChallengeModeManager.instance.isInChallengeBattle())
         {
            ChallengeModeManager.instance.cancelFight();
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_PAUSE,{"inPreBattle":true}));
         }
         else if(SurvivalModeManager.instance.isInSurvivalBattle())
         {
            SurvivalModeManager.instance.cancelFight();
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_PAUSE,{"inPreBattle":true}));
         }
         else if(QuestSurvivalModeManager.instance.isInQuestSurvivalBattle())
         {
            QuestSurvivalModeManager.instance.cancelFight();
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_PAUSE,{"inPreBattle":true}));
         }
         else if(DeathMatchManager.instance.isInDeathMatchBattle())
         {
            DeathMatchManager.instance.cancelFight();
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_PAUSE,{"inPreBattle":true}));
         }
         else
         {
            BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_CANCEL));
         }
      }
      
      private function onCancel(param1:Event) : void
      {
         this.cancelFight();
      }
      
      public function get fleet() : Fleet
      {
         return this.m_playerFleet;
      }
      
      public function get enemyFleet() : Fleet
      {
         return this.m_enemyFleet;
      }
      
      public function get numUnits() : int
      {
         return this.m_maxUnits;
      }
      
      public function get questData() : Object
      {
         return this.m_questData;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         PreBattleUI.getPreBattleUI().dispatchEvent(new WorldEvent(PreBattleUI.REMOVE_PREBATTLE_UI));
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         PreBattleUI.getPreBattleUI().dispatchEvent(new WorldEvent(PreBattleUI.ADD_PREBATTLE_UI,{
            "preBattle":this,
            "terrainSelect":this.m_terrainSelectMode
         }));
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_OR_PREBATTLE_GM_ENTERED,{"entered":true}));
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.UI_PLAYER_ISLAND_MODE_ACTIVE,{"active":false}));
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.UI_PAUSE_QUEST_ICONS,true));
         PlayerStatsUIItem.getPlayerStats().dispatchEvent(new WorldEvent(PlayerStatsUIItem.HIDE_ELEMENTS_FOR_CAMPAIGN,true));
         ContextualBarUIItem.getContextualBar().hide(false);
         BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_PRE_START));
         BattleDispatcher.instance.addEventListener(BattleDispatcher.PRE_BATTLE_CANCEL,this.onCancel);
         this.displayStoryPopup();
      }
      
      override public function disableMode() : void
      {
         super.disableMode();
         GMPreBattle.ACTIVE = false;
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_OR_PREBATTLE_GM_ENTERED,{"entered":false}));
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.UI_PLAYER_ISLAND_MODE_ACTIVE,{"active":true}));
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.UI_PAUSE_QUEST_ICONS,false));
         PlayerStatsUIItem.getPlayerStats().dispatchEvent(new WorldEvent(PlayerStatsUIItem.HIDE_ELEMENTS_FOR_CAMPAIGN,false));
         ContextualBarUIItem.getContextualBar().show(false);
         BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_PRE_END));
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.PRE_BATTLE_CANCEL,this.onCancel);
      }
      
      private function get renderer() : DisplayObjectContainer
      {
         var _loc1_:BattleRendererComponent = ViewManager.instance.getComponentFromView(BattleWorld.ID,BattleRendererComponent) as BattleRendererComponent;
         return _loc1_.displayObject.parent;
      }
      
      private function displayStoryPopup() : void
      {
         var _loc1_:Object = null;
         var _loc2_:String = null;
         var _loc3_:QuestTree = null;
         if(this.m_playerFleet.hasStatus(Fleet.QUESTTREE))
         {
            _loc1_ = (QuestManager.getInstance() as ZGameQuestManager).getTaskInfoFromFleetName(this.m_enemyFleet.name);
            _loc2_ = ZGlobal.player.questTrees.getQuestTreeNameForQuest(_loc1_.id);
            _loc3_ = ZGlobal.player.questTrees.getQuestTree(_loc2_);
            if(Boolean(_loc3_) && Boolean(_loc3_.xml.preBattle) && _loc3_.xml.preBattle != undefined)
            {
               PopupManager.instance.push(new GenericPopup1B(ZGameUtils.ZlocT("QuestTrees",_loc3_.xml.preBattle.@desc),ZGameUtils.ZlocT("QuestTrees",_loc3_.xml.preBattle.@title),0,null));
            }
         }
      }
   }
}

