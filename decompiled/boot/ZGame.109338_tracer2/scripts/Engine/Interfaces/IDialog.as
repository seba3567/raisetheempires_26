package Engine.Interfaces
{
   import flash.display.DisplayObject;
   
   public interface IDialog
   {
      
      function getDisplayObject() : DisplayObject;
      
      function show() : void;
      
      function hide() : void;
      
      function close() : void;
      
      function enable() : void;
      
      function disable() : void;
      
      function setUnique(param1:String) : void;
      
      function get unique() : Boolean;
      
      function get dialogName() : String;
   }
}

