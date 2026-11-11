package
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol23")]
   public dynamic class speedUpBub_mc extends MovieClip
   {
      
      public var bubble_mc:MovieClip;
      
      public var title_tf:TextField;
      
      public var generic_tf:TextField;
      
      public var info:MovieClip;
      
      public function speedUpBub_mc()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      internal function frame1() : *
      {
      }
   }
}

