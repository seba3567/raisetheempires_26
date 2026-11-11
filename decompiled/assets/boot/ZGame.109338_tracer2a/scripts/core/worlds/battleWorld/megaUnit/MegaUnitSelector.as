package core.worlds.battleWorld.megaUnit
{
   import core.worlds.battleWorld.BattleUnit;
   import core.worlds.battleWorld.BattleUnitSelector;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   
   public class MegaUnitSelector extends BattleUnitSelector
   {
      
      public function MegaUnitSelector(param1:Sprite)
      {
         super(param1);
      }
      
      override protected function isValid(param1:Object, param2:Point) : Boolean
      {
         var _loc4_:Point = null;
         var _loc3_:BattleUnit = this.getBattleUnit(param1);
         if(_loc3_)
         {
            _loc4_ = _loc3_.image.globalToLocal(param2);
            return _loc3_.hitTest(_loc4_);
         }
         return _loc3_ != null;
      }
      
      override protected function dispatcher(param1:Object) : EventDispatcher
      {
         var _loc2_:BattleUnit = this.getBattleUnit(param1);
         if(Boolean(_loc2_) && !_loc2_.dead)
         {
            return _loc2_.art;
         }
         return null;
      }
      
      private function getBattleUnit(param1:Object) : BattleUnit
      {
         var _loc2_:DisplayObject = param1 as DisplayObject;
         if(_loc2_)
         {
            while(_loc2_)
            {
               if(_loc2_ is EnemyMegaUnit || _loc2_ is PlayerMegaUnit)
               {
                  return _loc2_ as BattleUnit;
               }
               _loc2_ = _loc2_.parent;
            }
         }
         return null;
      }
   }
}

