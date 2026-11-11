package core.entities
{
   import core.gameobjects.GameItem;
   import flash.display.DisplayObjectContainer;
   
   public interface IDynamicProgressBar
   {
      
      function set referenceItem(param1:String) : void;
      
      function set ownerGameItem(param1:GameItem) : void;
      
      function setPosition(param1:Number, param2:Number) : void;
      
      function updateProgressBarPercentage(param1:String, param2:Number = 0) : void;
      
      function get referenceItem() : String;
      
      function get displaysOverUI() : Boolean;
      
      function get UIDisplayOffsetX() : Number;
      
      function get UIDisplayOffsetY() : Number;
      
      function get parent() : DisplayObjectContainer;
      
      function set scaleX(param1:Number) : void;
      
      function set scaleY(param1:Number) : void;
      
      function set visible(param1:Boolean) : void;
      
      function set x(param1:Number) : void;
      
      function set y(param1:Number) : void;
      
      function get x() : Number;
      
      function get y() : Number;
   }
}

