package core.managers.tutorialManager
{
   import ZQuest.Managers.QuestManager;
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import core.gamemode.battle.BattleDispatcher;
   import core.managers.WorldObjectManager;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.rewardPickupManager.RewardPickupManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.menuitem.NarratorUIItem;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.components.CineCameraComponent;
   import dispatchers.UIDispatcher;
   import displays.popups.EpisodePopup;
   import displays.popups.GenericPopup;
   import displays.popups.HudsonPopup;
   import displays.popups.InviteIdlePopup;
   import displays.popups.LetterPopup;
   import displays.popups.SpeechPopup;
   import displays.screens.gridScreen.GridScreen;
   import displays.screens.gridScreen.GridSlot;
   import entity.GameDataComponent;
   import events.MarketEvent;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import sound.SoundEvent;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.utils.StringUtils;
   
   public class TutorialStep
   {
      
      private var m_branch:String = null;
      
      private var m_quest:String = null;
      
      private var m_param:String = null;
      
      private var m_stencil:String = null;
      
      private var m_stencilMod:String = null;
      
      private var m_name:String = null;
      
      private var m_offset:String = null;
      
      public function TutorialStep(param1:XML)
      {
         super();
         this.m_name = param1.@name.toString();
         this.m_param = param1.@param.toString();
         this.m_branch = param1.@branch.toString();
         this.m_quest = param1.@quest.toString();
         this.m_stencil = param1.@stencil.toString();
         this.m_stencilMod = param1.@stencilMod.toString();
         this.m_offset = param1.@offset.toString();
         Logger.info(this,"TutorialStep","func:" + this.name + " param:" + this.m_param);
         if(this.m_quest.length == 0)
         {
            this.m_quest = null;
         }
         if(this.m_param.length > 0)
         {
            this[this.m_name](this.m_param);
         }
         else
         {
            this[this.m_name]();
         }
      }
      
      public function dispose() : void
      {
         this.removeAllEvents();
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get param() : String
      {
         return this.m_param;
      }
      
      private function matchesQuestId(param1:String) : Boolean
      {
         if(null == this.m_quest || this.m_quest == param1)
         {
            return true;
         }
         return false;
      }
      
      private function onQuestCompleteProgress(param1:WorldEvent) : void
      {
         if(this.matchesQuestId(String(param1.eventData.name)))
         {
            this.onEventProgress(null);
         }
      }
      
      private function localPopupClosed(param1:GenericPopupEvent) : void
      {
         param1.target.removeEventListener(GenericPopupEvent.SELECTED,this.localPopupClosed);
         this.onEventProgress(null);
      }
      
      private function onQuestPopupProgress(param1:WorldEvent) : void
      {
         if(this.matchesQuestId(String(param1.eventData)))
         {
            this.onEventProgress(null);
         }
      }
      
      private function onIslandClickProgress(param1:WorldEvent) : void
      {
         if(this.m_param.length == 0 || this.m_param == param1.eventData.toString())
         {
            this.onEventProgress(param1);
         }
      }
      
      private function onEventProgress(param1:Event) : void
      {
         this.removeAllEvents();
         TutorialManager.instance.progress(this.m_branch);
      }
      
      private function onQuestParamProgress(param1:WorldEvent) : void
      {
         if(this.matchesQuestId(String(param1.eventData)))
         {
            TutorialManager.instance.removeEventListener(TutorialManager.QUEST_TASK_CLICKED,this.onQuestParamProgress);
            this.onEventProgress(null);
         }
      }
      
      private function onStoreClicked(param1:WorldEvent) : void
      {
         this.removeAllEvents();
         TutorialManager.instance.progress(this.m_branch,false);
      }
      
      private function onStoreTabClicked(param1:WorldEvent) : void
      {
         if(param1.eventData.index == this.m_param)
         {
            this.removeAllEvents();
            TutorialManager.instance.progress(this.m_branch,false);
         }
      }
      
      private function onObjectSelected(param1:WorldEvent) : void
      {
         var _loc2_:GameDataComponent = GameDataComponent.getGameDataComponent(param1.eventData as IEntity);
         if(_loc2_.gameData.code == this.m_param)
         {
            WorldObjectManager.instance.removeEventListener(WorldObjectManager.OBJECT_SELECTED,this.onObjectSelected);
            this.onEventProgress(null);
         }
      }
      
      private function onObjectPlacedServer(param1:WorldEvent) : void
      {
         if(param1.eventData == this.m_param)
         {
            WorldObjectManager.instance.removeEventListener(WorldObjectManager.OBJECT_SELECTED,this.onObjectPlacedServer);
            this.onEventProgress(null);
         }
      }
      
      private function onObjectPlacedClient(param1:WorldEvent) : void
      {
         if(param1.eventData == this.m_param)
         {
            WorldObjectManager.instance.removeEventListener(WorldObjectManager.OBJECT_PLACED_CLIENT,this.onObjectPlacedClient);
            this.onEventProgress(null);
         }
      }
      
      private function onCombatUnitClicked(param1:WorldEvent) : void
      {
         if(param1.eventData.code == this.m_param)
         {
            this.removeAllEvents();
            TutorialManager.instance.progress(this.m_branch);
         }
      }
      
      private function onBattleStartProgress(param1:Event) : void
      {
         var _loc2_:Array = null;
         if(Boolean(this.m_param) && this.m_param.length > 0)
         {
            _loc2_ = this.m_param.split(",");
            if(_loc2_[0] == ZGlobal.player.campaign.currentMap.code && int(_loc2_[1]) == ZGlobal.player.campaign.currentMap.currentIslandItem.index)
            {
               this.onEventProgress(null);
            }
         }
      }
      
      private function onNeighborBarSlotClick(param1:WorldEvent) : void
      {
         if(this.m_param == param1.eventData)
         {
            this.onEventProgress(null);
         }
      }
      
      private function onWorldLoadedProgress(param1:WorldEvent) : void
      {
         if(this.m_param == param1.eventData)
         {
            this.onEventProgress(null);
         }
      }
      
      private function onRepelClick(param1:WorldEvent) : void
      {
         if(param1.eventData.quest == true)
         {
            this.onEventProgress(null);
         }
      }
      
      private function removeQuestEvents() : void
      {
         QuestManager.getInstance().removeEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestCompleteProgress);
      }
      
      private function removeBuyEvents() : void
      {
         UIDispatcher.instance.removeEventListener(MarketEvent.MARKET_BUY,this.onEventProgress);
      }
      
      private function removeUseEvents() : void
      {
         UIDispatcher.instance.removeEventListener(MarketEvent.MARKET_USE,this.onEventProgress);
      }
      
      private function removeStoreTabSelectedEvent() : void
      {
         UIDispatcher.instance.removeEventListener(TutorialManager.UI_STORE_TAB_CLICK,this.onStoreTabClicked);
      }
      
      private function removeAllWorldEvents() : void
      {
         WorldObjectManager.instance.removeEventListener(WorldObjectManager.OBJECT_BUILT,this.onEventProgress);
         WorldObjectManager.instance.removeEventListener(WorldObjectManager.OBJECT_SELECTED,this.onObjectSelected);
      }
      
      private function removeBattleEvents() : void
      {
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_CONSUMABLE_USED,this.onEventProgress);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_CONSUMABLE_SELECTED,this.onEventProgress);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_START,this.onEventProgress);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_START,this.onBattleStartProgress);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_COMPLETE_HOST,this.onEventProgress);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_PAUSE,this.onEventProgress);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_CANCEL,this.onEventProgress);
      }
      
      private function removeAllEvents() : void
      {
         this.removeAllUIListeners();
         this.removeAllWorldEvents();
         this.removeBuyEvents();
         this.removeUseEvents();
         this.removeQuestEvents();
         this.removeStoreTabSelectedEvent();
         this.removeBattleEvents();
         TutorialManager.instance.removeEventListener(TutorialManager.QUEST_POPUP_CONTINUE,this.onQuestPopupProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.QUEST_COMPLETE_POPUP_CONTINUE,this.onQuestPopupProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.CLEAR_CONTINUE,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.REWARDPICKUP_CONTINUE,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.DIALOG_CONTINUE,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.SELECT_CONTINUE,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.LETTER_CONTINUE,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_START,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_SEQUENCE_CONTINUE,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.LETTER_CLOSE,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.ISLAND_CONTINUE,this.onIslandClickProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.STRATEGIC_MAP_CONTINUE,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.RETURN_HOME_CONTINUE,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.CONTRACT_MARKET_CONTINUE,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.CONTRACT_MARKET_BUY_CONTINUE,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.LETTER_CREATION,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.SPEECH_CONTINUE,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.QUEST_TASK_CLICKED,this.onQuestParamProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_END,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.EPISODE_CONTINUE,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.BUILD_FINISHED,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.STORE_OPENED,this.onStoreClicked);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_FIGHT_CONTINUE,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_UNIT_CLICK,this.onCombatUnitClicked);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_SPECIAL_POWER_CLICKED,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_UNITS_SCREEN,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_ALLIES_SCREEN,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_SPECIALPOWERS_SCREEN,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_ALLY_ADDED,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_CONSUMABLE_USED,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_ALLY_NEXT,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.STRAT_MAP_HOME_CLICK,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.ZOOM_IN_CLICK,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.ZOOM_OUT_CLICK,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.FULL_SCREEN_CLICK,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.NEW_NATION_CONTINUE,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_PRE_BATTLE_UI_READY,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.PVP_MARKER_LOADED,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.PVP_REPEL_CLICKED,this.onRepelClick);
         TutorialManager.instance.removeEventListener(TutorialManager.INVENTORY_OPENED,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.NEIGHBOR_VISIT_CLICKED,this.onNeighborBarSlotClick);
         TutorialManager.instance.removeEventListener(TutorialManager.STRAT_MAP_LOADED,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.COMBAT_SPECIALPOWERS_SCREEN_PRE_ANIM,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.INVITE_FRIENDS_CONTINUE,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.WORLD_LOADED_CONTINUE,this.onWorldLoadedProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.CONTRACT_SCREEN_LOADED,this.onEventProgress);
         TutorialManager.instance.removeEventListener(TutorialManager.INVENTORY_CLOSED,this.onEventProgress);
         UIDispatcher.instance.removeEventListener(GridSlot.SELECTED,this.onEventProgress);
      }
      
      public function removeAllUIListeners() : void
      {
         var _loc1_:DisplayObject = TutorialManager.instance.getUIItem("TaskList");
         if(_loc1_)
         {
            _loc1_.removeEventListener(MouseEvent.CLICK,this.onEventProgress);
         }
      }
      
      private function playSoundEvent(param1:String) : void
      {
         SoundEvent.getSoundEvent(param1).play();
      }
      
      private function sendEvent(param1:String) : void
      {
         var _loc2_:Boolean = this.m_stencil == "true" ? true : false;
         TutorialManager.instance.sendEvent(param1,_loc2_);
      }
      
      private function pickLock(param1:String) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.SET_LOCKED,param1));
      }
      
      private function pickUnlock(param1:String) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.SET_UNLOCKED,param1));
      }
      
      private function setUnsellable(param1:String) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.SET_UNSELLABLE,param1));
      }
      
      private function clearUnsellable() : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.CLEAR_UNSELLABLE));
      }
      
      private function arrowTarget(param1:String) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.UI_HIGHLIGHT_ITEM,param1));
      }
      
      private function arrowAttach(param1:String) : void
      {
         var _loc4_:Array = null;
         var _loc2_:Point = null;
         var _loc3_:Array = param1.split(",");
         if(this.m_offset)
         {
            _loc4_ = this.m_offset.split(",");
            _loc2_ = new Point(_loc4_[0],_loc4_[1]);
         }
         TutorialManager.instance.arrowActive = true;
         WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.ATTACH_ARROW,{
            "codes":_loc3_,
            "offset":_loc2_
         }));
      }
      
      private function attachArrowToStoreTab(param1:String = null) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.UI_HIGHLIGHT_STORE_INDEX,param1));
      }
      
      private function attachArrowToDossier() : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.UI_HIGHLIGHT_LETTER_FOLDER));
      }
      
      private function arrowIsland(param1:String) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.UI_HIGHLIGHT_ISLAND,param1));
      }
      
      private function clearArrows() : void
      {
         TutorialManager.instance.arrowActive = false;
         WorldObjectManager.instance.dispatchEvent(new Event(WorldObjectManager.CLEAR_ARROWS));
      }
      
      private function attachStencil(param1:String) : void
      {
         WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.ATTACH_STENCIL,{
            "code":param1,
            "mod":this.m_stencilMod
         }));
      }
      
      private function stencilUIItem(param1:String) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.UI_STENCIL_ITEM,param1));
      }
      
      private function stencilCombatUIItem(param1:String) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(GridSlot.STENCIL,param1));
      }
      
      private function stencilCombatAllyItem(param1:String) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(GridSlot.STENCIL,param1));
      }
      
      private function stencilCombatAlly(param1:String) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.UI_STENCIL_COMBAT_ALLY,param1));
      }
      
      private function configureGridForItem(param1:String) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(GridScreen.CONFIGURE_FOR_ITEM,param1));
      }
      
      private function highlightNeighbor(param1:String) : void
      {
         var _loc2_:Boolean = this.m_stencil == "true" ? true : false;
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.UI_HIGHLIGHT_NEIGHBOR,{
            "id":param1,
            "stencil":_loc2_
         }));
      }
      
      private function stencilIsland(param1:String) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.UI_STENCIL_ISLAND,param1));
      }
      
      private function clearStencil() : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.REMOVE_STENCIL));
      }
      
      private function popup(param1:String) : void
      {
         var _loc2_:Array = param1.split(",");
         _loc2_[0] = ZGameUtils.ZlocT("Narrator",_loc2_[0]);
         _loc2_[1] = ZGameUtils.ZlocT("Narrator",_loc2_[1]);
         GameModeManager.instance.getTopGameMode().ignoreUIDeselect();
         var _loc3_:GenericPopup = new HudsonPopup(_loc2_[1],_loc2_[0],GenericPopup.TYPE_OK);
         _loc3_.addEventListener(GenericPopupEvent.SELECTED,this.localPopupClosed);
         PopupManager.instance.push(_loc3_);
      }
      
      private function showBar(param1:String) : void
      {
         var _loc3_:NarratorUIItem = null;
         var _loc2_:Array = param1.split(",");
         if(_loc2_.length > 1)
         {
            _loc3_ = NarratorUIItem.getNarratorBar() as NarratorUIItem;
            _loc3_.location = _loc2_[1];
         }
         if(_loc2_[0] == false.toString())
         {
            if(TutorialManager.instance.restoringState)
            {
               NarratorUIItem.getNarratorBar().hide(false);
            }
            else
            {
               NarratorUIItem.getNarratorBar().hide(true);
            }
         }
         else if(TutorialManager.instance.restoringState)
         {
            NarratorUIItem.getNarratorBar().show(false);
         }
         else
         {
            NarratorUIItem.getNarratorBar().show(true);
         }
      }
      
      private function movecamera(param1:String) : void
      {
         var _loc2_:Point = StringUtils.parsePoint(param1);
         var _loc3_:CineCameraComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,CineCameraComponent) as CineCameraComponent;
         _loc3_.moveTo(new Pt(_loc2_.x,_loc2_.y));
      }
      
      private function enableRewardPickupPulse(param1:String) : void
      {
         RewardPickupManager.instance.pulseGlow = param1 == "true";
      }
      
      private function setStoreTab(param1:String) : void
      {
         TutorialManager.instance.storeTab = param1;
      }
      
      private function showSpeechBubble(param1:String) : void
      {
         PopupManager.instance.push(new SpeechPopup(param1),0,true,false);
      }
      
      private function showEpisodePopup(param1:String) : void
      {
         PopupManager.instance.push(new EpisodePopup(param1));
      }
      
      private function showLetter(param1:String) : void
      {
         PopupManager.instance.push(new LetterPopup(param1));
      }
      
      private function pauseTutorial() : void
      {
         TutorialManager.instance.pauseTutorial();
      }
      
      private function hideCombatUI() : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_HIDE_UI));
      }
      
      private function showCombatUI() : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_SHOW_UI));
      }
      
      private function disableSpecialPowers() : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_DISABLE_SPECIAL_POWERS));
      }
      
      private function enableSpecialPowers() : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_ENABLE_SPECIAL_POWERS));
      }
      
      private function showViral(param1:String) : void
      {
         if(param1 == "invite_friends")
         {
            PopupManager.instance.push(new InviteIdlePopup(ViralsManager.instance.onInviteDialogTutorialClosed),0,true,false);
         }
         else if(param1 == "new_nation")
         {
            ViralsManager.instance.questCompleteViral(param1);
            ZGlobal.player.setSeenFlag(TutorialManager.TUTORIAL_NEW_NATION);
         }
      }
      
      private function combatLockSelection(param1:String) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_LOCK_SELECTION,param1));
      }
      
      private function combatUnlockSelection() : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_UNLOCK_SELECTION));
      }
      
      private function pauseQuestStarts() : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.PAUSE_QUEST_STARTS));
      }
      
      private function resumeQuestStarts() : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.RESUME_QUEST_STARTS));
      }
      
      private function disableIslandReturnHomeButton() : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.DISABLE_ISLAND_RETURN_HOME));
      }
      
      private function enableIslandReturnHomeButton() : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.ENABLE_ISLAND_RETURN_HOME));
      }
      
      private function disableStrategicMap() : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.DISABLE_STRATEGIC_MAP));
      }
      
      private function enableStrategicMap() : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.ENABLE_STRATEGIC_MAP));
      }
      
      private function disablePreBattleUIControls() : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.DISABLE_PRE_BATTLE_UI_CONTROLS));
      }
      
      private function enablePreBattleUIControls() : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.ENABLE_PRE_BATTLE_UI_CONTROLS));
      }
      
      private function disableSpecialPowerSelectionUIControls() : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.DISABLE_SPECIAL_POWER_SELECTION_CONTROLS));
      }
      
      private function enableSpecialPowerSelectionUIControls() : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.ENABLE_SPECIAL_POWER_SELECTION_CONTROLS));
      }
      
      private function progressStep() : void
      {
         this.onEventProgress(null);
      }
      
      private function limitAllySelection(param1:String) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.LIMIT_ALLY_SELECTION,param1));
      }
      
      private function setPVPTutorialMode(param1:String) : void
      {
         TutorialManager.instance.pvpTutorialMode = param1 == "true";
      }
      
      private function enableCombatPauseRetreatButtons(param1:String) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.ENABLE_COMBAT_PAUSE_RETREAT,param1));
      }
      
      private function disableUnitCardRemove() : void
      {
         TutorialManager.instance.unitCardRemoveDisabled = true;
      }
      
      private function enableUnitCardRemove() : void
      {
         TutorialManager.instance.unitCardRemoveDisabled = false;
      }
      
      private function highlightStratMapVillain(param1:String) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.UI_HIGHLIGHT_STRATMAP_VILLAIN,param1));
      }
      
      private function enableNeighborBar(param1:String) : void
      {
         if(param1 == "true")
         {
            TutorialManager.instance.neighborBarEnabled = true;
         }
         else
         {
            TutorialManager.instance.neighborBarEnabled = false;
         }
      }
      
      private function highlightPlayerClassCombatIcon(param1:String) : void
      {
         var _loc2_:int = int(param1);
         TutorialManager.instance.highlightCombatClassIcon(_loc2_);
      }
      
      private function removePlayerClassCombatIcon() : void
      {
         TutorialManager.instance.removeClassHighlighter();
      }
      
      private function alwaysShowCombatClassIcon(param1:String) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_ALWAYS_SHOW_CLASS_ICONS,param1));
      }
      
      private function highlightCombatUnitClassIcon(param1:String) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_HIGHLIGHT_UNIT_CLASS_ICON,param1));
      }
      
      private function removeHighlightCombatUnitClassIcon() : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_HIGHLIGHT_CLEAR_UNIT_CLASS_ICON));
      }
      
      private function highlightCombatTooltipClassIcon(param1:String) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_HIGHLIGHT_CLASS_TOOLTIP_ICON,param1));
      }
      
      private function clearHighlightCombatTooltipClassIcon() : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_CLEAR_HIGHLIGHT_CLASS_TOOLTIP_ICON));
      }
      
      private function enableSpecialPowerSelectionTooltip(param1:String) : void
      {
         TutorialManager.instance.specialPowerTooltipsEnabled = param1 == "true";
      }
      
      private function lockItemPurchase(param1:String) : void
      {
         var _loc2_:Array = param1.split(",");
         if(_loc2_)
         {
            TutorialManager.instance.lockedPurchaseItems = _loc2_;
         }
      }
      
      private function clearLockedPurchaseItems() : void
      {
         TutorialManager.instance.lockedPurchaseItems = null;
      }
      
      private function waitForPopupContinue(param1:String = null) : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.QUEST_POPUP_CONTINUE,this.onQuestPopupProgress);
      }
      
      private function waitForQuestCompletePopupContinue(param1:String = null) : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.QUEST_COMPLETE_POPUP_CONTINUE,this.onQuestPopupProgress);
      }
      
      private function waitForQuestCompletion(param1:String = null) : void
      {
         QuestManager.getInstance().addEventListener(ZGameQuestManager.QUEST_COMPLETE,this.onQuestCompleteProgress);
      }
      
      private function waitForStoreClick() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.STORE_OPENED,this.onStoreClicked);
      }
      
      private function waitForStratMapClick() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.STRATEGIC_MAP_CONTINUE,this.onEventProgress);
      }
      
      private function waitForReturnHome() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.RETURN_HOME_CONTINUE,this.onEventProgress);
      }
      
      private function waitForDialogClick() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.DIALOG_CONTINUE,this.onEventProgress);
      }
      
      private function waitForMarketBuyClick() : void
      {
         UIDispatcher.instance.addEventListener(MarketEvent.MARKET_BUY,this.onEventProgress);
      }
      
      private function waitForContractMarketBuyClick() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.CONTRACT_MARKET_BUY_CONTINUE,this.onEventProgress);
      }
      
      private function waitForMarketUseClick() : void
      {
         UIDispatcher.instance.addEventListener(MarketEvent.MARKET_USE,this.onEventProgress);
      }
      
      private function waitForObjectPlaced(param1:String) : void
      {
         WorldObjectManager.instance.addEventListener(WorldObjectManager.OBJECT_PLACED,this.onObjectPlacedServer);
      }
      
      private function waitForObjectPlacedClient(param1:String) : void
      {
         WorldObjectManager.instance.addEventListener(WorldObjectManager.OBJECT_PLACED_CLIENT,this.onObjectPlacedClient);
      }
      
      private function waitForObjectBuilt() : void
      {
         WorldObjectManager.instance.addEventListener(WorldObjectManager.OBJECT_BUILT,this.onEventProgress);
      }
      
      private function waitForObjectClear() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.CLEAR_CONTINUE,this.onEventProgress);
      }
      
      private function waitForObjectSelected(param1:String = null) : void
      {
         if(null != param1)
         {
            WorldObjectManager.instance.addEventListener(WorldObjectManager.OBJECT_SELECTED,this.onObjectSelected);
         }
         else
         {
            TutorialManager.instance.addEventListener(TutorialManager.SELECT_CONTINUE,this.onEventProgress);
         }
      }
      
      private function waitForRewardPickup() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.REWARDPICKUP_CONTINUE,this.onEventProgress);
      }
      
      private function waitForCombatStart() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.COMBAT_START,this.onEventProgress);
      }
      
      private function waitForCombatSequence() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.COMBAT_SEQUENCE_CONTINUE,this.onEventProgress);
      }
      
      private function waitForLetterCreation() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.LETTER_CREATION,this.onEventProgress);
      }
      
      private function waitForLetterContinue() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.LETTER_CONTINUE,this.onEventProgress);
      }
      
      private function waitForLetterClose() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.LETTER_CLOSE,this.onEventProgress);
      }
      
      private function waitForIslandClick(param1:String = null) : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.ISLAND_CONTINUE,this.onIslandClickProgress);
      }
      
      private function waitForContractMarketClick() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.CONTRACT_MARKET_CONTINUE,this.onEventProgress);
      }
      
      private function waitForSpeechPopupContinue() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.SPEECH_CONTINUE,this.onEventProgress);
      }
      
      private function waitForTaskClick(param1:String = null) : void
      {
         this.removeAllUIListeners();
         TutorialManager.instance.addEventListener(TutorialManager.QUEST_TASK_CLICKED,this.onQuestParamProgress);
      }
      
      private function waitForTaskListClick() : void
      {
         var _loc1_:DisplayObject = TutorialManager.instance.getUIItem("TaskList");
         if(_loc1_)
         {
            _loc1_.addEventListener(MouseEvent.CLICK,this.onEventProgress);
            TutorialManager.instance.addArrowToUIElement(_loc1_);
         }
         else
         {
            this.onEventProgress(null);
         }
      }
      
      private function waitForStoreTabClick(param1:String = null) : void
      {
         this.removeStoreTabSelectedEvent();
         TutorialManager.instance.addEventListener(TutorialManager.UI_STORE_TAB_CLICK,this.onStoreTabClicked);
      }
      
      private function waitForCombatEnd() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.COMBAT_END,this.onEventProgress);
      }
      
      private function waitForEpisodeContinue() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.EPISODE_CONTINUE,this.onEventProgress);
      }
      
      private function waitForBuildComplete() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.BUILD_FINISHED,this.onEventProgress);
      }
      
      private function waitForCombatConsumableSelected() : void
      {
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_CONSUMABLE_SELECTED,this.onEventProgress);
      }
      
      private function waitForCombatConsumableUsed() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.COMBAT_CONSUMABLE_USED,this.onEventProgress);
      }
      
      private function waitForCombatAllyUsed() : void
      {
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_CONSUMABLE_USED,this.onEventProgress);
      }
      
      private function waitForCombatAllyAdd() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.COMBAT_ALLY_ADDED,this.onEventProgress);
      }
      
      private function waitForCombatUnitAdd() : void
      {
         UIDispatcher.instance.addEventListener(GridSlot.SELECTED,this.onEventProgress);
      }
      
      private function waitForCombatAllySelectScreen() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.COMBAT_ALLIES_SCREEN,this.onEventProgress);
      }
      
      private function waitForCombatUnitSelectScreen() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.COMBAT_UNITS_SCREEN,this.onEventProgress);
      }
      
      private function waitForCombatSpecialPowerSelectScreen() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.COMBAT_SPECIALPOWERS_SCREEN,this.onEventProgress);
      }
      
      private function waitforCombatSpecialPowerSelectScreenPreAnim() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.COMBAT_SPECIALPOWERS_SCREEN_PRE_ANIM,this.onEventProgress);
      }
      
      private function waitForCombatFightClick() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.COMBAT_FIGHT_CONTINUE,this.onEventProgress);
      }
      
      private function waitForCombatUnitClick(param1:String = null) : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.COMBAT_UNIT_CLICK,this.onCombatUnitClicked);
      }
      
      private function waitForSpecialPowerClick() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.COMBAT_SPECIAL_POWER_CLICKED,this.onEventProgress);
      }
      
      private function waitForNewNationContinue() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.NEW_NATION_CONTINUE,this.onEventProgress);
      }
      
      private function waitForBattleStart() : void
      {
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_START,this.onEventProgress);
      }
      
      private function waitForCombatAllyNext() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.COMBAT_ALLY_NEXT,this.onEventProgress);
      }
      
      private function waitForStratMapHomeClick() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.STRAT_MAP_HOME_CLICK,this.onEventProgress);
      }
      
      private function waitForSpecificBattleStart(param1:String = null) : void
      {
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_START,this.onBattleStartProgress);
      }
      
      private function waitForZoomInClick() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.ZOOM_IN_CLICK,this.onEventProgress);
      }
      
      private function waitForZoomOutClick() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.ZOOM_OUT_CLICK,this.onEventProgress);
      }
      
      private function waitForFullScreenClick() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.FULL_SCREEN_CLICK,this.onEventProgress);
      }
      
      private function waitForPreBattleUI() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.COMBAT_PRE_BATTLE_UI_READY,this.onEventProgress);
      }
      
      private function waitForPVPMarkerLoaded() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.PVP_MARKER_LOADED,this.onEventProgress);
      }
      
      private function waitForRepelClick() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.PVP_REPEL_CLICKED,this.onRepelClick);
      }
      
      private function waitForInventoryClick() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.INVENTORY_OPENED,this.onEventProgress);
      }
      
      private function waitForNeighborVisitClick(param1:String = null) : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.NEIGHBOR_VISIT_CLICKED,this.onNeighborBarSlotClick);
      }
      
      private function waitForStratMapLoaded() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.STRAT_MAP_LOADED,this.onEventProgress);
      }
      
      private function waitForInviteFriendsContinue() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.INVITE_FRIENDS_CONTINUE,this.onEventProgress);
      }
      
      private function waitForWorldLoaded(param1:String) : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.WORLD_LOADED_CONTINUE,this.onWorldLoadedProgress);
      }
      
      private function waitForBattleHostBattleEnd() : void
      {
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_COMPLETE_HOST,this.onEventProgress);
      }
      
      private function waitForBattlePause() : void
      {
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_PAUSE,this.onEventProgress);
      }
      
      private function waitForBattleCancel() : void
      {
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_CANCEL,this.onEventProgress);
      }
      
      private function waitForContractScreenLoaded() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.CONTRACT_SCREEN_LOADED,this.onEventProgress);
      }
      
      private function waitForInventoryClosed() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.INVENTORY_CLOSED,this.onEventProgress);
      }
   }
}

