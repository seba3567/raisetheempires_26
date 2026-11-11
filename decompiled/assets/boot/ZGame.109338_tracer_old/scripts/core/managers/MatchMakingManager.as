package core.managers
{
   import Engine.Classes.SocialNetworkUser;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.ParliamentPickComponent;
   import core.entities.components.ParliamentPickComponentUpgrade;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.gameobjects.GameItem;
   import core.managers.autoActionsManager.AutoActionPanToEntity;
   import core.managers.viralsManager.ViralsManager;
   import core.player.Player;
   import displays.screens.CrewResizablePopUp;
   import displays.screens.MatchMakingScreen;
   import displays.screens.requests.RequestDialog;
   import entity.GameDataComponent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   import transactions.TMatchMaking;
   import transactions.TMatchMakingOptFlag;
   import transactions.TRequestNeighbor;
   import transactions.TUpgradeState;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.entity.EntityComponent;
   import zlabs.entity.IEntity;
   
   public class MatchMakingManager extends EventDispatcher
   {
      
      public static const BUILDING_CODE:String = "CA2";
      
      public static const MATCHMAKING_OPTIN:String = "MatchMakingoptIn";
      
      public static const MATCHMAKING_MASTER_NAME:String = "empire_matchmaking_master";
      
      public static const MATCHMAKING_MASTER_VALUE:uint = 3;
      
      public static var instance:MatchMakingManager = new MatchMakingManager();
      
      private static var uidMMNeighborCodeFlow:String = "";
      
      private static var bMMCodeFlow:Boolean = false;
      
      private var m_pick:EntityComponent;
      
      protected var m_data:Dictionary = null;
      
      private var m_optin:Boolean = true;
      
      private var m_init:Boolean = false;
      
      private var m_retriveData:Boolean = false;
      
      private var m_window:PopUpBase;
      
      public function MatchMakingManager(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public static function IsRequestPending(param1:String) : Boolean
      {
         if(ZGlobal.player.pendingNeighbors.indexOf(param1) < 0)
         {
            return false;
         }
         return true;
      }
      
      public static function IsAddFBButtonExpON() : Boolean
      {
         return ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MATCHMAKING_ADD_FB_BTN_FEEDS) == ExperimentsManager.EXPERIMENT_MATCHMAKING_ADD_FB_BTN_FEEDS_ON;
      }
      
      public static function MMNeighborCodeFlow(param1:String) : Boolean
      {
         if(uidMMNeighborCodeFlow == param1)
         {
            return bMMCodeFlow;
         }
         uidMMNeighborCodeFlow = param1;
         bMMCodeFlow = MatchMakingManager.instance.isActive() && MatchMakingManager.instance.isMatchMadeNeighbor(param1) && ZGlobal.player.friends.indexOf(param1) < 0;
         Logger.print(MatchMakingManager,"MatchMakingCodeFlow: " + bMMCodeFlow + " | " + param1);
         return bMMCodeFlow;
      }
      
      public static function ShowFBFriendRequestDialog(param1:String) : void
      {
         ViralsManager.instance.sendAddFriend("",{},param1);
      }
      
      public function getLevel() : int
      {
         if(ExperimentsManager.instance.getExperimentVariant("empire_matchmaking_lowerlevelcap") == 1)
         {
            return 6;
         }
         return ZGlobal.gameSettings.getInt("matchMakingLevel",10);
      }
      
      public function isActive() : Boolean
      {
         return ExperimentsManager.instance.getExperimentVariant(MATCHMAKING_MASTER_NAME) == MATCHMAKING_MASTER_VALUE && ZGlobal.player.level >= this.getLevel() && Boolean(WorldObjectManager.instance.getNumberObjectsWithCode(BUILDING_CODE));
      }
      
      public function showMatchMakingData() : void
      {
         this.getMatchMakingData();
      }
      
      public function getMatchMakingData() : void
      {
         if(this.m_retriveData)
         {
            return;
         }
         this.HidePick();
         this.m_pick = null;
         StatsManager.count("MatchMaking","retrieve_data");
         TransactionManager.addTransaction(new TMatchMaking());
         this.m_retriveData = true;
      }
      
      public function showDialog() : void
      {
         var _loc1_:IEntity = ZGameUtils.getBuildingByCode("CA2");
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode("CA2",GameItem) as GameItem;
         var _loc3_:GameDataComponent = GameDataComponent(_loc1_.lookupComponentByType(GameDataComponent));
         var _loc4_:Object = _loc3_.userData;
         this.m_window = MatchMakingScreen.display(_loc1_,_loc2_,_loc4_);
         this.m_window.addEventListener(CrewResizablePopUp.BUILT,this.onBuilt,false,0,true);
      }
      
      public function onBuilt(param1:Event) : void
      {
         var _loc3_:BuildingFSMComponent = null;
         var _loc4_:BehaviorStateMachine = null;
         var _loc2_:IEntity = ZGameUtils.getBuildingByCode("CA2");
         if(Boolean(_loc2_) && CrewManager.isCrewBuildingFull(_loc2_))
         {
            this.m_window.removeEventListener(CrewResizablePopUp.BUILT,this.onBuilt);
            _loc3_ = BuildingFSMComponent(_loc2_.lookupComponentByType(BuildingFSMComponent));
            _loc4_ = BehaviorStateMachine(_loc3_.stateMachine);
            BehaviorState(_loc4_.currentState).clickNextState();
         }
      }
      
      public function init(param1:Dictionary) : void
      {
         this.m_init = true;
         this.m_data = param1;
         this.showPick();
      }
      
      public function get initialized() : Boolean
      {
         return this.m_init == true;
      }
      
      public function set initialized(param1:Boolean) : void
      {
         this.m_init = param1;
      }
      
      public function getMMFriendInfo(param1:String) : Object
      {
         if(this.m_data == null)
         {
            return null;
         }
         return this.m_data[param1];
      }
      
      public function showPick() : void
      {
         if(!this.isActive())
         {
            return;
         }
         var _loc1_:IEntity = ZGameUtils.getBuildingByCode(BUILDING_CODE);
         if(_loc1_ == null)
         {
            return;
         }
         var _loc2_:BuildingFSMComponent = BuildingFSMComponent(_loc1_.lookupComponentByType(BuildingFSMComponent));
         var _loc3_:BehaviorStateMachine = BehaviorStateMachine(_loc2_.stateMachine);
         var _loc4_:Boolean = parseInt(BehaviorState(_loc3_.currentState).name) >= parseInt(_loc3_.upgradeState);
         if(_loc4_)
         {
            if(!this.m_init)
            {
               this.ShowUpgradePick(this.m_init);
            }
            else
            {
               this.ShowSuggestionPick();
               this.showDialog();
            }
         }
         else if(ExperimentsManager.instance.getExperimentVariant("empire_matchmaking_autoupgrade") == 3)
         {
            this.UpgradeParliament();
         }
         else
         {
            this.ShowUpgradePick();
         }
      }
      
      public function ShowUpgradePick(param1:Boolean = true) : void
      {
         var _loc2_:IEntity = null;
         if(this.m_pick == null)
         {
            _loc2_ = ZGameUtils.getBuildingByCode(BUILDING_CODE);
            if(_loc2_ == null)
            {
               return;
            }
            this.m_pick = new ParliamentPickComponentUpgrade(param1);
         }
         else
         {
            ParliamentPickComponentUpgrade(this.m_pick).addAgain();
         }
         if(!_loc2_.lookupComponentByName("ParliamentPick"))
         {
            _loc2_.addComponent(this.m_pick,"ParliamentPick");
         }
      }
      
      public function ShowSuggestionPick() : void
      {
         var _loc1_:IEntity = ZGameUtils.getBuildingByCode(BUILDING_CODE);
         if(_loc1_ == null)
         {
            return;
         }
         if(this.m_pick == null)
         {
            this.m_pick = new ParliamentPickComponent();
         }
         else
         {
            ParliamentPickComponent(this.m_pick).addAgain();
         }
         if(!_loc1_.lookupComponentByName("ParliamentPick"))
         {
            _loc1_.addComponent(this.m_pick,"ParliamentPick");
         }
         (this.m_pick as ParliamentPickComponent).UpdatePickPlayer();
      }
      
      public function HidePick() : void
      {
         if(this.m_pick == null)
         {
            return;
         }
         var _loc1_:IEntity = ZGameUtils.getBuildingByCode(BUILDING_CODE);
         _loc1_.removeComponent(this.m_pick);
      }
      
      public function addNeighbor(param1:String) : void
      {
         TransactionManager.addTransaction(new TRequestNeighbor([param1],ViralsManager.INVITE_REQUEST_SOURCE_MATCHMAKING,RequestDialog.TYPE_NEIGHBOR,true));
         ZGlobal.player.pendingNeighbors = ZGlobal.player.pendingNeighbors.concat(param1);
         this.ShowSuggestionPick();
      }
      
      public function initializeActions() : void
      {
         var _loc1_:AutoActionPanToEntity = null;
         var _loc2_:IEntity = ZGameUtils.getBuildingByCode(BUILDING_CODE);
         _loc1_ = new AutoActionPanToEntity();
         _loc1_.data = {"target":_loc2_};
         _loc1_.startAction();
      }
      
      public function showUpgrade() : void
      {
         if(!ZGlobal.player.getSeenFlag("MatchMakingOptIn") && this.isActive())
         {
            ZGlobal.player.setSeenFlag("MatchMakingOptIn");
            this.upgradeBuilding();
         }
      }
      
      public function upgradeBuilding() : void
      {
         var _loc1_:IEntity = ZGameUtils.getBuildingByCode(BUILDING_CODE);
         var _loc2_:BuildingFSMComponent = BuildingFSMComponent(_loc1_.lookupComponentByType(BuildingFSMComponent));
         var _loc3_:GameDataComponent = GameDataComponent(_loc1_.lookupComponentByType(GameDataComponent));
         var _loc4_:BehaviorStateMachine = BehaviorStateMachine(_loc2_.stateMachine);
         var _loc5_:String = null;
         if(CrewManager.isCrewBuildingFull(_loc1_))
         {
            _loc5_ = _loc4_.upgradeState;
            BehaviorState(_loc4_.currentState).switchToUpgradeState();
         }
         else
         {
            _loc5_ = _loc4_.crewState;
            BehaviorState(_loc4_.currentState).switchToCrewState(_loc5_);
         }
         if(ExperimentsManager.instance.getExperimentVariant("empire_matchmaking_autoupgrade") == 3)
         {
            StatsManager.count("MatchMaking","Upgrade","Parliament","Auto");
         }
         else
         {
            StatsManager.count("MatchMaking","Upgrade","Parliament","Manual");
         }
         TransactionManager.addTransaction(new TUpgradeState(BUILDING_CODE,_loc5_,_loc3_.getSaveObject()));
      }
      
      public function set optFlag(param1:Boolean) : void
      {
         this.m_optin = param1;
      }
      
      public function set optIn(param1:Boolean) : void
      {
         this.m_optin = param1;
         TransactionManager.addTransaction(new TMatchMakingOptFlag(param1));
      }
      
      public function get optIn() : Boolean
      {
         return this.m_optin;
      }
      
      public function UpgradeParliament() : void
      {
         this.HidePick();
         this.m_pick = null;
         this.upgradeBuilding();
         this.showPick();
      }
      
      public function isMatchMadeNeighbor(param1:String) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         var _loc2_:Object = ZGlobal.player.neighbors[param1];
         return _loc2_ != null && _loc2_.hasOwnProperty("isMatchMadeNeighbor") && Boolean(_loc2_.isMatchMadeNeighbor);
      }
      
      public function getPlayerObject(param1:Object) : Player
      {
         var _loc3_:SocialNetworkUser = null;
         var _loc2_:Object = Boolean(param1) && this.isMatchMadeNeighbor(param1.uid) ? ZGlobal.player.neighbors[param1.uid].matchMakingData : null;
         _loc3_ = new SocialNetworkUser(param1.uid);
         _loc3_.name = _loc3_.firstName = param1.name;
         if(_loc2_)
         {
            _loc3_.picture = _loc2_.image;
            _loc3_.gender = _loc2_.gender;
         }
         return new Player(_loc3_);
      }
      
      public function isUpgraded() : Boolean
      {
         var _loc1_:IEntity = ZGameUtils.getBuildingByCode(BUILDING_CODE);
         if(_loc1_ == null)
         {
            return false;
         }
         var _loc2_:BuildingFSMComponent = BuildingFSMComponent(_loc1_.lookupComponentByType(BuildingFSMComponent));
         var _loc3_:BehaviorStateMachine = BehaviorStateMachine(_loc2_.stateMachine);
         return parseInt(BehaviorState(_loc3_.currentState).name) >= parseInt(_loc3_.upgradeState);
      }
   }
}

