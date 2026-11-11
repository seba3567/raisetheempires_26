package core.managers.MOTDManager
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.player.Player;
   import flash.events.EventDispatcher;
   import zlabs.events.WorldEvent;
   
   public class MOTDMerchManager extends EventDispatcher
   {
      
      private static var m_instance:MOTDMerchManager;
      
      public static const EVENT_MOTD_MERCHANDISING_BONUS_GRANTED:String = "EVENT_MOTD_MERCHANDISING_BONUS_GRANTED";
      
      public static const EVENT_MOTD_MERCHANDISING_BONUS_UNLOCKED:String = "EVENT_MOTD_MERCHANDISING_BONUS_UNLOCKED";
      
      public function MOTDMerchManager()
      {
         super();
      }
      
      public static function itemPurchased(param1:String) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:MOTDData = null;
         var _loc5_:Array = null;
         var _loc6_:Player = null;
         var _loc7_:String = null;
         var _loc8_:Object = null;
         var _loc9_:* = 0;
         var _loc10_:Object = null;
         var _loc11_:* = undefined;
         if(MessageOfTheDayManager.instance.version == 2 && param1 != "")
         {
            _loc2_ = MessageOfTheDayManager.instance.getAllMerchMotds();
            _loc6_ = ZGlobal.player;
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               _loc4_ = _loc2_[_loc3_];
               _loc5_ = _loc4_.merchData.merchItems;
               if(!_loc6_.getMotdMerchHistory(_loc4_.name))
               {
                  _loc6_.resetMotdMerchHistory(_loc4_.name);
               }
               for each(_loc8_ in _loc5_)
               {
                  if(param1 == _loc8_["code"])
                  {
                     if(!_loc6_.isMotdMerchItemPurchased(_loc4_.name,param1))
                     {
                        _loc6_.setMotdMerchItemPurchased(_loc4_.name,param1);
                     }
                  }
               }
               _loc9_ = 0;
               _loc10_ = _loc6_.getMotdMerchHistory(_loc4_.name);
               for each(_loc11_ in _loc10_)
               {
                  _loc9_++;
               }
               if(_loc10_["awarded"] != null)
               {
                  _loc9_--;
               }
               if(_loc5_.length > 0 && _loc9_ >= _loc5_.length)
               {
                  _loc6_.resetMotdMerchHistory(_loc4_.name);
                  _loc6_.setMotdMerchAwarded(_loc4_.name,1);
                  _loc7_ = _loc4_.merchData.bonusItems[0]["code"];
                  _loc6_.addToInventory(_loc7_);
                  MOTDMerchManager.instance.dispatchEvent(new WorldEvent(EVENT_MOTD_MERCHANDISING_BONUS_GRANTED,{
                     "motd":_loc4_.name,
                     "itemCode":_loc7_
                  }));
               }
               else
               {
                  _loc6_.setMotdMerchAwarded(_loc4_.name,0);
               }
               _loc3_++;
            }
         }
      }
      
      public static function itemUnlocked(param1:String) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:MOTDData = null;
         var _loc5_:Array = null;
         var _loc6_:Player = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:Boolean = false;
         var _loc10_:String = null;
         var _loc11_:Object = null;
         var _loc12_:Boolean = false;
         var _loc13_:GameItem = null;
         if(MessageOfTheDayManager.instance.version == 2 && param1 != "")
         {
            _loc2_ = MessageOfTheDayManager.instance.getAllMerchMotds();
            _loc6_ = ZGlobal.player;
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               _loc4_ = _loc2_[_loc3_];
               _loc5_ = _loc4_.merchData.merchItems;
               _loc8_ = 0;
               _loc9_ = false;
               for each(_loc11_ in _loc5_)
               {
                  _loc10_ = _loc11_["code"];
                  if(_loc10_ == param1)
                  {
                     _loc9_ = true;
                  }
                  if(_loc6_.isItemUnlocked(_loc10_) || _loc6_.hasUnlockedUnit(_loc10_) || _loc6_.hasPurchasedContract(_loc10_))
                  {
                     _loc8_++;
                  }
               }
               if(_loc9_ && _loc5_.length > 0 && _loc8_ >= _loc5_.length)
               {
                  _loc12_ = false;
                  _loc7_ = _loc4_.merchData.bonusItems[0]["code"];
                  _loc13_ = ZGlobal.gameSettings.getItemByCode(_loc7_,GameItem) as GameItem;
                  if(_loc13_)
                  {
                     _loc12_ = _loc13_.contractLocked;
                  }
                  if(_loc12_)
                  {
                     _loc6_.unlockContractMotdAward(_loc7_);
                     MOTDMerchManager.instance.dispatchEvent(new WorldEvent(EVENT_MOTD_MERCHANDISING_BONUS_UNLOCKED,{
                        "motd":_loc4_.name,
                        "itemCode":_loc7_
                     }));
                  }
                  else
                  {
                     _loc7_ = _loc4_.merchData.bonusItems[0]["code"];
                     _loc6_.addToInventory(_loc7_);
                     MOTDMerchManager.instance.dispatchEvent(new WorldEvent(EVENT_MOTD_MERCHANDISING_BONUS_GRANTED,{
                        "motd":_loc4_.name,
                        "itemCode":_loc7_
                     }));
                  }
               }
               _loc3_++;
            }
         }
      }
      
      public static function get instance() : MOTDMerchManager
      {
         if(!m_instance)
         {
            m_instance = new MOTDMerchManager();
         }
         return m_instance;
      }
   }
}

