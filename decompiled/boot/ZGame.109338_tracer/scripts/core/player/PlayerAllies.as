package core.player
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.questPower.QuestPower;
   import core.managers.ReviveAlliesManager;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class PlayerAllies
   {
      
      private static const EXPERIMENT_COMBAT_ALLY_TIMEOUT_CONTROL:uint = 0;
      
      private static const EXPERIMENT_COMBAT_ALLY_TIMEOUT_VARIANT_1:uint = 1;
      
      private static const EXPERIMENT_COMBAT_ALLY_TIMEOUT_VARIANT_2:uint = 2;
      
      private static const EXPERIMENT_COMBAT_ALLY_TIMEOUT_VARIANT_3:uint = 3;
      
      private static const MAX_REVIVABLE:int = 10;
      
      private var m_allies:Dictionary = null;
      
      private var m_numAlliesRevivable:int = 0;
      
      public function PlayerAllies(param1:Object)
      {
         var _loc2_:Object = null;
         super();
         if(null != param1)
         {
            this.m_allies = new Dictionary();
            for each(_loc2_ in param1)
            {
               this.m_allies[_loc2_.uid] = _loc2_.time;
            }
         }
      }
      
      public function get allies() : Dictionary
      {
         return this.m_allies;
      }
      
      public function addAlly(param1:String) : void
      {
         if(null == this.m_allies)
         {
            this.m_allies = new Dictionary();
         }
         this.m_allies[param1] = 0;
      }
      
      public function startAllyTimer(param1:String) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
         if(Boolean(_loc2_) || QuestPower.isQuestPower(param1))
         {
            delete this.m_allies[param1];
         }
         else
         {
            _loc3_ = GlobalEngine.serverTime / 1000;
            this.m_allies[param1] = _loc3_;
         }
      }
      
      public function isAllyInBattle(param1:String) : Boolean
      {
         if(null != this.m_allies)
         {
            if(null != this.m_allies[param1])
            {
               return this.m_allies[param1] == 0;
            }
         }
         return false;
      }
      
      public function isAllyValidForConsumable(param1:String) : Boolean
      {
         if(null != this.m_allies)
         {
            this.updateTimeouts();
            if(null != this.m_allies[param1])
            {
               return false;
            }
         }
         return true;
      }
      
      public function getAllyTimeoutSeconds() : Number
      {
         var _loc1_:String = "consumableUserTimeout";
         switch(ZGlobal.allyTimeoutVariant)
         {
            case EXPERIMENT_COMBAT_ALLY_TIMEOUT_VARIANT_1:
               break;
            case EXPERIMENT_COMBAT_ALLY_TIMEOUT_VARIANT_2:
               _loc1_ += "_v2";
               break;
            case EXPERIMENT_COMBAT_ALLY_TIMEOUT_VARIANT_3:
               _loc1_ += "_v3";
         }
         return ZGlobal.gameSettings.getSeconds(_loc1_);
      }
      
      private function updateTimeouts() : void
      {
         var _loc3_:String = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc1_:Number = this.getAllyTimeoutSeconds();
         var _loc2_:Number = GlobalEngine.serverTime;
         _loc2_ /= 1000;
         for(_loc3_ in this.m_allies)
         {
            _loc4_ = Number(this.m_allies[_loc3_]);
            _loc5_ = _loc2_ - _loc4_;
            if(_loc5_ > _loc1_)
            {
               delete this.m_allies[_loc3_];
               if(ReviveAlliesManager.isEnabled())
               {
                  ReviveAlliesManager.instance.dispatchEvent(new Event(ReviveAlliesManager.ALLY_TIMER_EXPIRED));
               }
            }
         }
      }
      
      public function removeAlly(param1:String) : Boolean
      {
         if(Boolean(this.m_allies) && Boolean(this.m_allies.hasOwnProperty(param1)) && this.m_allies[param1] != 0)
         {
            delete this.m_allies[param1];
            return true;
         }
         return false;
      }
   }
}

