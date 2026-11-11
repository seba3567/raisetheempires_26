package PU_Requests_fla
{
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol32")]
   public dynamic class card_mc_5 extends MovieClip
   {
      
      public var name_tf:TextField;
      
      public var dogLogo_mc:MovieClip;
      
      public var picture:UILoader;
      
      public var epLogo_mc:MovieClip;
      
      public function card_mc_5()
      {
         super();
         addFrameScript(0,this.frame1,1,this.frame2,2,this.frame3,3,this.frame4);
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame2() : *
      {
         stop();
      }
      
      internal function frame4() : *
      {
         stop();
      }
      
      internal function frame3() : *
      {
         stop();
      }
   }
}

