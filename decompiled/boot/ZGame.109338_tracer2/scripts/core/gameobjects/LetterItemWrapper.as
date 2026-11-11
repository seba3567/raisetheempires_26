package core.gameobjects
{
   public class LetterItemWrapper
   {
      
      private var m_xml:XML = null;
      
      public function LetterItemWrapper(param1:GameItem, param2:XML = null)
      {
         super();
         this.m_xml = param2 ? param2 : param1.xml;
      }
      
      public function get startingLetter() : String
      {
         if(this.m_xml.letter.length() > 0)
         {
            return this.validatedLetter(this.m_xml.letter.attribute("start").toString());
         }
         return null;
      }
      
      public function get letterVersion() : String
      {
         if(this.m_xml.letter.length() > 0)
         {
            return this.validatedLetter(this.m_xml.letter.attribute("version").toString());
         }
         return null;
      }
      
      public function get endingLetter() : String
      {
         if(this.m_xml.letter.length() > 0)
         {
            return this.validatedLetter(this.m_xml.letter.attribute("end").toString());
         }
         return null;
      }
      
      private function validatedLetter(param1:String) : String
      {
         return param1.length > 0 ? param1 : null;
      }
   }
}

