package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol2027")]
   public dynamic class BattlePromptV2 extends MovieClip
   {
      
      public var pick:MovieClip;
      
      public var panel:MovieClip;
      
      public function BattlePromptV2()
      {
         super();
         addFrameScript(0,this.frame1,3,this.frame4,11,this.frame12,21,this.frame22,29,this.frame30);
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame4() : *
      {
         stop();
      }
      
      internal function frame12() : *
      {
         gotoAndStop(1);
      }
      
      internal function frame22() : *
      {
         stop();
      }
      
      internal function frame30() : *
      {
         gotoAndStop(1);
      }
   }
}

