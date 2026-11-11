package PU_Victory_fla
{
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol90")]
   public dynamic class Victory_01_28 extends MovieClip
   {
      
      public var bonusInd:MovieClip;
      
      public var popupBox_tf:TextField;
      
      public var title_tf:TextField;
      
      public var alliesEven:MovieClip;
      
      public var alliesOdd:MovieClip;
      
      public var exit_bt:SimpleButton;
      
      public var rewards_odd:MovieClip;
      
      public var rewards_even:MovieClip;
      
      public var background_mc:MovieClip;
      
      public var title01_tf:TextField;
      
      public var generic_tf:TextField;
      
      public var orangeButton_01:MovieClip;
      
      public var clipAnchor_mc:MovieClip;
      
      public var panel_mc:MovieClip;
      
      public var scarlett_mc:MovieClip;
      
      public var title02_tf:TextField;
      
      public function Victory_01_28()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      internal function frame1() : *
      {
         this.title_tf.autoSize = "center";
      }
   }
}

