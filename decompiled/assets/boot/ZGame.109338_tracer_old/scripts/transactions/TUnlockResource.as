package transactions
{
   public class TUnlockResource extends TGameTransaction
   {
      
      private var m_type:String;
      
      private var m_multiplier:int;
      
      public function TUnlockResource(param1:String, param2:int)
      {
         super();
         this.m_type = param1;
         this.m_multiplier = param2;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.unlockResource",this.m_type,this.m_multiplier);
      }
   }
}

