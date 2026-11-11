package core.worlds.strategicWorld.swf.version2
{
   import flash.display.MovieClip;
   
   public interface IStrategicScope
   {
      
      function get clip() : MovieClip;
      
      function get code() : String;
      
      function get home() : Boolean;
   }
}

