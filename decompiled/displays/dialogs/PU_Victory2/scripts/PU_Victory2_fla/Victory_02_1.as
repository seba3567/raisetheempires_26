package PU_Victory2_fla
{
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol118")]
   public dynamic class Victory_02_1 extends MovieClip
   {
      
      public var bonusInd:MovieClip;
      
      public var units_even:MovieClip;
      
      public var title02_tf:TextField;
      
      public var speechBubble_mc:MovieClip;
      
      public var bg_losses:MovieClip;
      
      public var message_tf:TextField;
      
      public var bg_flawless:MovieClip;
      
      public var exit_bt:SimpleButton;
      
      public var rewards_odd:MovieClip;
      
      public var rewards_even:MovieClip;
      
      public var title01_tf:TextField;
      
      public var generic_tf:TextField;
      
      public var background_mc:MovieClip;
      
      public var emp_bt:MovieClip;
      
      public var units_odd:MovieClip;
      
      public var orangeButton_01:MovieClip;
      
      public var discount_tf:TextField;
      
      public var panel_mc:MovieClip;
      
      public var clipAnchor_mc:MovieClip;
      
      public var title_tf:TextField;
      
      public var scarlett_mc:MovieClip;
      
      public function Victory_02_1()
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

