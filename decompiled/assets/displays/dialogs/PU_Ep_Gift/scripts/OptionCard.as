package
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol32")]
   public dynamic class OptionCard extends MovieClip
   {
      
      public var cost_tf:TextField;
      
      public var accept_bt:MovieClip;
      
      public var total_tf:TextField;
      
      public var points_tf:TextField;
      
      public var giftValue_tf:TextField;
      
      public var discount_tf:TextField;
      
      public var title_tf:TextField;
      
      public var friends_tf:TextField;
      
      public function OptionCard()
      {
         super();
      }
   }
}

