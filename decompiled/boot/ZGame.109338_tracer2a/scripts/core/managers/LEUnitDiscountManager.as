package core.managers
{
   import core.ZGlobal;
   import flash.utils.Dictionary;
   import zlabs.debug.Logger;
   import zlabs.utils.TimeUtil;
   
   public class LEUnitDiscountManager
   {
      
      public static var instance:LEUnitDiscountManager = new LEUnitDiscountManager();
      
      private var m_leUnitDiscount:Dictionary = new Dictionary();
      
      private var m_overrideDiscountPrice:Dictionary = new Dictionary();
      
      public function LEUnitDiscountManager()
      {
         super();
      }
      
      public function setLEUnitDiscounts(param1:Object) : void
      {
         var _loc2_:String = null;
         if(param1)
         {
            for(_loc2_ in param1)
            {
               if(this.m_leUnitDiscount[_loc2_] == null)
               {
                  this.m_leUnitDiscount[_loc2_] = param1[_loc2_];
               }
            }
         }
      }
      
      public function get leDiscountVariant() : int
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_LE_DISCOUNT_SALE);
         if(Boolean(_loc1_) && _loc1_ >= 0)
         {
            return _loc1_;
         }
         return 0;
      }
      
      public function isLEDiscountExpEnabled() : Boolean
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_LE_DISCOUNT_SALE);
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_LE_DISCOUNT_SALE) >= ExperimentsManager.EXPERIMENT_LE_DISCOUNT_SALE_ENABLED_VARIANT)
         {
            return true;
         }
         return false;
      }
      
      public function isOverrideLEItem(param1:String) : Boolean
      {
         if(Boolean(this.m_leUnitDiscount) && this.m_leUnitDiscount[param1] != null)
         {
            return true;
         }
         return false;
      }
      
      public function leUnitHasValidDiscount(param1:XML, param2:Boolean) : void
      {
         var itemCode:String = null;
         var startSeconds:Number = NaN;
         var endSeconds:Number = NaN;
         var currentSeconds:int = 0;
         var discount:String = null;
         var item:XML = param1;
         var isInUTC:Boolean = param2;
         itemCode = item.@code.toString();
         if(this.m_leUnitDiscount[itemCode] != null && this.leDiscountVariant >= ExperimentsManager.EXPERIMENT_LE_DISCOUNT_SALE_ENABLED_VARIANT)
         {
            currentSeconds = GlobalEngine.getTimer() / 1000;
            currentSeconds += ZGlobal.player.timeWarpSeconds;
            try
            {
               startSeconds = TimeUtil.dateToNumber(this.m_leUnitDiscount[itemCode]["start"],isInUTC) / 1000;
            }
            catch(e:Error)
            {
               Logger.debug(this,m_leUnitDiscount[itemCode]["start"],e.message);
            }
            try
            {
               endSeconds = TimeUtil.dateToNumber(this.m_leUnitDiscount[itemCode]["end"],isInUTC) / 1000;
            }
            catch(e:Error)
            {
               Logger.debug(this,m_leUnitDiscount[itemCode]["end"],e.message);
            }
            if(currentSeconds < endSeconds && currentSeconds > startSeconds)
            {
               item.requiredDate.@start = this.m_leUnitDiscount[itemCode]["start"];
               item.requiredDate.@end = this.m_leUnitDiscount[itemCode]["end"];
               discount = this.m_leUnitDiscount[itemCode]["discount"];
               this.setLEOverrideDiscount(itemCode,discount);
            }
         }
      }
      
      private function setLEOverrideDiscount(param1:String, param2:String) : void
      {
         var _loc3_:Number = NaN;
         if(this.m_overrideDiscountPrice[param1] == null)
         {
            _loc3_ = int(param2);
            if(_loc3_ > 0)
            {
               this.m_overrideDiscountPrice[param1] = _loc3_;
            }
         }
      }
      
      public function getLEOverrideDiscount(param1:String) : Number
      {
         var _loc2_:Number = NaN;
         if(this.m_overrideDiscountPrice[param1] != null)
         {
            _loc2_ = Number(this.m_overrideDiscountPrice[param1]);
            return _loc2_ / 100;
         }
         return 0;
      }
   }
}

