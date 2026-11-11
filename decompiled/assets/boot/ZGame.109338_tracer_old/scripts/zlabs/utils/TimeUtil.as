package zlabs.utils
{
   public class TimeUtil
   {
      
      public static const days:Array = ["sunday","monday","tuesday","wednesday","thursday","friday","saturday"];
      
      public function TimeUtil()
      {
         super();
      }
      
      public static function dateToNumber(param1:String, param2:Boolean = false) : Number
      {
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:Array = null;
         var _loc3_:Number = 0;
         if(param2)
         {
            _loc4_ = String(param1).split("/",3);
            if(_loc4_.length == 1)
            {
               return parseFloat(param1);
            }
            _loc5_ = String(_loc4_[2]).split(" ");
            if((Boolean(_loc5_)) && _loc5_.length > 1)
            {
               _loc6_ = String(_loc5_[1]).split(":",3);
               _loc3_ = Date.UTC(parseInt(_loc4_[2]),parseInt(_loc4_[0]) - 1,parseInt(_loc4_[1]),parseInt(_loc6_[0]),parseInt(_loc6_[1]),parseInt(_loc6_[2]));
            }
            else
            {
               _loc3_ = Date.UTC(parseInt(_loc4_[2]),parseInt(_loc4_[0]) - 1,parseInt(_loc4_[1]));
            }
         }
         else
         {
            _loc4_ = String(param1).split("/",3);
            if(_loc4_.length == 1)
            {
               return parseFloat(param1);
            }
            _loc3_ = new Date(param1).valueOf();
         }
         return _loc3_;
      }
   }
}

