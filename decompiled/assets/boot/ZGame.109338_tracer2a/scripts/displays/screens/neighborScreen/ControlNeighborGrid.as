package displays.screens.neighborScreen
{
   import flash.display.MovieClip;
   
   public class ControlNeighborGrid extends NeighborGrid
   {
      
      public function ControlNeighborGrid(param1:MovieClip, param2:Array, param3:Object)
      {
         super(param1,param2,param3);
      }
      
      override protected function addVarients(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(width > 0)
         {
            _loc2_ = int(param1.length);
            _loc3_ = width / 2;
            _loc4_ = Math.max(_loc2_,width);
            while(_loc3_ < _loc4_)
            {
               param1.splice(_loc3_,0,inviteNeighborToken());
               _loc3_ += width;
            }
         }
      }
      
      public function startRotation() : void
      {
      }
   }
}

