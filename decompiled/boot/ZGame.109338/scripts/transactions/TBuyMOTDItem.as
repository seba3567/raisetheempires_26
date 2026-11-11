package transactions
{
   public class TBuyMOTDItem extends TBuyItem
   {
      
      public function TBuyMOTDItem(param1:String, param2:Boolean, param3:int = 1, param4:Object = null, param5:String = null, param6:String = null)
      {
         super(param1,param2,param3,param4,param5,param6);
      }
      
      override public function perform() : void
      {
         signedCall("UserService.buyMOTDItem",modifiedData(data));
      }
   }
}

