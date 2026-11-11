package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol37")]
   public class UnitCard extends MovieClip
   {
      
      public var card_mc:MovieClip;
      
      public function UnitCard()
      {
         super();
         trace("Raise the empires: UnitCard contructor called");
         trace("stack trace: " + new Error().getStackTrace());
      }
   }
}

