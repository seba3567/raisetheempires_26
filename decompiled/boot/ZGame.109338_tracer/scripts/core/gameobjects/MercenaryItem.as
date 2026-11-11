package core.gameobjects
{
   import core.ZGlobal;
   import core.player.IAlly;
   
   public class MercenaryItem extends GameItem implements IAlly
   {
      
      public function MercenaryItem(param1:XML)
      {
         super(param1);
      }
      
      public function get firstName() : String
      {
         return getFriendlyName(MENU_FRIENDLYNAME);
      }
      
      public function get id() : String
      {
         return m_xml.@code;
      }
      
      public function get imageUrl() : String
      {
         return ZGlobal.getAssetURL(m_xml.image.@url);
      }
      
      public function get level() : int
      {
         return m_xml.level[0];
      }
      
      public function get gender() : String
      {
         return m_xml.gender.toString();
      }
   }
}

