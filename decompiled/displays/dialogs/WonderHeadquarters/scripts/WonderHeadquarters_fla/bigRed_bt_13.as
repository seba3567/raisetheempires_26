package WonderHeadquarters_fla
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol37")]
   public dynamic class bigRed_bt_13 extends MovieClip
   {
      
      public var generic_tf:TextField;
      
      public var button_mc:MovieClip;
      
      public function bigRed_bt_13()
      {
         super();
         addFrameScript(0,this.frame1,1,this.frame2,2,this.frame3,3,this.frame4,4,this.frame5);
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
      
      internal function frame3() : *
      {
         this.generic_tf.visible = false;
         stop();
      }
      
      internal function frame4() : *
      {
         this.generic_tf.visible = false;
         stop();
      }
      
      internal function frame5() : *
      {
         this.generic_tf.visible = false;
         stop();
      }
   }
}

