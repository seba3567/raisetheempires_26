package transactions
{
   import zlabs.entity.IEntity;
   
   public class TUpdatePartUnlocks extends TWorldState
   {
      
      public function TUpdatePartUnlocks(param1:IEntity)
      {
         super(param1);
      }
      
      override public function perform() : void
      {
         var _loc1_:Object = new Object();
         signedWorldAction("updatePartUnlocks",_loc1_);
      }
   }
}

