package transactions
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   
   public class TExitBattle extends Transaction
   {
      
      private var m_data:Object = null;
      
      public function TExitBattle(param1:String, param2:String, param3:Boolean, param4:Boolean)
      {
         super();
         this.m_data = new Object();
         this.m_data.fleet = param1;
         this.m_data.target = param2;
         if(param3 || param4)
         {
            if(param3)
            {
               this.m_data.retreat = true;
            }
            else
            {
               this.m_data.cancel = true;
            }
            this.m_data.map = ZGlobal.player.campaign.currentMapName;
         }
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.exitBattle",this.m_data);
      }
   }
}

