package core.entities.components
{
   import core.player.IPVPPlayer;
   
   public class PVPOccupationMarkerComponent extends PVPActivityMarkerComponent
   {
      
      private var m_player:IPVPPlayer;
      
      public function PVPOccupationMarkerComponent(param1:IPVPPlayer)
      {
         super();
         this.m_player = param1;
      }
      
      protected function get pickPlayer() : IPVPPlayer
      {
         return this.m_player;
      }
      
      override protected function get rectColor() : int
      {
         return 16711680;
      }
   }
}

