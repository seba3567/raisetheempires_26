package transactions
{
   import Engine.Classes.SNAPISocialNetwork;
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   
   public class TEPGiftSelectRecipients extends Transaction
   {
      
      private var m_info:Array = new Array();
      
      private var m_total:int;
      
      public function TEPGiftSelectRecipients(param1:Array, param2:int)
      {
         super();
         this.m_total = param2;
         ZGlobal.player.friendFlashEPBankHold -= this.m_total;
         if(Boolean(param1) && Boolean(param1.length))
         {
            this.m_info = param1;
         }
      }
      
      override public function perform() : void
      {
         signedCall("UserService.EPGiftSend",this.m_info);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Object = null;
         ZGlobal.player.friendFlashEPBank = param1.remaining;
         ZGlobal.player.friendFlashEPBankHold += this.m_total;
         if(GlobalEngine.socialNetwork is SNAPISocialNetwork)
         {
            _loc2_ = param1.failedRecipientFeedInfo as Array;
            if(_loc2_)
            {
               for each(_loc3_ in _loc2_)
               {
                  (GlobalEngine.socialNetwork as SNAPISocialNetwork).snapiStreamPublish(_loc3_);
               }
            }
         }
      }
   }
}

