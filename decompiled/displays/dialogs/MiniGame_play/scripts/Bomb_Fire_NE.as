package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol24")]
   public dynamic class Bomb_Fire_NE extends MovieClip
   {
      
      public function Bomb_Fire_NE()
      {
         super();
         addFrameScript(0,this.frame1,181,this.frame182);
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame182() : *
      {
         stop();
      }
   }
}

