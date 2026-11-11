package transactions
{
   import Engine.Transactions.Transaction;
   import displays.screens.requests.RequestDialog;
   
   public class TRequestNeighbor extends Transaction
   {
      
      private var m_ids:Array;
      
      private var m_requestType:String;
      
      private var m_inviteType:int;
      
      private var m_matchmaking:Boolean = false;
      
      public function TRequestNeighbor(param1:Array, param2:int, param3:String, param4:Boolean = false)
      {
         super();
         this.m_ids = param1;
         this.m_inviteType = param2;
         this.m_requestType = param3;
         this.m_matchmaking = param4;
      }
      
      override public function perform() : void
      {
         signedCall("RequestService.neighborRequest",this.m_ids,this.m_inviteType,this.m_requestType,this.m_matchmaking);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(param1 != null)
         {
            _loc2_ = {
               "sendkey":param1.outgoingSendKey,
               "zmcSendkey":param1.zmcSendKey,
               "signature":param1.signature,
               "ts":param1.timestamp,
               "totalRecipient":this.m_ids.length,
               "requestType":this.m_requestType,
               "button_href":param1.button_href,
               "zmc_button_href":param1.zmc_button_href
            };
            _loc2_.ts = _loc2_.ts == null || _loc2_.ts == undefined ? "" : _loc2_.ts;
            _loc3_ = param1.title;
            _loc4_ = param1.body;
            GlobalEngine.socialNetwork.sendRequest(param1.eligible,RequestDialog.NEIGHBOR_REQUEST,_loc3_,_loc4_,_loc2_);
         }
      }
   }
}

