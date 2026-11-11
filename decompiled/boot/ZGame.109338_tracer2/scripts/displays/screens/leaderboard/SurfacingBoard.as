package displays.screens.leaderboard
{
   import core.ZGlobal;
   import core.managers.leaderboardManager.Leaderboard;
   import core.player.Player;
   import flash.display.MovieClip;
   
   public class SurfacingBoard extends Board
   {
      
      private var m_validUids:Array = null;
      
      public function SurfacingBoard(param1:Leaderboard, param2:Boolean)
      {
         var _loc6_:int = 0;
         super(param1,param2);
         this.m_validUids = new Array();
         this.m_validUids.push(ZGlobal.player.uid);
         var _loc3_:int = param1.getIndex(ZGlobal.player.uid);
         var _loc4_:String = param1.getNextPlayerId(_loc3_,-1);
         if(_loc4_)
         {
            this.m_validUids.push(_loc4_);
         }
         _loc4_ = param1.getNextPlayerId(_loc3_,1);
         if(_loc4_)
         {
            this.m_validUids.push(_loc4_);
         }
         var _loc5_:XML = param1.getNextReward(_loc3_,-1);
         if(_loc5_)
         {
            this.m_validUids.push(_loc5_);
         }
         while(Boolean(_loc4_) && this.m_validUids.length < 4)
         {
            _loc6_ = param1.getIndex(_loc4_);
            _loc4_ = param1.getNextPlayerId(_loc6_,1);
            if(_loc4_)
            {
               this.m_validUids.push(_loc4_);
            }
         }
      }
      
      override protected function showTrophies(param1:MovieClip, param2:Object) : void
      {
      }
      
      override protected function validatePlayer(param1:Player) : Boolean
      {
         return this.m_validUids.indexOf(param1.uid) >= 0;
      }
      
      override protected function validateReward(param1:XML) : Boolean
      {
         return this.m_validUids.indexOf(param1) >= 0;
      }
   }
}

