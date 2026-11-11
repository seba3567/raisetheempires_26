package rendering.scroller
{
   import flash.geom.Rectangle;
   
   public class GridRect extends Rectangle
   {
      
      public var ID:String;
      
      public var isRendererd:Boolean = false;
      
      public var bitmap:ScrollPanel;
      
      public function GridRect(param1:Number = 0, param2:Number = 0, param3:Number = 0, param4:Number = 0)
      {
         super(param1,param2,param3,param4);
      }
      
      public function reset() : void
      {
         this.bitmap = null;
         this.isRendererd = false;
      }
      
      override public function clone() : Rectangle
      {
         return new GridRect(x,y,width,height);
      }
      
      public function dispose() : void
      {
         if(this.bitmap)
         {
            this.bitmap.dispose();
         }
         this.bitmap = null;
      }
   }
}

