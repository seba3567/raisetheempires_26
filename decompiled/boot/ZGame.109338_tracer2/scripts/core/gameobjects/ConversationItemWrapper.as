package core.gameobjects
{
   public class ConversationItemWrapper
   {
      
      private var m_xml:XML = null;
      
      public function ConversationItemWrapper(param1:GameItem, param2:XML = null)
      {
         super();
         this.m_xml = param2 ? param2 : param1.xml;
      }
      
      public function get startingConversation() : String
      {
         if(this.m_xml.conversation.length() > 0)
         {
            return this.validatedConversation(this.m_xml.conversation.attribute("start").toString());
         }
         return null;
      }
      
      public function get conversationVersion() : String
      {
         if(this.m_xml.conversation.length() > 0)
         {
            return this.validatedConversation(this.m_xml.conversation.attribute("version").toString());
         }
         return null;
      }
      
      public function get endingConversation() : String
      {
         if(this.m_xml.conversation.length() > 0)
         {
            return this.validatedConversation(this.m_xml.conversation.attribute("end").toString());
         }
         return null;
      }
      
      private function validatedConversation(param1:String) : String
      {
         return param1.length > 0 ? param1 : null;
      }
   }
}

