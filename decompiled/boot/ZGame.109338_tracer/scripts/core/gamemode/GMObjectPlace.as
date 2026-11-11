package core.gamemode
{
   import Engine.Managers.TransactionManager;
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.Pt;
   import core.ZGameManager;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.entities.components.utils.YieldHelper;
   import core.gamemode.helpers.PlacementProxy;
   import core.gamemode.helpers.UnitPlacementProxy;
   import core.gameobjects.GameItem;
   import core.managers.WorldObjectManager;
   import core.managers.leaderboardManager.LeaderboardManager;
   import core.managers.rewardPickupManager.RewardPickupManager;
   import core.ui.PlayerFeedbackManager;
   import core.ui.actionfeedback.CashActionFeedback;
   import core.ui.actionfeedback.ResourceActionFeedback;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import displays.popups.GenericPopup;
   import displays.screens.InventoryDialog;
   import entity.BuildingEntity;
   import entity.EntityInit;
   import entity.GameDataComponent;
   import events.MarketEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import rendering.renderingIso.QuadSpatialManager;
   import transactions.TDecorationPlace;
   import utils.TileUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.core.PBGroup;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   
   public class GMObjectPlace extends GMObjectMatchTerrainMove
   {
      
      private var m_type:String;
      
      private var m_forcedPlacement:Boolean = false;
      
      private var m_showInventoryPopup:Boolean = true;
      
      private var m_statsInfo:Object = null;
      
      protected var m_object:Object = null;
      
      public function GMObjectPlace(param1:String, param2:int = 0, param3:Boolean = false, param4:Object = null, param5:Object = null)
      {
         this.m_type = param1;
         m_source = param2;
         this.m_forcedPlacement = param3;
         this.m_statsInfo = param4;
         this.m_object = param5;
         super(null);
         this.createSelectedObjectProxy();
      }
      
      public static function notifyPlacementPopup(param1:GameItem) : void
      {
         var _loc3_:String = null;
         var _loc2_:Object = new Object();
         var _loc4_:String = InventoryDialog.getTabLabelString(param1);
         if((Boolean(_loc4_)) && param1.type == GameItem.TYPE_BUILDABLE)
         {
            if(param1.subType == GameItem.SUBTYPE_DECORATION)
            {
               _loc2_.tab = _loc4_;
               _loc3_ = "ItemPlacedIntoInventoryTab";
            }
            else
            {
               _loc2_.tab = _loc4_;
               _loc3_ = "UnitPlacedIntoInventoryTab";
            }
         }
         else if(param1.type == GameItem.TYPE_BUILDABLE)
         {
            if(param1.subType == GameItem.SUBTYPE_DECORATION)
            {
               _loc3_ = "ItemPlacedIntoInventory";
            }
            else
            {
               _loc3_ = "UnitPlacedIntoInventory";
            }
         }
         else if(Boolean(_loc4_) && param1.type == GameItem.TYPE_BUILDING)
         {
            _loc2_.tab = _loc4_;
            _loc3_ = "BuildingPlacedIntoInventoryTab";
         }
         else if(param1.type == GameItem.TYPE_BUILDING)
         {
            _loc3_ = "BuildingPlacedIntoInventory";
         }
         else if(_loc4_)
         {
            _loc2_.tab = _loc4_;
            _loc3_ = "ItemPlacedIntoInventoryTab";
         }
         else
         {
            _loc3_ = "ItemPlacedIntoInventory";
         }
         PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs",_loc3_,_loc2_)),100);
      }
      
      public static function placeItem(param1:GameItem, param2:int) : Boolean
      {
         if(param2 == MarketEvent.SOURCE_INVENTORY)
         {
            return ZGlobal.player.removeInventoryItem(param1.code);
         }
         if(param2 == MarketEvent.SOURCE_STORE)
         {
            LeaderboardManager.instance.dispatchEvent(new WorldEvent(LeaderboardManager.LEADERBOARD_SUPRESS_SURFACING,true));
            ZGlobal.player.buyItem(param1,param1.cash != 0);
            LeaderboardManager.instance.dispatchEvent(new WorldEvent(LeaderboardManager.LEADERBOARD_SUPRESS_SURFACING,false));
            return true;
         }
         return false;
      }
      
      override protected function highlightEntity(param1:MouseEvent) : void
      {
      }
      
      override protected function getCursor() : Object
      {
         if(m_source == MarketEvent.SOURCE_BUILDING && contextCursor())
         {
            return m_storageCursor;
         }
         return null;
      }
      
      private function get isInventory() : Boolean
      {
         return m_source == MarketEvent.SOURCE_INVENTORY || m_source == MarketEvent.SOURCE_BUILDING;
      }
      
      override public function disableMode() : void
      {
         var _loc1_:GameItem = null;
         if(Boolean(m_selectedObjectProxy && !m_objectPlacedSuccess && this.isInventory) && Boolean(this.m_forcedPlacement) && this.m_showInventoryPopup)
         {
            _loc1_ = ZGlobal.gameSettings.getItemByName(this.m_type,GameItem) as GameItem;
            if(ZGlobal.player.m_showAnnoyingInventoryDialog[_loc1_.subType] == true || _loc1_.forceAnnoyingInventoryDialog)
            {
               notifyPlacementPopup(_loc1_);
            }
            ZGlobal.player.m_showAnnoyingInventoryDialog[_loc1_.subType] = false;
         }
         super.disableMode();
      }
      
      private function createSelectedObjectProxy() : void
      {
         var _loc1_:IsoViewComponent = null;
         var _loc2_:IsoScene = null;
         var _loc3_:PBGroup = null;
         var _loc4_:GameItem = null;
         var _loc5_:QuadSpatialManager = null;
         var _loc6_:IEntity = null;
         var _loc7_:EntityInit = null;
         if(!m_selectedObjectProxy)
         {
            cacheIsoScene();
            _loc1_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
            _loc2_ = IsoScene(_loc1_.getSceneByID(ZGameManager.SCENE_GROUND_LAYER));
            screenToIso(getMouseStagePos(m_currentPos),m_highlightedPoint);
            _loc3_ = Zlab.nameManager.lookup(ZGameManager.WORLD_OBJECT_GROUP_NAME);
            _loc4_ = ZGlobal.gameSettings.getItemByName(this.m_type,GameItem) as GameItem;
            _loc5_ = QuadSpatialManager.getQuadSpatialManagerFromWorld(IslandWorld.ID,_loc4_);
            switch(_loc4_.type)
            {
               case GameItem.TYPE_BUILDABLE:
               case GameItem.TYPE_BUILDING:
                  _loc7_ = new EntityInit();
                  _loc7_.m_item = _loc4_;
                  _loc7_.m_isoScene = _loc2_;
                  _loc7_.m_fromLoad = false;
                  _loc7_.m_spatialComponent = _loc5_;
                  _loc7_.m_group = _loc3_;
                  _loc7_.m_delayId = true;
                  _loc7_.m_position = Pt.toPt(TileUtil.worldToTile(Pt.toVector3D(m_highlightedPoint),true));
                  if(this.m_object)
                  {
                     _loc7_.m_object = this.m_object;
                  }
                  _loc6_ = BuildingEntity.createEntity(_loc7_);
                  break;
               case GameItem.TYPE_CONSUMABLE:
                  notifyPlacementPopup(_loc4_);
            }
            if(UnitDefenseRangeRect.isUnit(_loc6_) || UnitDefenseRangeRect.isImmunityBuilding(_loc6_))
            {
               m_selectedObjectProxy = new UnitPlacementProxy(_loc6_ as IEntity);
            }
            else
            {
               m_selectedObjectProxy = new PlacementProxy(_loc6_);
            }
            m_selectedObjectProxy.moveTo(Pt.toVector3D(m_highlightedPoint));
         }
      }
      
      override public function onMouseUp(param1:MouseEvent) : Boolean
      {
         var itemXml:XML = null;
         var canBuy:Boolean = false;
         var gameItem:GameItem = null;
         var _entity:IEntity = null;
         var canPlaceNext:Boolean = false;
         var stateMachineComp:BuildingFSMComponent = null;
         var isInventoryValidForMultiPlace:Boolean = false;
         var gameDataComponent:GameDataComponent = null;
         var currentState:BehaviorState = null;
         var yieldHelper:YieldHelper = null;
         var images:Array = null;
         var xmlImages:XMLList = null;
         var xmlIdx:int = 0;
         var code:String = null;
         var placeXp:int = 0;
         var coinsFeedback:ResourceActionFeedback = null;
         var defaultMode:GMDefault = null;
         var cost:int = 0;
         var cashFeedback:CashActionFeedback = null;
         var event:MouseEvent = param1;
         var wasDragging:Boolean = m_dragging;
         super.onMouseUp(event);
         if(m_objectPlacedSuccess)
         {
            itemXml = ZGlobal.gameSettings.getItemXMLByName(this.m_type);
            canBuy = true;
            gameItem = ZGlobal.gameSettings.getItemByName(this.m_type,GameItem) as GameItem;
            _entity = m_selectedObjectProxy.getMapResource() as IEntity;
            canPlaceNext = true;
            stateMachineComp = _entity.lookupComponentByType(BuildingFSMComponent) as BuildingFSMComponent;
            if(stateMachineComp)
            {
               currentState = stateMachineComp.stateMachine.currentState as BehaviorState;
               yieldHelper = currentState.yieldHelper;
               if(yieldHelper.usesEnergy(_entity))
               {
                  if(!ZGlobal.player.m_energy.checkEnergy(-yieldHelper.getEnergyRequirement(_entity).energy))
                  {
                     canBuy = false;
                  }
                  else
                  {
                     canBuy = true;
                  }
               }
            }
            if(Boolean(itemXml) && this.isInventory == false)
            {
               placeItem(gameItem,m_source);
               if(itemXml.@actionBundle.toString() != "")
               {
                  images = [];
                  xmlImages = itemXml.image.(@name == "newsfeed");
                  if(Boolean(xmlImages) && Boolean(xmlImages.length()))
                  {
                     xmlIdx = 0;
                     while(xmlIdx < xmlImages.length())
                     {
                        images.push({
                           "src":ZGlobal.getAssetURL(xmlImages[xmlIdx].@url),
                           "href":"{SN_APP_URL}{creative:picture}index.php"
                        });
                        xmlIdx++;
                     }
                  }
                  else
                  {
                     xmlImages = itemXml.image.(@name == "icon");
                     if(xmlImages.length())
                     {
                        images.push({
                           "src":ZGlobal.getAssetURL(xmlImages[0].@url),
                           "href":"{SN_APP_URL}{creative:picture}index.php"
                        });
                     }
                  }
               }
            }
            if(canBuy)
            {
               canBuy = ZGlobal.player.canBuy(gameItem,false);
            }
            isInventoryValidForMultiPlace = false;
            if(this.isInventory)
            {
               code = gameItem.code;
               isInventoryValidForMultiPlace = ZGlobal.player.getNumberOfInventoryItems(code) > 1;
               placeItem(gameItem,m_source);
               placeXp = gameItem.placeXp;
               if(placeXp > 0)
               {
                  RewardPickupManager.instance.addXpReward(m_selectedObjectProxy.getMapResource(),placeXp);
               }
            }
            WorldObjectManager.instance.addObjectToCodeDictionary(gameItem.code);
            WorldObjectManager.instance.addObjectToTypeDictionary(gameItem.type,gameItem.subType,_entity.name,_entity);
            WorldObjectManager.instance.addObjectToCategoryDictionary(gameItem.categoryLimitName);
            gameDataComponent = GameDataComponent(m_selectedObjectProxy.getMapResource().lookupComponentByType(GameDataComponent));
            WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.OBJECT_PLACED_CLIENT,gameDataComponent.gameData.code));
            Logger.print(this,"JMR: about to send TDecorationPlace");
            if(!(Boolean(this.m_object) && Boolean(this.m_object.neighborhood)))
            {
               TransactionManager.addTransaction(new TDecorationPlace(m_selectedObjectProxy.getMapResource(),this.isInventory,0,this.m_statsInfo));
               m_selectedObjectProxy.onPurchased();
            }
            if(Boolean(yieldHelper) && yieldHelper.usesEnergy(_entity))
            {
               if(!ZGlobal.player.m_energy.checkEnergy(-yieldHelper.getEnergyRequirement(_entity).energy))
               {
                  canPlaceNext = false;
               }
            }
            if(Boolean(gameItem && gameItem.multiplace) && (Boolean(canBuy == true && this.isInventory == false || this.isInventory == true && isInventoryValidForMultiPlace == true)) && canPlaceNext)
            {
               if(!this.isInventory)
               {
                  coinsFeedback = new ResourceActionFeedback(_entity,"coins",-gameItem.cost,0);
               }
               GameModeManager.instance.addGameMode(new GMObjectPlace(this.m_type,m_source));
            }
            else
            {
               if(!this.isInventory && gameItem.subType == GameItem.TYPE_DECORATION)
               {
                  cost = gameItem.cash;
                  if(cost != 0)
                  {
                     cashFeedback = new CashActionFeedback(_entity,-cost,0);
                  }
               }
               defaultMode = GameModeManager.instance.setDefaultGameMode();
               defaultMode.updatePointer();
               defaultMode = null;
            }
         }
         else if(!wasDragging && Boolean(m_selectedObjectProxy))
         {
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackCannotPlaceHere"),m_selectedObjectProxy.getMapResource());
         }
         return true;
      }
      
      override protected function onExitMode(param1:Event) : void
      {
         var _loc2_:GameDataComponent = null;
         if(m_selectedObjectProxy)
         {
            _loc2_ = GameDataComponent(m_selectedObjectProxy.getMapResource().lookupComponentByType(GameDataComponent));
            WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.OBJECT_PLACE_CANCELLED,_loc2_.gameData.code));
            super.exitMode();
         }
      }
      
      public function set showInventoryPopup(param1:Boolean) : void
      {
         this.m_showInventoryPopup = param1;
      }
   }
}

