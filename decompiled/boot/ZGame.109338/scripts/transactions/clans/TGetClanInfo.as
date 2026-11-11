package transactions.clans
{
   import Engine.Transactions.Transaction;
   import core.managers.AlliancesManager;
   import zlabs.events.WorldEvent;
   
   public class TGetClanInfo extends Transaction
   {
      
      private var m_msg_id:String = null;
      
      public function TGetClanInfo(param1:String = null)
      {
         this.m_msg_id = param1;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("ClansService.getClanInfo");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         if(param1 != null)
         {
            AlliancesManager.instance.init(param1);
            if(this.m_msg_id)
            {
               AlliancesManager.instance.dispatchEvent(new WorldEvent(AlliancesManager.CLANS_ZLINGSHOT_MSG,this.m_msg_id));
            }
            else
            {
               AlliancesManager.instance.dispatchEvent(new WorldEvent(AlliancesManager.CLANS_ZLINGSHOT_MSG,"ALL"));
            }
         }
      }
   }
}

