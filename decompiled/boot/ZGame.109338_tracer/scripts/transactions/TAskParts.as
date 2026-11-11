package transactions
{
   import Engine.Transactions.Transaction;
   import displays.screens.requests.RequestDialog;
   
   public class TAskParts extends Transaction
   {
      
      private var m_ids:Array;
      
      private var m_part:String;
      
      private var m_unit:String;
      
      private var m_requestType:String;
      
      private var m_trackingParams:Array;
      
      public function TAskParts(param1:Array, param2:String, param3:String, param4:String, param5:Array = null)
      {
         super();
         this.m_ids = param1;
         this.m_part = param2;
         this.m_unit = param3;
         this.m_requestType = param4;
         this.m_trackingParams = param5;
      }
      
      override public function perform() : void
      {
         signedCall("RequestService.partRequest",this.m_part,this.m_unit,this.m_requestType,this.m_ids,this.m_trackingParams);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(param1 != null)
         {
            _loc2_ = {
               "title":param1.title,
               "body":param1.body,
               "item":param1.gift,
               "reference":this.m_unit,
               "zmcSendkey":param1.zmcSendKey,
               "sendkey":param1.outgoingSendKey,
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

