package core.managers.unitClassManager
{
   import core.ZGlobal;
   import core.gameobjects.UnitItem;
   import flash.utils.Dictionary;
   
   public class UnitClassManager
   {
      
      public static var instance:UnitClassManager = new UnitClassManager();
      
      private var m_units:Dictionary = null;
      
      public function UnitClassManager()
      {
         super();
      }
      
      public function initFromSettings(param1:XMLList) : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         this.m_units = new Dictionary();
         for each(_loc2_ in param1.unitClass)
         {
            _loc3_ = _loc2_.@name.toString();
            this.m_units[_loc3_] = new UnitClass(_loc2_);
         }
      }
      
      public function unitClassNamed(param1:String) : UnitClass
      {
         return this.m_units[param1] as UnitClass;
      }
      
      public function unitClassForUnit(param1:UnitItem) : UnitClass
      {
         return this.unitClassNamed(param1.unitClass);
      }
      
      public function getIconURLForUnit(param1:UnitItem) : String
      {
         var _loc2_:UnitClass = null;
         if(param1)
         {
            _loc2_ = this.unitClassNamed(param1.unitClass);
            if(_loc2_)
            {
               return ZGlobal.getAssetURL(_loc2_.getIconURL());
            }
         }
         return null;
      }
      
      public function getSmIconURLForUnit(param1:UnitItem) : String
      {
         var _loc2_:UnitClass = null;
         if(param1)
         {
            _loc2_ = this.unitClassNamed(param1.unitClass);
            if(_loc2_)
            {
               return ZGlobal.getAssetURL(_loc2_.getSmIconURL());
            }
         }
         return null;
      }
      
      public function getCountersFor(param1:UnitItem) : Array
      {
         var _loc6_:String = null;
         var _loc2_:String = param1.unitClass;
         var _loc3_:Array = new Array();
         var _loc4_:UnitClass = null;
         var _loc5_:Array = null;
         for each(_loc4_ in this.m_units)
         {
            if(!_loc4_.ignoreForWarning)
            {
               _loc5_ = _loc4_.getGoodAgainst().split(",");
               for each(_loc6_ in _loc5_)
               {
                  if(_loc6_ == _loc2_)
                  {
                     _loc3_.push(_loc4_);
                  }
               }
            }
         }
         if(_loc3_.length == 0)
         {
            for each(_loc4_ in this.m_units)
            {
               if(_loc4_.getGoodAgainst() != "" && !_loc4_.ignoreForWarning)
               {
                  _loc3_.push(_loc4_);
               }
            }
         }
         return _loc3_;
      }
   }
}

