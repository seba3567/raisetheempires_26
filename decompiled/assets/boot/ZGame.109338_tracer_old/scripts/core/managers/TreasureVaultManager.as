package core.managers
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import flash.events.EventDispatcher;
   import transactions.TTreasureVaultSpin;
   
   public class TreasureVaultManager extends EventDispatcher
   {
      
      public static var instance:TreasureVaultManager = new TreasureVaultManager();
      
      public static const SPIN_START:String = "spinStart";
      
      public static const SPIN_RESULTS:String = "spinResults";
      
      public static const SPIN_REWARD_CLAIMED:String = "spinRewardClaimed";
      
      public static const REWARD_SPIN_MODE_BUY:uint = 0;
      
      public static const REWARD_SPIN_MODE_KEYS:uint = 1;
      
      public static const TIER_NONE:uint = 0;
      
      public static const TIER_MIN:uint = 1;
      
      public static const TIER_MAX:uint = 4;
      
      public static const VAULT_KEY_ITEM:String = "B265";
      
      private static var m_lootTableHighlights:Object = null;
      
      public function TreasureVaultManager()
      {
         super();
      }
      
      public static function isEnabled() : Boolean
      {
         return true;
      }
      
      public static function getTierCostData(param1:uint) : XML
      {
         var _loc4_:XML = null;
         var _loc5_:XML = null;
         var _loc2_:uint = uint(ExperimentsManager.instance.getExperimentVariant("empire_vault_tierprice"));
         var _loc3_:XMLList = ZGlobal.gameSettings.getXML().treasureVaultCosts;
         if(_loc3_)
         {
            for each(_loc4_ in _loc3_.variant)
            {
               if(_loc4_.@index == _loc2_)
               {
                  for each(_loc5_ in _loc4_.info)
                  {
                     if(_loc5_.@tier == param1)
                     {
                        return _loc5_;
                     }
                  }
               }
            }
         }
         return null;
      }
      
      public static function getHighlightData(param1:uint) : Object
      {
         var _loc2_:String = "treasure_vault_tier_" + param1;
         if(Boolean(m_lootTableHighlights) && Boolean(m_lootTableHighlights[_loc2_]))
         {
            return m_lootTableHighlights[_loc2_];
         }
         return null;
      }
      
      public static function getSpinPurchaseCost(param1:uint) : uint
      {
         var _loc2_:XML = getTierCostData(param1);
         if(Boolean(_loc2_) && _loc2_.@cash != undefined)
         {
            return _loc2_.@cash;
         }
         return 100;
      }
      
      public static function getSpinKeyCost(param1:uint) : uint
      {
         var _loc2_:XML = getTierCostData(param1);
         if(Boolean(_loc2_) && _loc2_.@keys != undefined)
         {
            return _loc2_.@keys;
         }
         return 100;
      }
      
      public static function spinNextAvailable() : Number
      {
         var _loc1_:Number = GlobalEngine.serverTime / 1000;
         var _loc2_:Number = ZGlobal.player.m_treasureVaultOpenTS;
         var _loc3_:Number = _loc2_ + 24 * 60 * 60;
         return _loc3_ - _loc1_;
      }
      
      public static function isSpinAvailable() : Boolean
      {
         return spinNextAvailable() <= 0;
      }
      
      public function slotMachineSpin(param1:uint, param2:uint) : Boolean
      {
         var _loc3_:int = 0;
         switch(param1)
         {
            case REWARD_SPIN_MODE_BUY:
               _loc3_ = int(getSpinPurchaseCost(param2));
               if(ZGlobal.player.canBuyCash(_loc3_,true))
               {
                  ZGlobal.player.cash -= _loc3_;
                  break;
               }
               return false;
               break;
            case REWARD_SPIN_MODE_KEYS:
               ZGlobal.player.m_treasureVaultOpenTS = GlobalEngine.serverTime / 1000;
               _loc3_ = int(getSpinKeyCost(param2));
               if(_loc3_ <= ZGlobal.player.inventory[VAULT_KEY_ITEM])
               {
                  ZGlobal.player.removeInventoryItem(VAULT_KEY_ITEM,_loc3_);
                  break;
               }
               return false;
               break;
            default:
               return false;
         }
         var _loc4_:TTreasureVaultSpin = new TTreasureVaultSpin(param1,param2);
         TransactionManager.addTransaction(_loc4_);
         return true;
      }
      
      public function awardClaimed() : void
      {
      }
      
      public function initHighlights(param1:Object) : void
      {
         if(param1.treasureVaultHighlights)
         {
            m_lootTableHighlights = param1.treasureVaultHighlights;
         }
      }
   }
}

