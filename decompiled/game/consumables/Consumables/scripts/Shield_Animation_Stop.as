package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol94")]
   public dynamic class Shield_Animation_Stop extends MovieClip
   {
      
      public function Shield_Animation_Stop()
      {
         super();
         addFrameScript(50,this.frame51);
      }
      
      internal function frame51() : *
      {
         stop();
      }
   }
}

