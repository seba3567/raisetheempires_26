package transactions
{
   public class TBuyFullHeal extends TZGameTransaction
   {
      
      private var m_cost:int = 0;
      
      private var m_fleet:String;
      
      public function TBuyFullHeal(param1:int, param2:String)
      {
         super();
         this.m_cost = param1;
         this.m_fleet = param2;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.buyFullHeal",modifiedData(this.data));
      }
      
      protected function get data() : Object
      {
         return {
            "cost":this.m_cost,
            "fleet":this.m_fleet
         };
      }
   }
}

