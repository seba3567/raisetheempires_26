package zlabs.rendering.rendering2D.ui
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import zlabs.Zlab;
   
   public class SceneView extends Sprite implements IUITarget
   {
      
      private var _width:Number = 0;
      
      private var _height:Number = 0;
      
      public function SceneView()
      {
         super();
         if(Zlab.mainClass)
         {
            Zlab.mainClass.addChild(this);
            this.width = Zlab.mainStage.stage.stageWidth;
            this.height = Zlab.mainStage.stage.stageHeight;
            name = "SceneView";
         }
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
      }
      
      public function addDisplayObject(param1:DisplayObject) : void
      {
         addChild(param1);
      }
      
      public function clearDisplayObjects() : void
      {
         while(numChildren)
         {
            removeChildAt(0);
         }
      }
      
      public function removeDisplayObject(param1:DisplayObject) : void
      {
         removeChild(param1);
      }
      
      public function setDisplayObjectIndex(param1:DisplayObject, param2:int) : void
      {
         setChildIndex(param1,param2);
      }
   }
}

