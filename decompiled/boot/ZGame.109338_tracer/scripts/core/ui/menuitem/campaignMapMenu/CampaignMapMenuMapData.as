package core.ui.menuitem.campaignMapMenu
{
   import utils.CriteriaUtil;
   import utils.ZGameUtils;
   
   public class CampaignMapMenuMapData
   {
      
      private var m_xml:XML = null;
      
      public function CampaignMapMenuMapData(param1:XML)
      {
         super();
         this.m_xml = param1;
      }
      
      public function get name() : String
      {
         return this.m_xml.@name;
      }
      
      public function get menuName() : String
      {
         return ZGameUtils.ZlocT("Campaign",this.m_xml.@menuName);
      }
      
      public function get iconName() : String
      {
         return this.m_xml.@icon;
      }
      
      public function get isLocked() : Boolean
      {
         return !CriteriaUtil.meetsCriteria(this.m_xml.criteria);
      }
      
      public function get showAsNew() : Boolean
      {
         return Boolean(this.m_xml.@showAsNew.toString().length) && this.m_xml.@showAsNew.toString() == "true";
      }
   }
}

