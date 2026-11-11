package transactions
{
   public class TSetTag extends TZGameTransaction
   {
      
      private static const ACTION_SET:String = "SET";
      
      private static const ACTION_INCREMENT:String = "INC";
      
      private var m_tag:String = null;
      
      private var m_value:Object = null;
      
      private var m_action:String = TSetTag.ACTION_SET;
      
      public function TSetTag(param1:String, param2:Object = null)
      {
         this.m_tag = param1;
         this.m_value = param2;
         super();
      }
      
      public function doAsIncrement() : void
      {
         this.m_action = TSetTag.ACTION_INCREMENT;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.setTag",this.data);
      }
      
      protected function get data() : Object
      {
         return {
            "tag":this.m_tag,
            "value":this.m_value,
            "action":this.m_action
         };
      }
   }
}

