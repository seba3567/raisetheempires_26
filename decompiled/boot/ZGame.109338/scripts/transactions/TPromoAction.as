package transactions
{
   public class TPromoAction extends TZGameTransaction
   {
      
      public static const ACTION_MSG_VIEWED:String = "promoMsgViewed";
      
      public static const ACTION_MSG_ACCEPTED:String = "promoMsgAccepted";
      
      private var m_action:String = null;
      
      private var m_type:String = null;
      
      public function TPromoAction(param1:String, param2:String)
      {
         this.m_action = param1;
         this.m_type = param2;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.promoAction",modifiedData(this.data));
      }
      
      protected function get data() : Object
      {
         return {
            "action":this.m_action,
            "type":this.m_type
         };
      }
   }
}

