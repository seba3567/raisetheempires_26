package BattleSetupHudOverlay_fla
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol300")]
   public dynamic class BattleSetupFlow_13 extends MovieClip
   {
      
      public var UnitSelect:MovieClip;
      
      public var lineup_mc:MovieClip;
      
      public var unitSuggester_mc:MovieClip;
      
      public var mask_mc:MovieClip;
      
      public var bounds_mc:MovieClip;
      
      public var terrainSelect:MovieClip;
      
      public var AllySelect:MovieClip;
      
      public var opponentIcon_mc:MovieClip;
      
      public function BattleSetupFlow_13()
      {
         super();
         addFrameScript(0,this.frame1,29,this.frame30,46,this.frame47,58,this.frame59,72,this.frame73,83,this.frame84);
      }
      
      internal function frame73() : *
      {
         stop();
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame30() : *
      {
         stop();
      }
      
      internal function frame84() : *
      {
         stop();
      }
      
      internal function frame59() : *
      {
         this.lineup_mc.visible = false;
         stop();
      }
      
      internal function frame47() : *
      {
         stop();
      }
   }
}

