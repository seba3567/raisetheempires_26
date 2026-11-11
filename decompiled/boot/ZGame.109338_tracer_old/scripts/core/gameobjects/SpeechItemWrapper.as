package core.gameobjects
{
   public class SpeechItemWrapper
   {
      
      private var m_xml:XML = null;
      
      public function SpeechItemWrapper(param1:GameItem, param2:XML = null)
      {
         super();
         this.m_xml = param2 ? param2 : param1.xml;
      }
      
      public function get startingSpeech() : String
      {
         if(this.m_xml.speech.length() > 0)
         {
            return this.validatedSpeech(this.m_xml.speech.attribute("start").toString());
         }
         return null;
      }
      
      public function get endingSpeech() : String
      {
         if(this.m_xml.speech.length() > 0)
         {
            return this.validatedSpeech(this.m_xml.speech.attribute("end").toString());
         }
         return null;
      }
      
      private function validatedSpeech(param1:String) : String
      {
         return param1.length > 0 ? param1 : null;
      }
   }
}

