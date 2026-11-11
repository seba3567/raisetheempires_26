package core.ui.components.PortraitSlidePick
{
   import core.player.IPVPPlayer;
   import flash.display.MovieClip;
   import zgame.assets.ui.NeighborPickDismiss;
   
   public class PortraitRetainedSlidePick extends PortraitSlidePick
   {
      
      public static var VISIT:String = "visit";
      
      public static var GiftAndDismiss:String = "giftAndDismiss";
      
      public function PortraitRetainedSlidePick(param1:IPVPPlayer, param2:Number)
      {
         super(param1,param2);
      }
      
      override protected function getPickClass() : Class
      {
         return NeighborPickDismiss;
      }
      
      override protected function get slideCard() : MovieClip
      {
         return mc.card_mc;
      }
   }
}

