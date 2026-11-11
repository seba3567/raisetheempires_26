package transactions
{
   public class TCollectLeaderBoard extends TZGameTransaction
   {
      
      private var m_leaderboardId:String = null;
      
      private var m_rewardIndex:int = 0;
      
      private var m_clientRank:int = 0;
      
      private var m_complete:Boolean = false;
      
      private var m_buying:Boolean = false;
      
      public function TCollectLeaderBoard(param1:String, param2:int, param3:int, param4:Boolean, param5:Boolean)
      {
         super();
         this.m_leaderboardId = param1;
         this.m_rewardIndex = param2;
         this.m_clientRank = param3;
         this.m_complete = param4;
         this.m_buying = param5;
      }
      
      override public function perform() : void
      {
         var _loc1_:Object = {
            "id":this.m_leaderboardId,
            "index":this.m_rewardIndex,
            "cr":this.m_clientRank
         };
         if(this.m_complete)
         {
            _loc1_.complete = true;
         }
         if(this.m_buying)
         {
            _loc1_.buying = true;
         }
         signedCall("UserService.collectLeaderboards",modifiedData(_loc1_));
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
      }
   }
}

