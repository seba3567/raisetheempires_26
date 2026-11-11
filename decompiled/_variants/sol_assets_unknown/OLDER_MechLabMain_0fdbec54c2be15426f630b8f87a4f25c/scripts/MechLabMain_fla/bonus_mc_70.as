package MechLabMain_fla
{
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol392")]
   public dynamic class bonus_mc_70 extends MovieClip
   {
      
      public var bonus_tf:TextField;
      
      public var icon:UILoader;
      
      public function bonus_mc_70()
      {
         super();
         addFrameScript(0,this.frame1,1,this.frame2);
      }
      
      internal function frame2() : *
      {
         stop();
      }
      
      internal function frame1() : *
      {
         stop();
      }
   }
}

