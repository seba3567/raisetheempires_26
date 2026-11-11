package transactions
{
   import Engine.Transactions.Transaction;
   import displays.screens.requests.RequestDialog;
   
   public class TRequestSendGift extends Transaction
   {
      
      private var m_ids:Array;
      
      private var m_itemName:String;
      
      private var m_ref:String;
      
      private var m_giftType:String;
      
      private var m_requestType:String;
      
      private var m_subCategory:String;
      
      public function TRequestSendGift(param1:Array, param2:String, param3:String, param4:String, param5:String, param6:String = "unknown")
      {
         super();
         this.m_ids = param1;
         this.m_itemName = param2;
         this.m_giftType = param3;
         this.m_requestType = param4;
         this.m_subCategory = param5;
         this.m_ref = param6;
      }
      
      override public function perform() : void
      {
         signedCall("RequestService.giftRequest",this.m_itemName,this.m_giftType,this.m_ids,this.m_requestType,this.m_subCategory);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(param1 != null)
         {
            _loc2_ = {
               "item":param1.gift,
               "sendkey":param1.outgoingSendKey,
               "zmcSendkey":param1.zmcSendKey,
               "signature":param1.signature,
               "ts":param1.timestamp,
               "totalRecipient":this.m_ids.length,
               "requestType":this.m_requestType,
               "button_href":param1.button_href,
               "zmc_button_href":param1.zmc_button_href,
               "isRaffleGift":param1.isRaffleGift
            };
            _loc2_.ts = _loc2_.ts == null || _loc2_.ts == undefined ? "" : _loc2_.ts;
            _loc3_ = param1.title;
            _loc4_ = param1.body;
            GlobalEngine.socialNetwork.sendRequest(param1.eligible,RequestDialog.GIFT_REQUEST,_loc3_,_loc4_,_loc2_);
         }
      }
   }
}

