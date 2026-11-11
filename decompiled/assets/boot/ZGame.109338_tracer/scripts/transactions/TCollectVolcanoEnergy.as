package transactions
{
   import core.ZGlobal;
   import zlabs.entity.IEntity;
   
   public class TCollectVolcanoEnergy extends TWorldState
   {
      
      public function TCollectVolcanoEnergy(param1:IEntity)
      {
         super(param1);
      }
      
      override public function perform() : void
      {
         signedWorldAction("collectEnergy");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:String = null;
         super.onComplete(param1);
         if(param1.energy)
         {
            for(_loc2_ in param1.energy)
            {
               ZGlobal.player.addToInventory(_loc2_,param1.energy[_loc2_]);
            }
         }
      }
   }
}

