package StrategicMap_v3_fla
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol162")]
   public dynamic class FlagWave_16 extends MovieClip
   {
      
      public var shadow:MovieClip;
      
      public var flag:MovieClip;
      
      public var randomInt:*;
      
      public function FlagWave_16()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      internal function frame1() : *
      {
         this.randomInt = Math.floor(Math.random() * 15);
         this.flag.gotoAndPlay(this.randomInt);
         this.shadow.gotoAndPlay(this.randomInt);
      }
   }
}

