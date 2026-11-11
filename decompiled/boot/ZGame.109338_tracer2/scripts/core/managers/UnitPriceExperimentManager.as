package core.managers
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import flash.utils.Dictionary;
   
   public class UnitPriceExperimentManager
   {
      
      public static var instance:UnitPriceExperimentManager = new UnitPriceExperimentManager();
      
      private var m_dataCache:Dictionary = null;
      
      public function UnitPriceExperimentManager()
      {
         super();
      }
      
      public function getUnitPrice(param1:GameItem) : int
      {
         var _loc2_:int = int(this.dataCache[param1.code]);
         if(_loc2_ == 0)
         {
            _loc2_ = param1.xmlCash;
         }
         return _loc2_;
      }
      
      private function get dataCache() : Dictionary
      {
         var _loc1_:XMLList = null;
         var _loc2_:XML = null;
         var _loc3_:int = 0;
         var _loc4_:GameItem = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(!this.m_dataCache)
         {
            this.m_dataCache = new Dictionary();
            _loc1_ = ZGlobal.gameSettings.getXML().unitCosts.unitCost;
            for each(_loc2_ in _loc1_)
            {
               _loc3_ = ExperimentsManager.instance.getExperimentVariant(_loc2_.@experiment.toString());
               _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc2_.@unit.toString(),GameItem) as GameItem;
               if(_loc4_)
               {
                  _loc5_ = _loc4_.xmlCash;
                  _loc6_ = 0;
                  switch(_loc3_)
                  {
                     case 1:
                        _loc6_ = _loc2_.@costv1 != undefined ? int(_loc2_.@costv1) : _loc5_;
                        break;
                     case 2:
                        _loc6_ = _loc2_.@costv2 != undefined ? int(_loc2_.@costv2) : _loc5_;
                        break;
                     case 3:
                        _loc6_ = int(_loc2_.@costv3);
                        break;
                     case 4:
                        _loc6_ = int(_loc2_.@costv4);
                        break;
                     case 5:
                        _loc6_ = int(_loc2_.@costv5);
                        break;
                     case 6:
                        _loc6_ = int(_loc2_.@costv6);
                        break;
                     case 7:
                        _loc6_ = int(_loc2_.@costv7);
                        break;
                     default:
                        _loc6_ = _loc5_;
                  }
                  this.m_dataCache[_loc2_.@unit.toString()] = _loc6_;
               }
            }
         }
         return this.m_dataCache;
      }
   }
}

