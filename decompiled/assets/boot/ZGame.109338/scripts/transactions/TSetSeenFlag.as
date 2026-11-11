package transactions
{
   public class TSetSeenFlag extends TGameTransaction
   {
      
      private var m_flagName:String;
      
      public function TSetSeenFlag(param1:String)
      {
         super();
         this.m_flagName = param1;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.setSeenFlag",this.m_flagName);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
      }
   }
}

