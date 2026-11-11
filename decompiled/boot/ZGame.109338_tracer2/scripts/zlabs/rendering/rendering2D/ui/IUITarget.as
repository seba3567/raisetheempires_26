package zlabs.rendering.rendering2D.ui
{
   import flash.display.DisplayObject;
   import flash.events.IEventDispatcher;
   
   public interface IUITarget extends IEventDispatcher
   {
      
      function addDisplayObject(param1:DisplayObject) : void;
      
      function clearDisplayObjects() : void;
      
      function removeDisplayObject(param1:DisplayObject) : void;
      
      function setDisplayObjectIndex(param1:DisplayObject, param2:int) : void;
      
      function get width() : Number;
      
      function set width(param1:Number) : void;
      
      function get height() : Number;
      
      function set height(param1:Number) : void;
      
      function get x() : Number;
      
      function get y() : Number;
   }
}

