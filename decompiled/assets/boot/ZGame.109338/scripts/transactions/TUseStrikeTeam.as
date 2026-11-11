package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TUseStrikeTeam extends Transaction
   {
      
      private var m_itemCode:String = null;
      
      private var m_invader:String = null;
      
      public function TUseStrikeTeam(param1:String, param2:String)
      {
         super();
         this.m_itemCode = param1;
         this.m_invader = param2;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.useStrikeTeam",this.m_itemCode,this.m_invader);
      }
      
      override protected function onAmfComplete(param1:Object) : void
      {
         super.onAmfComplete(param1);
      }
   }
}

