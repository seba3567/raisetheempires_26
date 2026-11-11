package rendering.rendering2d
{
   import flash.display.Sprite;
   import zlabs.Zlab;
   
   public class FullScreenHorizontalBorders extends FullScreenBorders
   {
      
      private var m_scale:Number = 1;
      
      public function FullScreenHorizontalBorders(param1:Sprite, param2:int)
      {
         super(param1,param2);
      }
      
      public function set scale(param1:Number) : void
      {
         this.m_scale = param1;
      }
      
      override protected function createBorder(param1:uint) : Sprite
      {
         var _loc2_:Sprite = new Sprite();
         if(param1 == 0)
         {
            _loc2_.graphics.beginFill(0);
            _loc2_.graphics.moveTo(0,0);
            _loc2_.graphics.lineTo(0,-1200);
            _loc2_.graphics.lineTo(Zlab.mainStage.stageWidth * this.m_scale,-1200);
            _loc2_.graphics.lineTo(Zlab.mainStage.stageWidth * this.m_scale,0);
            _loc2_.graphics.endFill();
         }
         else
         {
            _loc2_.graphics.beginFill(0);
            _loc2_.graphics.moveTo(0,width);
            _loc2_.graphics.lineTo(0,width + 1200);
            _loc2_.graphics.lineTo(Zlab.mainStage.stageWidth * this.m_scale,width + 1200);
            _loc2_.graphics.lineTo(Zlab.mainStage.stageWidth * this.m_scale,width);
            _loc2_.graphics.endFill();
         }
         return _loc2_;
      }
   }
}

