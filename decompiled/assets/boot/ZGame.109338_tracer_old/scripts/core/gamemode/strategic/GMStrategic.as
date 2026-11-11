package core.gamemode.strategic
{
   import core.ZGlobal;
   import core.gamemode.GameMode;
   import core.gameobjects.IslandGroupItem;
   import core.managers.campaignManager.CampaignManager;
   import core.managers.rewardPickupManager.RewardPickupManager;
   import core.ui.menuitem.ContextualBarUIItem;
   import core.ui.menuitem.PlayerStatsUIItem;
   import core.views.ViewManager;
   import core.worlds.strategicWorld.StrategicIslandDataComponent;
   import core.worlds.strategicWorld.StrategicMap;
   import core.worlds.strategicWorld.StrategicWorld;
   import core.worlds.strategicWorld.swf.version2.StrategicRegionSWFRendererComponent;
   import dispatchers.StrategicDispatcher;
   import dispatchers.UIDispatcher;
   import flash.display.MovieClip;
   import flash.events.Event;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.core.PBGroup;
   import zlabs.entity.EntityComponent;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class GMStrategic extends GameMode
   {
      
      private static const ISLAND_GROUP_NAME:String = "StrategicIslandGroup";
      
      private var m_islandGroup:IslandGroupItem = null;
      
      public function GMStrategic()
      {
         super();
      }
      
      public static function setProgress(param1:MovieClip, param2:Number, param3:IslandGroupItem) : void
      {
         var _loc4_:int = param3.numIslands;
         var _loc5_:StrategicMap = ZGlobal.player.campaign.getMap(param3.code);
         var _loc6_:int = _loc5_.progressIsland;
         _loc6_ = Math.min(_loc6_,_loc4_);
         var _loc7_:Number = _loc6_ / _loc4_;
         param1.bar_mc.width = param2 * _loc7_;
         TextFieldUtil.processTextField(param1.strength_tf,ZGameUtils.ZlocT("Dialogs","BattleSelect_Progress",{"amount":int(_loc7_ * 100)}));
      }
      
      override public function get canSwitchToTutorial() : Boolean
      {
         return false;
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.LEFT,this.onLeft);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.RIGHT,this.onRight);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.SHIFT_LEFT,this.onShiftLeft);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.SHIFT_RIGHT,this.onShiftRight);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.SELECTED,this.onMapSelected);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.QUEST_LOCKING_UPDATED,this.onQuestLockingUpdated);
         StrategicDispatcher.instance.dispatchEvent(new Event(StrategicDispatcher.ENTERED));
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.UI_PLAYER_ISLAND_MODE_ACTIVE,{"active":false}));
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.UI_PAUSE_QUEST_ICONS,true));
         PlayerStatsUIItem.getPlayerStats().dispatchEvent(new WorldEvent(PlayerStatsUIItem.HIDE_ELEMENTS_FOR_CAMPAIGN,true));
         RewardPickupManager.instance.clear();
         this.displayWorld(ZGlobal.player.campaign.activeMap);
         ContextualBarUIItem.getContextualBar().hide(true);
         if(ZGlobal.player.campaign.rematch)
         {
            ZGlobal.player.campaign.rematch = false;
            StrategicIslandDataComponent.startIslandCampaign(ZGlobal.player.campaign.currentMap.currentIslandItem);
         }
         else
         {
            this.displayLetters();
         }
      }
      
      override public function disableMode() : void
      {
         super.disableMode();
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.LEFT,this.onLeft);
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.RIGHT,this.onRight);
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.SHIFT_LEFT,this.onShiftLeft);
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.SHIFT_RIGHT,this.onShiftRight);
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.SELECTED,this.onMapSelected);
         StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.QUEST_LOCKING_UPDATED,this.onQuestLockingUpdated);
         StrategicDispatcher.instance.dispatchEvent(new Event(StrategicDispatcher.EXITED));
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.UI_PLAYER_ISLAND_MODE_ACTIVE,{"active":true}));
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.UI_PAUSE_QUEST_ICONS,false));
         PlayerStatsUIItem.getPlayerStats().dispatchEvent(new WorldEvent(PlayerStatsUIItem.HIDE_ELEMENTS_FOR_CAMPAIGN,false));
         this.disposeWorld();
         ContextualBarUIItem.getContextualBar().show(true);
      }
      
      protected function getPBGroup() : PBGroup
      {
         return Zlab.nameManager.lookup(ISLAND_GROUP_NAME);
      }
      
      protected function displayWorld(param1:String) : void
      {
         var _loc3_:Array = null;
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc6_:IslandGroupItem = null;
         this.disposeWorld();
         ZGlobal.player.campaign.currentMapName = param1;
         var _loc2_:PBGroup = new PBGroup();
         _loc2_.initialize(ISLAND_GROUP_NAME);
         if(StrategicWorld.NEW_VERSION)
         {
            _loc3_ = CampaignManager.instance.getChaptersArray(ZGlobal.player.campaign.currentCampaignName);
            for each(_loc4_ in _loc3_)
            {
               _loc5_ = _loc4_.@code;
               _loc6_ = ZGlobal.gameSettings.getItemByCode(_loc5_,IslandGroupItem) as IslandGroupItem;
               this.createIslandGroup(_loc6_,param1 == _loc5_);
            }
         }
         else if(!ZGlobal.player.campaign.rematch)
         {
            this.m_islandGroup = ZGlobal.gameSettings.getItemByCode(param1,IslandGroupItem) as IslandGroupItem;
            this.m_islandGroup.load();
         }
      }
      
      protected function disposeWorld() : void
      {
         var _loc1_:PBGroup = Zlab.nameManager.lookup(ISLAND_GROUP_NAME);
         if(null != _loc1_)
         {
            _loc1_.destroy();
         }
         this.m_islandGroup = null;
      }
      
      protected function createIslandGroup(param1:IslandGroupItem, param2:Boolean) : void
      {
         var _loc3_:IEntity = Zlab.allocateEntity();
         _loc3_.owningGroup = Zlab.nameManager.lookup(ISLAND_GROUP_NAME);
         var _loc4_:EntityComponent = new StrategicRegionSWFRendererComponent(param1,param2);
         _loc3_.addComponent(_loc4_,"regionRenderer");
         _loc3_.initialize();
      }
      
      private function displayLetters() : void
      {
         ZGlobal.player.campaign.currentMap.showStartingSpeech();
         ZGlobal.player.campaign.currentMap.showStartingLetter();
         ZGlobal.player.campaign.currentMap.showStartingConversation();
      }
      
      private function onQuestLockingUpdated(param1:Event) : void
      {
         this.displayLetters();
      }
      
      private function gotoMap(param1:String) : void
      {
         if(param1.length > 0 && param1 != ZGlobal.player.campaign.currentMapName)
         {
            ViewManager.instance.currentView.eventDispatcher.dispatchEvent(new WorldEvent(ViewManager.RELOAD));
            this.displayWorld(param1);
         }
      }
      
      protected function onLeft(param1:Event) : void
      {
         ZGlobal.player.campaign.setPrevCampaign();
         this.gotoMap(ZGlobal.player.campaign.activeMap);
      }
      
      protected function onRight(param1:Event) : void
      {
         ZGlobal.player.campaign.setNextCampaign();
         this.gotoMap(ZGlobal.player.campaign.activeMap);
      }
      
      private function onShiftLeft(param1:Event) : void
      {
         var _loc4_:StrategicMap = null;
         var _loc2_:String = ZGlobal.player.campaign.currentMapName;
         var _loc3_:* = 10;
         while(_loc3_ > 0)
         {
            _loc4_ = ZGlobal.player.campaign.getKey(_loc2_);
            if(null != _loc4_)
            {
               _loc2_ = _loc4_.code;
            }
            _loc3_--;
         }
         this.gotoMap(_loc2_);
      }
      
      private function onShiftRight(param1:Event) : void
      {
         var _loc5_:String = null;
         var _loc2_:IslandGroupItem = this.islandGroup;
         var _loc3_:String = _loc2_.unlocks;
         var _loc4_:* = 9;
         while(_loc4_ > 0)
         {
            _loc2_ = ZGlobal.gameSettings.getItemByCode(_loc3_,IslandGroupItem) as IslandGroupItem;
            _loc5_ = _loc2_.unlocks;
            if(_loc5_.length > 0)
            {
               _loc3_ = _loc5_;
            }
            _loc4_--;
         }
         this.gotoMap(_loc3_);
      }
      
      private function onMapSelected(param1:WorldEvent) : void
      {
         this.gotoMap(param1.eventData as String);
      }
      
      public function get islandGroup() : IslandGroupItem
      {
         return this.m_islandGroup;
      }
   }
}

