package core.gamemode.battle.consumable
{
   import core.gamemode.battle.BattleObject;
   import core.gameobjects.ConsumableItem;
   
   public class BattleConsumable
   {
      
      private var m_effect:IConsumableEffect = null;
      
      public function BattleConsumable(param1:ConsumableItem, param2:BattleObject, param3:Boolean)
      {
         super();
         this.createEffect(param1,param2,param3);
      }
      
      public function update() : Boolean
      {
         if(this.m_effect.update())
         {
            return true;
         }
         return false;
      }
      
      public function dispose() : void
      {
         this.m_effect.dispose();
         this.m_effect = null;
      }
      
      protected function get ally() : Boolean
      {
         return false;
      }
      
      protected function createEffect(param1:ConsumableItem, param2:BattleObject, param3:Boolean) : void
      {
         var _loc4_:Boolean = true;
         if(param3)
         {
            if(!param1.targetsEnemy)
            {
               _loc4_ = false;
            }
         }
         else if(param1.targetsEnemy)
         {
            _loc4_ = false;
         }
         if(_loc4_)
         {
            if(Boolean(param1.diWeapon) || Boolean(param1.dotWeapon))
            {
               this.m_effect = new ApplyWeaponToEnemyFleet(param1,param2,this.ally);
            }
            else
            {
               this.m_effect = new AddToEnemyFleet(param1,this.ally);
            }
         }
         else if(Boolean(param1.diWeapon) || Boolean(param1.dotWeapon))
         {
            this.m_effect = new ApplyWeaponToPlayerFleet(param1,param2,this.ally);
         }
         else
         {
            this.m_effect = new AddToPlayerFleet(param1,this.ally);
         }
         this.m_effect.init(param3);
      }
   }
}

