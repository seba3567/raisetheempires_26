package transactions
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import entity.GameDataComponent;
   import zlabs.entity.IEntity;
   import zlabs.utils.MathUtils;
   
   public class TMove extends TWorldState
   {
      
      private var m_pos:Pt = null;
      
      private var m_direction:int = 0;
      
      public function TMove(param1:IEntity, param2:Pt)
      {
         super(param1);
         this.m_pos = MathUtils.worldToTile(param2,ZGlobal.cellSize);
         var _loc3_:GameDataComponent = GameDataComponent(param1.lookupComponentByType(GameDataComponent));
         this.m_direction = _loc3_.direction;
      }
      
      public function get pos() : Pt
      {
         return this.m_pos;
      }
      
      override public function perform() : void
      {
         var _loc1_:Object = new Object();
         _loc1_.x = this.m_pos.x;
         _loc1_.y = this.m_pos.y;
         _loc1_.direction = this.m_direction;
         if(ZGlobal.player.uid != ZGlobal.hostPlayer.uid)
         {
            _loc1_.hostId = ZGlobal.hostPlayer.uid;
         }
         signedWorldAction("move",_loc1_);
      }
   }
}

