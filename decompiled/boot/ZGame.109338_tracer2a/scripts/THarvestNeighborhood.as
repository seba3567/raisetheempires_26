package
{
   import core.managers.NeighborhoodHelper;
   import entity.GameDataComponent;
   import transactions.TWorldState;
   import zlabs.entity.IEntity;
   
   public class THarvestNeighborhood extends TWorldState
   {
      
      protected var m_items:Array;
      
      public function THarvestNeighborhood(param1:IEntity, param2:Array)
      {
         super(param1);
         this.m_items = param2;
      }
      
      override public function perform() : void
      {
         signedWorldAction("harvest",this.m_items);
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

