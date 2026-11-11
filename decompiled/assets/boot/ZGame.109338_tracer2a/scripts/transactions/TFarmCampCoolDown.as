package transactions
{
   import zlabs.entity.IEntity;
   
   public class TFarmCampCoolDown extends TWorldState
   {
      
      public function TFarmCampCoolDown(param1:IEntity)
      {
         super(param1);
      }
      
      override public function perform() : void
      {
         signedWorldAction("farmCampCoolDown");
      }
   }
}

