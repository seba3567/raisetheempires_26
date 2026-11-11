package transactions.clans
{
   import Engine.Transactions.Transaction;
   import core.managers.AlliancesManager;
   import zlabs.events.WorldEvent;
   
   public class TUpdateClanName extends Transaction
   {
      
      private var m_clanName:String;
      
      private var m_fBGroup:Object;
      
      public function TUpdateClanName(param1:String, param2:Object = null)
      {
         super();
         this.m_clanName = param1;
         this.m_fBGroup = param2;
      }
      
      override public function perform() : void
      {
         signedCall("ClansService.updateName",this.m_clanName,this.m_fBGroup);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         if(param1.groupCreated == true)
         {
            AlliancesManager.instance.setFBGroupID(param1.groupID);
         }
         if(AlliancesManager.instance.clanName != this.m_clanName)
         {
            AlliancesManager.instance.setClanName(this.m_clanName);
            AlliancesManager.instance.dispatchEvent(new WorldEvent(AlliancesManager.CLANS_ZLINGSHOT_MSG,"clan.updateName"));
         }
      }
   }
}

