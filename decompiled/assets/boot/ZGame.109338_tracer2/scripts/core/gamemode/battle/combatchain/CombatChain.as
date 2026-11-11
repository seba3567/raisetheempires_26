package core.gamemode.battle.combatchain
{
   import core.ZGlobal;
   import core.gamemode.battle.BattleObject;
   import flash.utils.Dictionary;
   import zlabs.debug.Logger;
   
   public class CombatChain
   {
      
      public static const POOR:uint = 0;
      
      public static const GOOD:uint = 1;
      
      public static const GREAT:uint = 2;
      
      private var m_combatChain:Dictionary = null;
      
      private var m_hitValues:Dictionary = null;
      
      private var m_chanceValues:Dictionary = null;
      
      public function CombatChain()
      {
         super();
         this.init();
      }
      
      public function dispose() : void
      {
         this.m_combatChain = null;
      }
      
      public function GetAttackingHitValue(param1:BattleObject, param2:BattleObject) : HitValue
      {
         var _loc3_:String = this.getHitValue(param1,param2);
         return this.m_hitValues[_loc3_];
      }
      
      public function GetAttackingHitChance(param1:BattleObject, param2:BattleObject) : uint
      {
         var _loc3_:String = this.getHitValue(param1,param2);
         return this.m_chanceValues[_loc3_];
      }
      
      private function getChain(param1:BattleObject) : Chain
      {
         var _loc2_:String = null;
         for(_loc2_ in this.m_combatChain)
         {
            if(param1.unitItem.hasType(_loc2_))
            {
               return this.m_combatChain[_loc2_];
            }
         }
         Logger.error(this,"getChain","no type match found in combat chain for " + param1.unitItem.code);
         return null;
      }
      
      private function getHitValue(param1:BattleObject, param2:BattleObject) : String
      {
         var _loc3_:Chain = this.getChain(param1);
         if(null != _loc3_)
         {
            return _loc3_.getHitValue(param2);
         }
         return Chain.GOOD;
      }
      
      private function init() : void
      {
         var _loc5_:XML = null;
         var _loc6_:XML = null;
         var _loc7_:String = null;
         var _loc8_:Chain = null;
         var _loc9_:HitValue = null;
         this.m_combatChain = new Dictionary();
         this.m_hitValues = new Dictionary();
         this.m_chanceValues = new Dictionary();
         this.m_chanceValues[Chain.POOR] = POOR;
         this.m_chanceValues[Chain.GOOD] = GOOD;
         this.m_chanceValues[Chain.GREAT] = GREAT;
         var _loc1_:Array = null;
         var _loc2_:Array = null;
         var _loc3_:Array = null;
         var _loc4_:XMLList = ZGlobal.gameSettings.getXML().combatChain;
         for each(_loc5_ in _loc4_.chain)
         {
            _loc1_ = _loc5_.@type.toString().split(",");
            _loc2_ = _loc5_.@great.toString().split(",");
            _loc3_ = _loc5_.@poor.toString().split(",");
            for each(_loc7_ in _loc1_)
            {
               _loc8_ = new Chain();
               _loc8_.great = _loc2_;
               _loc8_.poor = _loc3_;
               this.m_combatChain[_loc7_] = _loc8_;
            }
         }
         _loc4_ = ZGlobal.gameSettings.getXML().combatHitValues;
         for each(_loc6_ in _loc4_.value)
         {
            _loc9_ = new HitValue(parseFloat(_loc6_.@critical),parseFloat(_loc6_.@direct));
            this.m_hitValues[_loc6_.@type.toString()] = _loc9_;
         }
      }
   }
}

