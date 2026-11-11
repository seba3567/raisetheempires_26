package PU_SlotMachine_fla
{
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol123")]
   public dynamic class slotMachine_mc_1 extends MovieClip
   {
      
      public var win_mc:MovieClip;
      
      public var marquee:MovieClip;
      
      public var background_mc:MovieClip;
      
      public var message_tf:TextField;
      
      public var exit_bt:SimpleButton;
      
      public var share_mc:MovieClip;
      
      public var title_tf:TextField;
      
      public var slot1:MovieClip;
      
      public var spinBtns_mc:MovieClip;
      
      public function slotMachine_mc_1()
      {
         super();
         addFrameScript(0,this.frame1,49,this.frame50,79,this.frame80);
      }
      
      internal function frame80() : *
      {
         stop();
      }
      
      internal function frame50() : *
      {
         stop();
      }
      
      internal function frame1() : *
      {
         stop();
      }
   }
}

