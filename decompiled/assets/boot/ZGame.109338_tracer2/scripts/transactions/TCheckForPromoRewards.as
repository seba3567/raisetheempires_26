package transactions
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import core.managers.MOTDManager.MessageOfTheDayManager;
   import displays.popups.GallantPopup;
   import displays.popups.IncentivePopup;
   import flash.events.Event;
   import zlabs.managers.PopupManager;
   
   public class TCheckForPromoRewards extends Transaction
   {
      
      private var m_promoCode:String = null;
      
      public function TCheckForPromoRewards(param1:String)
      {
         super();
         this.m_promoCode = param1;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.checkForPromoReward",this.m_promoCode);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         if(param1.result != undefined && param1.level != undefined)
         {
            if(param1.result)
            {
               if(MessageOfTheDayManager.instance.pendingMOTD)
               {
                  MessageOfTheDayManager.instance.addEventListener(MessageOfTheDayManager.EVENT_SHOWN_ALL_MESSAGES,this.showRewardPopup,false,0,true);
               }
               else
               {
                  this.showRewardPopup();
               }
            }
         }
      }
      
      override protected function onFault(param1:int, param2:String) : void
      {
      }
      
      private function showRewardPopup(param1:Event = null) : void
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:GallantPopup = null;
         MessageOfTheDayManager.instance.removeEventListener(MessageOfTheDayManager.EVENT_SHOWN_ALL_MESSAGES,this.showRewardPopup);
         var _loc2_:Array = ZGlobal.gameSettings.getIncentiveItems(this.m_promoCode);
         if(_loc2_.length > 0)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               ZGlobal.player.addToInventory(_loc2_[_loc3_],1);
               _loc3_++;
            }
            _loc4_ = ZGlobal.gameSettings.getIncentiveRewardText(this.m_promoCode);
            _loc5_ = {
               "incentiveCode":this.m_promoCode,
               "suppressTransaction":true,
               "dialogLabel":_loc4_
            };
            _loc6_ = new IncentivePopup(_loc5_);
            PopupManager.instance.push(_loc6_);
         }
      }
   }
}

