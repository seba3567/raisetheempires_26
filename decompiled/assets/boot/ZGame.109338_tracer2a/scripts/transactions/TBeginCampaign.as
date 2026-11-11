package transactions
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import displays.popups.GenericPopup;
   import zlabs.managers.PopupManager;
   
   public class TBeginCampaign extends Transaction
   {
      
      private var m_map:String = null;
      
      private var m_progressIsland:int = 0;
      
      private var m_replayIsland:int = 0;
      
      private var m_replay:Boolean = false;
      
      public function TBeginCampaign()
      {
         super();
         this.m_map = ZGlobal.player.campaign.currentMapName;
         this.m_progressIsland = ZGlobal.player.campaign.currentMap.progressIsland;
         this.m_replayIsland = ZGlobal.player.campaign.currentMap.replayIsland;
         this.m_replay = ZGlobal.player.campaign.currentMap.inReplay;
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.beginNextCampaign",{
            "map":this.m_map,
            "index":(this.m_replay ? this.m_replayIsland : -1)
         });
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         var _loc2_:int = this.m_replay ? this.m_replayIsland : this.m_progressIsland;
         if(param1.map != this.m_map || param1.island != _loc2_)
         {
            PopupManager.instance.push(new GenericPopup("TBeginCampaign: campaign map/island out of sync: replay(" + this.m_replay + ") (" + param1.map + "," + this.m_map + ") (" + param1.island + "," + _loc2_ + ")"));
         }
      }
   }
}

