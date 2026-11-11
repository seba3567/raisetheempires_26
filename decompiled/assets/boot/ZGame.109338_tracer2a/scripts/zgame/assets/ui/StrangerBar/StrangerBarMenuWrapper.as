package zgame.assets.ui.StrangerBar
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol1390")]
   public dynamic class StrangerBarMenuWrapper extends MovieClip
   {
      
      public var steam1:MovieClip;
      
      public var steam2:MovieClip;
      
      public var jets1:MovieClip;
      
      public var jets2:MovieClip;
      
      public var hud_mc:MovieClip;
      
      public function StrangerBarMenuWrapper()
      {
         super();
         addFrameScript(0,this.frame1,33,this.frame34,42,this.frame43,54,this.frame55,60,this.frame61,69,this.frame70,101,this.frame102);
      }
      
      internal function frame70() : *
      {
         this.jets1.gotoAndPlay(2);
      }
      
      internal function frame61() : *
      {
         this.steam1.gotoAndPlay(2);
      }
      
      internal function frame1() : *
      {
         this.steam1.mouseEnabled = false;
         this.steam2.mouseEnabled = false;
         this.jets1.mouseEnabled = false;
         this.jets2.mouseEnabled = false;
         stop();
      }
      
      internal function frame43() : *
      {
         this.jets1.gotoAndPlay(2);
      }
      
      internal function frame55() : *
      {
         stop();
      }
      
      internal function frame102() : *
      {
         stop();
      }
      
      internal function frame34() : *
      {
         this.steam1.gotoAndPlay(2);
      }
   }
}

