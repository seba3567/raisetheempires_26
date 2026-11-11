package core.managers
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.player.Friend;
   import core.player.IAlly;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   import transactions.TReviveAllies;
   
   public class ReviveAlliesManager extends EventDispatcher
   {
      
      private static var m_instance:ReviveAlliesManager;
      
      public static const ALLY_TIMER_EXPIRED:String = "allyTimerExpired";
      
      public static const REVIVE_COUNT_UPDATED:String = "reviveCountUpdated";
      
      private var m_maxRevivable:int;
      
      private var m_reviveCostPerAlly:int;
      
      private var m_numAlliesRevivable:int = 0;
      
      public function ReviveAlliesManager(param1:IEventDispatcher = null)
      {
         super(param1);
         this.m_maxRevivable = ZGlobal.gameSettings.getInt("maxReviveAllyCount",10);
         this.m_reviveCostPerAlly = ZGlobal.gameSettings.getInt("reviveCostPerAlly",2);
      }
      
      public static function get instance() : ReviveAlliesManager
      {
         if(!m_instance)
         {
            m_instance = new ReviveAlliesManager();
         }
         return m_instance;
      }
      
      public static function isEnabled() : Boolean
      {
         return ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REVIVE_ALLIES) == ExperimentsManager.VARIANT_REVIVE_ALLIES_ON;
      }
      
      public static function numNonMercAlliesAvailable(param1:Array, param2:Array) : int
      {
         var _loc5_:int = 0;
         var _loc6_:IAlly = null;
         var _loc3_:int = 0;
         var _loc4_:Boolean = Boolean(param2) && param2.length > 0;
         if(param1)
         {
            _loc5_ = 0;
            while(_loc5_ < param1.length)
            {
               _loc6_ = param1[_loc5_];
               if(Boolean(_loc6_ is Friend) && (Boolean(_loc4_ || ZGlobal.player.allies.isAllyValidForConsumable(_loc6_.id))) && !ZGlobal.player.allies.isAllyInBattle(_loc6_.id))
               {
                  _loc3_++;
               }
               _loc5_++;
            }
         }
         return _loc3_;
      }
      
      public function initReviveAllies() : void
      {
         var _loc4_:String = null;
         var _loc1_:int = 0;
         var _loc2_:Dictionary = ZGlobal.player.allies.allies;
         var _loc3_:XMLList = ZGlobal.gameSettings.getXML().defaultAlly;
         for(_loc4_ in _loc2_)
         {
            if(!ZGlobal.player.allies.isAllyInBattle(_loc4_) && (Boolean(ZGlobal.player.neighbors[_loc4_]) || Boolean(_loc4_ == _loc3_.uid)))
            {
               _loc1_++;
            }
         }
         this.m_numAlliesRevivable = _loc1_;
         this.addEventListener(ALLY_TIMER_EXPIRED,this.onAllyTimerExpiry);
      }
      
      public function deinitReviveAllies() : void
      {
         this.m_numAlliesRevivable = 0;
         this.removeEventListener(ALLY_TIMER_EXPIRED,this.onAllyTimerExpiry);
      }
      
      public function reviveCount() : int
      {
         return this.m_numAlliesRevivable > this.m_maxRevivable ? this.m_maxRevivable : this.m_numAlliesRevivable;
      }
      
      public function reviveCostPerAlly() : int
      {
         return this.m_reviveCostPerAlly;
      }
      
      protected function onAllyTimerExpiry(param1:Event) : void
      {
         if(this.m_numAlliesRevivable > 0)
         {
            --this.m_numAlliesRevivable;
            if(this.m_numAlliesRevivable < this.m_maxRevivable)
            {
               this.dispatchEvent(new Event(REVIVE_COUNT_UPDATED));
            }
         }
      }
      
      public function reviveAllies() : void
      {
         var _loc4_:String = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc1_:Dictionary = ZGlobal.player.allies.allies;
         if(_loc1_ == null || this.m_numAlliesRevivable == 0)
         {
            return;
         }
         var _loc2_:Array = new Array();
         var _loc3_:XMLList = ZGlobal.gameSettings.getXML().defaultAlly;
         for(_loc4_ in _loc1_)
         {
            if(!ZGlobal.player.allies.isAllyInBattle(_loc4_) && (Boolean(ZGlobal.player.neighbors[_loc4_]) || Boolean(_loc4_ == _loc3_.uid)))
            {
               _loc2_.push({
                  "uid":_loc4_,
                  "time":_loc1_[_loc4_]
               });
            }
         }
         if(_loc2_.length > this.m_maxRevivable)
         {
            _loc2_.sortOn("time",Array.NUMERIC);
         }
         var _loc5_:int = this.reviveCount();
         var _loc6_:int = _loc5_ * this.m_reviveCostPerAlly;
         if(ZGlobal.player.canBuyCash(_loc6_,true,"",false))
         {
            TransactionManager.addTransaction(new TReviveAllies(_loc5_),true);
            _loc7_ = 0;
            _loc8_ = 0;
            while(_loc8_ < _loc2_.length && _loc7_ < _loc5_ && this.m_numAlliesRevivable > 0)
            {
               if(ZGlobal.player.allies.removeAlly(_loc2_[_loc8_].uid))
               {
                  --this.m_numAlliesRevivable;
                  _loc7_++;
               }
               _loc8_++;
            }
            ZGlobal.player.cash -= _loc7_ * this.m_reviveCostPerAlly;
            if(this.m_numAlliesRevivable < this.m_maxRevivable)
            {
               this.dispatchEvent(new Event(REVIVE_COUNT_UPDATED));
            }
         }
      }
   }
}

