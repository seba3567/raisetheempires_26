package core.managers
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import flash.utils.Dictionary;
   
   public class EarlyUnitUnlockManager
   {
      
      public static var instance:EarlyUnitUnlockManager = new EarlyUnitUnlockManager();
      
      private var m_dataCache:Dictionary = null;
      
      public function EarlyUnitUnlockManager()
      {
         super();
      }
      
      public function earlyUnlockCost(param1:GameItem) : int
      {
         return this.dataCache[param1.code];
      }
      
      private function get dataCache() : Dictionary
      {
         var _loc1_:int = 0;
         var _loc2_:XMLList = null;
         var _loc3_:XML = null;
         var _loc4_:int = 0;
         if(!this.m_dataCache)
         {
            this.m_dataCache = new Dictionary();
            _loc1_ = ExperimentsManager.instance.getExperimentVariant("empire_pricetest_earlyunitunlock");
            _loc2_ = ZGlobal.gameSettings.getXML().unitUnlockCosts.unitUnlockCost;
            for each(_loc3_ in _loc2_)
            {
               _loc4_ = 0;
               switch(_loc1_)
               {
                  case 1:
                     _loc4_ = int(_loc3_.@costv1);
                     break;
                  case 2:
                     _loc4_ = int(_loc3_.@costv2);
                     break;
                  case 3:
                     _loc4_ = int(_loc3_.@costv3);
                     break;
                  default:
                     _loc4_ = int(_loc3_.@costv0);
               }
               this.m_dataCache[_loc3_.@unit.toString()] = _loc4_;
            }
         }
         return this.m_dataCache;
      }
   }
}

