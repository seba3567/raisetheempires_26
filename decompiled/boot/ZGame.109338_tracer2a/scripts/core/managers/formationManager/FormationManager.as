package core.managers.formationManager
{
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import zlabs.utils.StringUtils;
   
   public class FormationManager
   {
      
      public static var instance:FormationManager = new FormationManager();
      
      private var m_formations:Dictionary = null;
      
      public function FormationManager()
      {
         super();
      }
      
      public function initFromSettings(param1:XMLList) : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         this.m_formations = new Dictionary();
         for each(_loc2_ in param1)
         {
            _loc3_ = _loc2_.@size.toString();
            _loc4_ = new Array();
            for each(_loc5_ in _loc2_.p)
            {
               _loc4_.push(StringUtils.parsePoint(_loc5_));
            }
            this.m_formations[_loc3_] = _loc4_;
         }
      }
      
      public function getLocalOffset(param1:String, param2:int, param3:Number) : Point
      {
         if(this.m_formations[param1] == null)
         {
            throw new Error("Formation Manager::getLocalOffset no entry for size: " + param1);
         }
         if(param2 >= this.m_formations[param1].length)
         {
            throw new Error("Formation Manager::getLocalOffset index too large: " + param2 + " for size: " + param1);
         }
         var _loc4_:Point = new Point(this.m_formations[param1][param2].x,this.m_formations[param1][param2].y);
         if(param3 != 1)
         {
            _loc4_.x *= param3;
            _loc4_.y *= param3;
         }
         return _loc4_;
      }
   }
}

