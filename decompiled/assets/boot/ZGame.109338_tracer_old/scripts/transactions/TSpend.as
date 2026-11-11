package transactions
{
   public class TSpend extends TZGameTransaction
   {
      
      private var m_type:String = null;
      
      private var m_item:String = null;
      
      private var m_amount:int = 0;
      
      public function TSpend(param1:String, param2:String, param3:int)
      {
         this.m_type = param1;
         this.m_item = param2;
         this.m_amount = param3;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.spend",modifiedData(this.data));
      }
      
      protected function get data() : Object
      {
         return {
            "type":this.m_type,
            "code":this.m_item,
            "amount":this.m_amount
         };
      }
   }
}

