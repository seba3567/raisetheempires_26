package core.gamemode.orders
{
   import as3isolib.geom.Pt;
   import events.UnitEvent;
   import zlabs.entity.IEntity;
   
   public class MoveOrderClientOnly extends MoveOrder
   {
      
      public function MoveOrderClientOnly(param1:Pt, param2:int)
      {
         super(param1,param2);
      }
      
      override protected function dispatchUnitEvent(param1:IEntity) : void
      {
         param1.eventDispatcher.dispatchEvent(new UnitEvent(UnitEvent.TERRAIN_AS_TARGET_CLIENT_ONLY));
      }
      
      override protected function moveGroupIfAllowed(param1:IEntity, param2:Pt) : Boolean
      {
         moveGroup(param1,param2);
         return true;
      }
   }
}

