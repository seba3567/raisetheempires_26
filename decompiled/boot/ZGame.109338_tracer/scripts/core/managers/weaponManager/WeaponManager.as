package core.managers.weaponManager
{
   import core.gameobjects.UnitItem;
   import flash.utils.Dictionary;
   import utils.ZGameTimeUtil;
   
   public class WeaponManager
   {
      
      public static var instance:WeaponManager = new WeaponManager();
      
      private var m_Weapons:Dictionary = null;
      
      public function WeaponManager()
      {
         super();
      }
      
      public function initFromSettings(param1:XMLList) : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         this.m_Weapons = new Dictionary();
         for each(_loc2_ in param1)
         {
            _loc3_ = _loc2_.@id.toString();
            this.m_Weapons[_loc3_] = _loc2_;
         }
      }
      
      public function getFiringFX(param1:String) : String
      {
         if(this.validId(param1))
         {
            return this.m_Weapons[param1].@firingfx.toString();
         }
         return null;
      }
      
      public function getWaterMissFX(param1:String) : String
      {
         if(this.validId(param1))
         {
            return this.m_Weapons[param1].@misswaterfx.toString();
         }
         return null;
      }
      
      public function getAirMissFX(param1:String) : String
      {
         if(this.validId(param1))
         {
            return this.m_Weapons[param1].@missairfx.toString();
         }
         return null;
      }
      
      public function getPreHitFX(param1:String) : String
      {
         if(this.validId(param1))
         {
            return this.m_Weapons[param1].@prehitfx.toString();
         }
         return null;
      }
      
      public function getOnHitFX(param1:String) : String
      {
         if(this.validId(param1))
         {
            return this.m_Weapons[param1].@onhitfx.toString();
         }
         return null;
      }
      
      public function getLandMissFX(param1:String) : String
      {
         if(this.validId(param1))
         {
            return this.m_Weapons[param1].@misslandfx.toString();
         }
         return null;
      }
      
      public function getHitFX(param1:String, param2:UnitItem) : String
      {
         var _loc3_:String = null;
         if(this.validId(param1))
         {
            if(Boolean(param2) && param2.hasType(UnitItem.INFANTRY))
            {
               _loc3_ = this.m_Weapons[param1].@hitinffx.toString();
               if(_loc3_.length > 0)
               {
                  return _loc3_;
               }
            }
            return this.m_Weapons[param1].@hitfx.toString();
         }
         return null;
      }
      
      public function getHitDelay(param1:String) : Number
      {
         var _loc2_:String = null;
         if(this.validId(param1))
         {
            _loc2_ = this.m_Weapons[param1].@hitDelay.toString();
            return ZGameTimeUtil.instance.parseTimeAsSeconds(_loc2_,0);
         }
         return 0;
      }
      
      public function hasRandDelay(param1:String) : Boolean
      {
         if(this.validId(param1))
         {
            return this.m_Weapons[param1].@hitDelay != undefined;
         }
         return false;
      }
      
      private function validId(param1:String) : Boolean
      {
         return null != this.m_Weapons[param1];
      }
   }
}

