package transactions
{
   public class TPurchaseEnergyRefill extends TBuyItem
   {
      
      public function TPurchaseEnergyRefill(param1:String, param2:Boolean, param3:int = 1, param4:Object = null)
      {
         super(param1,param2,param3,param4);
      }
      
      override public function perform() : void
      {
         signedCall("UserService.purchaseEnergyRefill",modifiedData(data));
      }
   }
}

