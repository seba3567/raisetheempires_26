package core.gameobjects
{
   public class SoundItem implements IItem
   {
      
      private var m_xml:XML;
      
      public function SoundItem(param1:XML)
      {
         super();
         this.m_xml = param1;
      }
      
      public function get count() : int
      {
         return 0;
      }
      
      public function get name() : String
      {
         return this.m_xml.@name.toString();
      }
   }
}

