package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TCrewZMC extends Transaction
   {
      
      protected var m_type:String;
      
      protected var m_data:Object;
      
      protected var m_targetId:String;
      
      public function TCrewZMC(param1:String, param2:Object, param3:String)
      {
         super();
         this.m_type = param1;
         this.m_data = param2;
         this.m_targetId = param3;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.crewZMCEvent",this.m_type,this.m_data,this.m_targetId);
      }
   }
}

