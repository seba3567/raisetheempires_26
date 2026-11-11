package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TEspionageHQUnitStolen extends Transaction
   {
      
      private var m_data:Object = null;
      
      public function TEspionageHQUnitStolen(param1:String, param2:String)
      {
         super();
         this.m_data = new Object();
         this.m_data.stolenUnit = param1;
         this.m_data.spyDeployedCode = param2;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.setEspionageHQData",this.m_data);
      }
   }
}

