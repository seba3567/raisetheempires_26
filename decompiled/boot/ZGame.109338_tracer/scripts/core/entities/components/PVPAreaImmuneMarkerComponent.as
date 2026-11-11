package core.entities.components
{
   public class PVPAreaImmuneMarkerComponent extends PVPActivityMarkerComponent
   {
      
      public static const TEXT_COLOR:int = 172 << 16 | 96 << 8 | 0xE3;
      
      public static const GLOW_COLOR:int = 172 << 16 | 96 << 8 | 0xE3;
      
      public static const AOE_COLOR:int = 136 << 16 | 5 << 8 | 0xF0;
      
      private var m_areaSize:int;
      
      public function PVPAreaImmuneMarkerComponent(param1:int)
      {
         super();
         this.m_areaSize = param1;
      }
      
      override protected function get activityAreaSize() : int
      {
         return this.m_areaSize;
      }
      
      override protected function get rectColor() : int
      {
         return AOE_COLOR;
      }
      
      override protected function get shouldOutline() : Boolean
      {
         return false;
      }
   }
}

