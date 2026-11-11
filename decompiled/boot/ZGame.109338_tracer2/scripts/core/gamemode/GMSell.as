package core.gamemode
{
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.Transaction;
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.WorldUnitComponent;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.gamemode.island.GMIsland;
   import core.gameobjects.GameItem;
   import core.gameobjects.RoadGameItem;
   import core.managers.BuildManager;
   import core.managers.NeighborhoodHelper;
   import core.managers.PVPManager;
   import core.managers.PopulationManager;
   import core.managers.WorldObjectManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.worldUnitManager.WorldUnitManager;
   import core.ui.CursorManager;
   import core.ui.PickManager;
   import core.ui.PlayerFeedbackManager;
   import core.ui.actionfeedback.ActionFeedback;
   import core.ui.actionfeedback.ResourceActionFeedback;
   import core.ui.menuitem.OptionUIItem;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import dispatchers.UIDispatcher;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.HudsonPopup;
   import displays.popups.genericPopup.GenericPopup1B;
   import entity.GameDataComponent;
   import entity.WarehouseComponent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import rendering.road.RoadRendererComponent;
   import sound.SoundEvent;
   import transactions.TClear;
   import transactions.TSell;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   
   public class GMSell extends GMIsland
   {
      
      private var m_nonEntitySellable:GameItem;
      
      private var m_sellableItem:IEntity;
      
      private var m_lastItem:GameItem;
      
      public function GMSell()
      {
         super();
         m_cursorImage = new Cursor_Sell(1,1);
      }
      
      public static function clearObject(param1:IEntity, param2:Boolean = false) : void
      {
         return sellOrClearObject(param1,true,param2);
      }
      
      public static function sellObject(param1:IEntity) : void
      {
         return sellOrClearObject(param1);
      }
      
      private static function sellOrClearObject(param1:IEntity, param2:Boolean = false, param3:Boolean = false) : void
      {
         var _loc5_:GameItem = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:BuildingFSMComponent = null;
         var _loc12_:BuildingFSMComponent = null;
         if(!param3)
         {
            TransactionManager.addTransaction(param2 ? new TClear(param1) : new TSell(param1));
         }
         var _loc4_:GameDataComponent = GameDataComponent(param1.lookupComponentByType(GameDataComponent));
         if((Boolean(_loc4_)) && Boolean(_loc4_.gameData))
         {
            _loc5_ = _loc4_.gameData;
            if(!param2)
            {
               _loc10_ = _loc5_.sellPrice;
               if(_loc10_ != 0)
               {
                  executeSell(_loc10_,param1);
               }
            }
            _loc6_ = _loc5_.workers;
            _loc7_ = _loc5_.workersCap;
            if(Boolean(_loc6_) && Boolean(_loc6_.length))
            {
               _loc8_ = parseInt(_loc6_);
            }
            if(Boolean(_loc7_) && Boolean(_loc7_.length))
            {
               _loc9_ = parseInt(_loc7_);
            }
            if(Boolean(_loc8_) || Boolean(_loc9_))
            {
               _loc11_ = param1.lookupComponentByType(BuildingFSMComponent) as BuildingFSMComponent;
               if((Boolean(_loc11_)) && _loc11_.isBuilt)
               {
                  PopulationManager.instance.updateMaxWorkers(-_loc8_,-_loc9_);
               }
            }
            WorldObjectManager.instance.removeObject(_loc5_.type,_loc5_.subType,param1.name,_loc5_.code,_loc5_.categoryLimitName);
         }
         if(!param2)
         {
            _loc12_ = BuildingFSMComponent(param1.lookupComponentByType(BuildingFSMComponent));
            if(_loc12_)
            {
               BehaviorState(_loc12_.stateMachine.getCurrentState()).sell();
            }
         }
         param1.destroy();
         GameModeManager.instance.getTopGameMode().updatePointer();
      }
      
      public static function getGameData(param1:IEntity) : GameItem
      {
         var _loc3_:GameItem = null;
         var _loc2_:GameDataComponent = GameDataComponent(param1.lookupComponentByType(GameDataComponent));
         if(Boolean(_loc2_) && Boolean(_loc2_.gameData))
         {
            _loc3_ = _loc2_.gameData;
         }
         return _loc3_;
      }
      
      public static function getSellPrice(param1:IEntity) : int
      {
         var _loc2_:int = 0;
         var _loc3_:GameItem = getGameData(param1);
         if(_loc3_)
         {
            _loc2_ = _loc3_.sellPrice;
         }
         return _loc2_;
      }
      
      private static function executeSell(param1:int, param2:Object) : void
      {
         ZGlobal.player.coins += param1;
         SoundEvent.getSoundEvent("SellItem").play();
         var _loc3_:ActionFeedback = new ResourceActionFeedback(param2,"coins",param1,0);
      }
      
      override public function enableMode() : void
      {
         UIDispatcher.instance.addEventListener(OptionUIItem.EXIT,onExitMode,false,0,true);
         PickManager.picksEnabled = false;
         super.enableMode();
      }
      
      override protected function getCursor() : Object
      {
         return null;
      }
      
      override protected function canBeSelected(param1:IEntity) : Boolean
      {
         var _loc2_:GameDataComponent = null;
         if(param1)
         {
            _loc2_ = GameDataComponent(param1.lookupComponentByType(GameDataComponent));
            if(_loc2_ != null)
            {
               if(_loc2_.gameData.type == GameItem.TYPE_NPC)
               {
                  return false;
               }
               if(TutorialManager.instance.isUnsellable(_loc2_.gameData.code))
               {
                  return false;
               }
            }
         }
         return true;
      }
      
      override protected function doHandleClick(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc5_:GameDataComponent = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:GenericPopup = null;
         if((Boolean(this.m_nonEntitySellable || m_highlightedObject)) && Boolean(this.canBeSelected(m_highlightedObject)) || Boolean(this.m_nonEntitySellable))
         {
            if(m_highlightedObject)
            {
               _loc5_ = m_highlightedObject.lookupComponentByType(GameDataComponent) as GameDataComponent;
               if((Boolean(_loc5_)) && Boolean(_loc5_.userData) && _loc5_.userData.itemName == "Neighborhood")
               {
                  if(!NeighborhoodHelper.instance.isNeighborhoodEmpty(_loc5_.userData))
                  {
                     PopupManager.instance.push(GenericPopup1B.NewOk(ZGameUtils.ZlocT("Dialogs","Neighborhood_sell"),ZGameUtils.ZlocT("Dialogs","Neighborhood_Title")));
                     return;
                  }
               }
            }
            _loc2_ = 0;
            _loc3_ = true;
            _loc4_ = false;
            if(this.m_nonEntitySellable)
            {
               _loc4_ = this.canMultiSell(this.m_nonEntitySellable);
               _loc2_ = this.m_nonEntitySellable.sellPrice;
            }
            else if(m_highlightedObject)
            {
               _loc3_ = this.canSellHighlightedObject();
               if(_loc3_)
               {
                  this.m_sellableItem = m_highlightedObject;
                  _loc4_ = this.canMultiSell(getGameData(this.m_sellableItem));
                  _loc2_ = getSellPrice(this.m_sellableItem);
               }
            }
            if(_loc3_)
            {
               CursorManager.enabled = false;
               if(!_loc4_)
               {
                  if(this.m_nonEntitySellable)
                  {
                     _loc6_ = ZGameUtils.ZlocT("Dialogs","SellQuery_Object",{
                        "price":_loc2_,
                        "item":this.m_nonEntitySellable.getSentenceNameLocalizationObject("singular,definite"),
                        "coin":ZGameUtils.ZlocTk("Objects","coin","",_loc2_)
                     });
                  }
                  else if(Boolean(this.m_sellableItem) && getGameData(this.m_sellableItem).hasSentenceName())
                  {
                     _loc6_ = ZGameUtils.ZlocT("Dialogs","SellQuery_Object",{
                        "price":_loc2_,
                        "item":getGameData(this.m_sellableItem).getSentenceNameLocalizationObject("singular,definite"),
                        "coin":ZGameUtils.ZlocTk("Objects","coin","",_loc2_)
                     });
                  }
                  else
                  {
                     _loc6_ = ZGameUtils.ZlocT("Dialogs","SellQuery",{
                        "price":_loc2_,
                        "item":getGameData(this.m_sellableItem).getFriendlyName(GameItem.MENU_FRIENDLYNAME),
                        "coin":ZGameUtils.ZlocTk("Objects","coin","",_loc2_)
                     });
                  }
                  _loc7_ = ZGameUtils.ZlocT("Dialogs","SellTitle");
                  _loc8_ = GenericPopup2B.NewSellSkip(_loc6_,_loc7_,this.onSellItem);
                  PopupManager.instance.push(_loc8_);
               }
               else
               {
                  this.onSellItem();
               }
            }
         }
      }
      
      private function canSellHighlightedObject() : Boolean
      {
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:String = null;
         var _loc12_:GenericPopup = null;
         var _loc13_:String = null;
         var _loc14_:GenericPopup1B = null;
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc3_:WorldUnitComponent = WorldUnitComponent(m_highlightedObject.lookupComponentByType(WorldUnitComponent));
         if(null != _loc3_ && _loc3_.type != WorldUnitManager.UNIT_AVAILABLE)
         {
            _loc1_ = ZGameUtils.ZlocT("Dialogs","SellFailBattleTitle");
            _loc2_ = ZGameUtils.ZlocT("Dialogs","SellFailBattleDesc");
            PopupManager.instance.push(new HudsonPopup(_loc2_,_loc1_,GenericPopup.TYPE_MODAL));
            return false;
         }
         var _loc4_:GameDataComponent = GameDataComponent(m_highlightedObject.lookupComponentByType(GameDataComponent));
         if(null != _loc4_ && (!_loc4_.gameData.sellable || _loc4_.gameData.subType == "prop"))
         {
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Dialogs","SellFailDesc"),m_highlightedObject);
            return false;
         }
         var _loc5_:BuildingFSMComponent = BuildingFSMComponent(m_highlightedObject.lookupComponentByType(BuildingFSMComponent));
         if((Boolean(_loc5_)) && _loc5_.isBuilt)
         {
            _loc7_ = _loc4_.gameData.workersCap;
            _loc8_ = _loc7_.length ? int(parseInt(_loc7_)) : 0;
            if(_loc8_)
            {
               _loc9_ = PopulationManager.instance.maxWorkersCap - _loc8_;
               _loc10_ = PopulationManager.instance.maxWorkers;
               if(_loc9_ < _loc10_)
               {
                  _loc11_ = ZLoc.t("Dialogs","LowWorkerCap");
                  _loc12_ = GenericPopup1B.NewOk(_loc11_,null);
                  PopupManager.instance.push(_loc12_);
                  return false;
               }
            }
         }
         if(PVPManager.instance.underInvasionMarkerInfluence(m_highlightedObject))
         {
            _loc13_ = ZGameUtils.ZlocT("Dialogs","PVPCannotSellBuilding");
            _loc14_ = GenericPopup1B.NewOk(_loc13_,null);
            PopupManager.instance.push(_loc14_);
            return false;
         }
         var _loc6_:WarehouseComponent = m_highlightedObject.lookupComponentByType(WarehouseComponent) as WarehouseComponent;
         if(_loc6_)
         {
            if(_loc6_.totalItemCount != 0)
            {
               PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Dialogs","SellFailDesc"),m_highlightedObject);
               return false;
            }
         }
         return true;
      }
      
      private function canMultiSell(param1:GameItem) : Boolean
      {
         if(param1.multiSell)
         {
            return true;
         }
         if(!this.m_lastItem || !param1)
         {
            return false;
         }
         if(param1.type != this.m_lastItem.type)
         {
            return false;
         }
         return false;
      }
      
      override protected function selectObjectAtMousePosition(param1:Point) : Boolean
      {
         var _loc6_:RoadRendererComponent = null;
         this.deselectObject();
         var _loc2_:Pt = screenToIso(new Pt(param1.x,param1.y,0));
         var _loc3_:int = _loc2_.x / ZGlobal.cellSize;
         var _loc4_:int = _loc2_.y / ZGlobal.cellSize;
         var _loc5_:Boolean = BuildManager.instance.getBuildType(_loc3_,_loc4_,BuildManager.instance.ROAD_STR);
         if(_loc5_)
         {
            if(!selectObjectAtGridPosition(_loc2_))
            {
               _loc6_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,RoadRendererComponent) as RoadRendererComponent;
               this.m_nonEntitySellable = _loc6_.getSellDataObject(_loc3_,_loc4_);
               SelectionMasker.instance.setGridTarget(new Point(_loc3_,_loc4_),false);
               GridPointer.instance.highlight = true;
               return true;
            }
         }
         return super.selectObjectAtMousePosition(param1);
      }
      
      override protected function deselectObject() : void
      {
         this.m_nonEntitySellable = null;
         GridPointer.instance.highlight = false;
         super.deselectObject();
      }
      
      private function onSellItem(param1:GenericPopupEvent = null) : void
      {
         var _loc2_:GameItem = null;
         CursorManager.enabled = true;
         if(!param1 || param1.button == GenericPopup.YES)
         {
            if(this.m_nonEntitySellable)
            {
               this.m_lastItem = this.m_nonEntitySellable;
               this.sellNonEntity(this.m_nonEntitySellable);
               this.deselectObject();
            }
            else if(this.m_sellableItem)
            {
               _loc2_ = getGameData(this.m_sellableItem);
               this.m_lastItem = _loc2_;
               sellObject(this.m_sellableItem);
               this.m_sellableItem = null;
            }
         }
      }
      
      private function sellNonEntity(param1:GameItem) : void
      {
         var _loc2_:RoadGameItem = null;
         var _loc3_:String = null;
         var _loc4_:GenericPopup1B = null;
         var _loc5_:RoadRendererComponent = null;
         var _loc6_:Point = null;
         var _loc7_:Vector3D = null;
         if(param1 is RoadGameItem)
         {
            _loc2_ = param1 as RoadGameItem;
            if(PVPManager.instance.positionUnderInvasionMarkerInfluence(_loc2_.x,_loc2_.y))
            {
               _loc3_ = ZGameUtils.ZlocT("Dialogs","PVPCannotSellBuilding");
               _loc4_ = GenericPopup1B.NewOk(_loc3_,null);
               PopupManager.instance.push(_loc4_);
            }
            else
            {
               _loc5_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,RoadRendererComponent) as RoadRendererComponent;
               _loc6_ = _loc5_.clearRoadAt(_loc2_.x,_loc2_.y);
               _loc7_ = new Vector3D(_loc6_.x,_loc6_.y);
               executeSell(_loc2_.sellPrice,_loc7_);
            }
         }
      }
      
      override public function disableMode() : void
      {
         UIDispatcher.instance.removeEventListener(OptionUIItem.EXIT,onExitMode);
         PickManager.picksEnabled = true;
         this.m_nonEntitySellable = null;
         this.m_lastItem = null;
         super.disableMode();
      }
   }
}

