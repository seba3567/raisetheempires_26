package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol44")]
   public class PlacementUnitCard extends MovieClip
   {
      
      public var card_mc:MovieClip;
      
      public var grid_mc:MovieClip;
      
      public var strength_mc:MovieClip;
      
      public function PlacementUnitCard()
      {
         super();
         trace("Raise the empires: PlacementUnitCard contructor called");
      }
   }
}

