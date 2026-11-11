package core.gameobjects
{
   public class VillainItem extends GameItem
   {
      
      public function VillainItem(param1:XML)
      {
         super(param1);
      }
      
      public function get gender() : String
      {
         return m_xml.@gender.toString().length ? m_xml.@gender : "M";
      }
      
      public function megaUnit() : String
      {
         if(Boolean(m_xml.mega) && m_xml.mega != undefined)
         {
            if(m_xml.mega.@item != undefined)
            {
               return m_xml.mega.@item;
            }
         }
         return null;
      }
   }
}

