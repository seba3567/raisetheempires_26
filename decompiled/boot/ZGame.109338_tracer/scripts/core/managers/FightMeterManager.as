package core.managers
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.ui.PlayerFeedbackManager;
   import dispatchers.UIDispatcher;
   import displays.popups.FightMeterBragPopup;
   import flash.events.Event;
   import transactions.TActivateFightMeter;
   import utils.ZGameUtils;
   import zlabs.managers.PopupManager;
   
   public class FightMeterManager
   {
      
      public static var instance:FightMeterManager = new FightMeterManager();
      
      private var m_fightCount:int = 0;
      
      private var m_lastActivated:int = 0;
      
      private var m_levelTarget:int = 0;
      
      private var m_lastInitWeek:int = 0;
      
      private var m_battleTarget:int = 0;
      
      public function FightMeterManager()
      {
         super();
      }
      
      public function init(param1:int, param2:int, param3:int, param4:int) : void
      {
         this.setLastInitWeek(param3);
         this.setFightCount(param2);
         this.setLastActivated(param1);
         this.setLevelTarget(ZGlobal.player.level);
         this.m_battleTarget = param4;
         UIDispatcher.instance.dispatchEvent(new Event(UIDispatcher.UI_FIGHTMETER_RELOADED));
      }
      
      public function set battleTarget(param1:int) : void
      {
         this.m_battleTarget = param1;
      }
      
      public function getLevelTarget(param1:int) : int
      {
         return this.m_battleTarget;
      }
      
      private function getProgressionCount(param1:int) : int
      {
         var _loc3_:XML = null;
         var _loc2_:XML = ZGlobal.gameSettings.getXML();
         if(Boolean(_loc2_) && _loc2_.fightMeter != undefined)
         {
            for each(_loc3_ in _loc2_.fightMeter.fights)
            {
               if(_loc3_.@target != undefined && _loc3_.@startLevel != undefined && _loc3_.@endLevel != undefined)
               {
                  if(param1 >= _loc3_.@startLevel && param1 <= _loc3_.@endLevel)
                  {
                     return _loc3_.@progressionCount;
                  }
               }
            }
         }
         return 0;
      }
      
      private function getProgressionArrayString(param1:int) : String
      {
         var _loc3_:XML = null;
         var _loc2_:XML = ZGlobal.gameSettings.getXML();
         if(Boolean(_loc2_) && _loc2_.fightMeter != undefined)
         {
            for each(_loc3_ in _loc2_.fightMeter.fights)
            {
               if(_loc3_.@target != undefined && _loc3_.@startLevel != undefined && _loc3_.@endLevel != undefined)
               {
                  if(param1 >= _loc3_.@startLevel && param1 <= _loc3_.@endLevel)
                  {
                     return _loc3_.@ratio;
                  }
               }
            }
         }
         return null;
      }
      
      public function getLevelTargetProgression(param1:int) : int
      {
         var _loc2_:int = GlobalEngine.getTimer() / 1000 + ZGlobal.player.timeWarpSeconds;
         var _loc3_:Number = this.m_lastInitWeek;
         var _loc4_:Number = (_loc2_ - _loc3_) / (60 * 60 * 24);
         var _loc5_:Number = Math.ceil(_loc4_);
         if(_loc5_ <= 4)
         {
            return Math.min(this.getLevelTarget(param1),66);
         }
         return Math.min(Math.ceil(1.2 * this.getLevelTarget(param1)),66);
      }
      
      public function checkWeeklyProgressionExpired() : Boolean
      {
         var _loc1_:int = GlobalEngine.getTimer() / 1000 + ZGlobal.player.timeWarpSeconds;
         var _loc2_:Number = this.m_lastInitWeek;
         var _loc3_:Number = (_loc1_ - _loc2_) / (60 * 60 * 24);
         var _loc4_:Number = Math.ceil(_loc3_);
         if(_loc4_ > 7)
         {
            return true;
         }
         return false;
      }
      
      public function setLevelTarget(param1:int) : void
      {
         this.m_levelTarget = this.getLevelTargetProgression(param1);
      }
      
      public function get levelTarget() : int
      {
         this.setLevelTarget(ZGlobal.player.level);
         return this.m_levelTarget;
      }
      
      public function setFightCount(param1:int) : void
      {
         this.m_fightCount = param1;
      }
      
      public function setLastActivated(param1:int) : void
      {
         this.m_lastActivated = param1;
      }
      
      public function setLastInitWeek(param1:int) : void
      {
         this.m_lastInitWeek = param1;
      }
      
      public function updateLastActivatedTime(param1:int) : void
      {
         this.setLastActivated(param1);
         this.setFightCount(0);
         this.setLevelTarget(ZGlobal.player.level);
         if(this.checkWeeklyProgressionExpired())
         {
            TransactionManager.addTransaction(new TActivateFightMeter(param1,true));
         }
         else
         {
            TransactionManager.addTransaction(new TActivateFightMeter(param1,false));
         }
      }
      
      public function incrementfightCount() : void
      {
         if(this.m_fightCount < this.m_levelTarget)
         {
            this.m_fightCount += 1;
            StatsManager.count("fightmeter","fight","fightcount");
            this.checkEnergyReward(this.m_fightCount,this.m_levelTarget);
            if(this.m_fightCount == this.m_levelTarget)
            {
               PopupManager.instance.push(new FightMeterBragPopup());
            }
         }
      }
      
      private function checkEnergyReward(param1:int, param2:int) : void
      {
         var _loc4_:String = null;
         var _loc3_:int = this.getAmountEnergyReward(param2);
         if(_loc3_ > 0)
         {
            StatsManager.count("fightmeter","energy","earned",_loc3_.toString());
            if(ZGlobal.player.canAddItemToInventory(GameItem(ZGlobal.gameSettings.getItemByCode("EN9",GameItem))))
            {
               ZGlobal.player.addToInventory("EN9",_loc3_);
               _loc4_ = ZGameUtils.ZlocT("Items","energy_menuName");
               PlayerFeedbackManager.instance.displayToaster(ZGameUtils.ZlocT("Main","FeedbackResourcesGiftReceived",{
                  "amount":_loc3_,
                  "item":_loc4_
               }),null,true);
            }
         }
      }
      
      public function getAmountEnergyReward(param1:int) : int
      {
         var _loc11_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = this.getProgressionCount(ZGlobal.player.level);
         var _loc4_:String = this.getProgressionArrayString(ZGlobal.player.level);
         var _loc5_:Array = _loc4_.split(",");
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         while(_loc8_ < _loc3_)
         {
            _loc7_ += int(_loc5_[_loc8_]);
            _loc8_++;
         }
         var _loc9_:Number = param1 / _loc7_;
         var _loc10_:int = 0;
         while(_loc2_ < _loc3_)
         {
            _loc6_ += int(_loc5_[_loc2_]);
            if(this.m_fightCount == Math.ceil(_loc6_ * _loc9_))
            {
               return int((this.m_fightCount - Math.ceil(_loc10_ * _loc9_)) * 2);
            }
            _loc10_ = _loc6_;
            _loc2_++;
         }
         return 0;
      }
      
      public function getfightsPerDayCount() : int
      {
         return this.m_fightCount;
      }
      
      public function get endTime() : int
      {
         return this.m_lastActivated + 24 * 60 * 60;
      }
   }
}

