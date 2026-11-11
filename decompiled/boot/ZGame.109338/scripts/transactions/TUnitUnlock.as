package transactions
{
   public class TUnitUnlock extends TGameTransaction
   {
      
      private var m_unitCode:String = null;
      
      public function TUnitUnlock(param1:String)
      {
         super();
         this.m_unitCode = param1;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.unitUnlock",this.m_unitCode);
      }
   }
}

