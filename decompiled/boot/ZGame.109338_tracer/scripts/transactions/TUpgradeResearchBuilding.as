package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TUpgradeResearchBuilding extends Transaction
   {
      
      private var m_type:String;
      
      public function TUpgradeResearchBuilding(param1:String)
      {
         this.m_type = param1;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.upgradeResearchBuilding",this.m_type);
      }
   }
}

