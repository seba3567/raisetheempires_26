package displays.screens
{
   import flash.display.MovieClip;
   
   public interface RequestDialogCardInterface
   {
      
      function dispose() : void;
      
      function release() : void;
      
      function setCard(param1:MovieClip) : void;
      
      function get selected() : Boolean;
      
      function get visible() : Boolean;
   }
}

