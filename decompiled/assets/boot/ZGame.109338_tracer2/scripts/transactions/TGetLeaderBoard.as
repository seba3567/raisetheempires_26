package transactions
{
   public class TGetLeaderBoard extends TZGameTransaction
   {
      
      private var m_callback:Function = null;
      
      private var m_names:Array = null;
      
      public function TGetLeaderBoard(param1:Array, param2:Function)
      {
         super();
         this.m_callback = param2;
         this.m_names = param1;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.getLeaderboards",modifiedData({"ids":this.m_names}));
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         this.m_callback(param1);
      }
   }
}

