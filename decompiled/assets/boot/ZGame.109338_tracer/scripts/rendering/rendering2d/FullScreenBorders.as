package rendering.rendering2d
{
   import flash.display.Sprite;
   import zlabs.Zlab;
   
   public class FullScreenBorders
   {
      
      private static var LEFT:int = 0;
      
      private static var RIGHT:int = 1;
      
      private var m_borders:Array = null;
      
      private var m_parent:Sprite = null;
      
      private var m_width:int = 0;
      
      private var m_height:int = 0;
      
      public function FullScreenBorders(param1:Sprite, param2:int)
      {
         super();
         this.m_parent = param1;
         this.m_width = param2;
      }
      
      public function dispose() : void
      {
         this.removeBorders();
         this.m_parent = null;
      }
      
      public function addBorders() : void
      {
         this.removeBorders();
         this.m_borders = new Array();
         var _loc1_:Sprite = this.createBorder(LEFT);
         this.m_parent.addChild(_loc1_);
         this.m_borders.push(_loc1_);
         _loc1_ = this.createBorder(RIGHT);
         this.m_parent.addChild(_loc1_);
         this.m_borders.push(_loc1_);
      }
      
      protected function get width() : int
      {
         return this.m_width;
      }
      
      protected function createBorder(param1:uint) : Sprite
      {
         var _loc2_:Sprite = new Sprite();
         switch(param1)
         {
            case LEFT:
               _loc2_.graphics.beginFill(0);
               _loc2_.graphics.moveTo(0,0);
               _loc2_.graphics.lineTo(-1200,0);
               _loc2_.graphics.lineTo(-1200,Zlab.mainStage.stageHeight);
               _loc2_.graphics.lineTo(0,Zlab.mainStage.stageHeight);
               _loc2_.graphics.endFill();
               break;
            case RIGHT:
               _loc2_.graphics.beginFill(0);
               _loc2_.graphics.moveTo(this.m_width,0);
               _loc2_.graphics.lineTo(this.m_width + 1200,0);
               _loc2_.graphics.lineTo(this.m_width + 1200,Zlab.mainStage.stageHeight);
               _loc2_.graphics.lineTo(this.m_width,Zlab.mainStage.stageHeight);
               _loc2_.graphics.endFill();
         }
         return _loc2_;
      }
      
      public function removeBorders() : void
      {
         var _loc1_:Sprite = null;
         if(null != this.m_borders)
         {
            for each(_loc1_ in this.m_borders)
            {
               this.m_parent.removeChild(_loc1_);
            }
            this.m_borders = null;
         }
      }
   }
}

