package transactions
{
   import core.managers.NeighborhoodHelper;
   import entity.GameDataComponent;
   import zlabs.entity.IEntity;
   
   public class TNeighborhoodRemove extends TWorldState
   {
      
      private var m_item:Object = null;
      
      private var m_block:int;
      
      public function TNeighborhoodRemove(param1:IEntity, param2:Object, param3:int)
      {
         super(param1);
         this.m_block = param3;
         this.m_item = param2;
      }
      
      override public function perform() : void
      {
         signedWorldAction("removeItem",this.m_item,{"block":this.m_block});
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:GameDataComponent = m_entity.lookupComponentByType(GameDataComponent) as GameDataComponent;
         if(Boolean(_loc2_) && Boolean(_loc2_.userData) && _loc2_.userData.itemName == param1.itemName)
         {
            _loc2_.userData = param1;
         }
         NeighborhoodHelper.instance.resetTimer();
      }
   }
}

