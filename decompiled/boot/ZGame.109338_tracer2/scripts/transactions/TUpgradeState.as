package transactions
{
   public class TUpgradeState extends TGameTransaction
   {
      
      protected var m_itemCode:String = null;
      
      protected var m_state:String = null;
      
      protected var m_save:Object = null;
      
      public function TUpgradeState(param1:String, param2:String, param3:Object)
      {
         this.m_itemCode = param1;
         this.m_state = param2;
         this.m_save = param3;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.upgradeState",this.m_save,this.m_itemCode,this.m_state);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
      }
   }
}

