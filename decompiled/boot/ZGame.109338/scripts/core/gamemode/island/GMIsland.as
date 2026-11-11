package core.gamemode.island
{
   import ZQuest.Managers.QuestManager;
   import as3isolib.geom.Pt;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.WorldUnitComponent;
   import core.gamemode.GMDefault;
   import core.gamemode.GameModeManager;
   import core.gamemode.GridPointer;
   import core.gamemode.battle.BattleMechlab;
   import core.gamemode.battle.GMBattle;
   import core.gamemode.unitMove.GMUnitMove;
   import core.gameobjects.Fleet;
   import core.gameobjects.GameItem;
   import core.gameobjects.IslandGroupItem;
   import core.gameobjects.IslandItem;
   import core.gameobjects.VillainItem;
   import core.gameobjects.expansionitem.ExpansionItem;
   import core.managers.AlliancesManager;
   import core.managers.BuildManager;
   import core.managers.ChallengeModeManager;
   import core.managers.ExperimentsManager;
   import core.managers.PVPManager;
   import core.managers.WorldObjectManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import core.managers.viralsManager.ViralsManager;
   import core.managers.worldUnitManager.WorldUnitManager;
   import core.player.IPVPPlayer;
   import core.ui.PlayerFeedbackManager;
   import core.ui.UI;
   import core.ui.UIManager;
   import core.ui.menuitem.MenuItem;
   import core.ui.menuitem.SettingsUIItem;
   import core.worlds.strategicWorld.StrategicIslandDataComponent;
   import core.worlds.strategicWorld.StrategicMap;
   import dispatchers.NeighborsDispatcher;
   import dispatchers.UIDispatcher;
   import displays.popups.FeedPopup;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.genericPopup.GenericPopup1B;
   import displays.screens.Store;
   import entity.GameDataComponent;
   import events.FriendBarSlotEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import utils.TimerHandler;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.utils.MathUtils;
   
   public class GMIsland extends GMDefault
   {
      
      public static var ISLAND_MODE_ENTERED:String = "islandModeEntered";
      
      private static var CAMPAIGN_FLEET:String = "gmislandcampaignfleet";
      
      private static var QUEST_FLEET:String = "questfleet";
      
      private static var QUEST_MECHLAB:String = "mechlabfleet";
      
      private static var NO_ENEMY:String = "noenemy";
      
      private static const MOUSE_WHEEL_ZOOM_THRESHOLD:int = 2;
      
      private var m_enteredModeHandler:TimerHandler;
      
      private var m_mouseWheelUpCount:Number = 0;
      
      private var m_mouseWheelDownCount:Number = 0;
      
      public function GMIsland()
      {
         this.m_enteredModeHandler = new TimerHandler(100,this,this.onDoEnteredMode);
         super();
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         if(null != ZGlobal.player && null != ZGlobal.player.campaign)
         {
            ZGlobal.player.campaign.currentMapName = null;
         }
         ViralsManager.instance.enable();
         if(this.m_enteredModeHandler)
         {
            this.m_enteredModeHandler.start();
         }
         PVPManager.instance.addEventListener(PVPManager.INVADER_UPDATED,this.onInvaderUpdated,false,1,true);
         PVPManager.instance.addEventListener(PVPManager.DEFENDER_UPDATED,this.onDefenderUpdated,false,1,true);
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.UI_PLAYER_ISLAND_MODE_ACTIVE,{"active":true}));
         this.enableZoomButtons = true;
      }
      
      override public function disableMode() : void
      {
         super.disableMode();
         if(this.m_enteredModeHandler)
         {
            this.m_enteredModeHandler.dispose();
            this.m_enteredModeHandler = null;
         }
         ViralsManager.instance.disable();
         PVPManager.instance.removeEventListener(PVPManager.INVADER_UPDATED,this.onInvaderUpdated);
         PVPManager.instance.removeEventListener(PVPManager.DEFENDER_UPDATED,this.onDefenderUpdated);
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.UI_PLAYER_ISLAND_MODE_ACTIVE,{"active":false}));
         this.enableZoomButtons = false;
      }
      
      override public function set overUI(param1:Boolean) : void
      {
         super.overUI = param1;
         if(param1)
         {
            deselect();
         }
         GridPointer.instance.hide = param1;
      }
      
      override public function get createParticlesOnLootPickup() : Boolean
      {
         return true;
      }
      
      override public function onMouseWheel(param1:MouseEvent) : Boolean
      {
         var _loc2_:SettingsUIItem = UIManager.instance.getMenuItemByName(SettingsUIItem.ITEM_ID) as SettingsUIItem;
         if(_loc2_)
         {
            if(param1.delta > 0)
            {
               ++this.m_mouseWheelUpCount;
               this.m_mouseWheelDownCount = 0;
            }
            else if(param1.delta < 0)
            {
               ++this.m_mouseWheelDownCount;
               this.m_mouseWheelUpCount = 0;
            }
            if(this.m_mouseWheelDownCount >= MOUSE_WHEEL_ZOOM_THRESHOLD)
            {
               _loc2_.zoomOut();
               this.m_mouseWheelDownCount = 0;
            }
            else if(this.m_mouseWheelUpCount >= MOUSE_WHEEL_ZOOM_THRESHOLD)
            {
               _loc2_.zoomIn();
               this.m_mouseWheelUpCount = 0;
            }
         }
         return true;
      }
      
      override protected function doHandleClick(param1:MouseEvent) : void
      {
         if(this.handleUnitInWorld())
         {
            return;
         }
         super.doHandleClick(param1);
      }
      
      protected function validateExpansion(param1:Number, param2:Number) : Boolean
      {
         var _loc3_:Pt = null;
         var _loc4_:Pt = null;
         var _loc5_:uint = 0;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:GenericPopup = null;
         var _loc11_:Vector3D = null;
         if(this.validForExpansion())
         {
            _loc3_ = GridPointer.instance.convertScreenCoordsToGrid(param1,param2);
            _loc4_ = new Pt(_loc3_.x / ZGlobal.cellSize,_loc3_.y / ZGlobal.cellSize);
            _loc5_ = MathUtils.gridToExpansionIndex(_loc4_.x / 4,_loc4_.y / 4,BuildManager.instance.width);
            if(!ZGlobal.player.expansions.isBitSet(_loc5_))
            {
               _loc6_ = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_EXPANSION_CREW_MASTER);
               if(this.enoughResourcesForExpansion())
               {
                  if(ZGameStats.active)
                  {
                     ZGameStats.instance.dispatchEvent(new Event(ZGameStats.STATS_EXPANSION_ATTEMPT_SUCCESS));
                  }
                  if(_loc6_ != ZGlobal.EXPERIMENT_EXPANSION_CREW_ENABLED)
                  {
                     _loc7_ = null;
                     _loc8_ = null;
                     _loc9_ = ZGlobal.getAssetURL("assets/game/quests/Quests_Icons_0.swf/LibertyBond_96.png");
                     _loc10_ = null;
                     _loc7_ = ZGameUtils.ZlocT("Dialogs","Expansion_FoggedSuccessMessage");
                     _loc8_ = ZGameUtils.ZlocT("Dialogs","Expansion_FoggedSuccessTitle");
                     _loc10_ = new FeedPopup(_loc7_,_loc8_,null,GenericPopup.TYPE_ACCEPTCANCEL,this.onSuccessPopupClose,_loc9_);
                     _loc10_.setAcceptTextName("Expansion_FoggedSuccessButton");
                     PopupManager.instance.push(_loc10_);
                  }
               }
               else
               {
                  _loc11_ = new Vector3D(_loc3_.x,_loc3_.y);
                  PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","Error_UnableToExpand"),_loc11_,ZGameUtils.ZlocT("Main","Error_UnableToExpandMessage"));
                  if(ZGameStats.active)
                  {
                     ZGameStats.instance.dispatchEvent(new Event(ZGameStats.STATS_EXPANSION_ATTEMPT_FAILURE));
                  }
               }
               if(_loc6_ == ZGlobal.EXPERIMENT_EXPANSION_CREW_ENABLED)
               {
                  UI.instance.displayStoreDialog({"tab":Store.TAB_EXPANSION_LABEL});
               }
               return false;
            }
         }
         return true;
      }
      
      private function validForExpansion() : Boolean
      {
         if(ZGlobal.visitMode == ZGlobal.MODE_HOME)
         {
            if(null != ZGlobal.player)
            {
               if(null != ZGlobal.player.expansions)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      private function enoughResourcesForExpansion() : Boolean
      {
         var _loc2_:XML = null;
         var _loc3_:ExpansionItem = null;
         var _loc1_:Array = ZGlobal.gameSettings.getArrayOfItemXMLByType(GameItem.TYPE_EXPANSION);
         for each(_loc2_ in _loc1_)
         {
            _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc2_.@code,ExpansionItem) as ExpansionItem;
            if(ZGlobal.player.canBuy(_loc3_,false))
            {
               return true;
            }
         }
         return false;
      }
      
      private function onSuccessPopupClose(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            UI.instance.displayStoreDialog({"tab":Store.TAB_EXPANSION_LABEL});
         }
      }
      
      private function set enableZoomButtons(param1:Boolean) : void
      {
         var _loc2_:MenuItem = UIManager.instance.getMenuItemByName(SettingsUIItem.ITEM_ID);
         if(null != _loc2_)
         {
            SettingsUIItem(_loc2_).enableZoomButtons = param1;
         }
      }
      
      private function onInvaderUpdated(param1:WorldEvent) : void
      {
         PVPManager.instance.performInvasion(param1.eventData.id,param1.eventData.invasion);
         PVPManager.instance.clearQueuedInvasions(param1.eventData.id);
         param1.stopImmediatePropagation();
      }
      
      private function onDefenderUpdated(param1:WorldEvent) : void
      {
         PVPManager.instance.performDefended(param1.eventData.id,param1.eventData.invasion,param1.eventData.local);
         PVPManager.instance.clearQueuedDefends(param1.eventData.id);
         param1.stopImmediatePropagation();
      }
      
      protected function onDoEnteredMode(param1:Object) : void
      {
         GameModeManager.instance.dispatchEvent(new Event(ISLAND_MODE_ENTERED));
      }
      
      override protected function getCursor() : Object
      {
         var _loc1_:WorldUnitComponent = null;
         if(m_highlightedObject)
         {
            _loc1_ = m_highlightedObject.lookupComponentByType(WorldUnitComponent) as WorldUnitComponent;
            if(_loc1_)
            {
               if(_loc1_.type == WorldUnitManager.UNIT_AVAILABLE)
               {
                  return new Cursor_Move(1,1);
               }
            }
         }
         return super.getCursor();
      }
      
      private function handleUnitInWorld() : Boolean
      {
         var _loc1_:WorldUnitComponent = null;
         if(ZGlobal.visitMode == ZGlobal.MODE_HOME)
         {
            if(m_highlightedObject)
            {
               _loc1_ = m_highlightedObject.lookupComponentByType(WorldUnitComponent) as WorldUnitComponent;
               if(_loc1_)
               {
                  if(_loc1_.type == WorldUnitManager.UNIT_AVAILABLE)
                  {
                     return this.handleIdleUnit();
                  }
                  if(_loc1_.type == WorldUnitManager.UNIT_IN_FLEET)
                  {
                     return this.handleUnitInCombat();
                  }
                  if(_loc1_.type == WorldUnitManager.UNIT_IN_MARKET)
                  {
                     return this.handleUnitInMarket();
                  }
               }
            }
         }
         return false;
      }
      
      private function handleIdleUnit() : Boolean
      {
         var _loc1_:String = null;
         var _loc2_:GenericPopup1B = null;
         if(PVPManager.instance.underInvasionMarkerInfluence(m_highlightedObject))
         {
            _loc1_ = ZGameUtils.ZlocT("Dialogs","PVPCannotMoveBuilding");
            _loc2_ = GenericPopup1B.NewOk(_loc1_,null);
            PopupManager.instance.push(_loc2_);
         }
         else
         {
            GameModeManager.instance.addGameMode(new GMUnitMove(m_highlightedObject),false);
         }
         return true;
      }
      
      private function getMarketStateMachine() : BuildingFSMComponent
      {
         var _loc2_:IEntity = null;
         var _loc3_:GameDataComponent = null;
         var _loc4_:GameItem = null;
         var _loc5_:BuildingFSMComponent = null;
         var _loc1_:Dictionary = WorldObjectManager.instance.getObjectsBySubType("building","production");
         for each(_loc2_ in _loc1_)
         {
            _loc3_ = GameDataComponent.getGameDataComponent(_loc2_);
            _loc4_ = _loc3_.gameData;
            if((Boolean(_loc4_)) && _loc4_.name == "Market")
            {
               _loc5_ = BuildingFSMComponent(_loc2_.lookupComponentByType(BuildingFSMComponent));
               if(_loc5_)
               {
                  return _loc5_;
               }
            }
         }
         return null;
      }
      
      private function handleUnitInMarket() : Boolean
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:GenericPopup2B = null;
         var _loc1_:BuildingFSMComponent = this.getMarketStateMachine();
         if(_loc1_)
         {
            _loc2_ = ZGameUtils.ZlocT("Dialogs","ActiveUnit_MarketConfirmTitle");
            _loc3_ = ZGameUtils.ZlocT("Dialogs","ActiveUnit_MarketConfirmDesc");
            _loc4_ = GenericPopup2B.NewYesNo(_loc3_,_loc2_,this.onMarketConfirm);
            _loc4_.setAcceptTextName("ActiveUnit_Market");
            _loc4_.setCancelTextName("ActiveUnit_Cancel");
            PopupManager.instance.push(_loc4_);
            return true;
         }
         return false;
      }
      
      private function onMarketConfirm(param1:GenericPopupEvent) : void
      {
         var _loc2_:BuildingFSMComponent = null;
         if(param1.button == GenericPopup.YES)
         {
            _loc2_ = this.getMarketStateMachine();
            if(_loc2_)
            {
               _loc2_.forceClick();
            }
         }
      }
      
      private function handleUnitInCombat() : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:VillainItem = null;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:GenericPopup2B = null;
         var _loc11_:IPVPPlayer = null;
         var _loc12_:StrategicMap = null;
         var _loc13_:String = null;
         var _loc14_:String = null;
         var _loc15_:String = null;
         var _loc16_:Object = null;
         var _loc1_:GameDataComponent = GameDataComponent.getGameDataComponent(m_highlightedObject);
         var _loc2_:Fleet = this.findFleet(_loc1_.gameData.code);
         if(_loc2_)
         {
            _loc3_ = this.getEnemyId(_loc2_);
            if(_loc3_ == null && _loc2_.hasStatus(Fleet.DOMINATION_DEFENSE))
            {
               _loc3_ = NO_ENEMY;
            }
            if(_loc3_)
            {
               _loc4_ = null;
               _loc5_ = null;
               _loc6_ = new Object();
               _loc7_ = null;
               if(_loc3_ == PVPManager.PVE_MARKER_KEY)
               {
                  _loc11_ = PVPManager.instance.getPVPPlayer(_loc3_);
                  _loc7_ = _loc11_.firstName;
                  _loc5_ = "ActiveUnit_PVEConfirmDesc";
               }
               else if(_loc3_ == CAMPAIGN_FLEET)
               {
                  _loc12_ = ZGlobal.player.campaign.mapContainingFleet(_loc2_);
                  _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc12_.villain,VillainItem) as VillainItem;
                  _loc7_ = _loc4_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
                  _loc5_ = "ActiveUnit_PVEConfirmDesc";
                  _loc6_.campaign = true;
                  _loc6_.mapInProgress = _loc12_;
               }
               else if(_loc3_ == QUEST_FLEET)
               {
                  _loc5_ = "ActiveUnit_PVEConfirmDesc";
                  _loc6_.enemyFleetName = _loc2_.battleTarget;
                  _loc6_.questData = this.getQuestInfo(_loc6_.enemyFleetName);
                  if(_loc6_.questData)
                  {
                     _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc6_.questData.villain,VillainItem) as VillainItem;
                     _loc7_ = _loc4_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
                  }
               }
               else if(_loc3_ == QUEST_MECHLAB)
               {
                  _loc5_ = "ActiveUnit_MechlabConfirmDesc";
                  _loc6_.mechlab = _loc2_.battleTarget;
                  _loc7_ = "unused";
               }
               else if(_loc2_.hasStatus(Fleet.SURVIVAL_PLAYER))
               {
                  _loc7_ = ZGameUtils.ZlocT("Dialogs","SurvivalModePlayer");
                  _loc5_ = "ActiveUnit_PVEConfirmDesc";
                  _loc6_.survival = true;
               }
               else if(_loc2_.hasStatus(Fleet.DOMINATION_PLAYER))
               {
                  _loc5_ = "ActiveUnit_DominationBattleDesc";
                  if(_loc2_.name == AlliancesManager.ALLIANCE_PLAYER_FLEET)
                  {
                     _loc6_.allianceBattle = true;
                  }
                  _loc6_.dominationBattle = true;
                  _loc7_ = "unused";
               }
               else if(_loc2_.hasStatus(Fleet.DOMINATION_DEFENSE))
               {
                  _loc5_ = "ActiveUnit_DominationDefenseDesc";
                  _loc6_.dominationDefense = true;
                  _loc7_ = "unused";
               }
               else
               {
                  _loc13_ = null;
                  _loc14_ = PVPManager.instance.getInvadedNeighborId(_loc3_);
                  if(null == _loc14_)
                  {
                     if(ChallengeModeManager.instance.isChallengeInProgress(_loc3_))
                     {
                        _loc6_.challenge = true;
                        _loc14_ = _loc3_;
                        _loc5_ = "ActiveUnit_PVPConfirmDesc";
                     }
                     else
                     {
                        _loc16_ = PVPManager.instance.getGlobalPVPStrangerInfo(_loc3_);
                        if(_loc16_)
                        {
                           if(Boolean(_loc16_.playerInfo) && Boolean(_loc16_.playerInfo.snUser) && Boolean(_loc16_.playerInfo.snUser.firstName))
                           {
                              _loc15_ = _loc16_.playerInfo.snUser.firstName;
                           }
                           else if(Boolean(_loc16_.opponent) && Boolean(_loc16_.opponent.m_name))
                           {
                              _loc15_ = _loc16_.opponent.m_name;
                           }
                        }
                        _loc14_ = _loc3_;
                        _loc13_ = FriendBarSlotEvent.BUTTON_ATTACK;
                        _loc5_ = "ActiveUnit_FightConfirmDesc";
                     }
                  }
                  else
                  {
                     _loc13_ = FriendBarSlotEvent.BUTTON_VISIT;
                     _loc5_ = "ActiveUnit_FightConfirmDesc";
                  }
                  _loc6_.visitType = _loc13_;
                  _loc6_.targetUid = _loc14_;
                  _loc7_ = _loc15_ ? _loc15_ : ZGlobal.player.getFriendFirstName(_loc14_);
               }
               _loc8_ = ZGameUtils.ZlocT("Dialogs","ActiveUnit_FightConfirmTitle");
               _loc9_ = ZGameUtils.ZlocT("Dialogs",_loc5_,{"host":_loc7_});
               _loc10_ = GenericPopup2B.NewYesNo(_loc9_,_loc8_,this.onContinueFightConfirm);
               _loc10_.userData = _loc6_;
               _loc10_.setAcceptTextName(_loc2_.hasStatus(Fleet.DOMINATION_DEFENSE) ? "DominationUpdateDefenseForce" : "ActiveUnit_Fight");
               _loc10_.setCancelTextName("ActiveUnit_Cancel");
               PopupManager.instance.push(_loc10_);
               return true;
            }
         }
         return false;
      }
      
      private function onContinueFightConfirm(param1:GenericPopupEvent) : void
      {
         var _loc2_:IslandPlayerSlot = null;
         var _loc3_:StrategicMap = null;
         var _loc4_:IslandGroupItem = null;
         var _loc5_:IslandItem = null;
         var _loc6_:StrategicIslandDataComponent = null;
         var _loc7_:Boolean = false;
         if(param1.button == GenericPopup.YES)
         {
            if(param1.userData.challenge)
            {
               ChallengeModeManager.instance.onSelectChallengerPlayer(param1.userData.targetUid);
            }
            else if(param1.userData.questData)
            {
               GMBattle.createStaticBattleFromQuest(param1.userData.questData,param1.userData.enemyFleetName);
            }
            else if(param1.userData.visitType)
            {
               _loc2_ = new IslandPlayerSlot(param1.userData.targetUid);
               NeighborsDispatcher.instance.dispatchEvent(new FriendBarSlotEvent(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,param1.userData.visitType,_loc2_));
            }
            else if(param1.userData.campaign)
            {
               _loc3_ = param1.userData.mapInProgress;
               _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_.code,IslandGroupItem) as IslandGroupItem;
               _loc5_ = _loc4_.getIslandItem(_loc3_.inReplay ? _loc3_.replayIsland : _loc3_.progressIsland);
               _loc6_ = new StrategicIslandDataComponent(_loc5_);
               ZGlobal.player.campaign.currentMapName = _loc3_.code;
               _loc6_.click();
            }
            else if(param1.userData.survival)
            {
               SurvivalModeManager.instance.launchSurvivalMode(SurvivalModeManager.ENTRY_POINT_UNIT);
            }
            else if(param1.userData.mechlab)
            {
               BattleMechlab.startBattleFromEnemyFleet(param1.userData.mechlab);
            }
            else if(param1.userData.dominationBattle)
            {
               if(param1.userData.allianceBattle)
               {
                  DominationModeManager.instance.launchDominationScreen();
               }
               else
               {
                  DominationModeManager.instance.loadDominationModeBattle();
               }
            }
            else if(param1.userData.dominationDefense)
            {
               DominationModeManager.instance.enterDefenseForceEditor();
            }
            else
            {
               _loc7_ = false;
               PVPManager.instance.doPveRepel(_loc7_);
            }
         }
      }
      
      private function getQuestInfo(param1:String) : Object
      {
         return (QuestManager.getInstance() as ZGameQuestManager).getTaskInfoFromFleetName(param1);
      }
      
      private function findFleet(param1:String) : Fleet
      {
         var _loc2_:Fleet = null;
         for each(_loc2_ in ZGlobal.player.fleets.fleets)
         {
            if(_loc2_.isOwnedByPlayer(ZGlobal.player.uid))
            {
               if(_loc2_.countUnits(param1) > 0)
               {
                  return _loc2_;
               }
            }
         }
         return null;
      }
      
      private function getEnemyId(param1:Fleet) : String
      {
         var _loc3_:StrategicMap = null;
         var _loc4_:Fleet = null;
         var _loc2_:Array = ZGlobal.player.campaign.allMapsInProgress;
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_)
            {
               if(param1.name == _loc3_.fleets[0])
               {
                  return CAMPAIGN_FLEET;
               }
            }
         }
         if(param1.hasStatus(Fleet.QUESTTREE))
         {
            return QUEST_FLEET;
         }
         if(param1.battleTarget)
         {
            _loc4_ = Fleet.getFleet(param1.battleTarget);
            if(_loc4_)
            {
               if(_loc4_.hasStatus(Fleet.MECHLAB))
               {
                  return QUEST_MECHLAB;
               }
               if(_loc4_.hasStatus(Fleet.QUEST))
               {
                  return QUEST_FLEET;
               }
               return _loc4_.uid;
            }
         }
         return null;
      }
   }
}

