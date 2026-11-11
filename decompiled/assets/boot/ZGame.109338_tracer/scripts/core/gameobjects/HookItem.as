package core.gameobjects
{
   public class HookItem extends GameItem
   {
      
      public function HookItem(param1:XML)
      {
         super(param1);
      }
      
      public function get url() : String
      {
         return m_xml.dialog.@url;
      }
      
      public function get text() : String
      {
         return m_xml.dialog.@text;
      }
      
      override public function get textReplacements() : String
      {
         return m_xml.dialog.@textReplacements;
      }
      
      public function get playerImage() : String
      {
         return m_xml.dialog.@playerImage;
      }
      
      public function get isMegaseries() : Boolean
      {
         if(m_xml.dialog.@isMegaseries.toString() == "true")
         {
            return true;
         }
         return false;
      }
      
      public function get megaseriesDialgoText() : Array
      {
         var _loc1_:Array = new Array();
         _loc1_.push(m_xml.dialog.@text.toString());
         _loc1_.push(m_xml.dialog.@text2.toString());
         _loc1_.push(m_xml.dialog.@text3.toString());
         return _loc1_;
      }
   }
}

