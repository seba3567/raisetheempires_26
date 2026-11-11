package core.worlds.strategicWorld
{
   import Engine.Managers.TransactionManager;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.prebattle.GMPreBattle;
   import core.gameobjects.Fleet;
   import core.gameobjects.GameItem;
   import core.gameobjects.IslandGroupItem;
   import core.gameobjects.IslandItem;
   import core.gameobjects.LetterItemWrapper;
   import core.gameobjects.UnitItem;
   import core.managers.InventoryList;
   import core.managers.campaignManager.CampaignManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.warehouseManager.WarehouseUnitManager;
   import core.managers.worldUnitManager.WorldUnitManager;
   import dispatchers.StrategicDispatcher;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.LetterPopup;
   import displays.popups.OutOfUnitsPopup;
   import displays.popups.genericPopup.GenericPopup1B;
   import displays.screens.ItemTooltip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import transactions.TBeginCampaign;
   import utils.ZGameUtils;
   import zlabs.entity.EntityComponent;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class StrategicIslandDataComponent extends EntityComponent
   {
      
      private static const STATE_NONE:int = 0;
      
      private static const STATE_REPLAY_COMPLETED:int = 1;
      
      private static const STATE_CONTINUE_CURRENT:int = 2;
      
      private var m_islandItem:IslandItem = null;
      
      private var m_enemyFleet:Fleet = null;
      
      private var m_playerFleet:Fleet = null;
      
      private var m_state:int = 0;
      
      public function StrategicIslandDataComponent(param1:IslandItem)
      {
         super();
         this.m_islandItem = param1;
      }
      
      public static function startIslandCampaign(param1:IslandItem) : void
      {
         TransactionManager.addTransaction(new TBeginCampaign());
         var _loc2_:Fleet = ZGlobal.player.fleets.createFleet(param1.playerType,true);
         if(!ZGlobal.player.campaign.currentMap.inReplay)
         {
            _loc2_.inventory = param1.getFleetInventory();
         }
         var _loc3_:Fleet = param1.createFleet();
         ZGlobal.player.campaign.currentMap.start(param1,_loc2_.name,_loc3_.name);
      }
      
      public function get islandItem() : IslandItem
      {
         return this.m_islandItem;
      }
      
      public function fillTooltip() : ItemTooltip
      {
         return new ItemTooltip(GameItem.ISLAND_TOOLTIP,this.m_islandItem,ItemTooltip.SOURCE_NONE);
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         owner.eventDispatcher.addEventListener(MouseEvent.CLICK,this.onClick);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.REMATCH,this.onRematch);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.CANCEL,this.onCancel);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         owner.eventDispatcher.removeEventListener(MouseEvent.CLICK,this.onClick);
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.DEPLOY,this.onFleetDeploy);
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.REMATCH,this.onRematch);
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.CANCEL,this.onCancel);
         this.m_islandItem = null;
      }
      
      public function click() : void
      {
         var _loc1_:int = this.m_islandItem.index;
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.ISLAND_CONTINUE,_loc1_));
         }
         this.onClick(null);
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         var _loc4_:IslandGroupItem = null;
         var _loc5_:int = 0;
         var _loc2_:String = CampaignManager.instance.getCampaignForChapter(this.m_islandItem.map);
         var _loc3_:StrategicMap = ZGlobal.player.campaign.mapInProgressForCampaign(_loc2_);
         if(this.isLocked())
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(this.map.code,IslandGroupItem) as IslandGroupItem;
            if(_loc4_.questLocked)
            {
               this.error("Campaign_IslandLockedTitle","Campaign_IslandLockedQuest",true);
            }
            else
            {
               this.error("Campaign_IslandLockedTitle","Campaign_IslandLockedDesc",true);
            }
         }
         else if(this.isDone())
         {
            if(this.isReplay())
            {
               this.continueCampaign();
            }
            else if(_loc3_ != null)
            {
               this.m_state = STATE_CONTINUE_CURRENT;
               this.error("Campaign_IslandInProgressTitle","Campaign_IslandInProgressDesc");
            }
            else
            {
               _loc5_ = ZGlobal.player.campaign.getMastery(this.m_islandItem.index);
               if(_loc5_ >= 3)
               {
                  this.m_state = STATE_REPLAY_COMPLETED;
                  this.error("Campaign_IslandCompletedTitle","Campaign_IslandCompletedDesc");
               }
               else if(this.hasUnitsToBattle())
               {
                  ZGlobal.player.campaign.currentMap.replay(this.m_islandItem);
                  this.startCampaign();
               }
            }
         }
         else if(null != _loc3_)
         {
            if(this.isReplay())
            {
               this.continueCampaign();
            }
            else if(!this.map.inReplay && this.isProgess())
            {
               this.continueCampaign();
               BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_RESUME));
            }
            else
            {
               this.m_state = STATE_CONTINUE_CURRENT;
               this.error("Campaign_IslandInProgressTitle","Campaign_IslandInProgressDesc");
            }
         }
         else if(!this.addLetter())
         {
            if(this.hasUnitsToBattle())
            {
               this.startCampaign();
            }
         }
      }
      
      private function addLetter() : Boolean
      {
         var _loc1_:LetterItemWrapper = new LetterItemWrapper(this.m_islandItem);
         var _loc2_:String = _loc1_.startingLetter;
         if(Boolean(_loc2_) && !ZGlobal.player.hasSeenDialog("letter",_loc2_))
         {
            PopupManager.instance.push(new LetterPopup(_loc2_,this.onLetterClosed));
            return true;
         }
         return false;
      }
      
      private function onLetterClosed(param1:Event) : void
      {
         this.startCampaign();
      }
      
      private function error(param1:String, param2:String, param3:Boolean = false) : void
      {
         var _loc4_:GenericPopup = null;
         var _loc5_:String = ZGameUtils.ZlocT("Campaign",param1);
         var _loc6_:String = ZGameUtils.ZlocT("Campaign",param2);
         if(param3)
         {
            _loc4_ = GenericPopup1B.NewOk(_loc6_,_loc5_,this.onPopupSelected);
         }
         else
         {
            _loc4_ = GenericPopup2B.NewAcceptCancel(_loc6_,_loc5_,this.onPopupSelected);
         }
         PopupManager.instance.push(_loc4_);
      }
      
      private function continueCampaignIfHasUnits() : void
      {
         if(this.hasUnitsToBattle())
         {
            this.continueCampaign();
         }
      }
      
      private function continueCampaign() : void
      {
         this.m_playerFleet = Fleet.getFleet(this.map.fleets[0]);
         this.m_enemyFleet = Fleet.getFleet(this.map.fleets[1]);
         this.startBattle();
         ZGameStats.instance.dispatchEvent(new Event(ZGameStats.STATS_RESUME_CAMPAIGN_BATTLE));
      }
      
      private function startCampaign() : void
      {
         if(GMPreBattle.ENABLED)
         {
            startIslandCampaign(this.m_islandItem);
         }
         else
         {
            StrategicDispatcher.instance.addEventListener(StrategicDispatcher.DEPLOY,this.onFleetDeploy);
         }
      }
      
      private function hasUnitsToBattle(param1:Boolean = true) : Boolean
      {
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc2_:String = this.m_islandItem.playerType;
         var _loc3_:UnitItem = null;
         var _loc4_:Dictionary = WorldUnitManager.instance.availableUnits;
         for(_loc5_ in _loc4_)
         {
            if(_loc4_[_loc5_] > 0)
            {
               _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc5_,UnitItem) as UnitItem;
               if(Boolean(_loc3_) && _loc3_.subType == _loc2_)
               {
                  return true;
               }
            }
         }
         _loc6_ = InventoryList.instance.items;
         _loc7_ = 0;
         while(_loc7_ < _loc6_.length)
         {
            _loc10_ = _loc6_[_loc7_];
            _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc10_,UnitItem) as UnitItem;
            if(Boolean(_loc3_ && _loc3_.type == "Buildable") && Boolean(_loc3_.subType == _loc2_) && ZGlobal.player.getNumberOfInventoryItems(_loc10_) > 0)
            {
               return true;
            }
            _loc7_++;
         }
         var _loc8_:Dictionary = WarehouseUnitManager.instance.getAvailableUnits();
         for(_loc9_ in _loc8_)
         {
            if(_loc8_[_loc9_] > 0)
            {
               _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc9_,UnitItem) as UnitItem;
               if(Boolean(_loc3_) && _loc3_.subType == _loc2_)
               {
                  return true;
               }
            }
         }
         if(param1)
         {
            OutOfUnitsPopup.display(_loc2_);
         }
         return false;
      }
      
      private function onFleetDeploy(param1:WorldEvent) : void
      {
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.DEPLOY,this.onFleetDeploy);
         TransactionManager.addTransaction(new TBeginCampaign());
         this.m_enemyFleet = this.m_islandItem.createFleet();
         this.m_playerFleet = param1.eventData as Fleet;
         this.startBattle();
      }
      
      private function startBattle() : void
      {
         ZGlobal.player.campaign.currentMap.start(this.m_islandItem,this.m_playerFleet.name,this.m_enemyFleet.name);
         this.m_playerFleet = null;
         this.m_enemyFleet = null;
      }
      
      private function get map() : StrategicMap
      {
         return ZGlobal.player.campaign.getMap(this.m_islandItem.map);
      }
      
      public function isLocked() : Boolean
      {
         var _loc1_:StrategicMap = ZGlobal.player.campaign.getKey(this.m_islandItem.map);
         if(null != _loc1_)
         {
            if(ZGlobal.player.campaign.isMapLocked(this.m_islandItem.map))
            {
               return true;
            }
         }
         return this.m_islandItem.index > this.map.progressIsland;
      }
      
      public function isDone() : Boolean
      {
         return this.m_islandItem.index < this.map.progressIsland;
      }
      
      public function isProgess() : Boolean
      {
         if(this.map.inProgress)
         {
            return this.m_islandItem.index == this.map.progressIsland;
         }
         return false;
      }
      
      public function isReplay() : Boolean
      {
         if(this.map.inReplay)
         {
            return this.m_islandItem.index == this.map.replayIsland;
         }
         return false;
      }
      
      private function onPopupSelected(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            switch(this.m_state)
            {
               case STATE_CONTINUE_CURRENT:
                  this.m_state = STATE_NONE;
                  StrategicDispatcher.instance.dispatchEvent(new Event(StrategicDispatcher.CONTINUE_PROGRESS));
                  break;
               case STATE_REPLAY_COMPLETED:
                  this.m_state = STATE_NONE;
                  if(this.hasUnitsToBattle())
                  {
                     ZGlobal.player.campaign.currentMap.replay(this.m_islandItem);
                     this.startCampaign();
                  }
            }
         }
      }
      
      private function onRematch(param1:Event) : void
      {
         if(this.map.progressIsland == this.m_islandItem.index)
         {
            this.startCampaign();
            param1.stopImmediatePropagation();
            param1.stopPropagation();
         }
      }
      
      private function onCancel(param1:Event) : void
      {
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.DEPLOY,this.onFleetDeploy);
         if(ZGlobal.player.campaign.currentMap.inReplay)
         {
            if(ZGlobal.player.campaign.currentMap.replayIsland == this.m_islandItem.index)
            {
               ZGlobal.player.campaign.currentMap.replay(null);
            }
         }
      }
   }
}

