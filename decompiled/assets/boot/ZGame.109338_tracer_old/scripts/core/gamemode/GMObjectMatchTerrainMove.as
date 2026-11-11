package core.gamemode
{
   import as3isolib.geom.Pt;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.BuildingSpatialComponent;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.gameobjects.GameItem;
   import core.managers.BuildManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.components.IslandMapComponent;
   import entity.GameDataComponent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import zlabs.entity.IEntity;
   
   public class GMObjectMatchTerrainMove extends GMObjectMove
   {
      
      private var m_directions:Array = [GameItem.DIRECTION_SW,GameItem.DIRECTION_NW,GameItem.DIRECTION_NE,GameItem.DIRECTION_SE];
      
      public function GMObjectMatchTerrainMove(param1:IEntity, param2:String = null)
      {
         super(param1,param2);
      }
      
      override public function onMouseMove(param1:MouseEvent) : Boolean
      {
         var _loc3_:IEntity = null;
         var _loc4_:GameDataComponent = null;
         var _loc5_:GameItem = null;
         var _loc6_:BuildingFSMComponent = null;
         var _loc7_:BuildingSpatialComponent = null;
         var _loc8_:Pt = null;
         var _loc9_:IslandMapComponent = null;
         var _loc10_:Array = null;
         var _loc11_:String = null;
         var _loc12_:int = 0;
         var _loc13_:Point = null;
         var _loc2_:Boolean = super.onMouseMove(param1);
         if(m_selectedObjectProxy)
         {
            _loc3_ = m_selectedObjectProxy.getMapResource();
            _loc4_ = GameDataComponent.getGameDataComponent(_loc3_);
            _loc5_ = _loc4_.gameData;
            if(_loc5_.rotateable)
            {
               _loc6_ = BuildingFSMComponent(_loc3_.lookupComponentByType(BuildingFSMComponent));
               _loc7_ = BuildingSpatialComponent(_loc3_.lookupComponentByType(BuildingSpatialComponent));
               _loc8_ = _loc7_.volume.clone() as Pt;
               _loc9_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,IslandMapComponent) as IslandMapComponent;
               _loc10_ = _loc5_.placementArray;
               _loc11_ = _loc5_.canBuildOn;
               for each(_loc12_ in this.m_directions)
               {
                  _loc13_ = BuildManager.instance.rawPlacementPosition;
                  if(BuildManager.instance.isValidForBuild(_loc13_,_loc12_,_loc8_.x,_loc8_.y,_loc10_,_loc11_,_loc9_))
                  {
                     (_loc6_.stateMachine.currentState as BehaviorState).direction = this.m_directions[_loc12_];
                     this.swapAxis(_loc12_,_loc7_,_loc8_);
                     _loc7_.update();
                     PlacementRect.instance.direction = this.m_directions[_loc12_];
                     PlacementRect.instance.bounds = _loc7_.volume.clone() as Pt;
                     break;
                  }
               }
            }
         }
         return _loc2_;
      }
      
      private function swapAxis(param1:int, param2:BuildingSpatialComponent, param3:Pt) : void
      {
         if(param3.y != param3.x)
         {
            if(param1 == GameItem.DIRECTION_SE || param1 == GameItem.DIRECTION_NW)
            {
               param2.volume.x = param3.y;
               param2.volume.y = param3.x;
            }
            else
            {
               param2.volume.x = param3.x;
               param2.volume.y = param3.y;
            }
         }
      }
   }
}

