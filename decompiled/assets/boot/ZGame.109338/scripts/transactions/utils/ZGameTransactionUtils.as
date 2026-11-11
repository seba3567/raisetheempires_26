package transactions.utils
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   
   public class ZGameTransactionUtils
   {
      
      public function ZGameTransactionUtils()
      {
         super();
      }
      
      public static function getCheckSum(param1:Object) : uint
      {
         var _loc2_:uint = getCheckSumFromObject(param1);
         _loc2_ += getCheckSumFromObject(ZGlobal.player.uid);
         return uint(_loc2_ + getCheckSumFromObject(TransactionManager.sequenceNumber));
      }
      
      private static function getCheckSumFromObject(param1:Object) : uint
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc2_:uint = 0;
         if(param1 != null)
         {
            if(param1 is String)
            {
               _loc3_ = 0;
               while(_loc3_ < param1.length)
               {
                  _loc2_ += param1.charCodeAt(_loc3_) + _loc3_;
                  _loc3_++;
               }
            }
            else if(isNumber(param1))
            {
               _loc2_ += uint((param1 as Number) / 2);
            }
            else if(param1 is Boolean)
            {
               _loc2_ += param1 ? 16 : 9;
            }
            else
            {
               for(_loc4_ in param1)
               {
                  _loc2_ += getCheckSumFromObject(param1[_loc4_]);
               }
            }
         }
         return _loc2_;
      }
      
      private static function isNumber(param1:Object) : Boolean
      {
         return param1 is int || param1 is uint || param1 is Number;
      }
   }
}

