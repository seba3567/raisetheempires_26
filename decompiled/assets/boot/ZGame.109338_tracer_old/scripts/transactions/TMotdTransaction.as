package transactions
{
   public class TMotdTransaction extends TZGameTransaction
   {
      
      public static const ACTION_MSG_VIEWED:String = "motdMsgViewed";
      
      public static const ACTION_MSG_ACCEPTED:String = "motdMsgAccepted";
      
      private var m_action:String = null;
      
      private var m_data:String = null;
      
      public function TMotdTransaction(param1:String, param2:String)
      {
         this.m_action = param1;
         this.m_data = param2;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.motdAction",modifiedData(this.data));
      }
      
      protected function get data() : Object
      {
         return {
            "action":this.m_action,
            "data":this.m_data
         };
      }
   }
}

