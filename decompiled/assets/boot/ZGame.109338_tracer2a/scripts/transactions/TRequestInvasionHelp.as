package transactions
{
   import Engine.Transactions.Transaction;
   import displays.screens.requests.RequestDialog;
   
   public class TRequestInvasionHelp extends Transaction
   {
      
      private var m_ids:Array;
      
      private var m_requestType:String;
      
      private var m_invasionId:String;
      
      public function TRequestInvasionHelp(param1:Array, param2:String, param3:String)
      {
         super();
         this.m_ids = param1;
         this.m_invasionId = param2;
         this.m_requestType = param3;
      }
      
      override public function perform() : void
      {
         signedCall("RequestService.invasionHelpRequest",this.m_ids,this.m_invasionId,this.m_requestType);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(param1 != null)
         {
            _loc2_ = {
               "invasionId":this.m_invasionId,
               "title":param1.title,
               "body":param1.body,
               "sendkey":param1.outgoingSendKey,
               "zmcSendkey":param1.zmcSendKey,
               "frHost":param1.frHost,
               "frType":param1.frType,
               "frId":param1.frId,
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
            GlobalEngine.socialNetwork.sendRequest(param1.eligible,RequestDialog.HELP_REQUEST,_loc3_,_loc4_,_loc2_);
         }
      }
   }
}

