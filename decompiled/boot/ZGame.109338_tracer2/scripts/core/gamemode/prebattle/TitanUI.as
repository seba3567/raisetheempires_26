package core.gamemode.prebattle
{
   import com.adobe.utils.DictionaryUtil;
   import core.ZGlobal;
   import core.gameobjects.UnitItem;
   import flash.utils.Dictionary;
   import zlabs.debug.Logger;
   
   public class TitanUI
   {
      
      public static const ARM1:int = 0;
      
      public static const SHOULDER1:int = 1;
      
      public static const HEAD:int = 2;
      
      public static const SHOULDER2:int = 3;
      
      public static const ARM2:int = 4;
      
      private var m_titanSlots:Dictionary = null;
      
      public function TitanUI()
      {
         super();
      }
      
      public function reset() : void
      {
         this.m_titanSlots = new Dictionary();
      }
      
      public function updateSlot(param1:Array, param2:int) : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:UnitItem = null;
         var _loc5_:int = 0;
         for each(_loc3_ in param1)
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,UnitItem) as UnitItem;
            _loc5_ = _loc4_.formationIndex;
            if(param2 < 0)
            {
               if(!this.m_titanSlots[_loc5_])
               {
                  this.m_titanSlots[_loc5_] = _loc3_;
                  return this.refreshCards(true,_loc5_);
               }
            }
            else if(this.m_titanSlots[_loc5_])
            {
               delete this.m_titanSlots[_loc5_];
               return this.refreshCards(false,_loc5_);
            }
         }
         Logger.error(this,"updateSlot","no slot found");
         return false;
      }
      
      public function AnyLimbOccupied() : Boolean
      {
         var _loc1_:int = 0;
         while(_loc1_ <= ARM2)
         {
            if(_loc1_ != HEAD && Boolean(this.getOccupiedAt(_loc1_)))
            {
               return true;
            }
            _loc1_++;
         }
         return false;
      }
      
      public function getOccupiedAt(param1:int) : String
      {
         return this.m_titanSlots ? this.m_titanSlots[param1] : null;
      }
      
      public function getNumOccupied() : int
      {
         return DictionaryUtil.getKeys(this.m_titanSlots).length;
      }
      
      public function getMegaUnitFromUnits(param1:Array) : UnitItem
      {
         var _loc4_:int = 0;
         var _loc2_:String = null;
         var _loc3_:UnitItem = null;
         for each(_loc2_ in param1)
         {
            _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc2_,UnitItem) as UnitItem;
            _loc4_ = _loc3_.formationIndex;
            if(!this.m_titanSlots[_loc4_])
            {
               return _loc3_;
            }
         }
         var _loc5_:int = 0;
         var _loc6_:* = param1;
         for each(_loc2_ in _loc6_)
         {
            return ZGlobal.gameSettings.getItemByCode(_loc2_,UnitItem) as UnitItem;
         }
         return null;
      }
      
      public function validateItem(param1:UnitItem) : Boolean
      {
         if(!this.m_titanSlots[HEAD])
         {
            return param1.hasType(UnitItem.MEGA_UNIT_CONTROLLER);
         }
         if(param1.hasType(UnitItem.MEGA_UNIT_CONTROLLER))
         {
            return !this.m_titanSlots[HEAD];
         }
         if(param1.hasType(UnitItem.MEGA_UNIT_ARM))
         {
            return !this.m_titanSlots[ARM1] || !this.m_titanSlots[ARM2];
         }
         return !this.m_titanSlots[SHOULDER1] || !this.m_titanSlots[SHOULDER2];
      }
      
      private function refreshCards(param1:Boolean, param2:int) : Boolean
      {
         if(param2 == HEAD)
         {
            return true;
         }
         if(param2 == ARM1 || param2 == ARM2)
         {
            return Boolean(this.m_titanSlots[ARM1]) && Boolean(this.m_titanSlots[ARM2]);
         }
         return Boolean(this.m_titanSlots[SHOULDER1]) && Boolean(this.m_titanSlots[SHOULDER2]);
      }
   }
}

