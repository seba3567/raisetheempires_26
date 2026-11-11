package
{
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol1575")]
   public dynamic class BattleBar extends MovieClip
   {
      
      public var bar_mc:MovieClip;
      
      public var mana_tf:TextField;
      
      public var strength_tf:TextField;
      
      public var power_bt:SimpleButton;
      
      public var tierRating_mc:MovieClip;
      
      public var powerButtonIcon:UILoader;
      
      public var icon:UILoader;
      
      public function BattleBar()
      {
         super();
      }
   }
}

