package
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol20")]
   public dynamic class OptionCard extends MovieClip
   {
      
      public var currentAmount_tf:TextField;
      
      public var oldAmount_tf:TextField;
      
      public var accept_bt:MovieClip;
      
      public var title_tf:TextField;
      
      public var points_tf:TextField;
      
      public function OptionCard()
      {
         super();
      }
   }
}

