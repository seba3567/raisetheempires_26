package core.managers.autoActionsManager
{
   import core.managers.AlliancesManager;
   import core.managers.CommandoManager;
   import core.managers.CyclonePowerManager;
   import core.managers.DeepSeaDrillManager;
   import core.managers.EnergiserManager;
   import core.managers.ExperimentsManager;
   import core.managers.MatchMakingManager;
   import core.managers.MeteoriteMiningManager;
   import core.managers.NuclearPowerManager;
   import core.managers.QuestBuildableManager;
   import core.managers.RaffleManager;
   import core.managers.TimedBuildableManager;
   import core.managers.VolcanoPowerManager;
   import core.managers.VolcanoReskin6Manager;
   import core.managers.WorldGamesManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.mayhemManager.MayhemManager;
   import core.managers.miniGameManager.BomberGameManager;
   import core.managers.tutorialManager.TutorialManager;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   
   public class AutoActionsManager extends EventDispatcher
   {
      
      private static var m_instance:AutoActionsManager = new AutoActionsManager();
      
      private var m_activeAction:AutoAction;
      
      public function AutoActionsManager(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public static function get instance() : AutoActionsManager
      {
         return m_instance;
      }
      
      public function set activeAction(param1:AutoAction) : void
      {
         this.m_activeAction = param1;
      }
      
      public function islandMayhemDemo() : void
      {
         var _loc1_:Boolean = ExperimentsManager.instance.getExperimentVariant("empire_buildable_mayhem_master") == 3;
         if(_loc1_)
         {
            MayhemManager.instance.initiateMayhemEvents();
         }
      }
      
      public function initEnergiser() : void
      {
         var _loc1_:Boolean = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_BUILDABLE_ENERGYBOOSTER_MASTER) == ExperimentsManager.VARIANT_BUILDABLE_ENERGYBOOSTER_ON;
         if(_loc1_)
         {
            EnergiserManager.instance.initEvents();
         }
      }
      
      public function initCommando() : void
      {
         CommandoManager.instance.initEvents();
      }
      
      public function initVolcanoPower() : void
      {
         VolcanoPowerManager.instance.showStory();
      }
      
      public function initWorldGames() : void
      {
         WorldGamesManager.instance.onStart();
      }
      
      public function initMeteoriteMining() : void
      {
         MeteoriteMiningManager.instance.showStory();
      }
      
      public function initQuestBuildable() : void
      {
         QuestBuildableManager.instance.onStart();
      }
      
      public function initCyclonePower() : void
      {
         CyclonePowerManager.instance.showStory();
      }
      
      public function initDeepSeaDrill() : void
      {
         DeepSeaDrillManager.instance.showStory();
      }
      
      public function initRaffle() : void
      {
         RaffleManager.instance.onStart();
      }
      
      public function initElementZCollider() : void
      {
         var _loc2_:AutoActionShowSpeechPopup = null;
         var _loc3_:AutoActionPlaceItem = null;
         var _loc1_:Boolean = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_BUILDABLE_ZCOLLIDER_MASTER) == 3;
         if(_loc1_)
         {
            _loc2_ = new AutoActionShowSpeechPopup();
            _loc2_.data = {"speechId":"Speech_Seabolt_ElementZCoil"};
            _loc3_ = new AutoActionPlaceItem();
            _loc3_.data = {"item":"EZC1"};
            _loc2_.setNextAction(_loc3_);
            _loc2_.startAction();
         }
      }
      
      public function initMatchMaking() : void
      {
         if(MatchMakingManager.instance.isActive())
         {
            MatchMakingManager.instance.initializeActions();
         }
      }
      
      public function showDominationDialog() : void
      {
         DominationModeManager.instance.launchDominationScreen();
      }
      
      public function startBomberGame() : void
      {
         BomberGameManager.instance.showTutorial();
      }
      
      public function initNuclearPower() : void
      {
         NuclearPowerManager.instance.showStory();
      }
      
      public function initElementZGenerator() : void
      {
         var _loc1_:AutoActionShowSpeechPopup = null;
         var _loc2_:AutoActionPlaceItem = null;
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_BUILDABLE_ZGENERATOR_MASTER) == 3)
         {
            _loc1_ = new AutoActionShowSpeechPopup();
            _loc1_.data = {"speechId":"Speech_ElementZGenerator_01"};
            _loc2_ = new AutoActionPlaceItem();
            _loc2_.data = {"item":"DB15"};
            _loc1_.setNextAction(_loc2_);
            _loc1_.startAction();
         }
      }
      
      public function initVolcanoReskin6() : void
      {
         VolcanoReskin6Manager.instance.showStory();
      }
      
      public function initTimedBuildable(param1:String, param2:String) : void
      {
         TimedBuildableManager.instance.showStory(param1,param2);
      }
      
      public function allianceArrow() : void
      {
         AlliancesManager.instance.m_motdActive = true;
         TutorialManager.instance.sendEvent(TutorialManager.ALLIANCE_HUD,true);
      }
   }
}

