package core.gamemode.helpers
{
   import core.ZGlobal;
   import core.gamemode.UnitDefenseRangeRect;
   import core.gameobjects.GameItem;
   import core.managers.PVPManager;
   import entity.GameDataComponent;
   import flash.geom.Vector3D;
   import zlabs.entity.IEntity;
   
   public class UnitPlacementProxy extends PlacementProxy
   {
      
      private var m_rect:UnitDefenseRangeRect;
      
      public function UnitPlacementProxy(param1:IEntity)
      {
         super(param1);
      }
      
      override public function moveTo(param1:Vector3D, param2:Boolean = false) : void
      {
         super.moveTo(param1,param2);
         if(PVPManager.canLevelParticipate(ZGlobal.player.level))
         {
            this.createOrUpdateRect();
         }
      }
      
      override protected function releaseEntity() : void
      {
         super.releaseEntity();
         this.disposeRect();
      }
      
      private function createOrUpdateRect() : void
      {
         var _loc1_:GameDataComponent = null;
         var _loc2_:GameItem = null;
         if(!this.m_rect)
         {
            _loc1_ = GameDataComponent(m_entity.lookupComponentByType(GameDataComponent));
            _loc2_ = _loc1_.gameData as GameItem;
            this.m_rect = new UnitDefenseRangeRect(originalBounds,_loc2_.defenseRangeX,_loc2_.defenseRangeY,m_entity);
         }
         this.m_rect.setPosition(getPosition());
      }
      
      private function disposeRect() : void
      {
         if(this.m_rect)
         {
            this.m_rect.dispose();
            this.m_rect = null;
         }
      }
   }
}

