package core.managers
{
   public class BuyBackManager
   {
      
      public static var instance:BuyBackManager = new BuyBackManager();
      
      private var m_data:Object = null;
      
      public function BuyBackManager()
      {
         super();
      }
      
      public function init(param1:Object) : void
      {
         this.m_data = param1;
      }
      
      public function costMultiplier(param1:String, param2:uint) : Number
      {
         if(this.m_data.hasOwnProperty(param1))
         {
            return this.m_data[param1][param2];
         }
         return 1;
      }
   }
}

