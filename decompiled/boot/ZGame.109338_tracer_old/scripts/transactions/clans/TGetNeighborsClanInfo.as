package transactions.clans
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   
   public class TGetNeighborsClanInfo extends Transaction
   {
      
      public function TGetNeighborsClanInfo()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("ClansService.getNeighborClanInfo");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         if(param1)
         {
            for(_loc3_ in ZGlobal.player.neighbors)
            {
               if(Number(_loc3_) > 0 && _loc3_ != ZGlobal.player.uid)
               {
                  _loc2_ = param1["zid" + _loc3_];
                  if(_loc2_)
                  {
                     ZGlobal.player.neighbors[_loc3_].clanId = _loc2_.clanId;
                     ZGlobal.player.neighbors[_loc3_].crestId = _loc2_.crestId;
                     ZGlobal.player.neighbors[_loc3_].canAddMembers = _loc2_.canAddMembers;
                     ZGlobal.player.neighbors[_loc3_].clanName = _loc2_.clanName;
                  }
               }
               ZGlobal.player.neighbors[_loc3_].clanInit = true;
            }
         }
      }
   }
}

