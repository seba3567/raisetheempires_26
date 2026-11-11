package PlayerStats_fla
{
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol97")]
   public dynamic class FightMeter_mc_23 extends MovieClip
   {
      
      public var title_tf:TextField;
      
      public var clock_mc:MovieClip;
      
      public var progressbar_mc:MovieClip;
      
      public var description_tf:TextField;
      
      public var icon:UILoader;
      
      public var description3_tf:TextField;
      
      public var description2_tf:TextField;
      
      public var starburst_mc:MovieClip;
      
      public function FightMeter_mc_23()
      {
         super();
         addFrameScript(125,this.frame126,126,this.frame127);
      }
      
      internal function frame126() : *
      {
         gotoAndPlay("minimized");
      }
      
      internal function frame127() : *
      {
         stop();
      }
   }
}

