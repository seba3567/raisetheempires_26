package core.gamemode.battle.combatchain
{
   public class HitValue
   {
      
      private var m_critical:Number = 0;
      
      private var m_direct:Number = 0;
      
      public function HitValue(param1:Number, param2:Number)
      {
         super();
         this.m_critical = param1;
         this.m_direct = param2;
      }
      
      public function get critical() : Number
      {
         return this.m_critical;
      }
      
      public function get direct() : Number
      {
         return this.m_direct;
      }
   }
}

