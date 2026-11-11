package transactions
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   
   public class TCalculateRansom extends Transaction
   {
      
      private var m_data:Object = null;
      
      public function TCalculateRansom(param1:String, param2:String)
      {
         super();
         this.m_data = new Object();
         this.m_data.playerFleet = param1;
         this.m_data.enemyFleet = param2;
         this.m_data.map = ZGlobal.player.campaign.currentMapName;
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.calculateRansom",this.m_data);
      }
   }
}

