package displays.screens.blackMarket
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsBuildingItem;
   import core.gameobjects.PartsItem;
   import core.gameobjects.PartsPowerupItem;
   import core.player.Player;
   
   public class BlackMarketDataHelper
   {
      
      private static var m_instance:BlackMarketDataHelper = null;
      
      public function BlackMarketDataHelper()
      {
         super();
      }
      
      public static function get instance() : BlackMarketDataHelper
      {
         if(!m_instance)
         {
            m_instance = new BlackMarketDataHelper();
         }
         return m_instance;
      }
      
      public function getItemList(param1:Object) : Array
      {
         var _loc4_:Object = null;
         var _loc5_:GameItem = null;
         var _loc6_:* = 0;
         var _loc2_:int = this.numProperties(param1.items);
         var _loc3_:Array = new Array(_loc2_);
         for each(_loc4_ in param1.items)
         {
            _loc3_[_loc4_.index] = _loc4_;
         }
         _loc6_ = int(_loc2_ - 1);
         while(_loc6_ >= 0)
         {
            _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc3_[_loc6_].code,GameItem) as GameItem;
            if(ZGlobal.player.checkGate(_loc5_).isBitSet(Player.GATE_FAILURE_LEVEL))
            {
               _loc3_.splice(_loc6_,1);
            }
            _loc6_--;
         }
         return _loc3_;
      }
      
      public function getPartList(param1:Object) : Array
      {
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         var _loc2_:PartsItem = ZGlobal.gameSettings.getItemByCode(param1.code,PartsItem) as PartsItem;
         if(_loc2_.type == "consumable")
         {
            _loc2_ = ZGlobal.gameSettings.getItemByCode(param1.code,PartsPowerupItem) as PartsPowerupItem;
         }
         else
         {
            _loc2_ = ZGlobal.gameSettings.getItemByCode(param1.code,PartsBuildingItem) as PartsBuildingItem;
         }
         var _loc3_:int = this.numProperties(param1.parts);
         var _loc4_:Array = new Array(_loc3_);
         for each(_loc5_ in param1.parts)
         {
            if(_loc2_ != null)
            {
               _loc6_ = this.findIndex(_loc2_.xml.part,_loc5_.code);
               if(_loc6_ > -1)
               {
                  _loc5_.count = _loc2_.getPartCountForIndex(_loc6_);
                  _loc5_.askMethod = _loc2_.xml.part[_loc6_].@askMethod;
                  _loc5_.askName = _loc2_.xml.part[_loc6_].@askName;
               }
            }
            _loc4_[_loc5_.index] = _loc5_;
         }
         return _loc4_;
      }
      
      public function getRequirementList(param1:Object) : Array
      {
         var _loc4_:Object = null;
         var _loc2_:int = this.numProperties(param1.requires);
         var _loc3_:Array = new Array(_loc2_);
         for each(_loc4_ in param1.requires)
         {
            _loc3_[_loc4_.index] = _loc4_;
         }
         return _loc3_;
      }
      
      public function findIndex(param1:XMLList, param2:String) : int
      {
         var _loc3_:uint = 0;
         while(_loc3_ < param1.length())
         {
            if(param1[_loc3_].@code == param2)
            {
               return _loc3_;
            }
            _loc3_++;
         }
         return -1;
      }
      
      public function numProperties(param1:Object) : int
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         for each(_loc3_ in param1)
         {
            _loc2_++;
         }
         return _loc2_;
      }
   }
}

