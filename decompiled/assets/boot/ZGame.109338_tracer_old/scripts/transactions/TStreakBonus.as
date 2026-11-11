package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TStreakBonus extends Transaction
   {
      
      protected var m_data:Array;
      
      public function TStreakBonus(param1:int, param2:int)
      {
         super();
         this.m_data = new Array();
         this.m_data["amount"] = param1;
         this.m_data["maxesReached"] = param2;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.streakBonus",this.m_data);
      }
   }
}

