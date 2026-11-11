package core.managers
{
   import core.gameobjects.GameItem;
   import flash.utils.Dictionary;
   import utils.CriteriaUtil;
   
   public class ItemCostOverridesManager
   {
      
      public static var instance:ItemCostOverridesManager = new ItemCostOverridesManager();
      
      private var m_overrideXML:XMLList = null;
      
      private var m_overrides:Array = null;
      
      public function ItemCostOverridesManager()
      {
         super();
      }
      
      public function initFromSettings(param1:XMLList) : void
      {
         this.m_overrideXML = param1;
      }
      
      public function getOverride(param1:String, param2:String, param3:GameItem) : String
      {
         var _loc4_:Object = null;
         if(this.m_overrides == null)
         {
            this.cacheOverrides();
         }
         for each(_loc4_ in this.m_overrides)
         {
            if(_loc4_.overrides[param1] != null && this.itemAttributesMatch(param3,_loc4_.attributes))
            {
               return this.performOverride(_loc4_.overrides[param1],param2);
            }
         }
         return param2;
      }
      
      private function cacheOverrides() : void
      {
         var _loc1_:XML = null;
         var _loc2_:XMLList = null;
         var _loc3_:XML = null;
         this.m_overrides = new Array();
         for each(_loc1_ in this.m_overrideXML)
         {
            _loc2_ = _loc1_.cost;
            for each(_loc3_ in _loc2_)
            {
               if(CriteriaUtil.meetsCriteria(_loc3_.criteria))
               {
                  this.m_overrides.push({
                     "attributes":this.attributesInXML(_loc1_),
                     "overrides":this.attributesInXML(_loc3_)
                  });
               }
            }
         }
      }
      
      private function attributesInXML(param1:XML) : Dictionary
      {
         var _loc4_:XML = null;
         var _loc2_:Dictionary = new Dictionary();
         var _loc3_:XMLList = param1.attributes();
         for each(_loc4_ in _loc3_)
         {
            _loc2_[_loc4_.name().toString()] = _loc4_.toString();
         }
         return _loc2_;
      }
      
      private function itemAttributesMatch(param1:GameItem, param2:Dictionary) : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:Boolean = false;
         var _loc5_:String = null;
         var _loc6_:String = null;
         for(_loc3_ in param2)
         {
            _loc4_ = param1.xml.attribute(_loc3_).length() > 0;
            _loc5_ = param1.xml.attribute(_loc3_).toString();
            _loc6_ = param2[_loc3_];
            if(param1.xml.attribute(_loc3_).length() == 0 || param1.xml.attribute(_loc3_).toString() != param2[_loc3_])
            {
               return false;
            }
         }
         return true;
      }
      
      private function performOverride(param1:String, param2:String) : String
      {
         switch(param1.charAt(0))
         {
            case "*":
               param2 = String(Math.ceil(Number(param1.substr(1)) * Number(param2)));
               break;
            default:
               param2 = param1;
         }
         return param2;
      }
   }
}

