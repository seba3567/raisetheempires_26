package zgame.assets.ui.CombatBar
{
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol1534")]
   public dynamic class CombatBarMenu extends MovieClip
   {
      
      public var enemy_unit_card_mc:MovieClip;
      
      public var player_unit_card_mc:MovieClip;
      
      public var exit_bt:SimpleButton;
      
      public var bg_mc:MovieClip;
      
      public var enemy_profile_card_mc:MovieClip;
      
      public var redHaloGlow_mc:MovieClip;
      
      public var powerUpSuggesterBig_mc:MovieClip;
      
      public var messageTab_mc:MovieClip;
      
      public var consumable_bt:MovieClip;
      
      public var player_profile_card_mc:MovieClip;
      
      public var pause:SimpleButton;
      
      public var unitReviveToaster_mc:MovieClip;
      
      public function CombatBarMenu()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      internal function frame1() : *
      {
         this.mouseEnabled = false;
      }
   }
}

