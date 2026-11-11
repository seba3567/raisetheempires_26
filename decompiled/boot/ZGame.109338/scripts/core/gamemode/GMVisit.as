package core.gamemode
{
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.gamemode.island.GMIsland;
   import core.managers.BuildManager;
   import core.managers.CrewManager;
   import core.managers.EspionageHQManager;
   import dispatchers.UIDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   import zlabs.utils.MathUtils;
   
   public class GMVisit extends GMIsland
   {
      
      private var m_anyTileUnlocked:Boolean;
      
      public function GMVisit()
      {
         super();
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.UI_PAUSE_QUEST_ICONS,true));
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.UI_PLAYER_ISLAND_MODE_ACTIVE,{"active":false}));
      }
      
      override public function disableMode() : void
      {
         super.disableMode();
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.UI_PAUSE_QUEST_ICONS,false));
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.UI_PLAYER_ISLAND_MODE_ACTIVE,{"active":true}));
      }
      
      override protected function canBeClicked(param1:MouseEvent) : Boolean
      {
         var _loc2_:BuildingFSMComponent = null;
         var _loc3_:BehaviorState = null;
         var _loc4_:PropertyReference = null;
         var _loc5_:Vector3D = null;
         var _loc6_:Point = null;
         if(m_highlightedObject != null)
         {
            _loc2_ = BuildingFSMComponent(m_highlightedObject.lookupComponentByType(BuildingFSMComponent));
            if(_loc2_)
            {
               _loc3_ = BehaviorState(_loc2_.stateMachine.getCurrentState());
               if(_loc3_.isVisitable())
               {
                  return true;
               }
               if(_loc3_.canVisitorHelp())
               {
                  _loc4_ = new PropertyReference("@IsoSpatial.position");
                  _loc5_ = m_highlightedObject.getProperty(_loc4_);
                  if(_loc5_)
                  {
                     _loc6_ = new Point(_loc5_.x / ZGlobal.cellSize,_loc5_.y / ZGlobal.cellSize);
                     this.m_anyTileUnlocked = false;
                     BuildManager.instance.iterateEntityBounds(_loc6_,m_highlightedObject,this.anyTilesUnlocked);
                     if(this.m_anyTileUnlocked)
                     {
                        return true;
                     }
                  }
               }
               else if(CrewManager.canBeClicked(m_highlightedObject,_loc2_.isBuilt,_loc3_))
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      override protected function getCursor() : Object
      {
         var _loc2_:BuildingFSMComponent = null;
         var _loc3_:BehaviorState = null;
         var _loc1_:Object = m_cursorImage;
         if(m_highlightedObject)
         {
            if(this.canBeClicked(null))
            {
               _loc2_ = BuildingFSMComponent(m_highlightedObject.lookupComponentByType(BuildingFSMComponent));
               _loc3_ = BehaviorState(_loc2_.stateMachine.getCurrentState());
               _loc1_ = _loc3_.visitorCursor;
            }
         }
         return _loc1_;
      }
      
      override protected function onDoEnteredMode(param1:Object) : void
      {
         super.onDoEnteredMode(param1);
         EspionageHQManager.instance.doIslandLoadedActions();
      }
      
      private function anyTilesUnlocked(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         var _loc5_:int = int(MathUtils.gridToExpansionIndex(param1 / 4,param2 / 4,BuildManager.instance.width));
         if(ZGlobal.hostPlayer.expansions.isBitSet(_loc5_))
         {
            this.m_anyTileUnlocked = true;
            return false;
         }
         return true;
      }
   }
}

