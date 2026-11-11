package MOTD2_fla
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol164")]
   public dynamic class message_panel_anim_64 extends MovieClip
   {
      
      public var panel_mc:MovieClip;
      
      public function message_panel_anim_64()
      {
         super();
         addFrameScript(0,this.frame1,15,this.frame16,31,this.frame32);
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame16() : *
      {
         stop();
         dispatchEvent(new Event("OPENNED"));
      }
      
      internal function frame32() : *
      {
         dispatchEvent(new Event("CLOSED"));
      }
   }
}

