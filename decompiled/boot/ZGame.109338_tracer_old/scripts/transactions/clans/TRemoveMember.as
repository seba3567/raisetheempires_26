package transactions.clans
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import core.managers.AlliancesManager;
   
   public class TRemoveMember extends Transaction
   {
      
      private var m_member:String;
      
      public function TRemoveMember(param1:String)
      {
         this.m_member = param1;
         super();
      }
      
      override public function perform() : void
      {
         if(this.m_member)
         {
            signedCall("ClansService.removeMember",this.m_member);
            if(ZGlobal.player.uid == this.m_member)
            {
               AlliancesManager.instance.deinit();
            }
         }
      }
   }
}

