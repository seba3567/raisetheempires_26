package core.gamemode.battle.consumable.suggester
{
   import core.ZGlobal;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleObject;
   import core.gamemode.battle.consumable.suggester.algorithms.AccuracySuggestionAlgorithm;
   import core.gamemode.battle.consumable.suggester.algorithms.AirStrikeSuggestionAlgorithm;
   import core.gamemode.battle.consumable.suggester.algorithms.DisplayPopupAlgorithm;
   import core.gamemode.battle.consumable.suggester.algorithms.EvasionSuggestionAlgorithm;
   import core.gamemode.battle.consumable.suggester.algorithms.ExplosiveAmmoSuggestionAlgorithm;
   import core.gamemode.battle.consumable.suggester.algorithms.FieldRepairsSuggestionAlgorithm;
   import core.gamemode.battle.consumable.suggester.algorithms.HunkerDownSuggestionAlgorithm;
   import core.gamemode.battle.consumable.suggester.algorithms.MissileAttackSuggestionAlgorithm;
   import core.gamemode.battle.consumable.suggester.algorithms.PoisonGasSuggestionAlgorithm;
   import core.gamemode.battle.consumable.suggester.algorithms.TacticalNukeAlgorithm;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.Fleet;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   
   public class ConsumableSuggester
   {
      
      public static const CONSUMABLE_SUGGESTED:String = "consumableSuggested";
      
      private var m_consumableSugguestionAlgorithms:Vector.<AbstractConsumableSuggestionAlgorithm>;
      
      private var weightedConsumableSelection:Vector.<AbstractConsumableSuggestionAlgorithm>;
      
      private var m_displayPopupAlgorithm:DisplayPopupAlgorithm;
      
      private var m_previousSuggestedConsumableCode:String;
      
      public function ConsumableSuggester()
      {
         super();
         this.initVars();
         this.initEvents();
      }
      
      public function updateFleets(param1:Fleet, param2:Fleet) : void
      {
         var _loc3_:AbstractConsumableSuggestionAlgorithm = null;
         if(this.m_displayPopupAlgorithm != null)
         {
            if(param1 != null && param1.units != null && param1.units.length != 0)
            {
               this.m_displayPopupAlgorithm.playerFleet = param1;
            }
            if(param2 != null && param2.units != null && param2.units.length != 0)
            {
               this.m_displayPopupAlgorithm.enemyFleet = param2;
            }
         }
         for each(_loc3_ in this.m_consumableSugguestionAlgorithms)
         {
            if(param1 != null && param1.units != null && param1.units.length != 0)
            {
               _loc3_.playerFleet = param1;
            }
            if(param2 != null && param2.units != null && param2.units.length != 0)
            {
               _loc3_.enemyFleet = param2;
            }
         }
      }
      
      private function initVars() : void
      {
         this.m_consumableSugguestionAlgorithms = new Vector.<AbstractConsumableSuggestionAlgorithm>();
      }
      
      private function initEvents() : void
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_POWER_UP_PROMPT) == ExperimentsManager.VARIANT_VALUE_POWER_UP_PROMPT_ENABLED_WITH_CRITICAL_HIT || ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_POWER_UP_PROMPT) == ExperimentsManager.VARIANT_VALUE_POWER_UP_PROMPT_ENABLED_WITH_CRITICAL_HIT_EVERY_OTHER_TURN)
         {
            BattleDispatcher.instance.addEventListener(BattleDispatcher.UNIT_HIT,this.onUnitHit,false,0,true);
         }
         BattleDispatcher.instance.addEventListener(BattleDispatcher.UNIT_KILLED,this.onUnitKilled,false,0,true);
      }
      
      private function killEvents() : void
      {
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.UNIT_HIT,this.onUnitHit);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.UNIT_KILLED,this.onUnitKilled);
      }
      
      private function onUnitHit(param1:WorldEvent) : void
      {
         if(Boolean(param1.eventData && param1.eventData.critical != null && param1.eventData.critial == true) && Boolean(param1.eventData.target != null) && (param1.eventData.target as BattleObject).fleet.isOwnedByPlayer(ZGlobal.player.uid))
         {
            this.forcePopupDisplay();
         }
      }
      
      private function onUnitKilled(param1:WorldEvent) : void
      {
         if(Boolean(param1.eventData) && Boolean(param1.eventData.target != null) && (param1.eventData.target as BattleObject).fleet.isOwnedByPlayer(ZGlobal.player.uid))
         {
            this.forcePopupDisplay();
         }
      }
      
      private function forcePopupDisplay() : void
      {
         this.m_displayPopupAlgorithm.forceDisplay = true;
      }
      
      public function setupStandardSuggestionAlgorithms(param1:Fleet, param2:Fleet) : void
      {
         this.m_displayPopupAlgorithm = new DisplayPopupAlgorithm(param1,param2);
         this.addConsumableSuggestionAlgorithm(new FieldRepairsSuggestionAlgorithm(param1));
         this.addConsumableSuggestionAlgorithm(new AccuracySuggestionAlgorithm(param1,param2));
         this.addConsumableSuggestionAlgorithm(new ExplosiveAmmoSuggestionAlgorithm(param1,param2));
         this.addConsumableSuggestionAlgorithm(new AirStrikeSuggestionAlgorithm(param2));
         this.addConsumableSuggestionAlgorithm(new MissileAttackSuggestionAlgorithm(param2));
         this.addConsumableSuggestionAlgorithm(new HunkerDownSuggestionAlgorithm(param1,param2));
         this.addConsumableSuggestionAlgorithm(new EvasionSuggestionAlgorithm(param1,param2));
         this.addConsumableSuggestionAlgorithm(new PoisonGasSuggestionAlgorithm(param2));
         this.addConsumableSuggestionAlgorithm(new TacticalNukeAlgorithm(param1,param2));
      }
      
      public function addConsumableSuggestionAlgorithmAt(param1:AbstractConsumableSuggestionAlgorithm, param2:int, param3:Boolean = false) : void
      {
         if(this.m_consumableSugguestionAlgorithms != null)
         {
            if(param3 == true)
            {
               param2 = Math.max(0,Math.min(this.m_consumableSugguestionAlgorithms.length,param2));
            }
            if(param2 >= 0 && param2 <= this.m_consumableSugguestionAlgorithms.length)
            {
               this.m_consumableSugguestionAlgorithms.splice(param2,0,param1);
            }
         }
      }
      
      public function addConsumableSuggestionAlgorithm(param1:AbstractConsumableSuggestionAlgorithm) : void
      {
         this.addConsumableSuggestionAlgorithmAt(param1,int.MAX_VALUE,true);
      }
      
      public function removeConsumableSuggestionAlgorithm(param1:AbstractConsumableSuggestionAlgorithm, param2:Boolean = false) : void
      {
         if(this.m_consumableSugguestionAlgorithms != null && this.m_consumableSugguestionAlgorithms.indexOf(param1) != -1)
         {
            this.m_consumableSugguestionAlgorithms.splice(this.m_consumableSugguestionAlgorithms.indexOf(param1),1);
         }
         else if(param2 == true)
         {
            throw new Error("Could not find Consumable Suggestion Algorithm to remove");
         }
      }
      
      public function suggestConsumable() : IConsumableSuggestion
      {
         var _loc4_:ConsumableItem = null;
         var _loc5_:AbstractConsumableSuggestionAlgorithm = null;
         var _loc6_:int = 0;
         var _loc1_:IConsumableSuggestion = null;
         var _loc2_:Vector.<AbstractConsumableSuggestionAlgorithm> = new Vector.<AbstractConsumableSuggestionAlgorithm>();
         var _loc3_:String = "";
         _loc6_ = 0;
         while(_loc6_ < this.m_consumableSugguestionAlgorithms.length)
         {
            _loc5_ = this.m_consumableSugguestionAlgorithms[_loc6_];
            _loc5_.calculateSuggestionWeight();
            if(_loc5_.weight > 0 && _loc5_.consumableCode != this.m_previousSuggestedConsumableCode && _loc5_.consumableCode != AbstractConsumableSuggestionAlgorithm.NO_CONSUMABLE_SUGGESTABLE)
            {
               if(_loc5_.forceIfSuggested == true)
               {
                  _loc1_ = _loc5_;
                  break;
               }
               _loc2_.push(_loc5_);
               _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc5_.consumableCode,ConsumableItem) as ConsumableItem;
               _loc3_ += _loc4_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME) + ", ";
            }
            _loc6_++;
         }
         if(this.m_previousSuggestedConsumableCode)
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(this.m_previousSuggestedConsumableCode,ConsumableItem) as ConsumableItem;
            _loc3_ += " and the previous suggestion was: " + _loc4_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME);
         }
         Logger.info(this,"SuggestConsumable","List of all possible suggestions: " + _loc3_);
         this.m_displayPopupAlgorithm.calculateSuggestionWeight();
         if(_loc1_ == null && this.m_displayPopupAlgorithm.weight != 0)
         {
            _loc1_ = this.selectWeightedConsumable(_loc2_);
         }
         if(_loc1_ == null)
         {
            this.m_previousSuggestedConsumableCode = null;
         }
         else
         {
            this.m_previousSuggestedConsumableCode = _loc1_.consumableCode;
         }
         return _loc1_;
      }
      
      private function selectWeightedConsumable(param1:Vector.<AbstractConsumableSuggestionAlgorithm>) : IConsumableSuggestion
      {
         var _loc4_:int = 0;
         var _loc2_:IConsumableSuggestion = null;
         var _loc3_:Number = 0;
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc3_ += param1[_loc4_].weight;
            _loc4_++;
         }
         var _loc5_:Number = Math.random() * _loc3_;
         var _loc6_:Number = 0;
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc6_ += param1[_loc4_].weight;
            if(_loc5_ < _loc6_)
            {
               _loc2_ = param1[_loc4_];
               break;
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function dispose() : void
      {
         var _loc1_:AbstractConsumableSuggestionAlgorithm = null;
         this.m_displayPopupAlgorithm.dispose();
         this.m_displayPopupAlgorithm = null;
         for each(_loc1_ in this.m_consumableSugguestionAlgorithms)
         {
            _loc1_.dispose();
         }
         this.m_consumableSugguestionAlgorithms = new Vector.<AbstractConsumableSuggestionAlgorithm>();
         this.killEvents();
      }
   }
}

