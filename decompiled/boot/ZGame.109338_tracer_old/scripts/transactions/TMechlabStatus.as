package transactions
{
   public class TMechlabStatus extends TZGameTransaction
   {
      
      private var m_rewardIndex:int = 0;
      
      private var m_partsItemCode:String = "";
      
      public function TMechlabStatus(param1:int, param2:String)
      {
         this.m_rewardIndex = param1;
         this.m_partsItemCode = param2;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.mechlabStatus",modifiedData({
            "index":this.m_rewardIndex,
            "partsItemCode":this.m_partsItemCode
         }));
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
      }
   }
}

