package transactions
{
   import Engine.Transactions.Transaction;
   import displays.screens.requests.RequestDialog;
   
   public class TRequestAllianceInvite extends Transaction
   {
      
      private var m_ids:Array;
      
      private var m_requestType:String;
      
      private var m_data:Object;
      
      public function TRequestAllianceInvite(param1:Array, param2:String, param3:Object)
      {
         super();
         this.m_ids = param1;
         this.m_requestType = param2;
         this.m_data = param3;
      }
      
      override public function perform() : void
      {
         signedCall("RequestService.allianceInviteRequest",this.m_ids,this.m_requestType,this.m_data);
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
               "zmc_button_href":param1.zmc_button_href,
               "title":param1.title,
               "body":param1.body,
               "key":param1.key,
               "join":param1.join
            };
            _loc2_.ts = _loc2_.ts == null || _loc2_.ts == undefined ? "" : _loc2_.ts;
            _loc3_ = param1.title;
            _loc4_ = param1.body;
            GlobalEngine.socialNetwork.sendRequest(param1.eligible,RequestDialog.OTHER_REQUEST,_loc3_,_loc4_,_loc2_);
         }
      }
   }
}

