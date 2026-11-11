package core.gamemode.battle.combatchain
{
   import core.gamemode.battle.BattleObject;
   
   public class Chain
   {
      
      public static const POOR:String = "poor";
      
      public static const GOOD:String = "good";
      
      public static const GREAT:String = "great";
      
      private var m_great:Array = new Array();
      
      private var m_poor:Array = new Array();
      
      public function Chain()
      {
         super();
      }
      
      public function getHitValue(param1:BattleObject) : String
      {
         if(this.isIn(this.m_poor,param1))
         {
            return POOR;
         }
         if(this.isIn(this.m_great,param1))
         {
            return GREAT;
         }
         return GOOD;
      }
      
      public function get great() : Array
      {
         return this.m_great;
      }
      
      public function set great(param1:Array) : void
      {
         this.m_great = param1;
      }
      
      public function get poor() : Array
      {
         return this.m_poor;
      }
      
      public function set poor(param1:Array) : void
      {
         this.m_poor = param1;
      }
      
      private function isIn(param1:Array, param2:BattleObject) : Boolean
      {
         var _loc3_:String = null;
         for each(_loc3_ in param1)
         {
            if(param2.unitItem.hasType(_loc3_))
            {
               return true;
            }
         }
         return false;
      }
   }
}

