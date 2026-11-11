package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TSpawnFleet extends Transaction
   {
      
      private var m_code:String = null;
      
      private var m_fleetName:String = null;
      
      public function TSpawnFleet(param1:String, param2:String)
      {
         super();
         this.m_code = param1;
         this.m_fleetName = param2;
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.spawnFleet",{
            "code":this.m_code,
            "fleet":this.m_fleetName
         });
      }
   }
}

