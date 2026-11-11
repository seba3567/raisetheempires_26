package core.worlds.strategicWorld.swf.version2
{
   public interface ISelectableRegion
   {
      
      function hitTest() : Boolean;
      
      function click() : void;
      
      function set focus(param1:Boolean) : void;
      
      function get code() : String;
   }
}

