package BattleMap02_fla
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol94")]
   public dynamic class FlagWave_14 extends MovieClip
   {
      
      public var shadow:MovieClip;
      
      public var flag:MovieClip;
      
      public var randomInt:*;
      
      public function FlagWave_14()
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

