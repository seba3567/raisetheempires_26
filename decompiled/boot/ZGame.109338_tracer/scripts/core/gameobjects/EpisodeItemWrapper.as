package core.gameobjects
{
   public class EpisodeItemWrapper
   {
      
      private var m_xml:XML = null;
      
      public function EpisodeItemWrapper(param1:GameItem, param2:XML = null)
      {
         super();
         this.m_xml = param2 ? param2 : param1.xml;
      }
      
      public function get startingEpisode() : String
      {
         if(this.m_xml.episode.length() > 0)
         {
            return this.validatedEpisode(this.m_xml.episode.attribute("start").toString());
         }
         return null;
      }
      
      public function get endingEpisode() : String
      {
         if(this.m_xml.episode.length() > 0)
         {
            return this.validatedEpisode(this.m_xml.episode.attribute("end").toString());
         }
         return null;
      }
      
      private function validatedEpisode(param1:String) : String
      {
         return param1.length > 0 ? param1 : null;
      }
   }
}

