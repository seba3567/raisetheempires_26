package Energon_PartsGather_fla
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol42")]
   public dynamic class Lightning_12 extends MovieClip
   {
      
      public var vNum:int;
      
      public var vClips:int;
      
      public var vRand:int;
      
      public var vPlay:int;
      
      public var vClip:int;
      
      public var vPlaying:Boolean;
      
      public function Lightning_12()
      {
         super();
         addFrameScript(0,this.frame1,12,this.frame13,28,this.frame29,42,this.frame43,54,this.frame55);
      }
      
      public function Loop(param1:Event) : void
      {
         if(!this.vPlaying)
         {
            this.vRand = Math.floor(Math.random() * 25);
            if(this.vRand == this.vNum)
            {
               this.vClip = Math.floor(Math.random() * this.vClips) + 1;
               gotoAndPlay("_" + String(this.vClip));
               this.vPlaying = true;
            }
         }
      }
      
      internal function frame1() : *
      {
         addEventListener(Event.ENTER_FRAME,this.Loop);
         this.vNum = 5;
         this.vClips = 4;
         this.vPlaying = false;
      }
      
      internal function frame13() : *
      {
         stop();
         this.vPlaying = false;
      }
      
      internal function frame29() : *
      {
         stop();
         this.vPlaying = false;
      }
      
      internal function frame43() : *
      {
         stop();
         this.vPlaying = false;
      }
      
      internal function frame55() : *
      {
         stop();
         this.vPlaying = false;
      }
   }
}

