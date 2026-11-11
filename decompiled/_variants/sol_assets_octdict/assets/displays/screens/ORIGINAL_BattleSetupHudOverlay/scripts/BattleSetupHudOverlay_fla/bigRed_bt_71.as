package BattleSetupHudOverlay_fla
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol284")]
   public dynamic class bigRed_bt_71 extends MovieClip
   {
      
      public var button_mc:MovieClip;
      
      public var generic_tf:TextField;
      
      public function bigRed_bt_71()
      {
         super();
         addFrameScript(0,this.frame1,1,this.frame2,2,this.frame3,3,this.frame4);
      }
      
      internal function frame1() : *
      {
         this.generic_tf.visible = false;
         stop();
      }
      
      internal function frame2() : *
      {
         this.generic_tf.visible = true;
         stop();
      }
      
      internal function frame4() : *
      {
         this.generic_tf.visible = false;
         stop();
      }
      
      internal function frame3() : *
      {
         this.generic_tf.visible = false;
         stop();
      }
   }
}

