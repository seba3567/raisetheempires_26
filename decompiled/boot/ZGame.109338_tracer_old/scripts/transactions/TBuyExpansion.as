package transactions
{
   public class TBuyExpansion extends TBuyItem
   {
      
      private var m_index:uint = 0;
      
      public function TBuyExpansion(param1:String, param2:Boolean, param3:uint, param4:String = null)
      {
         super(param1,param2,1,null,param4);
         this.m_index = param3;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.buyExpansion",modifiedData(this.data));
      }
      
      override protected function get data() : Object
      {
         var _loc1_:Object = super.data;
         _loc1_.index = this.m_index;
         _loc1_.skipInventory = 1;
         return _loc1_;
      }
   }
}

