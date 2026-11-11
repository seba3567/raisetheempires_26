package core.gamemode
{
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.Transaction;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.BuildingSpatialComponent;
   import core.entities.components.UIControllerComponent;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.gameobjects.GameItem;
   import core.managers.WorldObjectManager;
   import entity.GameDataComponent;
   import flash.events.MouseEvent;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import transactions.TNeighborhoodAdd;
   import utils.TileUtil;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   
   public class GMNeighborhoodAdd extends GMSell
   {
      
      protected var m_neighborhood:IEntity = null;
      
      protected var m_block:int;
      
      protected var imageReference:PropertyReference;
      
      public function GMNeighborhoodAdd(param1:IEntity, param2:int)
      {
         super();
         m_cursorImage = new Cursor_Move(1,1);
         this.m_neighborhood = param1;
         this.m_block = param2;
      }
      
      private function getTargetCurrentState(param1:IEntity) : BehaviorState
      {
         var _loc2_:BuildingFSMComponent = BuildingFSMComponent(param1.lookupComponentByType(BuildingFSMComponent));
         if(_loc2_)
         {
            return BehaviorState(_loc2_.stateMachine.getCurrentState());
         }
         return null;
      }
      
      private function doesTargetActionHavePVPPenalty(param1:IEntity) : Boolean
      {
         var _loc2_:BehaviorState = this.getTargetCurrentState(param1);
         if(_loc2_)
         {
            return _loc2_.actionSuffersPVPPenaltyNeighborhood();
         }
         return false;
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         this.highlightHouses(true);
      }
      
      public function highlightHouses(param1:Boolean) : void
      {
         var _loc3_:String = null;
         var _loc2_:Dictionary = WorldObjectManager.instance.getObjectsBySubType(GameItem.TYPE_BUILDING,GameItem.SUBTYPE_RESIDENTIAL);
         for(_loc3_ in _loc2_)
         {
            if(this.canBeSelected(_loc2_[_loc3_]))
            {
               this.setHighlightEnabled(param1,_loc2_[_loc3_]);
            }
         }
      }
      
      private function setHighlightEnabled(param1:Boolean, param2:IEntity) : void
      {
         var _loc3_:String = param1 ? UIControllerComponent.FILTER_MULTIHARVEST_HIGHLIGHT_ON : UIControllerComponent.FILTER_MULTIHARVEST_HIGHLIGHT_OFF;
         var _loc4_:WorldEvent = new WorldEvent(UIControllerComponent.EVENT_FILTER_EFFECT,_loc3_);
         param2.eventDispatcher.dispatchEvent(_loc4_);
      }
      
      override protected function canBeSelected(param1:IEntity) : Boolean
      {
         var _loc2_:GameDataComponent = null;
         var _loc3_:BuildingFSMComponent = null;
         if(param1)
         {
            _loc2_ = GameDataComponent(param1.lookupComponentByType(GameDataComponent));
            if(_loc2_ != null)
            {
               if(_loc2_.gameData.type == GameItem.TYPE_BUILDING && _loc2_.gameData.subType == GameItem.SUBTYPE_RESIDENTIAL && !this.doesTargetActionHavePVPPenalty(param1))
               {
                  _loc3_ = BuildingFSMComponent(param1.lookupComponentByType(BuildingFSMComponent));
                  if(_loc3_.isBuilt && Boolean(_loc3_.stateMachine))
                  {
                     return true;
                  }
               }
            }
         }
         return false;
      }
      
      override public function exitMode() : void
      {
         this.highlightHouses(false);
         super.exitMode();
      }
      
      override protected function doHandleClick(param1:MouseEvent) : void
      {
         var _loc2_:GameDataComponent = null;
         var _loc3_:Object = null;
         var _loc4_:Transaction = null;
         var _loc5_:IEntity = null;
         var _loc6_:GameDataComponent = null;
         var _loc7_:BuildingSpatialComponent = null;
         var _loc8_:Vector3D = null;
         var _loc9_:GameItem = null;
         if(Boolean(m_highlightedObject) && this.canBeSelected(m_highlightedObject))
         {
            _loc2_ = GameDataComponent(m_highlightedObject.lookupComponentByType(GameDataComponent));
            _loc3_ = _loc2_.getSaveObject();
            _loc4_ = new TNeighborhoodAdd(this.m_neighborhood,_loc3_,this.m_block);
            TransactionManager.addTransaction(_loc4_,true);
            _loc5_ = m_highlightedObject;
            _loc6_ = GameDataComponent(_loc5_.lookupComponentByType(GameDataComponent));
            _loc7_ = BuildingSpatialComponent(_loc5_.lookupComponentByType(BuildingSpatialComponent));
            _loc8_ = TileUtil.worldToTile(_loc7_.position);
            _loc9_ = _loc6_.gameData;
            this.exitMode();
            WorldObjectManager.instance.removeObject(_loc9_.type,_loc9_.subType,_loc5_.name,_loc9_.code,_loc9_.categoryLimitName);
            m_highlightedObject = null;
            _loc5_.destroy();
         }
      }
   }
}

