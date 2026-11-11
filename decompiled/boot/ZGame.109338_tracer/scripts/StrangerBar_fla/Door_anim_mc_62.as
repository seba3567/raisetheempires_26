package StrangerBar_fla
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol1805")]
   public dynamic class Door_anim_mc_62 extends MovieClip
   {
      
      public var fight_bt:MovieClip;
      
      public var fight_mc:MovieClip;
      
      public var gray_mc:MovieClip;
      
      public var arrow_mc:MovieClip;
      
      public var num_mc:MovieClip;
      
      public var spin_mc:MovieClip;
      
      public var icon:MovieClip;
      
      public function Door_anim_mc_62()
      {
         super();
         addFrameScript(0,this.frame1,12,this.frame13,44,this.frame45,69,this.frame70);
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame70() : *
      {
         stop();
      }
      
      internal function frame45() : *
      {
         dispatchEvent(new Event("triggerNextCard"));
      }
      
      internal function frame13() : *
      {
         stop();
      }
   }
}

