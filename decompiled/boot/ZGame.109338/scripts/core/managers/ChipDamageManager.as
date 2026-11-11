package core.managers
{
   import core.gamemode.battle.BattleObject;
   import core.gameobjects.ConsumableItem;
   import core.views.ViewManager;
   import core.worlds.battleWorld.BattleRendererComponent;
   import core.worlds.battleWorld.BattleSide;
   import core.worlds.battleWorld.BattleWorld;
   
   public class ChipDamageManager
   {
      
      public static var instance:ChipDamageManager = new ChipDamageManager();
      
      private var m_renderComponent:BattleRendererComponent;
      
      private var m_battleSide:BattleSide;
      
      private var m_numberOfUnits:Number;
      
      public function ChipDamageManager()
      {
         super();
         this.m_renderComponent = BattleRendererComponent(ViewManager.instance.getComponentFromView(BattleWorld.ID,BattleRendererComponent));
         this.m_battleSide = this.m_renderComponent.getEnemySide();
         this.m_numberOfUnits = this.m_battleSide.getNumberofUnits();
      }
      
      public function isAdjacent(param1:Number, param2:Number, param3:Number = 0) : Boolean
      {
         this.m_renderComponent = BattleRendererComponent(ViewManager.instance.getComponentFromView(BattleWorld.ID,BattleRendererComponent));
         this.m_battleSide = this.m_renderComponent.getEnemySide();
         this.m_numberOfUnits = this.m_battleSide.getNumberofUnits();
         if(this.uniqueNumber(param2,param1) > 0)
         {
            return true;
         }
         return false;
      }
      
      private function uniqueNumber(param1:Number, param2:Number) : Number
      {
         if(param1 < 0 || param2 < 0 || param1 == param2)
         {
            return 0;
         }
         switch(this.m_numberOfUnits)
         {
            case 1:
               return 0;
            case 2:
               return 4;
            case 3:
               if(param1 == 0 || param1 == 2)
               {
                  if(param2 == 1)
                  {
                     return 4;
                  }
                  if(param2 == 0 || param2 == 2)
                  {
                     return 3;
                  }
               }
               if(param1 == 1)
               {
                  if(param2 < param1)
                  {
                     return 4;
                  }
                  return 3;
               }
               return 0;
               break;
            case 4:
               if(param1 == 0)
               {
                  if(param2 == 1)
                  {
                     return 4;
                  }
                  return 0;
               }
               if(param1 - param2 == 1)
               {
                  return 4;
               }
               if(param1 - param2 == -1)
               {
                  return 3;
               }
               return 0;
               break;
            case 5:
               switch(param1)
               {
                  case 0:
                     if(param2 == 1)
                     {
                        return 4;
                     }
                     if(param2 == 2)
                     {
                        return 3;
                     }
                     return 0;
                     break;
                  case 1:
                     if(param2 == 0)
                     {
                        return 4;
                     }
                     if(param2 == 2)
                     {
                        return 3;
                     }
                     if(param2 == 3)
                     {
                        return 2;
                     }
                     return 0;
                     break;
                  case 2:
                     switch(param2)
                     {
                        case 0:
                           return 4;
                        case 1:
                           return 3;
                        case 3:
                           return 2;
                        case 4:
                           return 1;
                        default:
                           return 0;
                     }
                     break;
                  case 3:
                     if(param2 == 1)
                     {
                        return 4;
                     }
                     if(param2 == 2)
                     {
                        return 3;
                     }
                     if(param2 == 4)
                     {
                        return 2;
                     }
                     return 0;
                     break;
                  case 4:
                     if(param2 == 3)
                     {
                        return 4;
                     }
                     if(param2 == 2)
                     {
                        return 3;
                     }
                     return 0;
               }
         }
         return 0;
      }
      
      public function getDamage(param1:BattleObject, param2:BattleObject, param3:ConsumableItem) : Number
      {
         this.m_renderComponent = BattleRendererComponent(ViewManager.instance.getComponentFromView(BattleWorld.ID,BattleRendererComponent));
         this.m_battleSide = this.m_renderComponent.getEnemySide();
         this.m_numberOfUnits = this.m_battleSide.getNumberofUnits();
         var _loc4_:int = this.m_battleSide.getUnitIndex(param1);
         var _loc5_:int = this.m_battleSide.getUnitIndex(param2);
         var _loc6_:Number = param3.chipDamageFactor;
         var _loc7_:Number = this.uniqueNumber(_loc4_,_loc5_);
         var _loc8_:Number = _loc7_ * _loc6_ * param3.di / 100;
         return Math.ceil(_loc8_);
      }
   }
}

